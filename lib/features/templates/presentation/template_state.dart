import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';

sealed class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];
}

final class TemplateInitial extends TemplateState {
  const TemplateInitial();
}

final class TemplateLoading extends TemplateState {
  const TemplateLoading();
}

final class TemplateLoaded extends TemplateState {
  const TemplateLoaded({
    required this.items,
    this.query = '',
    this.selectedNote,
    this.selectedBaseTemplateId,
    this.pendingDuplicateVariantId,
  });

  final List<TemplateListItem> items;
  final String query;
  final SoapNote? selectedNote;
  final String? selectedBaseTemplateId;
  final String? pendingDuplicateVariantId;

  TemplateLoaded copyWith({
    List<TemplateListItem>? items,
    String? query,
    SoapNote? selectedNote,
    String? selectedBaseTemplateId,
    String? pendingDuplicateVariantId,
    bool clearSelectedNote = false,
    bool clearPendingDuplicate = false,
  }) {
    return TemplateLoaded(
      items: items ?? this.items,
      query: query ?? this.query,
      selectedNote:
          clearSelectedNote ? null : (selectedNote ?? this.selectedNote),
      selectedBaseTemplateId:
          selectedBaseTemplateId ?? this.selectedBaseTemplateId,
      pendingDuplicateVariantId: clearPendingDuplicate
          ? null
          : (pendingDuplicateVariantId ?? this.pendingDuplicateVariantId),
    );
  }

  @override
  List<Object?> get props => [
        items,
        query,
        selectedNote,
        selectedBaseTemplateId,
        pendingDuplicateVariantId,
      ];
}

final class TemplateSavingSuccess extends TemplateState {
  const TemplateSavingSuccess();
}

final class TemplateError extends TemplateState {
  const TemplateError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
