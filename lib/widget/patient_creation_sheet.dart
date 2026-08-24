import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';

class PatientCreationSheet extends StatefulWidget {
  const PatientCreationSheet({super.key, this.onSuccess, this.initialPatient});

  final void Function(String patientId)? onSuccess;
  final Patient? initialPatient;

  static Future<void> show(
    BuildContext context, {
    void Function(String patientId)? onSuccess,
    Patient? initialPatient,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (sheetContext) {
        PatientBloc? existingBloc;
        try {
          existingBloc = context.read<PatientBloc>();
        } catch (_) {}

        final child = Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: PatientCreationSheet(
            initialPatient: initialPatient,
            onSuccess: onSuccess == null
                ? null
                : (patientId) {
                    context.pop();
                    onSuccess(patientId);
                  },
          ),
        );

        if (existingBloc != null) {
          return BlocProvider.value(
            value: existingBloc,
            child: child,
          );
        } else {
          return BlocProvider<PatientBloc>(
            create: (_) => getIt<PatientBloc>(),
            child: child,
          );
        }
      },
    );
  }

  @override
  State<PatientCreationSheet> createState() => _PatientCreationSheetState();
}

class _PatientCreationSheetState extends State<PatientCreationSheet> {
  late final TextEditingController _mrnController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  String? _selectedSex;
  DateTime? _selectedBirthDate;

  final _mrnFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final GlobalKey _mrnKey = GlobalKey();
  final GlobalKey _firstNameKey = GlobalKey();
  final GlobalKey _lastNameKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();
  final Set<TutorialStepId> _startedTutorialSteps = <TutorialStepId>{};

  static const _patientFormSteps = {
    TutorialStepId.patientMrn,
    TutorialStepId.patientFirstName,
    TutorialStepId.patientLastName,
    TutorialStepId.patientCreate,
  };

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;
    _mrnController = TextEditingController(text: patient?.mrn);
    _firstNameController = TextEditingController(text: patient?.firstName);
    _lastNameController = TextEditingController(text: patient?.lastName);
    _emailController = TextEditingController(text: patient?.contact?.email);
    _phoneController = TextEditingController(text: patient?.contact?.phone);
    _addressController = TextEditingController(text: patient?.contact?.address);
    _notesController = TextEditingController(text: patient?.notes);
    _selectedSex = patient?.sex;
    _selectedBirthDate = patient?.birthDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  @override
  void dispose() {
    _mrnController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _mrnFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  void _handleTutorialState(TutorialState state) {
    final stepId = state.tutorialStepId;
    if (stepId == null || !_patientFormSteps.contains(stepId)) return;
    if (_startedTutorialSteps.contains(stepId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final started = await TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _showcaseKeyForStep(stepId),
      );
      if (started && mounted) {
        _startedTutorialSteps.add(stepId);
      }
    });
  }

  GlobalKey _showcaseKeyForStep(TutorialStepId stepId) {
    return switch (stepId) {
      TutorialStepId.patientMrn => _mrnKey,
      TutorialStepId.patientFirstName => _firstNameKey,
      TutorialStepId.patientLastName => _lastNameKey,
      _ => _submitKey,
    };
  }

