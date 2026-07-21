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
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/appointment_form_sheet.dart';
import 'package:medicail/widget/appointment_list_row.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

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

  @override
  void initState() {
    super.initState();
    appointmentChangeNotifier.addListener(_onAppointmentsChanged);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      variant: AppTextVariant.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.appointmentCreateTitle,
                style: AppButtonStyle.secondary,
                onPressed: () => AppointmentFormSheet.show(
                  context,
                  initialDay: DateTime.now(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : preview.isEmpty
                    ? Center(
                        child: AppText(
                          l10n.appointmentsUpcomingEmpty,
                          variant: AppTextVariant.body,
                        ),
                      )
                    : ListView.separated(
                        padding: MainShellScope.scrollPaddingOf(context),
                        itemCount: preview.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = preview[index];
                          return AppointmentListRow(
                            item: item,
                            onTap: () => context.goPatientDetail(
                              item.appointment.patientId,
                            ),
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
