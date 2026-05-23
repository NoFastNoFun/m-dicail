import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/templates/domain/services/template_suggestion_service.dart';
import 'package:medicail/widget/soap_note_bottom_sheet.dart';
import 'package:medicail/widget/template_picker_sheet.dart';
import 'package:medicail/widget/template_suggestion_dialog.dart';

class ConsultationCompletionFlow {
  ConsultationCompletionFlow._();

  static Future<void> run({
    required BuildContext context,
    required String sessionId,
    required String transcript,
  }) async {
    final sessionRepo = getIt<RecordingSessionRepository>();
    final suggestionService = getIt<TemplateSuggestionService>();

    final session = await sessionRepo.getById(sessionId);
    if (session == null || !context.mounted) {
      return;
    }

    final suggestion = await suggestionService.suggest(transcript);
    if (!context.mounted) {
      return;
    }

    var initialNote = _noteFromTranscript(transcript);

    if (suggestion != null) {
      final action = await TemplateSuggestionDialog.show(
        context,
        suggestion: suggestion,
      );
      if (!context.mounted) {
        return;
      }

      switch (action) {
        case TemplateSuggestionAction.apply:
          initialNote = suggestion.template.toSoapNote();
        case TemplateSuggestionAction.chooseOther:
          final picked = await _pickTemplate(context);
          if (!context.mounted) {
            return;
          }
          if (picked != null) {
            initialNote = picked;
          }
        case TemplateSuggestionAction.skip:
        case null:
          break;
      }
    }

    if (!context.mounted) {
      return;
    }

    await SoapNoteBottomSheet.show(
      context,
      initialNote: initialNote,
      onSave: (note) async {
        await sessionRepo.save(session.copyWith(soapNote: note));
      },
    );
  }

  static SoapNote _noteFromTranscript(String transcript) {
    final clean = transcript.trim();
    return SoapNote(
      subjective: clean.isEmpty
          ? '- Motif de consultation :\n- Symptomes decrits :'
          : clean,
      objective: '- Constantes :\n- Examen clinique :',
      assessment: '- Diagnostics suspectes :',
      plan: '- Traitement :\n- Examens complementaires :\n- Suivi :',
    );
  }

  static Future<SoapNote?> _pickTemplate(BuildContext context) async {
    final completer = Completer<SoapNote?>();

    final sheetFuture = TemplatePickerSheet.show(
      context,
      onTemplateApplied: (note, {baseTemplateId}) {
        if (!completer.isCompleted) {
          completer.complete(note);
        }
      },
    );

    sheetFuture.whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
