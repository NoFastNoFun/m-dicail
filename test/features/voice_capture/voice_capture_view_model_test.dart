import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/i18n/app_localizations_fr.dart';
import 'package:medicail/features/recording/domain/exceptions/invalid_soap_note_exception.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';

void main() {
  test('invalid SOAP uses the localized error and preserves unsaved work', () {
    final l10n = AppLocalizationsFr();
    final state = VoiceCaptureFailure.fromException(
      const InvalidSoapNoteException(),
      transcript: 'Texte à conserver.',
    );
    final model = VoiceCaptureViewModel.fromState(state);

    expect(model.localizedErrorMessage(l10n), l10n.recordErrorInvalidSoapNote);
    expect(model.errorCode, VoiceCaptureErrorCode.invalidSoapNote);
    expect(model.hasUnsavedWork, isTrue);
    expect(model.isProcessing, isFalse);
  });

  test('existing server errors keep their message', () {
    final model = VoiceCaptureViewModel.fromState(
      VoiceCaptureFailure.fromException(const ServerException('Test error')),
    );
    expect(model.localizedErrorMessage(AppLocalizationsFr()), 'Test error');
    expect(model.errorCode, isNull);
  });

  test('a saved consultation allows leaving the transcription screen', () {
    final model = VoiceCaptureViewModel.fromState(
      const VoiceCaptureConsultationFinished(
        sessionId: 'session',
        transcript: 'Consultation sauvegardée.',
      ),
    );

    expect(model.hasTranscript, isTrue);
    expect(model.hasUnsavedWork, isFalse);
    expect(model.isProcessing, isFalse);
  });

  test('stopped or failed transcription still protects unsaved work', () {
    for (final state in const <VoiceCaptureState>[
      ListeningPaused(transcript: 'Transcription à sauvegarder.'),
      VoiceCaptureReady(transcript: 'Transcription à sauvegarder.'),
      VoiceCaptureFailure('Erreur', transcript: 'Transcription à sauvegarder.'),
    ]) {
      expect(VoiceCaptureViewModel.fromState(state).hasUnsavedWork, isTrue);
    }
  });
}
