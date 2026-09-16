import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_state.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@lazySingleton
class AiTranscriptionJobCubit extends Cubit<AiTranscriptionJobState> {
  AiTranscriptionJobCubit(
    this._enhancedTranscriptionRepository,
    this._offlineAudioTranscriptionService,
    this._recordingNotificationService,
  ) : super(const AiTranscriptionJobIdle());

  final EnhancedTranscriptionRepository _enhancedTranscriptionRepository;
  final OfflineAudioTranscriptionService _offlineAudioTranscriptionService;
  final RecordingNotificationService _recordingNotificationService;

  static const _notificationTitle = 'Transcription en cours';
  static const _notificationBody =
      'La transcription IA continue en arriere-plan';
  static const _notificationReadyTitle = 'Transcription prete';
  static const _notificationReadyBody =
      'Touchez pour comparer les transcriptions';

  static const _minEta = Duration(seconds: 20);
  static const _maxEta = Duration(minutes: 3);
  static const _etaRatio = 0.3;

  String? _audioPath;
  int _jobGeneration = 0;

  bool get isBusy {
    final current = state;
    return current is AiTranscriptionJobRunning ||
        current is AiTranscriptionJobReady;
  }

  bool get hasActiveJob => state is! AiTranscriptionJobIdle;

  String? get activeSessionId => switch (state) {
        AiTranscriptionJobRunning(:final sessionId) => sessionId,
        AiTranscriptionJobReady(:final sessionId) => sessionId,
        AiTranscriptionJobCompletedWithoutCompare(:final sessionId) =>
          sessionId,
        AiTranscriptionJobFailed(:final sessionId) => sessionId,
        _ => null,
      };

  String? get activePatientId => switch (state) {
        AiTranscriptionJobRunning(:final patientId) => patientId,
        AiTranscriptionJobReady(:final patientId) => patientId,
        AiTranscriptionJobCompletedWithoutCompare(:final patientId) => patientId,
        AiTranscriptionJobFailed(:final patientId) => patientId,
        _ => null,
      };

  /// Honest ETA: clamp(20s, audioElapsed * 0.3, 3min).
  static Duration estimateDuration(Duration audioDuration) {
    final rawMs = (audioDuration.inMilliseconds * _etaRatio).round();
    final raw = Duration(milliseconds: rawMs);
    if (raw < _minEta) return _minEta;
    if (raw > _maxEta) return _maxEta;
    return raw;
  }

  Future<void> start({
    required String sessionId,
    required String audioPath,
    required String language,
    required String roughTranscript,
    required Duration audioDuration,
    String? patientId,
    NoteTemplate? selectedTemplate,
  }) async {
    if (isBusy) {
      throw const AudioException(
        'Une transcription est deja en cours.',
      );
    }

    final generation = ++_jobGeneration;
    _audioPath = audioPath;
    final startedAt = DateTime.now();
    final estimated = estimateDuration(audioDuration);

    emit(
      AiTranscriptionJobRunning(
        sessionId: sessionId,
        patientId: patientId,
        language: language,
        roughTranscript: roughTranscript,
        selectedTemplate: selectedTemplate,
        startedAt: startedAt,
        estimatedDuration: estimated,
        audioDuration: audioDuration,
      ),
    );

    await _recordingNotificationService.start(
      title: _notificationTitle,
      body: _notificationBody,
      serviceTypes: const [ForegroundServiceTypes.dataSync],
    );

    try {
      final results = await Future.wait([
        _runCloud(audioPath, sessionId, language),
        _runLocal(audioPath, language),
      ]);

      if (generation != _jobGeneration) return;

      final enhanced = results[0];
      final offline = results[1];

      var localTranscript = roughTranscript;
      if (offline != null && offline.trim().isNotEmpty) {
        localTranscript = AnonymizationHelper.anonymize(offline);
      }

      if (enhanced != null && enhanced.trim().isNotEmpty) {
        emit(
          AiTranscriptionJobReady(
            sessionId: sessionId,
            patientId: patientId,
            language: language,
            localTranscript: localTranscript,
            aiTranscript: AnonymizationHelper.anonymize(enhanced),
            selectedTemplate: selectedTemplate,
          ),
        );
        await _recordingNotificationService.update(
          title: _notificationReadyTitle,
          body: _notificationReadyBody,
        );
        return;
      }

      if (localTranscript.trim().isEmpty) {
        throw const AudioException(
          'La transcription a echoue ou ne contient aucune parole. '
          'Veuillez reessayer.',
        );
      }

      emit(
        AiTranscriptionJobCompletedWithoutCompare(
          sessionId: sessionId,
          patientId: patientId,
          language: language,
          transcript: localTranscript,
          selectedTemplate: selectedTemplate,
        ),
      );
      await _recordingNotificationService.stop();
    } catch (error) {
      if (generation != _jobGeneration) return;
      final message = error is Exception
          ? error.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '')
          : 'La transcription a echoue.';
      emit(
        AiTranscriptionJobFailed(
          sessionId: sessionId,
          patientId: patientId,
          message: message,
          roughTranscript: roughTranscript,
          selectedTemplate: selectedTemplate,
        ),
      );
      await _recordingNotificationService.stop();
    } finally {
      if (generation == _jobGeneration) {
        await _deleteAudioFile(_audioPath);
        _audioPath = null;
      }
    }
  }

  /// Clears ready/failed/completed state after the record flow consumes it.
  void acknowledge() {
    final current = state;
    if (current is AiTranscriptionJobReady ||
        current is AiTranscriptionJobFailed ||
        current is AiTranscriptionJobCompletedWithoutCompare) {
      emit(const AiTranscriptionJobIdle());
    }
  }

  /// Stops the ready notification once compare is open.
  Future<void> markCompareOpened() async {
    await _recordingNotificationService.stop();
  }

  /// Resets to idle (e.g. after discard of a failed job).
  Future<void> reset() async {
    _jobGeneration++;
    await _deleteAudioFile(_audioPath);
    _audioPath = null;
    await _recordingNotificationService.stop();
    emit(const AiTranscriptionJobIdle());
  }

  Future<String?> _runCloud(
    String audioPath,
    String sessionId,
    String language,
  ) async {
    try {
      return await _enhancedTranscriptionRepository.transcribeFile(
        filePath: audioPath,
        sessionId: sessionId,
        language: language,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _runLocal(String audioPath, String language) async {
    try {
      final text = await _offlineAudioTranscriptionService.transcribeFile(
        audioPath,
        language: language,
      );
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteAudioFile(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
