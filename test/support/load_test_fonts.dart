import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

/// Use the SDK's real Roboto metrics instead of the square Ahem test font.
Future<void> loadTestFonts() async {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final flutter = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((package) => package['name'] == 'flutter');
  final root = configFile.uri.resolve('${flutter['rootUri']}/');
  final font = File.fromUri(
    root.resolve('../../bin/cache/artifacts/material_fonts/roboto-medium.ttf'),
  );
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
  await loader.load();
}
