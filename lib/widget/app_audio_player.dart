import 'package:flutter/material.dart';
import 'package:medicail/core/audio/audio_playback_service.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/core/i18n/app_localizations.dart';

class AppAudioPlayer extends StatefulWidget {
  const AppAudioPlayer({
    super.key,
    required this.playbackService,
    required this.source,
  });

  final AudioPlaybackService playbackService;
  final String? source;

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  bool _isLoading = false;
  bool _hasError = false;

  bool get _hasSource => widget.source != null && widget.source!.isNotEmpty;

  Future<void> _play() async {
    if (!_hasSource) {
      return;
    }

    await _runPlaybackAction(() => widget.playbackService.play(widget.source!));
  }

  Future<void> _pause() async {
    await _runPlaybackAction(widget.playbackService.pause);
  }

  Future<void> _stop() async {
    await _runPlaybackAction(widget.playbackService.stop);
  }

  Future<void> _runPlaybackAction(Future<void> Function() action) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await action();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return StreamBuilder<bool>(
      stream: widget.playbackService.playingStream,
      initialData: false,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(_statusIcon(isPlaying: isPlaying), 
                    color: _statusColor(isPlaying: isPlaying)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.audioPlayerTitle,
                        variant: AppTextVariant.body,
                      ),
                      AppText(
                        _statusLabel(isPlaying: isPlaying, l10n: l10n),
                        variant: AppTextVariant.caption,
                        color: _statusColor(isPlaying: isPlaying),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: isPlaying ? l10n.audioPlayerPause : l10n.audioPlayerPlay,
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    layout: AppButtonLayout.textWithIcon,
                    style: AppButtonStyle.primary,
                    enabled: _hasSource && !_isLoading,
                    isLoading: _isLoading && !isPlaying,
                    onPressed: isPlaying ? _pause : _play,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  icon: Icons.stop,
                  label: l10n.audioPlayerStop,
                  layout: AppButtonLayout.textWithIcon,
                  style: AppButtonStyle.secondary,
                  expanded: false,
                  enabled: _hasSource && !_isLoading,
                  onPressed: _stop,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _statusLabel({required bool isPlaying, required AppLocalizations l10n}) {
    if (_hasError) {
      return l10n.audioPlayerError;
    }
    if (_isLoading) {
      return l10n.audioPlayerLoading;
    }
    if (!_hasSource) {
      return l10n.audioPlayerUnavailable;
    }
    if (isPlaying) {
      return l10n.audioPlayerPlaying;
    }
    return l10n.audioPlayerAvailable;
  }

  Color _statusColor({required bool isPlaying}) {
    if (_hasError) {
      return AppColors.error;
    }
    if (!_hasSource) {
      return AppColors.textDisabled;
    }
    if (isPlaying) {
      return AppColors.info;
    }
    return AppColors.textSecondary;
  }

  IconData _statusIcon({required bool isPlaying}) {
    if (_hasError) {
      return Icons.error_outline;
    }
    if (!_hasSource) {
      return Icons.music_off;
    }
    if (isPlaying) {
      return Icons.graphic_eq;
    }
    return Icons.audiotrack;
  }
}
