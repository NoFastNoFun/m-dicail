import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/note_template/data/models/note_template_model.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/pathology/data/datasources/asset_pathology_data_source.dart';
import 'package:medicail/features/pathology/data/models/pathology_model.dart';
import 'package:medicail/features/pathology/data/repositories/api_pubmed_mesh_repository.dart';
import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';
import 'package:medicail/features/pathology/domain/repositories/pathology_repository.dart';

@LazySingleton(as: PathologyRepository)
class PathologyRepositoryImpl implements PathologyRepository {
  PathologyRepositoryImpl(
    this._assetDataSource,
    this._storage,
    this._templateRepository,
    this._meshRepository,
    this._tokenStorage,
  );

  static const String _userPathologiesKey = 'pathologies_user_v1';
  static const String _migrationKey = 'pathology_migration_v1';

  final AssetPathologyDataSource _assetDataSource;
  final FlutterSecureStorage _storage;
  final NoteTemplateRepository _templateRepository;
  final ApiPubmedMeshRepository _meshRepository;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<void> ensureMigrated() async {
    final migrated = await _storage.read(key: _migrationKey);
    if (migrated == 'done') {
      return;
    }

    final variants = await _templateRepository.getUserVariants();
    final existingPathologies = await _readUserPathologies();
    final pathologiesById = {
      for (final pathology in existingPathologies) pathology.id: pathology,
    };
    final updatedVariants = <NoteTemplate>[];

    for (final template in variants) {
      if (template.pathologyId != null && template.pathologyId!.isNotEmpty) {
        updatedVariants.add(template);
        continue;
      }

      final pathologyId = 'pathology_${template.id}';
      final pathology = PathologyModel(
        id: pathologyId,
        name: template.name,
        domain: PathologyDomain.other,
        source: PathologySource.user,
        templateId: template.id,
        updatedAt: template.updatedAt ?? DateTime.now(),
      );
      pathologiesById[pathologyId] = pathology;
      updatedVariants.add(template.copyWith(pathologyId: pathologyId));
    }

    if (pathologiesById.isNotEmpty) {
      await _writeUserPathologies(pathologiesById.values.toList());
    }

    for (final template in updatedVariants) {
      if (template.pathologyId != null) {
        await _templateRepository.saveVariant(template);
      }
    }

    await _storage.write(key: _migrationKey, value: 'done');
  }

  @override
  Future<List<Pathology>> getAll() async {
    await ensureMigrated();
    final builtIn = await getBuiltInPathologies();
    final user = await getUserPathologies();
    return [...builtIn, ...user];
  }

  @override
  Future<List<Pathology>> getBuiltInPathologies() {
    return _assetDataSource.loadBuiltInPathologies();
  }

  @override
  Future<List<Pathology>> getUserPathologies() async {
    final pathologies = (await _readUserPathologies()).toList();
    pathologies.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return pathologies;
  }

  @override
  Future<Pathology?> getById(String id) async {
    if (id.isEmpty) {
      return null;
    }

    final builtIn = await getBuiltInPathologies();
    for (final pathology in builtIn) {
      if (pathology.id == id) {
        return pathology;
      }
    }

    try {
      final user = await getUserPathologies();
      for (final pathology in user) {
        if (pathology.id == id) {
          return pathology;
        }
      }
    } catch (_) {
      // Built-in pathologies remain resolvable when user storage fails.
    }

    return null;
  }

