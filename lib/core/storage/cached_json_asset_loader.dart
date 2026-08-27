import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CachedJsonAssetLoader<T> {
  CachedJsonAssetLoader(this._assetPath, this._parse);

  final String _assetPath;
  final T Function(dynamic decoded) _parse;
  T? _cache;
  Future<T>? _inFlight;

  Future<T> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }

    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _loadAndCache();
    _inFlight = future;
    try {
      return await future;
    } catch (_) {
      _inFlight = null;
      rethrow;
    }
  }

  Future<T> _loadAndCache() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final parsed = _parse(jsonDecode(raw));
      _cache = parsed;
      return parsed;
    } on FlutterError catch (error) {
      throw StateError('Impossible de charger $_assetPath: ${error.message}');
    }
  }
}
