import 'dart:io';

import 'package:audio_decoder/audio_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// An upload copy. Disposing it never removes the recording used by local STT.
class AudioUploadFile {
  AudioUploadFile({
    required this.path,
    required this.mimeType,
    Directory? temporaryDirectory,
  }) : _temporaryDirectory = temporaryDirectory;

  final String path;
  final String mimeType;
  final Directory? _temporaryDirectory;

  Future<void> dispose() async {
    try {
      final directory = _temporaryDirectory;
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } on FileSystemException {
      // Best effort cleanup of this upload's temporary directory.
    }
  }
}

abstract class AudioCompressionService {
  Future<AudioUploadFile> prepareUpload(String recordingPath);
}

@LazySingleton(as: AudioCompressionService)
class NativeAudioCompressionService implements AudioCompressionService {
  @override
  Future<AudioUploadFile> prepareUpload(String recordingPath) async {
    final original = AudioUploadFile(
      path: recordingPath,
      mimeType: recordingPath.toLowerCase().endsWith('.wav')
          ? 'audio/wav'
          : 'application/octet-stream',
    );
    // The recorder produces 16 kHz mono PCM WAV. Do not re-encode imports
    // that may already be compressed.
    if (!recordingPath.toLowerCase().endsWith('.wav')) return original;

    AudioUploadFile? compressed;
    try {
      final sourceSize = await File(recordingPath).length();
      if (sourceSize == 0) return original;
      final cache = await getTemporaryDirectory();
      final directory = await cache.createTemp('medicail_upload_');
      compressed = AudioUploadFile(
        path: '${directory.path}/audio.m4a',
        mimeType: 'audio/mp4',
        temporaryDirectory: directory,
      );
      // Native AAC-LC encoding; the source WAV remains available for Whisper.
      await AudioDecoder.convertToM4a(recordingPath, compressed.path);
      final compressedSize = await File(compressed.path).length();
      if (compressedSize > 0 && compressedSize < sourceSize) {
        if (kDebugMode) {
          final saved = (100 * (1 - compressedSize / sourceSize)).toStringAsFixed(1);
          debugPrint('[AudioCompression] WAV=$sourceSize bytes -> M4A=$compressedSize bytes; saved=$saved%');
        }
        return compressed;
      }
      if (kDebugMode) {
        debugPrint('[AudioCompression] Original WAV retained: converted file empty or not smaller.');
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[AudioCompression] Conversion unavailable; original WAV retained.');
      }
    }

    await compressed?.dispose();
    return original;
  }
}
