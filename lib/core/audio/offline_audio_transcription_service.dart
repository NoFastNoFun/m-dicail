import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:whisper_kit/whisper_kit.dart' hide AudioException;

abstract class OfflineAudioTranscriptionService {
  Future<String> transcribeFile(
    String path, {
    String language = 'fr',
  });
}

@LazySingleton(as: OfflineAudioTranscriptionService)
class WhisperOfflineAudioTranscriptionService
    implements OfflineAudioTranscriptionService {
  WhisperOfflineAudioTranscriptionService()
      : _whisper = const Whisper(model: WhisperModel.tiny);

  final Whisper _whisper;

  @override
  Future<String> transcribeFile(
    String path, {
    String language = 'fr',
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const AudioException('Fichier audio introuvable');
    }
    if (await file.length() == 0) {
      return '';
    }

    try {
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: path,
          language: language,
          isNoTimestamps: true,
        ),
      );
      return result.text.trim();
    } on WhisperKitException catch (error) {
      throw AudioException(error.message);
    } catch (error) {
      throw AudioException('Transcription hors ligne impossible: $error');
    }
  }
}
