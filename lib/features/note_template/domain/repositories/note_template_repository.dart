import 'package:medicail/features/note_template/domain/entities/note_template.dart';

abstract interface class NoteTemplateRepository {
  Future<List<NoteTemplate>> getAll();

  Future<List<NoteTemplate>> getBuiltInTemplates();

  Future<List<NoteTemplate>> getUserVariants();

  Future<NoteTemplate?> getById(String id);

  Future<NoteTemplate> saveVariant(NoteTemplate template);

  Future<NoteTemplate> duplicateAsVariant({
    required String parentTemplateId,
    required String name,
  });

  Future<void> deleteVariant(String id);
}
