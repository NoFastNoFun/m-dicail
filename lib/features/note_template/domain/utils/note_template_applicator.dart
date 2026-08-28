import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

abstract final class NoteTemplateApplicator {
  static SoapNote genericSoapNote(String transcript) {
    return _defaultSoapNote(transcript);
  }

  static SoapNote apply({
    NoteTemplate? template,
    required String transcript,
  }) {
    if (template == null) {
      return genericSoapNote(transcript);
    }

    final sections = template.orderedSections;
    final subjectivePrompt = _promptForKind(sections, NoteSectionKind.subjective);
    final objectivePrompt = _promptForKind(sections, NoteSectionKind.objective);
    final assessmentPrompt = _promptForKind(sections, NoteSectionKind.assessment);
    final planPrompt = _promptForKind(sections, NoteSectionKind.plan);
    final customBlocks = _customBlocks(sections);

    final cleanTranscript = transcript.trim();
    final subjective = _mergeSubjective(cleanTranscript, subjectivePrompt);
    final objective = _appendCustomBlocks(objectivePrompt, customBlocks, toPlan: false);
    final plan = _appendCustomBlocks(planPrompt, customBlocks, toPlan: true);

    return SoapNote(
      subjective: subjective,
      objective: objective,
      assessment: assessmentPrompt,
      plan: plan,
    );
  }

  static String _promptForKind(
    List<NoteSection> sections,
    NoteSectionKind kind,
  ) {
    for (final section in sections) {
      if (section.kind == kind) {
        return section.prompt.trim();
      }
    }
    return '';
  }

  static List<NoteSection> _customBlocks(List<NoteSection> sections) {
    return [
      for (final section in sections)
        if (section.kind == NoteSectionKind.custom) section,
    ];
  }

  static String _mergeSubjective(String transcript, String prompt) {
    if (transcript.isEmpty) {
      return prompt.isEmpty
          ? '- Motif de consultation :\n- Symptomes decrits :'
          : prompt;
    }
    if (prompt.isEmpty) {
      return transcript;
    }
    return '$transcript\n\n$prompt';
  }

  static String _appendCustomBlocks(
    String basePrompt,
    List<NoteSection> customSections, {
    required bool toPlan,
  }) {
    final blocks = <String>[];
    if (basePrompt.isNotEmpty) {
      blocks.add(basePrompt);
    }

    for (var index = 0; index < customSections.length; index++) {
      final section = customSections[index];
      final goesToPlan = index.isOdd;
      if (goesToPlan != toPlan) {
        continue;
      }

      final title = section.title.trim();
      final prompt = section.prompt.trim();
      if (title.isEmpty && prompt.isEmpty) {
        continue;
      }

      final header = title.isEmpty ? '' : '## $title';
      if (header.isEmpty) {
        blocks.add(prompt);
      } else if (prompt.isEmpty) {
        blocks.add(header);
      } else {
        blocks.add('$header\n$prompt');
      }
    }

    return blocks.join('\n\n').trim();
  }

  static SoapNote _defaultSoapNote(String transcript) {
    final cleanTranscript = transcript.trim();
    return SoapNote(
      subjective: cleanTranscript.isEmpty
          ? '- Motif de consultation :\n- Symptomes decrits :'
          : cleanTranscript,
      objective: '- Constantes :\n- Examen clinique :',
      assessment: '- Diagnostics suspectes :',
      plan: '- Traitement :\n- Examens complementaires :\n- Suivi :',
    );
  }
}
