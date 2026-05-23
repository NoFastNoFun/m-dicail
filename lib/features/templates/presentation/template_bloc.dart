import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/templates/domain/entities/custom_template_variant.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';
import 'package:medicail/features/templates/domain/repositories/template_repository.dart';
import 'package:medicail/features/templates/presentation/template_event.dart';
import 'package:medicail/features/templates/presentation/template_state.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc(this._templateRepository) : super(const TemplateInitial()) {
    on<TemplatesLoadRequested>(_onLoadRequested);
    on<TemplateSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<TemplateSelected>(_onTemplateSelected);
    on<VariantSaveRequested>(_onVariantSaveRequested);
    on<VariantOverwriteConfirmed>(_onVariantOverwriteConfirmed);
    on<TemplateDuplicateDismissed>(_onDuplicateDismissed);
  }

  final TemplateRepository _templateRepository;

  Future<void> _onLoadRequested(
    TemplatesLoadRequested event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());
    await _loadItems(emit, query: event.query ?? '');
  }

  Future<void> _onSearchQueryChanged(
    TemplateSearchQueryChanged event,
    Emitter<TemplateState> emit,
  ) async {
    final current = state;
    if (current is TemplateLoaded) {
      await _loadItems(emit, query: event.query, preserveSelection: current);
      return;
    }
    emit(const TemplateLoading());
    await _loadItems(emit, query: event.query);
  }

  void _onTemplateSelected(
    TemplateSelected event,
    Emitter<TemplateState> emit,
  ) {
    final current = state;
    if (current is! TemplateLoaded) {
      return;
    }

    for (final item in current.items) {
      if (item.id == event.itemId) {
        final baseId = item.type == TemplateItemType.builtin
            ? item.id
            : item.baseTemplateId;
        emit(
          current.copyWith(
            selectedNote: item.soapNote,
            selectedBaseTemplateId: baseId,
          ),
        );
        return;
      }
    }
  }

  Future<void> _onVariantSaveRequested(
    VariantSaveRequested event,
    Emitter<TemplateState> emit,
  ) async {
    final current = state;
    if (current is! TemplateLoaded) {
      return;
    }

    try {
      final name = event.displayName.trim();
      if (name.isEmpty) {
        emit(const TemplateError('Nom de variante requis'));
        emit(current);
        return;
      }

      if (event.overwriteExistingId != null) {
        await _persistVariant(
          id: event.overwriteExistingId!,
          displayName: name,
          soapNote: event.soapNote,
          baseTemplateId: event.baseTemplateId,
        );
      } else {
        final existing = await _templateRepository.findVariantByDisplayName(name);
        if (existing != null) {
          emit(
            current.copyWith(
              pendingDuplicateVariantId: existing.id,
            ),
          );
          return;
        }

        await _persistVariant(
          id: _generateVariantId(),
          displayName: name,
          soapNote: event.soapNote,
          baseTemplateId: event.baseTemplateId,
        );
      }

      emit(const TemplateSavingSuccess());
      await _loadItems(emit, query: current.query);
    } catch (error) {
      emit(TemplateError(Failure.fromException(error).message));
      emit(current);
    }
  }

  Future<void> _onVariantOverwriteConfirmed(
    VariantOverwriteConfirmed event,
    Emitter<TemplateState> emit,
  ) async {
    add(
      VariantSaveRequested(
        displayName: event.displayName,
        soapNote: event.soapNote,
        baseTemplateId: event.baseTemplateId,
        overwriteExistingId: event.existingVariantId,
      ),
    );
  }

  void _onDuplicateDismissed(
    TemplateDuplicateDismissed event,
    Emitter<TemplateState> emit,
  ) {
    final current = state;
    if (current is TemplateLoaded) {
      emit(current.copyWith(clearPendingDuplicate: true));
    }
  }

  Future<void> _loadItems(
    Emitter<TemplateState> emit, {
    required String query,
    TemplateLoaded? preserveSelection,
  }) async {
    try {
      await _templateRepository.ensureSeeded();
      final items = await _templateRepository.getAllItems(query: query);
      emit(
        TemplateLoaded(
          items: items,
          query: query,
          selectedNote: preserveSelection?.selectedNote,
        ),
      );
    } catch (error) {
      emit(TemplateError(Failure.fromException(error).message));
    }
  }

  Future<void> _persistVariant({
    required String id,
    required String displayName,
    required SoapNote soapNote,
    String? baseTemplateId,
  }) async {
    final variant = CustomTemplateVariant(
      id: id,
      displayName: displayName,
      baseTemplateId: baseTemplateId,
      subjective: soapNote.subjective,
      objective: soapNote.objective,
      assessment: soapNote.assessment,
      plan: soapNote.plan,
      createdAt: DateTime.now(),
    );
    await _templateRepository.saveVariant(variant);
  }

  String _generateVariantId() {
    return 'variant_${DateTime.now().toUtc().microsecondsSinceEpoch}';
  }
}
