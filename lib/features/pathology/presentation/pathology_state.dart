import 'package:equatable/equatable.dart';
import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';

sealed class PathologyState extends Equatable {
  const PathologyState();

  @override
  List<Object?> get props => [];
}

final class PathologyInitial extends PathologyState {
  const PathologyInitial();
}

final class PathologyLoading extends PathologyState {
  const PathologyLoading();
}

final class PathologyLoaded extends PathologyState {
  const PathologyLoaded({
    required this.builtInPathologies,
    required this.userPathologies,
    this.pubmedResults = const [],
    this.isSearchingPubmed = false,
  });

  final List<Pathology> builtInPathologies;
  final List<Pathology> userPathologies;
  final List<MeshDescriptor> pubmedResults;
  final bool isSearchingPubmed;

  @override
  List<Object?> get props => [
        builtInPathologies,
        userPathologies,
        pubmedResults,
        isSearchingPubmed,
      ];
}

final class PathologyFailure extends PathologyState {
  const PathologyFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class PathologyActionSuccess extends PathologyState {
  const PathologyActionSuccess({
    required this.builtInPathologies,
    required this.userPathologies,
    required this.message,
    this.savedPathologyId,
    this.pubmedResults = const [],
  });

  final List<Pathology> builtInPathologies;
  final List<Pathology> userPathologies;
  final String message;
  final String? savedPathologyId;
  final List<MeshDescriptor> pubmedResults;

  @override
  List<Object?> get props => [
        builtInPathologies,
        userPathologies,
        message,
        savedPathologyId,
        pubmedResults,
      ];
}
