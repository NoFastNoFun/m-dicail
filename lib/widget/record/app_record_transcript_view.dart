import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

class AppRecordTranscriptView extends StatelessWidget {
  const AppRecordTranscriptView({
    super.key,
    required this.transcript,
    required this.emptyHint,
  });

  final String transcript;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final paragraphs = _splitIntoParagraphs(transcript);

    if (paragraphs.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: AppText(
          emptyHint,
          variant: AppTextVariant.body,
          color: context.secondaryTextColor,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: paragraphs.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, index) {
        return AppText(
          paragraphs[index],
          variant: AppTextVariant.body,
          color: context.secondaryTextColor,
        );
      },
    );
  }

  static List<String> _splitIntoParagraphs(String transcript) {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final blocks = trimmed.split(RegExp(r'\n\s*\n'));
    final paragraphs = <String>[];

    for (final block in blocks) {
      final normalized = block.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (normalized.isEmpty) {
        continue;
      }

      final sentences = normalized.split(RegExp(r'(?<=[.!?])\s+'));
      if (sentences.length <= 1) {
        paragraphs.add(normalized);
        continue;
      }

      paragraphs.addAll(
        sentences
            .map((sentence) => sentence.trim())
            .where((sentence) => sentence.isNotEmpty),
      );
    }

    return paragraphs;
  }
}
