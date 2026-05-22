import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class PatientCreationSheet extends StatefulWidget {
  const PatientCreationSheet({super.key, this.onSuccess});

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
  String? _selectedSex;
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _mrnController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final mrn = _mrnController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (mrn.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      AppToast.showError(context, AppLocalizations.of(context).patientCreateErrorRequired);
      return;
    }

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

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientCreateSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!(state.patientId);
          } else {
            Navigator.of(context).pop();
          }
          AppToast.showSuccess(context, l10n.patientCreateSuccess);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(l10n.patientCreateTitle, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.lg),
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.patientMrnLabel,
                controller: _mrnController,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      variant: AppInputVariant.text,
                      label: l10n.patientFirstNameRequiredLabel,
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppInput(
                      variant: AppInputVariant.text,
                      label: l10n.patientLastNameRequiredLabel,
                      controller: _lastNameController,
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
                            DropdownMenuItem(value: 'M', child: Text(l10n.patientSexMale)),
                            DropdownMenuItem(value: 'F', child: Text(l10n.patientSexFemale)),
                            DropdownMenuItem(value: 'Other', child: Text(l10n.patientSexOther)),
                          ],
                          onChanged: (val) => setState(() => _selectedSex = val),
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
                  return AppButton(
                    label: l10n.patientCreateSubmit,
                    isLoading: state is PatientLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
