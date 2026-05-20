abstract class RawAudioRecorderService {
  Future<String> startRecording({required String sessionId});

  Future<String?> stopRecording();

  Future<void> cancelRecording();

  bool get isRecording;
}
