import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/raw_audio_recorder_service.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

@LazySingleton(as: RawAudioRecorderService)
class RecordRawAudioRecorderService implements RawAudioRecorderService {
  RecordRawAudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;

  @override
  bool get isRecording => _currentPath != null;

  @override
  Future<String> startRecording({required String sessionId}) async {
    if (_currentPath != null) {
      return _currentPath!;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const AudioException('Permission microphone refusee');
    }

    final directory = await getApplicationDocumentsDirectory();
    final recordingsDirectory = Directory('${directory.path}/recordings');
    if (!recordingsDirectory.existsSync()) {
      recordingsDirectory.createSync(recursive: true);
    }

    final path = '${recordingsDirectory.path}/$sessionId.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    _currentPath = path;
    return path;
  }

  @override
  Future<String?> stopRecording() async {
    if (_currentPath == null) {
      return null;
    }
    final path = await _recorder.stop();
    _currentPath = null;
    return path;
  }

  @override
  Future<void> cancelRecording() async {
    if (_currentPath == null) {
      return;
    }
    final path = _currentPath!;
    await _recorder.cancel();
    _currentPath = null;
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
