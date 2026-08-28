import 'package:equatable/equatable.dart';

class MeshDescriptor extends Equatable {
  const MeshDescriptor({
    required this.meshUi,
    required this.term,
    this.synonyms = const [],
    this.treeNumbers = const [],
  });

  final String meshUi;
  final String term;
  final List<String> synonyms;
  final List<String> treeNumbers;

  @override
  List<Object?> get props => [meshUi, term, synonyms, treeNumbers];
}
