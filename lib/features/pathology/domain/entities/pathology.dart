import 'package:equatable/equatable.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';

class Pathology extends Equatable {
  const Pathology({
    required this.id,
    required this.name,
    required this.domain,
    required this.source,
    this.meshUi,
    this.meshTerm,
    this.aliases = const [],
    this.templateId,
    this.updatedAt,
  });

  final String id;
  final String name;
  final PathologyDomain domain;
  final PathologySource source;
  final String? meshUi;
  final String? meshTerm;
  final List<String> aliases;
  final String? templateId;
  final DateTime? updatedAt;

  bool get isBuiltIn => source == PathologySource.builtIn;

  bool get hasTemplate => templateId != null && templateId!.isNotEmpty;

  Pathology copyWith({
    String? id,
    String? name,
    PathologyDomain? domain,
    PathologySource? source,
    String? meshUi,
    String? meshTerm,
    List<String>? aliases,
    String? templateId,
    DateTime? updatedAt,
    bool clearMeshUi = false,
    bool clearMeshTerm = false,
    bool clearTemplateId = false,
    bool clearUpdatedAt = false,
  }) {
    return Pathology(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      source: source ?? this.source,
      meshUi: clearMeshUi ? null : meshUi ?? this.meshUi,
      meshTerm: clearMeshTerm ? null : meshTerm ?? this.meshTerm,
      aliases: aliases ?? this.aliases,
      templateId: clearTemplateId ? null : templateId ?? this.templateId,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        domain,
        source,
        meshUi,
        meshTerm,
        aliases,
        templateId,
        updatedAt,
      ];
}
