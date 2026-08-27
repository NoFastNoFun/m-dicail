abstract class AudioCaptureService {
  Future<bool> initialize();

  Future<void> startListening({
    required void Function(String text, {bool isFinal}) onResult,
    void Function()? onListeningEnded,
  });

  Future<void> stopListening();

  bool get isListening;
}
