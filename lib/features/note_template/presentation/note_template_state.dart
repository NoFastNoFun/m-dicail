import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';

sealed class NoteTemplateState extends Equatable {
  const NoteTemplateState();

  @override
  List<Object?> get props => [];
}

final class NoteTemplateInitial extends NoteTemplateState {
  const NoteTemplateInitial();
}

final class NoteTemplateLoading extends NoteTemplateState {
  const NoteTemplateLoading();
}

final class NoteTemplateLoaded extends NoteTemplateState {
  const NoteTemplateLoaded({
    required this.builtInTemplates,
    required this.userVariants,
  });

  final List<NoteTemplate> builtInTemplates;
  final List<NoteTemplate> userVariants;

  @override
  List<Object?> get props => [builtInTemplates, userVariants];
}

final class NoteTemplateFailure extends NoteTemplateState {
  const NoteTemplateFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NoteTemplateActionSuccess extends NoteTemplateState {
  const NoteTemplateActionSuccess({
    required this.builtInTemplates,
    required this.userVariants,
    required this.message,
    this.savedTemplateId,
  });

  final List<NoteTemplate> builtInTemplates;
  final List<NoteTemplate> userVariants;
  final String message;
  final String? savedTemplateId;

  @override
  List<Object?> get props => [
        builtInTemplates,
        userVariants,
        message,
        savedTemplateId,
      ];
}
