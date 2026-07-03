import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/note_template/presentation/note_template_event.dart';
import 'package:medicail/features/note_template/presentation/note_template_state.dart';

@injectable
class NoteTemplateBloc extends Bloc<NoteTemplateEvent, NoteTemplateState> {
  NoteTemplateBloc(this._repository) : super(const NoteTemplateInitial()) {
    on<NoteTemplatesRequested>(_onTemplatesRequested);
    on<NoteTemplateSaveVariantRequested>(_onSaveVariant);
    on<NoteTemplateDuplicateRequested>(_onDuplicate);
    on<NoteTemplateDeleteRequested>(_onDelete);
  }

  final NoteTemplateRepository _repository;

  Future<void> _onTemplatesRequested(
    NoteTemplatesRequested event,
    Emitter<NoteTemplateState> emit,
  ) async {
    emit(const NoteTemplateLoading());
    await _loadTemplates(emit);
  }

  Future<void> _onSaveVariant(
    NoteTemplateSaveVariantRequested event,
    Emitter<NoteTemplateState> emit,
  ) async {
    try {
      final saved = await _repository.saveVariant(event.template);
      final builtIn = await _repository.getBuiltInTemplates();
      final variants = await _repository.getUserVariants();
      emit(
        NoteTemplateActionSuccess(
          builtInTemplates: builtIn,
          userVariants: variants,
          message: 'saved',
          savedTemplateId: saved.id,
        ),
      );
    } catch (error) {
      emit(NoteTemplateFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onDuplicate(
    NoteTemplateDuplicateRequested event,
    Emitter<NoteTemplateState> emit,
  ) async {
    try {
      final saved = await _repository.duplicateAsVariant(
        parentTemplateId: event.parentTemplateId,
        name: event.name,
      );
      final builtIn = await _repository.getBuiltInTemplates();
      final variants = await _repository.getUserVariants();
      emit(
        NoteTemplateActionSuccess(
          builtInTemplates: builtIn,
          userVariants: variants,
          message: 'duplicated',
          savedTemplateId: saved.id,
        ),
      );
    } catch (error) {
      emit(NoteTemplateFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onDelete(
    NoteTemplateDeleteRequested event,
    Emitter<NoteTemplateState> emit,
  ) async {
    try {
      await _repository.deleteVariant(event.templateId);
      await _loadTemplates(emit);
    } catch (error) {
      emit(NoteTemplateFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadTemplates(Emitter<NoteTemplateState> emit) async {
    try {
      final builtIn = await _repository.getBuiltInTemplates();
      var variants = const <NoteTemplate>[];
      try {
        variants = await _repository.getUserVariants();
      } catch (_) {
        // Built-in templates must remain available even if variants fail.
        variants = const [];
      }

      if (emit.isDone) {
        return;
      }

      emit(
        NoteTemplateLoaded(
          builtInTemplates: builtIn,
          userVariants: variants,
        ),
      );
    } catch (error) {
      if (emit.isDone) {
        return;
      }
      emit(NoteTemplateFailure(Failure.fromException(error).message));
    }
  }
}
