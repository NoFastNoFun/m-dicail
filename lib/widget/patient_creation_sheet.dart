import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/contact.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:showcaseview/showcaseview.dart';

class PatientCreationSheet extends StatefulWidget {
  const PatientCreationSheet({super.key, this.initialPatient, this.onSuccess});

  final Patient? initialPatient;
  final void Function(String patientId)? onSuccess;

  @override
  State<PatientCreationSheet> createState() => _PatientCreationSheetState();
}

class _PatientCreationSheetState extends State<PatientCreationSheet> {
  final _mrnController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _mrnFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final GlobalKey _mrnKey = GlobalKey();
  final GlobalKey _firstNameKey = GlobalKey();
  final GlobalKey _lastNameKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();
  String? _selectedSex;
  DateTime? _selectedBirthDate;
  final Set<TutorialStepId> _startedTutorialSteps = <TutorialStepId>{};
  final Map<TutorialStepId, Timer> _fieldCompletionTimers = {};

  static const _patientFormSteps = {
    TutorialStepId.patientMrn,
    TutorialStepId.patientFirstName,
    TutorialStepId.patientLastName,
    TutorialStepId.patientCreate,
  };
  static const _fieldCompletionDelay = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;
    if (patient != null) {
      _mrnController.text = patient.mrn;
      _firstNameController.text = patient.firstName;
      _lastNameController.text = patient.lastName;
      _emailController.text = patient.contact?.email ?? '';
      _phoneController.text = patient.contact?.phone ?? '';
      _addressController.text = patient.contact?.address ?? '';
      _notesController.text = patient.notes ?? '';
      _selectedSex = patient.sex;
      _selectedBirthDate = patient.birthDate;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  @override
  void dispose() {
    for (final timer in _fieldCompletionTimers.values) {
      timer.cancel();
    }
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
    if (!_startedTutorialSteps.add(stepId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.get().startShowCase([_showcaseKeyForStep(stepId)]);
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

  void _completeTutorialStepAfterTyping(TutorialStepId stepId, String value) {
    _fieldCompletionTimers.remove(stepId)?.cancel();
    if (value.trim().isEmpty) return;
    _fieldCompletionTimers[stepId] = Timer(_fieldCompletionDelay, () {
      if (!mounted) return;
      final tutorialBloc = context.read<TutorialBloc>();
      if (!tutorialBloc.isCurrentStep(stepId)) return;
      tutorialBloc.completeStep(stepId);
    });
  }

  void _completeSubmitTutorialStep() {
    final tutorialBloc = context.read<TutorialBloc>();
    tutorialBloc.completeStep(TutorialStepId.patientCreate);
  }

  void _submit() {
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

    context.read<PatientBloc>().add(
      widget.initialPatient == null
          ? PatientCreated(
              mrn: mrn,
              firstName: firstName,
              lastName: lastName,
              birthDate: _selectedBirthDate,
              sex: _selectedSex,
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              notes: _notesController.text.trim(),
            )
          : PatientUpdated(
              widget.initialPatient!.copyWith(
                mrn: mrn,
                firstName: firstName,
                lastName: lastName,
                birthDate: _selectedBirthDate,
                sex: _selectedSex,
                contact: Contact(
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                  address: _addressController.text.trim(),
                ),
                notes: _notesController.text.trim(),
                updatedAt: DateTime.now(),
                clearBirthDate: _selectedBirthDate == null,
                clearSex: _selectedSex == null,
              ),
            ),
    );
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
    final isEditing = widget.initialPatient != null;

    return BlocListener<TutorialBloc, TutorialState>(
      listener: (context, state) => _handleTutorialState(state),
      child: BlocListener<PatientBloc, PatientState>(
        listenWhen: (previous, current) =>
            current is PatientCreateSuccess || current is PatientUpdateSuccess,
        listener: (context, state) {
          if (state is PatientCreateSuccess || state is PatientUpdateSuccess) {
            AppToast.showSuccess(
              context,
              isEditing
                  ? 'Dossier patient mis a jour avec succes.'
                  : l10n.patientCreateSuccess,
            );
            final patientId = state is PatientCreateSuccess
                ? state.patientId
                : (state as PatientUpdateSuccess).patientId;
            if (widget.onSuccess != null) {
              widget.onSuccess!(patientId);
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  isEditing ? 'Modifier le patient' : l10n.patientCreateTitle,
                  variant: AppTextVariant.title,
                ),
                const SizedBox(height: AppSpacing.lg),
                Showcase(
                  key: _mrnKey,
                  title: l10n.tutorialPatientMrnTitle,
                  description: l10n.tutorialPatientMrnDesc,
                  disposeOnTap: true,
                  onTargetClick: _mrnFocusNode.requestFocus,
                  child: AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.patientMrnLabel,
                    controller: _mrnController,
                    focusNode: _mrnFocusNode,
                    onChanged: (value) => _completeTutorialStepAfterTyping(
                      TutorialStepId.patientMrn,
                      value,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Showcase(
                        key: _firstNameKey,
                        title: l10n.tutorialPatientFirstNameTitle,
                        description: l10n.tutorialPatientFirstNameDesc,
                        disposeOnTap: true,
                        onTargetClick: _firstNameFocusNode.requestFocus,
                        child: AppInput(
                          variant: AppInputVariant.text,
                          label: l10n.patientFirstNameRequiredLabel,
                          controller: _firstNameController,
                          focusNode: _firstNameFocusNode,
                          onChanged: (value) =>
                              _completeTutorialStepAfterTyping(
                                TutorialStepId.patientFirstName,
                                value,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Showcase(
                        key: _lastNameKey,
                        title: l10n.tutorialPatientLastNameTitle,
                        description: l10n.tutorialPatientLastNameDesc,
                        disposeOnTap: true,
                        onTargetClick: _lastNameFocusNode.requestFocus,
                        child: AppInput(
                          variant: AppInputVariant.text,
                          label: l10n.patientLastNameRequiredLabel,
                          controller: _lastNameController,
                          focusNode: _lastNameFocusNode,
                          onChanged: (value) =>
                              _completeTutorialStepAfterTyping(
                                TutorialStepId.patientLastName,
                                value,
                              ),
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
                              borderRadius: AppRadius.mdBorder,
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
                            borderRadius: AppRadius.mdBorder,
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
                    return Showcase(
                      key: _submitKey,
                      title: l10n.tutorialPatientCreateTitle,
                      description: l10n.tutorialPatientCreateDesc,
                      disposeOnTap: true,
                      onTargetClick: () {
                        _completeSubmitTutorialStep();
                        _submit();
                      },
                      child: AppButton(
                        label: isEditing
                            ? 'Enregistrer les modifications'
                            : l10n.patientCreateSubmit,
                        isLoading: state is PatientLoading,
                        onPressed: () {
                          _completeSubmitTutorialStep();
                          _submit();
                        },
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
    );
  }
}
