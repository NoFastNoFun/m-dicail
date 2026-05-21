import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'dart:async';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
      child: const _PatientsView(),
    );
  }
}

class _PatientsView extends StatefulWidget {
  const _PatientsView();

  @override
  State<_PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<_PatientsView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<PatientBloc>()
          .add(PatientsRequested(query: _searchController.text.trim()));
    });
  }

  void _showCreatePatientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PatientBloc>(),
          child: const _PatientCreationSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final patients = state is PatientLoaded ? state.patients : <Patient>[];
        final isLoading = state is PatientLoading;

        return AppScaffold(
          title: l10n.patientsTitle,
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.textPrimary),
              onPressed: () => _showCreatePatientSheet(context),
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                variant: AppInputVariant.text,
                label: 'Rechercher un patient',
                controller: _searchController,
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppText(l10n.patientsSectionTitle, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: isLoading && patients.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : patients.isEmpty
                        ? Center(
                            child: AppText(
                              l10n.patientsEmpty,
                              variant: AppTextVariant.body,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : ListView.separated(
                            itemCount: patients.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              return _PatientListItem(patient: patients[index]);
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

class _PatientListItem extends StatelessWidget {
  const _PatientListItem({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
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
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppText(
                    'MRN: ${patient.mrn}',
                    variant: AppTextVariant.caption,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.patientOpenButton,
              style: AppButtonStyle.secondary,
              onPressed: () => context.goPatientDetail(patient.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCreationSheet extends StatefulWidget {
  const _PatientCreationSheet();

  @override
  State<_PatientCreationSheet> createState() => _PatientCreationSheetState();
}

class _PatientCreationSheetState extends State<_PatientCreationSheet> {
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
      AppToast.showError(context, 'MRN, Prénom et Nom sont requis.');
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
    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientLoaded) {
          Navigator.of(context).pop();
          AppToast.showSuccess(context, 'Dossier patient créé avec succès.');
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
              const AppText('Nouveau Patient', variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.lg),
              AppInput(
                variant: AppInputVariant.text,
                label: 'MRN (Numéro de dossier) *',
                controller: _mrnController,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      variant: AppInputVariant.text,
                      label: 'Prénom *',
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppInput(
                      variant: AppInputVariant.text,
                      label: 'Nom *',
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
                          labelText: 'Date de naissance',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                        child: Text(
                          _selectedBirthDate != null
                              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                              : 'Sélectionner',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sexe',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSex,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Homme')),
                            DropdownMenuItem(value: 'F', child: Text('Femme')),
                            DropdownMenuItem(value: 'Other', child: Text('Autre')),
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
                label: 'Email',
                controller: _emailController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                variant: AppInputVariant.text,
                label: 'Téléphone',
                controller: _phoneController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                variant: AppInputVariant.text,
                label: 'Adresse',
                controller: _addressController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                variant: AppInputVariant.text,
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Créer le dossier',
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
