import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medicail/core/audio/audio_playback_service.dart';

@LazySingleton(as: AudioPlaybackService)
class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService() : _audioPlayer = AudioPlayer();

  final AudioPlayer _audioPlayer;
  String? _currentSource;

  @override
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  @override
  Future<void> play(String source) async {
    if (source.isEmpty) {
      return;
    }

    if (_currentSource != source) {
      await _loadSource(source);
      _currentSource = source;
    }

    // Do not await _audioPlayer.play() because it completes only when playback finishes,
    // which would block the UI in a "loading" state.
    unawaited(_audioPlayer.play());
  }

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSource = null;
  }

  @override
  Future<void> dispose() => _audioPlayer.dispose();

  Future<void> _loadSource(String source) {
    if (_isRemoteOrBlobSource(source)) {
      return _audioPlayer.setUrl(source);
    }
    return _audioPlayer.setFilePath(source);
  }

  bool _isRemoteOrBlobSource(String source) {
    return source.startsWith('http://') ||
        source.startsWith('https://') ||
        source.startsWith('blob:');
  }
}
