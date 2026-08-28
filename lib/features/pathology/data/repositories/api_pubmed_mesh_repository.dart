import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/pathology/data/models/mesh_descriptor_model.dart';
import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';

@injectable
class ApiPubmedMeshRepository {
  ApiPubmedMeshRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MeshDescriptor>> searchMesh(
    String query, {
    int maxResults = 15,
  }) async {
    final response = await _apiClient.post<List<dynamic>>(
      '/pubmed/mesh',
      data: {
        'query': query,
        'max_results': maxResults,
      },
    );

    final data = response.data;
    if (data == null) {
      return const [];
    }

    return data
        .map(
          (json) => MeshDescriptorModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
