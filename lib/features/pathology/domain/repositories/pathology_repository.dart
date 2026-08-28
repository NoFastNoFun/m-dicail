import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';

abstract interface class PathologyRepository {
  Future<void> ensureMigrated();

  Future<List<Pathology>> getAll();

  Future<List<Pathology>> getBuiltInPathologies();

  Future<List<Pathology>> getUserPathologies();

  Future<Pathology?> getById(String id);

  Future<List<Pathology>> searchLocal(String query);

  Future<Pathology> saveUserPathology(Pathology pathology);

  Future<Pathology> createUserPathology({
    required String name,
    required PathologyDomain domain,
  });

  Future<Pathology> importFromPubmed(MeshDescriptor descriptor);

  Future<void> linkTemplate({
    required String pathologyId,
    required String templateId,
  });

  Future<void> deleteUserPathology(String id);

  Future<List<MeshDescriptor>> searchPubmedMesh(
    String query, {
    int maxResults = 15,
  });
}
