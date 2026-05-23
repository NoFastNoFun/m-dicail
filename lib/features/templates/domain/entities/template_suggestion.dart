import 'package:equatable/equatable.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';

class TemplateSuggestion extends Equatable {
  const TemplateSuggestion({
    required this.template,
    required this.score,
    this.alternatives = const [],
  });

  final SoapTemplate template;
  final int score;
  final List<SoapTemplate> alternatives;

  @override
  List<Object?> get props => [template, score, alternatives];
}
