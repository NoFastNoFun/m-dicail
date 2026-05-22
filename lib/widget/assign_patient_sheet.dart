import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';

class AssignPatientSheet extends StatelessWidget {
  const AssignPatientSheet({super.key, required this.sessionId});

  final String sessionId;

  static void show(BuildContext context, String sessionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
          child: AssignPatientSheet(sessionId: sessionId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: AppSpacing.lg,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppText(
                l10n.assignPatientTitle,
                variant: AppTextVariant.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: l10n.assignPatientSearchTab),
                Tab(text: l10n.assignPatientNewTab),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PatientSearchTab(sessionId: sessionId),
                  PatientCreationSheet(
                    onSuccess: (patientId) => _assignAndNavigate(context, sessionId, patientId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _assignAndNavigate(BuildContext context, String sessionId, String patientId) async {
    try {
      final repo = getIt<RecordingSessionRepository>();
      final session = await repo.getById(sessionId);
      if (session != null) {
        await repo.save(session.copyWith(patientId: patientId));
      }
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer la modale
        if (context.canPop()) {
          context.pop(); // Fermer la page de record si besoin
        }
        context.goPatientDetail(patientId);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, "Erreur lors de l'association");
      }
    }
  }
}

class _PatientSearchTab extends StatefulWidget {
  const _PatientSearchTab({required this.sessionId});

  final String sessionId;

  @override
  State<_PatientSearchTab> createState() => _PatientSearchTabState();
}

class _PatientSearchTabState extends State<_PatientSearchTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context
        .read<PatientBloc>()
        .add(PatientsRequested(query: _searchController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.patientSearchPlaceholder,
            controller: _searchController,
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                final patients = state is PatientLoaded ? state.patients : <Patient>[];
                final isLoading = state is PatientLoading;

                if (isLoading && patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (patients.isEmpty) {
                  return Center(
                    child: AppText(
                      l10n.patientsEmpty,
                      variant: AppTextVariant.body,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: patients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return InkWell(
                      onTap: () => AssignPatientSheet._assignAndNavigate(
                        context,
                        widget.sessionId,
                        patient.id,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppText(patient.displayName, variant: AppTextVariant.title),
                              const SizedBox(height: AppSpacing.xs),
                              AppText(
                                'MRN: ${patient.mrn}',
                                variant: AppTextVariant.caption,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
