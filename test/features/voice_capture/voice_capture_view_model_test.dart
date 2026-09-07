import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';

void main() {
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
