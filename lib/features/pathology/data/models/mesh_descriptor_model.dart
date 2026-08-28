import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';

final class MeshDescriptorModel extends MeshDescriptor {
  const MeshDescriptorModel({
    required super.meshUi,
    required super.term,
    super.synonyms,
    super.treeNumbers,
  });

  factory MeshDescriptorModel.fromJson(Map<String, dynamic> json) {
    final synonymsJson = json['synonyms'];
    final synonyms = <String>[];
    if (synonymsJson is List) {
      for (final item in synonymsJson) {
        if (item is String && item.isNotEmpty) {
          synonyms.add(item);
        }
      }
    }

    final treeJson = json['tree_numbers'];
    final treeNumbers = <String>[];
    if (treeJson is List) {
      for (final item in treeJson) {
        if (item is String && item.isNotEmpty) {
          treeNumbers.add(item);
        }
      }
    }

    return MeshDescriptorModel(
      meshUi: json['mesh_ui'] as String? ?? json['meshUi'] as String? ?? '',
      term: json['term'] as String? ?? '',
      synonyms: synonyms,
      treeNumbers: treeNumbers,
    );
  }
}
