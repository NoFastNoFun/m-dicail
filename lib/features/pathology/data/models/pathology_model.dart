import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';

final class PathologyModel extends Pathology {
  const PathologyModel({
    required super.id,
    required super.name,
    required super.domain,
    required super.source,
    super.meshUi,
    super.meshTerm,
    super.aliases,
    super.templateId,
    super.updatedAt,
  });

  factory PathologyModel.fromEntity(Pathology pathology) {
    return PathologyModel(
      id: pathology.id,
      name: pathology.name,
      domain: pathology.domain,
      source: pathology.source,
      meshUi: pathology.meshUi,
      meshTerm: pathology.meshTerm,
      aliases: pathology.aliases,
      templateId: pathology.templateId,
      updatedAt: pathology.updatedAt,
    );
  }

  factory PathologyModel.fromJson(Map<String, dynamic> json) {
    final aliasesJson = json['aliases'];
    final aliases = <String>[];
    if (aliasesJson is List) {
      for (final item in aliasesJson) {
        if (item is String && item.isNotEmpty) {
          aliases.add(item);
        }
      }
    }

    return PathologyModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      domain: PathologyDomainX.fromJson(json['domain'] as String?),
      source: PathologySourceX.fromJson(json['source'] as String?),
      meshUi: json['meshUi'] as String?,
      meshTerm: json['meshTerm'] as String?,
      aliases: aliases,
      templateId: json['templateId'] as String?,
      updatedAt: _parseNullableDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain.jsonValue,
      'source': source.jsonValue,
      'meshUi': meshUi,
      'meshTerm': meshTerm,
      'aliases': aliases,
      'templateId': templateId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
