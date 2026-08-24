import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/appointment/presentation/appointment_bloc.dart';
import 'package:medicail/features/appointment/presentation/appointment_change_notifier.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/appointment_form_sheet.dart';
import 'package:medicail/widget/appointment_list_row.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

import 'package:medicail/widget/home/home_greeting_header.dart';
import 'package:medicail/widget/home/home_recent_session_tile.dart';
import 'package:medicail/widget/layout/app_empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AppointmentBloc>()..add(const AppointmentsUpcomingRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  List<AppointmentListItem> _lastItems = const [];
  List<RecordingSession> _recentSessions = const [];
  bool _sessionsLoading = true;

  @override
  void initState() {
    super.initState();
    appointmentChangeNotifier.addListener(_onAppointmentsChanged);
    _loadRecentSessions();
  }

  @override
  void dispose() {
    appointmentChangeNotifier.removeListener(_onAppointmentsChanged);
    super.dispose();
  }

  void _onAppointmentsChanged() {
    if (!mounted) return;
    context.read<AppointmentBloc>().add(
      const AppointmentsUpcomingRequested(showLoading: false),
    );
  }

  Future<void> _loadRecentSessions() async {
    try {
      // Use local repository to always get recent sessions even if API doesn't support global listing
      final repo = getIt<SecureStorageRecordingSessionRepository>();
      final all = await repo.getAll();
      final completed = all
          .where((s) => s.status == RecordingSessionStatus.completed)
          .take(5)
          .toList();
      if (mounted) {
        setState(() {
          _recentSessions = completed;
          _sessionsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sessionsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is AppointmentDayLoaded) {
          _lastItems = state.items;
        }
        final items = state is AppointmentDayLoaded ? state.items : _lastItems;
        final isLoading = state is AppointmentLoading && _lastItems.isEmpty;
        final preview = items.take(5).toList();

        return AppScaffold(
          title: l10n.homeTitle,
          body: ListView(
            padding: MainShellScope.scrollPaddingOf(context),
            children: [
              // ── Greeting Section ──
              const HomeGreetingHeader(),
              const SizedBox(height: AppSpacing.xl),

              // ── Upcoming Appointments ──
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      l10n.appointmentsUpcomingTitle,
                      variant: AppTextVariant.title,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.goAppointments(),
                    child: AppText(
                      l10n.appointmentsSeeAll,
                      variant: AppTextVariant.label,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (preview.isEmpty)
                AppEmptyState(
                  icon: Icons.event_outlined,
                  message: l10n.appointmentsUpcomingEmpty,
                  actionLabel: l10n.appointmentCreateTitle,
                  onAction: () => AppointmentFormSheet.show(
                    context,
                    initialDay: DateTime.now(),
                  ),
                )
              else
                ...preview.map(
                  (item) => Column(
                    children: [
                      AppointmentListRow(
                        item: item,
                        onTap: () => context.goPatientDetail(
                          item.appointment.patientId,
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Recent Consultations ──
              AppText(
                l10n.homeRecentConsultationsTitle,
                variant: AppTextVariant.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_sessionsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_recentSessions.isEmpty)
                AppEmptyState(
                  icon: Icons.mic_none_outlined,
                  message: l10n.homeRecentConsultationsEmpty,
                  actionLabel: l10n.homeQuickRecord,
                  onAction: () => context.goRecord(),
                )
              else
                ..._recentSessions.map(
                  (session) => HomeRecentSessionTile(session: session),
                ),
            ],
          ),
        );
      },
    );
  }
}
