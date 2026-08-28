import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/pathology/data/models/pathology_model.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';

@lazySingleton
class AssetPathologyDataSource {
  static const String assetPath = 'assets/pathologies/default_pathologies.json';

  List<Pathology>? _cache;

  Future<List<Pathology>> loadBuiltInPathologies() async {
    if (_cache != null) {
      return List<Pathology>.from(_cache!);
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw StateError('Format de pathologies invalide.');
      }

      final pathologies = <Pathology>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final json = Map<String, dynamic>.from(item);
        json['source'] = PathologySource.builtIn.jsonValue;
        pathologies.add(PathologyModel.fromJson(json));
      }

      if (pathologies.isEmpty) {
        throw StateError('Aucune pathologie par defaut trouvee.');
      }

      _cache = pathologies;
      return List<Pathology>.from(pathologies);
    } on FlutterError catch (error) {
      throw StateError(
        'Impossible de charger les pathologies embarquees ($assetPath). '
        'Reinstallez l application: ${error.message}',
      );
    } on Object catch (error) {
      Error.throwWithStackTrace(
        StateError('Impossible de lire les pathologies par defaut: $error'),
        StackTrace.current,
      );
    }
  }
}
