import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/presentation/appointment_bloc.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/settings/presentation/notifier/settings_notifier.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class AppointmentFormSheet extends StatefulWidget {
  const AppointmentFormSheet({
    super.key,
    this.existing,
    this.initialDay,
    this.toastContext,
  });

  final Appointment? existing;
  final DateTime? initialDay;
  final BuildContext? toastContext;

  static Future<void> show(
    BuildContext context, {
    Appointment? existing,
    DateTime? initialDay,
  }) {
    final day = initialDay ?? existing?.startsAt ?? DateTime.now();
    final toastContext = context;

    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<AppointmentBloc>(),
              ),
              BlocProvider(
                create: (_) =>
                    getIt<PatientBloc>()..add(const PatientsRequested()),
              ),
            ],
            child: AppointmentFormSheet(
              existing: existing,
              initialDay: day,
              toastContext: toastContext,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<AppointmentFormSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  Patient? _selectedPatient;
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isSaving = false;

  Duration get _sessionDuration =>
      getIt<SettingsNotifier>().defaultSessionDuration;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _selectedDate = DateTime(
        existing.startsAt.year,
        existing.startsAt.month,
        existing.startsAt.day,
      );
      _startTime = TimeOfDay.fromDateTime(existing.startsAt);
      final endsAt = existing.endsAt ?? existing.startsAt.add(_sessionDuration);
      _endTime = TimeOfDay.fromDateTime(endsAt);
      _notesController.text = existing.notes ?? '';
    } else {
      final day = widget.initialDay ?? DateTime.now();
      _selectedDate = DateTime(day.year, day.month, day.day);
      _startTime = TimeOfDay.now();
      _endTime = _endFromStart(_startTime);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  TimeOfDay _endFromStart(TimeOfDay start) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = startMinutes + _sessionDuration.inMinutes;
    return TimeOfDay(hour: (endMinutes ~/ 60) % 24, minute: endMinutes % 60);
  }

  void _onSearchChanged() {
    context.read<PatientBloc>().add(
      PatientsRequested(query: _searchController.text.trim()),
    );
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _endTime = _endFromStart(picked);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _submit() {
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;
    final patientId = _selectedPatient?.id ?? existing?.patientId;
    if (patientId == null || patientId.isEmpty) {
      AppToast.showError(_toastContext, l10n.appointmentPatientRequired);
      return;
    }

    final startsAt = _combine(_selectedDate, _startTime);
    final endsAt = _combine(_selectedDate, _endTime);
    if (!endsAt.isAfter(startsAt)) {
      AppToast.showError(_toastContext, l10n.appointmentEndBeforeStart);
      return;
    }

    setState(() => _isSaving = true);
    context.read<AppointmentBloc>().add(
      AppointmentSaved(
        id: existing?.id ?? '',
        patientId: patientId,
        startsAt: startsAt,
        endsAt: endsAt,
        status: existing?.status ?? AppointmentStatus.scheduled,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  BuildContext get _toastContext => widget.toastContext ?? context;

  void _onAppointmentStateChanged(
    BuildContext context,
    AppointmentState state,
  ) {
    if (state is AppointmentFailure) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.showError(_toastContext, state.message);
    }
    if (state is AppointmentSaveSuccess) {
      AppToast.showSuccess(
        _toastContext,
        AppLocalizations.of(context).appointmentSaved,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;
    final dateLabel = DateFormat.yMMMEd().format(_selectedDate);

    return BlocListener<AppointmentBloc, AppointmentState>(
      listenWhen: (previous, current) =>
          current is AppointmentSaveSuccess || current is AppointmentFailure,
      listener: _onAppointmentStateChanged,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.lgBorder,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    isEdit
                        ? l10n.appointmentEditTitle
                        : l10n.appointmentCreateTitle,
                    variant: AppTextVariant.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: dateLabel,
                          style: AppButtonStyle.secondary,
                          onPressed: _pickDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: l10n.appointmentStartTime(
                            _startTime.format(context),
                          ),
                          style: AppButtonStyle.secondary,
                          onPressed: _pickStartTime,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: l10n.appointmentEndTime(
                            _endTime.format(context),
                          ),
                          style: AppButtonStyle.secondary,
                          onPressed: _pickEndTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isEdit && _selectedPatient == null)
                    AppText(
                      l10n.appointmentKeepPatientHint,
                      variant: AppTextVariant.caption,
                      color: context.secondaryTextColor,
                    ),
                  AppInput(
                    variant: AppInputVariant.text,
                    controller: _searchController,
                    label: l10n.patientSearchPlaceholder,
                    prefixIcon: Icons.search,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        final patients = state is PatientLoaded
                            ? state.patients
                            : <Patient>[];
                        if (state is PatientLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (patients.isEmpty) {
                          return Center(
                            child: AppText(
                              l10n.patientsEmpty,
                              variant: AppTextVariant.body,
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: patients.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final patient = patients[index];
                            final selected =
                                _selectedPatient?.id == patient.id ||
                                (widget.existing?.patientId == patient.id &&
                                    _selectedPatient == null);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: AppText(
                                patient.displayName,
                                variant: AppTextVariant.body,
                              ),
                              subtitle: AppText(
                                'MRN: ${patient.mrn}',
                                variant: AppTextVariant.caption,
                                color: context.secondaryTextColor,
                              ),
                              trailing: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdBorder,
                              ),
                              onTap: () =>
                                  setState(() => _selectedPatient = patient),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    controller: _notesController,
                    label: l10n.appointmentNotesLabel,
                    maxLines: 3,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: isEdit
                        ? l10n.appointmentSaveChanges
                        : l10n.appointmentCreateSubmit,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
