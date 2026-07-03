import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';

class NoteSection extends Equatable {
  const NoteSection({
    required this.id,
    required this.kind,
    required this.title,
    required this.prompt,
    required this.order,
  });

  final String id;
  final NoteSectionKind kind;
  final String title;
  final String prompt;
  final int order;

  NoteSection copyWith({
    String? id,
    NoteSectionKind? kind,
    String? title,
    String? prompt,
    int? order,
  }) {
    return NoteSection(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, kind, title, prompt, order];
}
