import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/raw_audio_recorder_service.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

@LazySingleton(as: RawAudioRecorderService)
class RecordRawAudioRecorderService implements RawAudioRecorderService {
  RecordRawAudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentSessionId;

  @override
  bool get isRecording => _currentSessionId != null;

  @override
  Future<String> startRecording({required String sessionId}) async {
    if (_currentSessionId != null) {
      return _pendingPath(_currentSessionId!);
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const AudioException('Permission microphone refusee');
    }

    final path = await _buildRecordingPath(sessionId);
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    _currentSessionId = sessionId;
    return _pendingPath(sessionId);
  }

  @override
  Future<String?> stopRecording() async {
    if (_currentSessionId == null) {
      return null;
    }
    final path = await _recorder.stop();
    _currentSessionId = null;
    return path;
  }

  @override
  Future<void> cancelRecording() async {
    if (_currentSessionId == null) {
      return;
    }
    await _recorder.cancel();
    _currentSessionId = null;
  }

  String _pendingPath(String sessionId) => 'pending:$sessionId';

  Future<String> _buildRecordingPath(String sessionId) async {
    if (kIsWeb) {
      return '$sessionId.m4a';
    }

    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$sessionId.m4a';
  }
}
