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
    _log('initialize:start web=$kIsWeb');
    if (!kIsWeb) {
      final micStatus = await Permission.microphone.request();
      _log('permission:status=$micStatus');
      if (!micStatus.isGranted) {
        throw const AudioException('Permission microphone refusee');
      }
    } else {
      final supported = await _speech.hasPermission;
      _log('web:speechRecognitionSupported=$supported');
    }

    try {
      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) {
          _log('native:error=${error.errorMsg} permanent=${error.permanent}');
        },
        debugLogging: kDebugMode,
      );

      _log(
        'initialize:done available=$available isAvailable=${_speech.isAvailable}',
      );

      if (!available) {
        throw const AudioException('Reconnaissance vocale indisponible');
      }

      return true;
    } catch (error, stackTrace) {
      _log('initialize:exception=$error');
      rethrow;
    }
  }

  void _onSpeechStatus(String status) {
    _log(
      'native:status=$status pluginListening=${_speech.isListening} localListening=$_isListening',
    );
    if (status != SpeechToText.doneStatus) {
      return;
    }
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
    _log(
      'listen:start available=${_speech.isAvailable} localListening=$_isListening',
    );
    if (!_speech.isAvailable) {
      throw const AudioException('Service vocal non initialise');
    }
    if (_isListening) {
      return;
    }

    _onListeningEnded = onListeningEnded;
    _keepListening = true;

    try {
      await _speech.listen(
        onResult: (result) {
          _log(
            'result:received final=${result.finalResult} chars=${result.recognizedWords.length}',
          );
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        localeId: kIsWeb ? 'fr-FR' : 'fr_FR',
        pauseFor: _pauseFor,
        listenFor: _listenFor,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
      _isListening = true;
      _log(
        'listen:requested pluginListening=${_speech.isListening} localListening=$_isListening',
      );
    } catch (error, stackTrace) {
      _keepListening = false;
      _log('listen:exception=$error');
      rethrow;
    }
  }

  @override
  Future<void> stopListening() async {
    _log(
      'stop:start pluginListening=${_speech.isListening} localListening=$_isListening',
    );
    _keepListening = false;
    _onListeningEnded = null;
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    _log('stop:done');
  }

  void _log(String message) {
    // Debug logs removed as requested.
  }
}