  void _completeTutorialFieldStep(TutorialStepId stepId) {
    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.isCurrentStep(stepId)) return;
    ShowcaseView.get().dismiss();
    tutorialBloc.completeStep(stepId);
  }

  void _handleTutorialCreateSubmit() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.isCurrentStep(TutorialStepId.patientCreate)) {
      _submit();
      return;
    }
    ShowcaseView.get().dismiss();
    tutorialBloc.completeStep(TutorialStepId.patientCreate);
    Navigator.of(context).pop();
    context.go('/patients/${TutorialFlow.demoPatientId}');
  }

  void _submit() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.state is TutorialInProgress) {
      return;
    }

    final mrn = _mrnController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (mrn.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      AppToast.showError(
        context,
        AppLocalizations.of(context).patientCreateErrorRequired,
      );
      return;
    }

    if (widget.initialPatient != null) {
      context.read<PatientBloc>().add(
        PatientUpdated(
          id: widget.initialPatient!.id,
          mrn: mrn,
          firstName: firstName,
          lastName: lastName,
          birthDate: _selectedBirthDate,
          sex: _selectedSex,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      context.read<PatientBloc>().add(
        PatientCreated(
          mrn: mrn,
          firstName: firstName,
          lastName: lastName,
          birthDate: _selectedBirthDate,
          sex: _selectedSex,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTutorial =
        context.watch<TutorialBloc>().state is TutorialInProgress;
    final sheetBorderRadius =
        isTutorial ? AppRadius.onboardingLgBorder : AppRadius.lgBorder;
    final fieldBorderRadius =
        isTutorial ? AppRadius.onboardingMdBorder : AppRadius.mdBorder;

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientCreateSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!(state.patientId);
          } else {
            Navigator.of(context).pop();
          }
          AppToast.showSuccess(context, l10n.patientCreateSuccess);
        } else if (state is PatientUpdateSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!(state.patientId);
          } else {
            Navigator.of(context).pop();
          }
          AppToast.showSuccess(context, 'Patient modifié avec succès');
        }
      },
      child: BlocListener<TutorialBloc, TutorialState>(
        listener: (context, state) => _handleTutorialState(state),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: sheetBorderRadius,
          ),
          padding: const EdgeInsets.only(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    widget.initialPatient != null 
                        ? 'Modifier le patient' 
                        : l10n.patientCreateTitle,
                    variant: AppTextVariant.title,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppShowcase(
                    key: _mrnKey,
                    title: l10n.tutorialPatientMrnTitle,
                    description: l10n.tutorialPatientMrnDesc,
                    disposeOnTap: false,
                    disableBarrierInteraction: true,
                    onTargetClick: () =>
                        _completeTutorialFieldStep(TutorialStepId.patientMrn),
                    child: AppInput(
                      variant: AppInputVariant.text,
                      label: l10n.patientMrnLabel,
                      controller: _mrnController,
                      focusNode: _mrnFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _firstNameFocusNode.requestFocus(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppShowcase(
                          key: _firstNameKey,
                          title: l10n.tutorialPatientFirstNameTitle,
                          description: l10n.tutorialPatientFirstNameDesc,
                          disposeOnTap: false,
                          disableBarrierInteraction: true,
                          onTargetClick: () => _completeTutorialFieldStep(
                            TutorialStepId.patientFirstName,
                          ),
                          child: AppInput(
                            variant: AppInputVariant.text,
                            label: l10n.patientFirstNameRequiredLabel,
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _lastNameFocusNode.requestFocus(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppShowcase(
                          key: _lastNameKey,
                          title: l10n.tutorialPatientLastNameTitle,
                          description: l10n.tutorialPatientLastNameDesc,
                          disposeOnTap: false,
                          disableBarrierInteraction: true,
                          onTargetClick: () => _completeTutorialFieldStep(
                            TutorialStepId.patientLastName,
                          ),
                          child: AppInput(
                            variant: AppInputVariant.text,
                            label: l10n.patientLastNameRequiredLabel,
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.patientBirthDateLabel,
                              border: OutlineInputBorder(
                                borderRadius: fieldBorderRadius,
                              ),
                            ),
                            child: Text(
                              _selectedBirthDate != null
                                  ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                  : l10n.patientBirthDateSelect,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.patientSexLabel,
                            border: OutlineInputBorder(
                              borderRadius: fieldBorderRadius,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSex,
                              isDense: true,
                              items: [
                                DropdownMenuItem(
                                  value: 'M',
                                  child: Text(l10n.patientSexMale),
                                ),
                                DropdownMenuItem(
                                  value: 'F',
                                  child: Text(l10n.patientSexFemale),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text(l10n.patientSexOther),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedSex = val),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    variant: AppInputVariant.email,
                    label: l10n.patientEmailLabel,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.patientPhoneLabel,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.patientAddressLabel,
                    controller: _addressController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.patientNotesLabel,
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, state) {
                      return AppShowcase(
                        key: _submitKey,
                        title: l10n.tutorialPatientCreateTitle,
                        description: l10n.tutorialPatientCreateDesc,
                        disposeOnTap: false,
                        disableBarrierInteraction: true,
                        onTargetClick: _handleTutorialCreateSubmit,
                        child: AppButton(
                          label: widget.initialPatient != null
                              ? 'Enregistrer'
                              : l10n.patientCreateSubmit,
                          isLoading: state is PatientLoading,
                          onPressed: _handleTutorialCreateSubmit,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
