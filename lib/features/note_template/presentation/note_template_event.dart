import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';

sealed class NoteTemplateEvent extends Equatable {
  const NoteTemplateEvent();

  @override
  List<Object?> get props => [];
}

final class NoteTemplatesRequested extends NoteTemplateEvent {
  const NoteTemplatesRequested();
}

final class NoteTemplateSaveVariantRequested extends NoteTemplateEvent {
  const NoteTemplateSaveVariantRequested(this.template);

  final NoteTemplate template;

  @override
  List<Object?> get props => [template];
}

final class NoteTemplateDuplicateRequested extends NoteTemplateEvent {
  const NoteTemplateDuplicateRequested({
    required this.parentTemplateId,
    required this.name,
  });

  final String parentTemplateId;
  final String name;

  @override
  List<Object?> get props => [parentTemplateId, name];
}

final class NoteTemplateDeleteRequested extends NoteTemplateEvent {
  const NoteTemplateDeleteRequested(this.templateId);

  final String templateId;

  @override
  List<Object?> get props => [templateId];
}
