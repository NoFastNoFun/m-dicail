import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/appointment/presentation/appointment_bloc.dart';
import 'package:medicail/features/appointment/presentation/appointment_change_notifier.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/appointment_form_sheet.dart';
import 'package:medicail/widget/appointment_list_row.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

class AppointmentsDayPage extends StatelessWidget {
  const AppointmentsDayPage({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    final day = initialDate ?? DateTime.now();
    return BlocProvider(
      create: (_) =>
          getIt<AppointmentBloc>()..add(AppointmentsDayRequested(day)),
      child: _AppointmentsDayView(initialDay: day),
    );
  }
}

class _AppointmentsDayView extends StatefulWidget {
  const _AppointmentsDayView({required this.initialDay});

  final DateTime initialDay;

  @override
  State<_AppointmentsDayView> createState() => _AppointmentsDayViewState();
}

class _AppointmentsDayViewState extends State<_AppointmentsDayView> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    _day = DateTime(
      widget.initialDay.year,
      widget.initialDay.month,
      widget.initialDay.day,
    );
    appointmentChangeNotifier.addListener(_onAppointmentsChanged);
  }

  @override
  void dispose() {
    appointmentChangeNotifier.removeListener(_onAppointmentsChanged);
    super.dispose();
  }

  void _onAppointmentsChanged() {
    if (!mounted) return;
    context.read<AppointmentBloc>().add(AppointmentsDayRequested(_day));
  }

  void _changeDay(int delta) {
    setState(() {
      _day = _day.add(Duration(days: delta));
    });
    context.read<AppointmentBloc>().add(AppointmentsDayRequested(_day));
  }

  void _openCreate() {
    AppointmentFormSheet.show(context, initialDay: _day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMMEEEEd().format(_day);

    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final items = state is AppointmentDayLoaded ? state.items : const [];
        final isLoading = state is AppointmentLoading;

        return AppScaffold(
          title: l10n.appointmentsDayTitle,
          actions: [
            IconButton(
              tooltip: l10n.appointmentCreateTitle,
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeDay(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _day,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) {
                          if (!context.mounted) return;
                          setState(() {
                            _day = selected;
                          });
                          context.read<AppointmentBloc>().add(AppointmentsDayRequested(_day));
                        }
                      },
                      borderRadius: AppRadius.smBorder,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: AppText(
                          dateLabel,
                          variant: AppTextVariant.title,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeDay(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? Center(
                        child: AppText(
                          l10n.appointmentsEmpty,
                          variant: AppTextVariant.body,
                        ),
                      )
                    : ListView.separated(
                        padding: MainShellScope.scrollPaddingOf(context),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return AppointmentListRow(
                            item: item,
                            showMenu: true,
                            onTap: () => context.goPatientDetail(
                              item.appointment.patientId,
                            ),
                            onEdit: () => AppointmentFormSheet.show(
                              context,
                              existing: item.appointment,
                              initialDay: _day,
                            ),
                            onCancel: () async {
                              final confirm = await AppDialog.show<bool>(
                                context,
                                variant: AppDialogVariant.standard,
                                title: 'Annuler le rendez-vous ?',
                                body: AppText('Êtes-vous sûr de vouloir annuler le rendez-vous de ${item.patient.displayName} ?', variant: AppTextVariant.body),
                                actionsBuilder: (dialogContext) => [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: AppText('Confirmer', variant: AppTextVariant.label, color: Theme.of(context).colorScheme.error),
                                  ),
                                ],
                              );
                              if (confirm == true && context.mounted) {
                                context.read<AppointmentBloc>().add(
                                  AppointmentCancelled(item.appointment.id),
                                );
                              }
                            },
                            onDelete: () async {
                              final confirm = await AppDialog.show<bool>(
                                context,
                                variant: AppDialogVariant.standard,
                                title: 'Supprimer le rendez-vous ?',
                                body: AppText('Cette action est irréversible. Voulez-vous supprimer ce rendez-vous ?', variant: AppTextVariant.body),
                                actionsBuilder: (dialogContext) => [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: AppText('Supprimer', variant: AppTextVariant.label, color: Theme.of(context).colorScheme.error),
                                  ),
                                ],
                              );
                              if (confirm == true && context.mounted) {
                                context.read<AppointmentBloc>().add(
                                  AppointmentDeleted(item.appointment.id),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
