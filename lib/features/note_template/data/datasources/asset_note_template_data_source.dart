import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/note_template/data/models/note_template_model.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';

@lazySingleton
class AssetNoteTemplateDataSource {
  static const String assetPath = 'assets/templates/default_templates.json';

  List<NoteTemplate>? _cache;

  Future<List<NoteTemplate>> loadBuiltInTemplates() async {
    if (_cache != null) {
      return List<NoteTemplate>.from(_cache!);
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw StateError('Format de modeles invalide.');
      }

      final templates = <NoteTemplate>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final json = Map<String, dynamic>.from(item);
        json['source'] = NoteTemplateSource.builtIn.jsonValue;
        templates.add(NoteTemplateModel.fromJson(json));
      }

      if (templates.isEmpty) {
        throw StateError('Aucun modele par defaut trouve.');
      }

      _cache = templates;
      return List<NoteTemplate>.from(templates);
    } on FlutterError catch (error) {
      throw StateError(
        'Impossible de charger les modeles embarques ($assetPath). '
        'Reinstallez l application: ${error.message}',
      );
    } on Object catch (error) {
      Error.throwWithStackTrace(
        StateError('Impossible de lire les modeles par defaut: $error'),
        StackTrace.current,
      );
    }
  }
}
