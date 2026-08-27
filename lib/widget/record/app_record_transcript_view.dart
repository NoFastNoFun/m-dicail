import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

class AppRecordTranscriptView extends StatefulWidget {
  const AppRecordTranscriptView({
    super.key,
    required this.transcript,
    required this.emptyHint,
  });

  final String transcript;
  final String emptyHint;

  @override
  State<AppRecordTranscriptView> createState() =>
      _AppRecordTranscriptViewState();
}

class _AppRecordTranscriptViewState extends State<AppRecordTranscriptView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(AppRecordTranscriptView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcript != oldWidget.transcript) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = _splitIntoParagraphs(widget.transcript);

    if (paragraphs.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: AppText(
          widget.emptyHint,
          variant: AppTextVariant.body,
          color: context.secondaryTextColor,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
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