  @override
  Future<List<Pathology>> searchLocal(String query) async {
    final normalized = query.trim().toLowerCase();
    final all = await getAll();
    if (normalized.isEmpty) {
      return all;
    }

    return all.where((pathology) {
      if (pathology.name.toLowerCase().contains(normalized)) {
        return true;
      }
      final meshTerm = pathology.meshTerm;
      if (meshTerm != null && meshTerm.toLowerCase().contains(normalized)) {
        return true;
      }
      for (final alias in pathology.aliases) {
        if (alias.toLowerCase().contains(normalized)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Future<Pathology> saveUserPathology(Pathology pathology) async {
    if (pathology.source == PathologySource.builtIn) {
      throw StateError('Built-in pathologies cannot be saved.');
    }

    final saved = pathology.copyWith(updatedAt: DateTime.now());
    final pathologies = await _readUserPathologies();
    final next = <Pathology>[
      for (final current in pathologies)
        if (current.id != saved.id) current,
      saved,
    ];
    await _writeUserPathologies(next);
    return saved;
  }

  @override
  Future<Pathology> createUserPathology({
    required String name,
    required PathologyDomain domain,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('Pathology name is required.');
    }

    final id = 'pathology_user_${DateTime.now().toUtc().microsecondsSinceEpoch}';
    final pathology = PathologyModel(
      id: id,
      name: trimmed,
      domain: domain,
      source: PathologySource.user,
      updatedAt: DateTime.now(),
    );
    return saveUserPathology(pathology);
  }

  @override
  Future<Pathology> importFromPubmed(MeshDescriptor descriptor) async {
    final term = descriptor.term.trim();
    if (term.isEmpty) {
      throw StateError('MeSH term is required.');
    }

    final templateId =
        'template_pubmed_${DateTime.now().toUtc().microsecondsSinceEpoch}';
    final pathologyId =
        'pathology_pubmed_${DateTime.now().toUtc().microsecondsSinceEpoch}';

    final template = NoteTemplateModel(
      id: templateId,
      pathologyId: pathologyId,
      pathologyKey: _slugify(term),
      name: term,
      sections: const [
        NoteSection(
          id: 'subjective',
          kind: NoteSectionKind.subjective,
          title: 'Subjectif',
          prompt: '',
          order: 0,
        ),
        NoteSection(
          id: 'objective',
          kind: NoteSectionKind.objective,
          title: 'Objectif',
          prompt: '',
          order: 1,
        ),
        NoteSection(
          id: 'assessment',
          kind: NoteSectionKind.assessment,
          title: 'Evaluation',
          prompt: '',
          order: 2,
        ),
        NoteSection(
          id: 'plan',
          kind: NoteSectionKind.plan,
          title: 'Plan',
          prompt: '',
          order: 3,
        ),
      ],
      source: NoteTemplateSource.userVariant,
      updatedAt: DateTime.now(),
    );
    await _templateRepository.saveVariant(template);

    final pathology = PathologyModel(
      id: pathologyId,
      name: term,
      domain: PathologyDomain.other,
      source: PathologySource.pubmed,
      meshUi: descriptor.meshUi,
      meshTerm: descriptor.term,
      aliases: descriptor.synonyms,
      templateId: templateId,
      updatedAt: DateTime.now(),
    );
    return saveUserPathology(pathology);
  }

  @override
  Future<void> linkTemplate({
    required String pathologyId,
    required String templateId,
  }) async {
    final pathology = await getById(pathologyId);
    if (pathology == null) {
      throw StateError('Pathology not found.');
    }
    if (pathology.source == PathologySource.builtIn) {
      throw StateError('Built-in pathologies cannot be modified.');
    }

    await saveUserPathology(pathology.copyWith(templateId: templateId));
  }

  @override
  Future<void> deleteUserPathology(String id) async {
    final pathology = await getById(id);
    if (pathology == null) {
      return;
    }
    if (pathology.source == PathologySource.builtIn) {
      throw StateError('Built-in pathologies cannot be deleted.');
    }

    final templateId = pathology.templateId;
    if (templateId != null && templateId.isNotEmpty) {
      try {
        await _templateRepository.deleteVariant(templateId);
      } catch (_) {
        // Best effort cleanup when linked template is missing.
      }
    }

    final pathologies = await _readUserPathologies();
    final next = <Pathology>[
      for (final current in pathologies)
        if (current.id != id) current,
    ];
    await _writeUserPathologies(next);
  }

  @override
  Future<List<MeshDescriptor>> searchPubmedMesh(
    String query, {
    int maxResults = 15,
  }) async {
    final token = await _tokenStorage.readToken();
    if (AppConfig.isOfflineMode(token)) {
      return const [];
    }
    return _meshRepository.searchMesh(query, maxResults: maxResults);
  }

  Future<List<Pathology>> _readUserPathologies() async {
    try {
      final raw = await _storage.read(key: _userPathologiesKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return [
        for (final item in decoded)
          if (item is Map)
            PathologyModel.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      try {
        await _storage.delete(key: _userPathologiesKey);
      } catch (_) {
        // Best effort cleanup when local pathologies are corrupted.
      }
      return const [];
    }
  }

  Future<void> _writeUserPathologies(List<Pathology> pathologies) {
    final encoded = jsonEncode(
      pathologies
          .map(PathologyModel.fromEntity)
          .map((pathology) => pathology.toJson())
          .toList(),
    );
    return _storage.write(key: _userPathologiesKey, value: encoded);
  }

  String _slugify(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) {
      return 'pathology';
    }
    return normalized;
  }
}
