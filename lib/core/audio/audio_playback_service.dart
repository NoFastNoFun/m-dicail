abstract class AudioPlaybackService {
  Future<void> play(String source);

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();

  Stream<bool> get playingStream;
}
