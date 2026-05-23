import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

enum TemplateItemType { builtin, variant }

class TemplateListItem extends Equatable {
  const TemplateListItem({
    required this.id,
    required this.displayName,
    required this.type,
    required this.soapNote,
    this.baseTemplateId,
  });

  final String id;
  final String displayName;
  final TemplateItemType type;
  final SoapNote soapNote;
  final String? baseTemplateId;

  @override
  List<Object?> get props => [id, displayName, type, soapNote, baseTemplateId];
}
