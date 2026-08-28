import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/repositories/pathology_repository.dart';
import 'package:medicail/features/pathology/presentation/pathology_event.dart';
import 'package:medicail/features/pathology/presentation/pathology_state.dart';

@injectable
class PathologyBloc extends Bloc<PathologyEvent, PathologyState> {
  PathologyBloc(this._repository) : super(const PathologyInitial()) {
    on<PathologiesRequested>(_onPathologiesRequested);
    on<PathologyCreateRequested>(_onCreate);
    on<PathologyDeleteRequested>(_onDelete);
    on<PathologyPubmedSearchRequested>(_onPubmedSearch);
    on<PathologyImportFromPubmedRequested>(_onImportFromPubmed);
  }

  final PathologyRepository _repository;

  Future<void> _onPathologiesRequested(
    PathologiesRequested event,
    Emitter<PathologyState> emit,
  ) async {
    emit(const PathologyLoading());
    await _loadPathologies(emit);
  }

  Future<void> _onCreate(
    PathologyCreateRequested event,
    Emitter<PathologyState> emit,
  ) async {
    try {
      final saved = await _repository.createUserPathology(
        name: event.name,
        domain: PathologyDomainX.fromJson(event.domain),
      );
      final builtIn = await _repository.getBuiltInPathologies();
      final user = await _repository.getUserPathologies();
      emit(
        PathologyActionSuccess(
          builtInPathologies: builtIn,
          userPathologies: user,
          message: 'created',
          savedPathologyId: saved.id,
        ),
      );
    } catch (error) {
      emit(PathologyFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onDelete(
    PathologyDeleteRequested event,
    Emitter<PathologyState> emit,
  ) async {
    try {
      await _repository.deleteUserPathology(event.pathologyId);
      await _loadPathologies(emit);
    } catch (error) {
      emit(PathologyFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onPubmedSearch(
    PathologyPubmedSearchRequested event,
    Emitter<PathologyState> emit,
  ) async {
    final current = state;
    if (current is PathologyLoaded) {
      emit(
        PathologyLoaded(
          builtInPathologies: current.builtInPathologies,
          userPathologies: current.userPathologies,
          isSearchingPubmed: true,
        ),
      );
    }

    try {
      final results = await _repository.searchPubmedMesh(event.query);
      final builtIn = await _repository.getBuiltInPathologies();
      final user = await _repository.getUserPathologies();
      emit(
        PathologyLoaded(
          builtInPathologies: builtIn,
          userPathologies: user,
          pubmedResults: results,
        ),
      );
    } catch (error) {
      emit(PathologyFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onImportFromPubmed(
    PathologyImportFromPubmedRequested event,
    Emitter<PathologyState> emit,
  ) async {
    try {
      final descriptor = MeshDescriptor(
        meshUi: event.meshUi,
        term: event.term,
      );
      final saved = await _repository.importFromPubmed(descriptor);
      final builtIn = await _repository.getBuiltInPathologies();
      final user = await _repository.getUserPathologies();
      emit(
        PathologyActionSuccess(
          builtInPathologies: builtIn,
          userPathologies: user,
          message: 'imported',
          savedPathologyId: saved.id,
        ),
      );
    } catch (error) {
      emit(PathologyFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadPathologies(Emitter<PathologyState> emit) async {
    try {
      await _repository.ensureMigrated();
      final builtIn = await _repository.getBuiltInPathologies();
      var user = const <Pathology>[];
      try {
        user = await _repository.getUserPathologies();
      } catch (_) {
        user = const <Pathology>[];
      }

      if (emit.isDone) {
        return;
      }

      emit(
        PathologyLoaded(
          builtInPathologies: builtIn,
          userPathologies: user,
        ),
      );
    } catch (error) {
      if (emit.isDone) {
        return;
      }
      emit(PathologyFailure(Failure.fromException(error).message));
    }
  }
}
