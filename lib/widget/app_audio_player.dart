import 'package:flutter/material.dart';
import 'package:medicail/core/audio/audio_playback_service.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';

class AppAudioPlayer extends StatefulWidget {
  const AppAudioPlayer({
    super.key,
    required this.playbackService,
    required this.source,
    this.title = 'Audio brut',
    this.playLabel = 'Lire',
    this.pauseLabel = 'Pause',
    this.stopLabel = 'Stop',
    this.availableLabel = 'Audio disponible',
    this.unavailableLabel = 'Audio indisponible',
    this.loadingLabel = 'Chargement...',
    this.errorLabel = 'Lecture impossible',
  });

  final AudioPlaybackService playbackService;
  final String? source;
  final String title;
  final String playLabel;
  final String pauseLabel;
  final String stopLabel;
  final String availableLabel;
  final String unavailableLabel;
  final String loadingLabel;
  final String errorLabel;

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  bool _isLoading = false;
  String? _errorMessage;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await action();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = widget.errorLabel;
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
    return StreamBuilder<bool>(
      stream: widget.playbackService.playingStream,
      initialData: false,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        final statusLabel = _statusLabel(isPlaying: isPlaying);
        final statusColor = _statusColor(isPlaying: isPlaying);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(widget.title, variant: AppTextVariant.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(_statusIcon(isPlaying: isPlaying), color: statusColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    statusLabel,
                    variant: AppTextVariant.caption,
                    color: statusColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: isPlaying ? widget.pauseLabel : widget.playLabel,
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
                  label: widget.stopLabel,
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

  String _statusLabel({required bool isPlaying}) {
    if (_errorMessage != null) {
      return _errorMessage!;
    }
    if (_isLoading) {
      return widget.loadingLabel;
    }
    if (!_hasSource) {
      return widget.unavailableLabel;
    }
    if (isPlaying) {
      return 'Lecture en cours';
    }
    return widget.availableLabel;
  }

  Color _statusColor({required bool isPlaying}) {
    if (_errorMessage != null) {
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
    if (_errorMessage != null) {
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
