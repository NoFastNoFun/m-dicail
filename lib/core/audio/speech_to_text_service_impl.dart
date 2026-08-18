import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

@LazySingleton(as: AudioCaptureService)
class SpeechToTextServiceImpl implements AudioCaptureService {
  SpeechToTextServiceImpl() : _speech = SpeechToText();

  static const _pauseFor = Duration(minutes: 2);
  static const _listenFor = Duration(minutes: 30);

  final SpeechToText _speech;
  bool _isListening = false;
  bool _keepListening = false;
  void Function()? _onListeningEnded;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw const AudioException('Permission microphone refusee');
    }

    final available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );

    if (!available) {
      throw const AudioException('Reconnaissance vocale indisponible');
    }

    return true;
  }

  void _onSpeechStatus(String status) {
    debugPrint('STT Status: $status');
    if (status != SpeechToText.doneStatus) {
      return;
    }
    _isListening = false;
    if (_keepListening) {
      _onListeningEnded?.call();
    }
  }

  void _onSpeechError(Object error) {
    debugPrint('STT Error: $error');
    _isListening = false;
    if (_keepListening) {
      _onListeningEnded?.call();
    }
  }

  @override
  Future<void> startListening({
    required void Function(String text) onResult,
    void Function()? onListeningEnded,
  }) async {
    if (!_speech.isAvailable) {
      throw const AudioException('Service vocal non initialise');
    }
    if (_isListening) {
      return;
    }

    _onListeningEnded = onListeningEnded;
    _keepListening = true;

    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
        pauseFor: _pauseFor,
        listenFor: _listenFor,
      ),
    );
    _isListening = true;
  }

  @override
  Future<void> stopListening() async {
    _keepListening = false;
    _onListeningEnded = null;
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
}
