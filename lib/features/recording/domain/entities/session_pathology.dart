import 'package:equatable/equatable.dart';

class SessionPathology extends Equatable {
  const SessionPathology({
    required this.id,
    required this.name,
    this.templateId,
  });

  final String id;
  final String name;
  final String? templateId;

  factory SessionPathology.fromJson(Map<String, dynamic> json) {
    return SessionPathology(
      id: json['id'] as String,
      name: json['name'] as String,
      templateId: json['template_id'] as String? ?? json['templateId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (templateId != null) 'template_id': templateId,
    };
  }

  SessionPathology copyWith({
    String? id,
    String? name,
    String? templateId,
    bool clearTemplateId = false,
  }) {
    return SessionPathology(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: clearTemplateId ? null : templateId ?? this.templateId,
    );
  }

  @override
  List<Object?> get props => [id, name, templateId];
}
