import 'package:equatable/equatable.dart';

sealed class PathologyEvent extends Equatable {
  const PathologyEvent();

  @override
  List<Object?> get props => [];
}

final class PathologiesRequested extends PathologyEvent {
  const PathologiesRequested();
}

final class PathologyCreateRequested extends PathologyEvent {
  const PathologyCreateRequested({
    required this.name,
    required this.domain,
  });

  final String name;
  final String domain;

  @override
  List<Object?> get props => [name, domain];
}

final class PathologyDeleteRequested extends PathologyEvent {
  const PathologyDeleteRequested(this.pathologyId);

  final String pathologyId;

  @override
  List<Object?> get props => [pathologyId];
}

final class PathologyPubmedSearchRequested extends PathologyEvent {
  const PathologyPubmedSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class PathologyImportFromPubmedRequested extends PathologyEvent {
  const PathologyImportFromPubmedRequested(this.meshUi, this.term);

  final String meshUi;
  final String term;

  @override
  List<Object?> get props => [meshUi, term];
}
