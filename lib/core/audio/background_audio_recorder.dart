import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract class BackgroundAudioRecorder {
  bool get isRecording;

  Future<void> start({required String sessionId});

  /// Pauses capture while retaining the file; [start] resumes it.
  Future<void> pause();

  Future<String?> stop();

  /// Finalizes the current WAV and immediately starts a new segment.
  /// Returns the path of the completed chunk, or null if empty.
  Future<String?> rotateChunk({required String sessionId});

  Future<void> cancel();
}

@LazySingleton(as: BackgroundAudioRecorder)
class BackgroundAudioRecorderImpl implements BackgroundAudioRecorder {
  BackgroundAudioRecorderImpl() : _audioRecorder = AudioRecorder();

  final AudioRecorder _audioRecorder;
  String? _activePath;
  bool _isPaused = false;

  @override
  bool get isRecording => _activePath != null;

  @override
  Future<void> start({required String sessionId}) async {
    if (_activePath != null) {
      if (_isPaused) {
        await _audioRecorder.resume();
        _isPaused = false;
      }
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      throw const AudioException('Permission microphone refusee');
    }

    await _beginNewFile(sessionId);
  }

  @override
  Future<void> pause() async {
    if (_activePath != null && !_isPaused) {
      await _audioRecorder.pause();
      _isPaused = true;
    }
  }

  @override
  Future<String?> stop() async {
    final path = _activePath;
    _activePath = null;
    _isPaused = false;
    if (path == null) {
      return null;
    }

    final recordedPath = await _audioRecorder.stop();
    final filePath = recordedPath ?? path;
    final file = File(filePath);
    if (!await file.exists() || await file.length() == 0) {
      await _deleteIfExists(filePath);
      return null;
    }
    return filePath;
  }

  @override
  Future<String?> rotateChunk({required String sessionId}) async {
    if (_activePath == null || _isPaused) {
      return null;
    }
    final chunkPath = await stop();
    await start(sessionId: sessionId);
    return chunkPath;
  }

  @override
  Future<void> cancel() async {
    final path = _activePath;
    _activePath = null;
    _isPaused = false;
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    if (path != null) {
      await _deleteIfExists(path);
    }
  }

  Future<void> _beginNewFile(String sessionId) async {
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/medicail_session_${sessionId}_${DateTime.now().microsecondsSinceEpoch}.wav';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
        androidConfig: AndroidRecordConfig(
          audioSource: AndroidAudioSource.voiceRecognition,
        ),
      ),
      path: path,
    );
    _activePath = path;
    _isPaused = false;
  }

  Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
