import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/medical_watch/data/models/medical_watch_article_model.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';

@LazySingleton(as: MedicalWatchRepository)
class ApiMedicalWatchRepository implements MedicalWatchRepository {
  ApiMedicalWatchRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/medical-watch',
      queryParameters: {
        if (specialty != null) 'specialty': specialty.apiValue,
        if (limit != null) 'limit': limit,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Aucun article de veille medicale retourne.');
    }

    return data
        .map((json) => MedicalWatchArticleModel.fromJson(
              json as Map<String, dynamic>,
            ))
        .toList();
  }
}
