import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medicail/core/audio/audio_playback_service.dart';

@LazySingleton(as: AudioPlaybackService)
class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService() : _player = AudioPlayer();

  final AudioPlayer _player;
  String? _currentSource;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Future<void> play(String source) async {
    if (source.isEmpty) {
      return;
    }

    if (_currentSource != source) {
      await _loadSource(source);
      _currentSource = source;
    }

    // Do not await _player.play() because it completes only when playback finishes,
    // which would block the UI in a "loading" state.
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentSource = null;
  }

  @override
  Future<void> dispose() => _player.dispose();

  Future<void> _loadSource(String source) {
    if (_isRemoteOrBlobSource(source)) {
      return _player.setUrl(source);
    }
    return _player.setFilePath(source);
  }

  bool _isRemoteOrBlobSource(String source) {
    return source.startsWith('http://') ||
        source.startsWith('https://') ||
        source.startsWith('blob:');
  }
}
