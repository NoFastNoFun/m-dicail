import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

sealed class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

final class TemplatesLoadRequested extends TemplateEvent {
  const TemplatesLoadRequested({this.query});

  final String? query;

  @override
  List<Object?> get props => [query];
}

final class TemplateSearchQueryChanged extends TemplateEvent {
  const TemplateSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class TemplateSelected extends TemplateEvent {
  const TemplateSelected(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

final class VariantSaveRequested extends TemplateEvent {
  const VariantSaveRequested({
    required this.displayName,
    required this.soapNote,
    this.baseTemplateId,
    this.overwriteExistingId,
  });

  final String displayName;
  final SoapNote soapNote;
  final String? baseTemplateId;
  final String? overwriteExistingId;

  @override
  List<Object?> get props => [
        displayName,
        soapNote,
        baseTemplateId,
        overwriteExistingId,
      ];
}

final class VariantOverwriteConfirmed extends TemplateEvent {
  const VariantOverwriteConfirmed({
    required this.existingVariantId,
    required this.displayName,
    required this.soapNote,
    this.baseTemplateId,
  });

  final String existingVariantId;
  final String displayName;
  final SoapNote soapNote;
  final String? baseTemplateId;

  @override
  List<Object?> get props => [
        existingVariantId,
        displayName,
        soapNote,
        baseTemplateId,
      ];
}

final class TemplateDuplicateDismissed extends TemplateEvent {
  const TemplateDuplicateDismissed();
}
