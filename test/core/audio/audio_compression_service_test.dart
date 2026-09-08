import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_compression_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const converter = MethodChannel('audio_decoder');
  const paths = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory cache;
  late File recording;
  late NativeAudioCompressionService service;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('audio_compression_test_');
    recording = await File(
      '${cache.path}/recording.wav',
    ).writeAsBytes(List.filled(4096, 1));
    service = NativeAudioCompressionService();
    messenger.setMockMethodCallHandler(paths, (_) async => cache.path);
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(converter, null);
    messenger.setMockMethodCallHandler(paths, null);
    await cache.delete(recursive: true);
  });

  void encode({int size = 1024, bool fail = false}) {
    messenger.setMockMethodCallHandler(converter, (call) async {
      expect(call.method, 'convertToM4a');
      expect(call.arguments['inputPath'], recording.path);
      final output = call.arguments['outputPath'] as String;
      await File(output).writeAsBytes(List.filled(size, 2));
      if (fail) throw PlatformException(code: 'ENCODING_FAILED');
      return output;
    });
  }

  test('returns a smaller M4A and cleans only the upload copy', () async {
    encode();
    final upload = await service.prepareUpload(recording.path);
    expect(upload.mimeType, 'audio/mp4');
    expect(upload.path, endsWith('.m4a'));
    expect(await File(upload.path).length(), 1024);
    expect(await recording.length(), 4096);
    await upload.dispose();
    expect(await File(upload.path).exists(), isFalse);
    expect(await recording.readAsBytes(), List.filled(4096, 1));
  });

  for (final size in [0, 4096, 8192]) {
    test(
      'uses the original if output is empty or not smaller ($size)',
      () async {
        encode(size: size);
        final upload = await service.prepareUpload(recording.path);
        expect(upload.path, recording.path);
        expect(upload.mimeType, 'audio/wav');
        await upload.dispose();
        expect(await cache.list().length, 1);
        expect(await recording.exists(), isTrue);
      },
    );
  }

  test('falls back and removes partial output on conversion failure', () async {
    encode(fail: true);
    final upload = await service.prepareUpload(recording.path);
    expect(upload.path, recording.path);
    expect(await cache.list().length, 1);
  });

  test('falls back when the native converter is unavailable', () async {
    final upload = await service.prepareUpload(recording.path);
    expect(upload.path, recording.path);
    expect(await cache.list().length, 1);
  });

  test(
    'keeps uploads isolated when preparing the same recording twice',
    () async {
      encode();
      final first = await service.prepareUpload(recording.path);
      final second = await service.prepareUpload(recording.path);
      expect(first.path, isNot(second.path));
      await first.dispose();
      expect(await File(second.path).exists(), isTrue);
      await second.dispose();
      expect(await recording.exists(), isTrue);
    },
  );

  test('does not re-encode an already compressed recording', () async {
    final compressed = await File(
      '${cache.path}/recording.m4a',
    ).writeAsBytes([1, 2]);
    messenger.setMockMethodCallHandler(
      converter,
      (_) async => fail('Unexpected conversion'),
    );
    final upload = await service.prepareUpload(compressed.path);
    expect(upload.path, compressed.path);
    await upload.dispose();
    expect(await compressed.exists(), isTrue);
  });
}
