import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_pages.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

/// Multi-step PageView for identity + optional anamnèse.
///
/// Returns the patient id on success (create or update).
class NewPatientAnamneseCarousel extends StatefulWidget {
  const NewPatientAnamneseCarousel({
    super.key,
    this.initialPatient,
    this.onCancel,
  });

  final Patient? initialPatient;
  final VoidCallback? onCancel;

  @override
  State<NewPatientAnamneseCarousel> createState() =>
      _NewPatientAnamneseCarouselState();
}

class _NewPatientAnamneseCarouselState
    extends State<NewPatientAnamneseCarousel> {
  late final PageController _pageController;
  late final AnamneseFormData _data;
  int _pageIndex = 0;
  bool _submitting = false;

  bool get _isEdit => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _data = widget.initialPatient != null
        ? AnamneseFormData.fromPatient(widget.initialPatient!)
        : AnamneseFormData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    if (index < 0 || index >= kAnamnesePageCount) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _pageIndex = index);
  }

  bool _validateIdentity() {
    if (_data.identityValid) return true;
    AppToast.showError(
      context,
      AppLocalizations.of(context).anamneseIdentityRequired,
    );
    return false;
  }

  Future<void> _onNext() async {
    if (_pageIndex == 0 && !_validateIdentity()) return;
    if (_pageIndex >= kAnamnesePageCount - 1) {
      await _submit();
      return;
    }
    await _goTo(_pageIndex + 1);
  }

  Future<void> _onSkip() async {
    if (_pageIndex == 0 && !_validateIdentity()) return;
    await _submit();
  }

  Future<void> _onBack() async {
    if (_pageIndex == 0) {
      if (widget.onCancel != null) {
        widget.onCancel!();
      } else {
        Navigator.of(context).pop();
      }
      return;
    }
    await _goTo(_pageIndex - 1);
  }

  Future<void> _submit() async {
    if (!_validateIdentity()) return;
    if (_submitting) return;
    setState(() => _submitting = true);

    final bloc = context.read<PatientBloc>();
    final metadata = _data.buildMetadata(
      base: widget.initialPatient?.metadata,
    );

    if (_isEdit) {
      final patient = widget.initialPatient!;
      bloc.add(
        PatientUpdated(
          id: patient.id,
          mrn: patient.mrn,
          firstName: _data.firstName.trim(),
          lastName: _data.lastName.trim(),
          birthDate: _data.birthDate,
          sex: _data.sex,
          email: patient.contact?.email,
          phone: patient.contact?.phone,
          address: _data.address.trim().isEmpty ? null : _data.address.trim(),
          notes: patient.notes,
          metadata: metadata,
        ),
      );
    } else {
      bloc.add(
        PatientCreated(
          mrn: AnamneseFormData.generateMrn(),
          firstName: _data.firstName.trim(),
          lastName: _data.lastName.trim(),
          birthDate: _data.birthDate,
          sex: _data.sex,
          address: _data.address.trim().isEmpty ? null : _data.address.trim(),
          metadata: metadata,
        ),
      );
    }
  }

  void _onPatientState(PatientState state) {
    final l10n = AppLocalizations.of(context);
    if (state is PatientCreateSuccess) {
      AppToast.showSuccess(context, l10n.patientCreateSuccess);
      Navigator.of(context).pop(state.patientId);
    } else if (state is PatientUpdateSuccess) {
      AppToast.showSuccess(context, l10n.anamneseSaveSuccess);
      Navigator.of(context).pop(state.patientId);
    } else if (state is PatientFailure) {
      setState(() => _submitting = false);
      AppToast.showError(context, state.message);
    } else if (state is PatientMrnConflict) {
      setState(() => _submitting = false);
      AppToast.showError(context, l10n.patientMrnConflict);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _pageIndex >= kAnamnesePageCount - 1;
    final canSkipAnamnese = _pageIndex > 0 || _data.identityValid;

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) => _onPatientState(state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _isEdit
                            ? l10n.anamneseCarouselEditTitle
                            : l10n.anamneseCarouselTitle,
                        variant: AppTextVariant.title,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        l10n.anamnesePageIndicator(
                          _pageIndex + 1,
                          kAnamnesePageCount,
                        ),
                        variant: AppTextVariant.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _submitting
                      ? null
                      : () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: (_pageIndex + 1) / kAnamnesePageCount,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _pageIndex = index),
              children: [
                AnamneseIdentityPage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseNaissanceEnfancePage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseVieFamilialePage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseStylesDeViePage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseActivitesPhysioPage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseActiviteProPage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamnesePersonnalitePage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseAntecedentsPage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
                AnamneseTraumatismesPage(
                  data: _data,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: _submitting ? null : _onBack,
                      style: AppButtonStyle.secondary,
                      label: _pageIndex == 0 && widget.onCancel != null
                          ? l10n.buttonCancel
                          : l10n.anamneseBack,
                      enabled: !_submitting,
                      expanded: true,
                    ),
                  ),
                  if (canSkipAnamnese && !isLast) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        onPressed: _submitting ? null : _onSkip,
                        style: AppButtonStyle.tertiary,
                        label: l10n.anamneseSkip,
                        enabled: !_submitting,
                        expanded: true,
                      ),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      onPressed: _submitting ? null : _onNext,
                      label: isLast ? l10n.anamneseFinish : l10n.anamneseNext,
                      isLoading: _submitting,
                      enabled: !_submitting,
                      expanded: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the anamnèse carousel fullscreen for create or edit.
Future<String?> showAnamneseCarousel(
  BuildContext context, {
  Patient? initialPatient,
}) {
  return showDialog<String>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dialogContext) {
      PatientBloc? existingBloc;
      try {
        existingBloc = context.read<PatientBloc>();
      } catch (_) {}

      final child = Dialog.fullscreen(
        child: SafeArea(
          child: NewPatientAnamneseCarousel(
            initialPatient: initialPatient,
          ),
        ),
      );

      if (existingBloc != null) {
        return BlocProvider.value(value: existingBloc, child: child);
      }
      return BlocProvider(
        create: (_) => getIt<PatientBloc>(),
        child: child,
      );
    },
  );
}
