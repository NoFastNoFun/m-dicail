import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/medical_watch/data/models/medical_watch_article_model.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';

@injectable
class ApiMedicalWatchRepository implements MedicalWatchRepository {
  ApiMedicalWatchRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (specialty != null) queryParameters['specialty'] = specialty.value;
    if (limit != null) queryParameters['limit'] = limit;

    final response = await _apiClient.get<List<dynamic>>(
      '/medical-watch',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data;
    if (data == null) return [];

    return data
        .map((json) =>
            MedicalWatchArticleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MedicalWatchArticle>> searchPubmed(
    String query, {
    int maxResults = 10,
  }) async {
    final response = await _apiClient.post<List<dynamic>>(
      '/pubmed/search',
      data: {
        'query': query,
        'max_results': maxResults,
      },
    );

    final data = response.data;
    if (data == null) return [];

    return data
        .map((json) =>
            MedicalWatchArticleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> triggerSync() async {
    await _apiClient.post<void>('/medical-watch/trigger');
  }
}
