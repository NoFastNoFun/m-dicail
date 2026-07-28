import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract class BackgroundAudioRecorder {
  bool get isRecording;

  Future<void> start({required String sessionId});

  Future<String?> stop();

  Future<void> cancel();
}

@LazySingleton(as: BackgroundAudioRecorder)
class BackgroundAudioRecorderImpl implements BackgroundAudioRecorder {
  BackgroundAudioRecorderImpl() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _activePath;

  @override
  bool get isRecording => _activePath != null;

  @override
  Future<void> start({required String sessionId}) async {
    if (_activePath != null) {
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const AudioException('Permission microphone refusee');
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/medicail_session_${sessionId}_${DateTime.now().microsecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: path,
    );
    _activePath = path;
  }

  @override
  Future<String?> stop() async {
    final path = _activePath;
    _activePath = null;
    if (path == null) {
      return null;
    }

    final recordedPath = await _recorder.stop();
    final filePath = recordedPath ?? path;
    final file = File(filePath);
    if (!await file.exists() || await file.length() == 0) {
      await _deleteIfExists(filePath);
      return null;
    }
    return filePath;
  }

  @override
  Future<void> cancel() async {
    final path = _activePath;
    _activePath = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    if (path != null) {
      await _deleteIfExists(path);
    }
  }

  Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
