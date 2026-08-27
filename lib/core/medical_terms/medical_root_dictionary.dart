import 'package:injectable/injectable.dart';
import 'package:medicail/core/storage/cached_json_asset_loader.dart';

class MedicalRoot {
  const MedicalRoot({
    required this.id,
    required this.variants,
    required this.meaning,
  });

  factory MedicalRoot.fromJson(Map<String, dynamic> json) {
    return MedicalRoot(
      id: json['id'] as String,
      variants: List<String>.from(json['variants'] as List),
      meaning: json['meaning'] as String,
    );
  }

  final String id;
  final List<String> variants;
  final String meaning;
}

class MedicalRootDictionaryData {
  const MedicalRootDictionaryData({
    required this.prefixesAnatomiques,
    required this.prefixesRegions,
    required this.prefixesDirection,
    required this.suffixesPathologiques,
    required this.knownTerms,
  });

  final List<MedicalRoot> prefixesAnatomiques;
  final List<MedicalRoot> prefixesRegions;
  final List<MedicalRoot> prefixesDirection;
  final List<MedicalRoot> suffixesPathologiques;
  final List<String> knownTerms;
}

@lazySingleton
class MedicalRootDictionary {
  MedicalRootDictionary()
    : _loader = CachedJsonAssetLoader<MedicalRootDictionaryData>(
        assetPath,
        _parse,
      );

  static const String assetPath = 'assets/medical_terms/greco_latin_roots.json';

  final CachedJsonAssetLoader<MedicalRootDictionaryData> _loader;

  Future<MedicalRootDictionaryData> load() => _loader.load();

  static MedicalRootDictionaryData _parse(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Format de dictionnaire medical invalide.');
    }

    List<MedicalRoot> roots(String key) {
      final list = decoded[key];
      if (list is! List) {
        throw StateError('Section "$key" manquante ou invalide.');
      }
      return list
          .map(
            (item) =>
                MedicalRoot.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }

    final knownTerms = decoded['knownTerms'];
    if (knownTerms is! List) {
      throw StateError('Section "knownTerms" manquante ou invalide.');
    }

    return MedicalRootDictionaryData(
      prefixesAnatomiques: roots('prefixesAnatomiques'),
      prefixesRegions: roots('prefixesRegions'),
      prefixesDirection: roots('prefixesDirection'),
      suffixesPathologiques: roots('suffixesPathologiques'),
      knownTerms: List<String>.from(knownTerms),
    );
  }
}
