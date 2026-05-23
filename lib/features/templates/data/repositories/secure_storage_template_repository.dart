import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/templates/data/default_soap_templates.dart';
import 'package:medicail/features/templates/data/models/custom_template_variant_model.dart';
import 'package:medicail/features/templates/data/models/soap_template_model.dart';
import 'package:medicail/features/templates/domain/entities/custom_template_variant.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';
import 'package:medicail/features/templates/domain/exceptions/template_exception.dart';
import 'package:medicail/features/templates/domain/repositories/template_repository.dart';

@LazySingleton(as: TemplateRepository)
class SecureStorageTemplateRepository implements TemplateRepository {
  const SecureStorageTemplateRepository(this._storage);

  static const String _builtinKey = 'soap_templates_builtin_v1';
  static const String _variantsKey = 'soap_templates_variants_v1';
  static const String _seededKey = 'soap_templates_seeded_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<void> ensureSeeded() async {
    final seeded = await _storage.read(key: _seededKey);
    if (seeded == 'true') {
      return;
    }

    final defaults = DefaultSoapTemplates.all();
    await _writeBuiltin(defaults);
    await _storage.write(key: _seededKey, value: 'true');
  }

  @override
  Future<List<SoapTemplate>> getBuiltinTemplates({String? query}) async {
    await ensureSeeded();
    final templates = await _readBuiltin();
    return _filterBuiltin(templates, query);
  }

  @override
  Future<List<CustomTemplateVariant>> getVariants({String? query}) async {
    await ensureSeeded();
    final variants = await _readVariants();
    return _filterVariants(variants, query);
  }

  @override
  Future<List<TemplateListItem>> getAllItems({String? query}) async {
    final builtins = await getBuiltinTemplates(query: query);
    final variants = await getVariants(query: query);

    final items = <TemplateListItem>[
      for (final template in builtins)
        TemplateListItem(
          id: template.id,
          displayName: template.pathologyName,
          type: TemplateItemType.builtin,
          soapNote: template.toSoapNote(),
        ),
      for (final variant in variants)
        TemplateListItem(
          id: variant.id,
          displayName: variant.displayName,
          type: TemplateItemType.variant,
          soapNote: variant.toSoapNote(),
          baseTemplateId: variant.baseTemplateId,
        ),
    ];

    items.sort((a, b) {
      final typeOrder = a.type.index.compareTo(b.type.index);
      if (typeOrder != 0) {
        return typeOrder;
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return items;
  }

  @override
  Future<CustomTemplateVariant?> findVariantByDisplayName(
    String displayName,
  ) async {
    final normalized = displayName.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final variants = await _readVariants();
    for (final variant in variants) {
      if (variant.displayName.trim().toLowerCase() == normalized) {
        return variant;
      }
    }
    return null;
  }

  @override
  Future<void> saveVariant(CustomTemplateVariant variant) async {
    final variants = await _readVariants();
    final nextVariants = <CustomTemplateVariant>[
      for (final current in variants)
        if (current.id != variant.id) current,
      variant,
    ]..sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

    await _writeVariants(nextVariants);
  }

  Future<void> throwIfDuplicateName(
    String displayName, {
    String? excludingId,
  }) async {
    final existing = await findVariantByDisplayName(displayName);
    if (existing != null && existing.id != excludingId) {
      throw DuplicateTemplateVariantNameException(existing.id);
    }
  }

  Future<List<SoapTemplate>> _readBuiltin() async {
    try {
      final raw = await _storage.read(key: _builtinKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((json) => Map<String, dynamic>.from(json))
          .map(SoapTemplateModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (_) {
      await _storage.delete(key: _builtinKey);
      return const [];
    }
  }

  Future<List<CustomTemplateVariant>> _readVariants() async {
    try {
      final raw = await _storage.read(key: _variantsKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((json) => Map<String, dynamic>.from(json))
          .map(CustomTemplateVariantModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (_) {
      await _storage.delete(key: _variantsKey);
      return const [];
    }
  }

  Future<void> _writeBuiltin(List<SoapTemplate> templates) {
    final encoded = jsonEncode(
      templates
          .map(SoapTemplateModel.fromEntity)
          .map((model) => model.toJson())
          .toList(),
    );
    return _storage.write(key: _builtinKey, value: encoded);
  }

  Future<void> _writeVariants(List<CustomTemplateVariant> variants) {
    final encoded = jsonEncode(
      variants
          .map(CustomTemplateVariantModel.fromEntity)
          .map((model) => model.toJson())
          .toList(),
    );
    return _storage.write(key: _variantsKey, value: encoded);
  }

  List<SoapTemplate> _filterBuiltin(List<SoapTemplate> templates, String? query) {
    if (query == null || query.trim().isEmpty) {
      return templates;
    }
    final q = query.trim().toLowerCase();
    return templates
        .where((t) => t.pathologyName.toLowerCase().contains(q))
        .toList();
  }

  List<CustomTemplateVariant> _filterVariants(
    List<CustomTemplateVariant> variants,
    String? query,
  ) {
    if (query == null || query.trim().isEmpty) {
      return variants;
    }
    final q = query.trim().toLowerCase();
    return variants
        .where((v) => v.displayName.toLowerCase().contains(q))
        .toList();
  }
}
