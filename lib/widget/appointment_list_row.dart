import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/widget/app_text.dart';

class AppointmentListRow extends StatelessWidget {
  const AppointmentListRow({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.showMenu = false,
  });

  final AppointmentListItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointment = item.appointment;
    final muted = appointment.isCancelled;
    final timeFormat = DateFormat.Hm();
    final start = timeFormat.format(appointment.startsAt);
    final end = appointment.endsAt != null
        ? timeFormat.format(appointment.endsAt!)
        : null;
    final timeLabel = end == null ? start : '$start – $end';

    final statusLabel = switch (appointment.status) {
      AppointmentStatus.cancelled => l10n.appointmentStatusCancelled,
      AppointmentStatus.completed => l10n.appointmentStatusCompleted,
      AppointmentStatus.scheduled => l10n.appointmentStatusScheduled,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: AppText(
                timeLabel,
                variant: AppTextVariant.body,
                color: muted
                    ? context.secondaryTextColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.patientDisplayName,
                    variant: AppTextVariant.title,
                    color: muted ? context.secondaryTextColor : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    statusLabel,
                    variant: AppTextVariant.caption,
                    color: context.secondaryTextColor,
                  ),
                  if (appointment.notes != null &&
                      appointment.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      appointment.notes!,
                      variant: AppTextVariant.caption,
                      color: context.secondaryTextColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (showMenu)
              PopupMenuButton<_AppointmentMenuAction>(
                onSelected: (action) {
                  switch (action) {
                    case _AppointmentMenuAction.edit:
                      onEdit?.call();
                    case _AppointmentMenuAction.cancel:
                      onCancel?.call();
                    case _AppointmentMenuAction.delete:
                      onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _AppointmentMenuAction.edit,
                    child: Text(l10n.appointmentEdit),
                  ),
                  if (!appointment.isCancelled)
                    PopupMenuItem(
                      value: _AppointmentMenuAction.cancel,
                      child: Text(l10n.appointmentCancel),
                    ),
                  PopupMenuItem(
                    value: _AppointmentMenuAction.delete,
                    child: Text(l10n.appointmentDelete),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum _AppointmentMenuAction { edit, cancel, delete }
