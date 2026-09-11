import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_pages.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

enum _AnamnesePhase { identity, hub, chapter }

enum AnamneseChapter {
  antecedents,
  traumatismes,
  activitePro,
  stylesDeVie,
  activitesPhysio,
  vieFamiliale,
  personnalite,
  naissanceEnfance,
}

extension on AnamneseChapter {
  bool isFilled(Anamnese a) {
    switch (this) {
      case AnamneseChapter.antecedents:
        return !a.antecedentsChroniques.isEmpty;
      case AnamneseChapter.traumatismes:
        return !a.traumatismesChirurgieInfections.isEmpty;
      case AnamneseChapter.activitePro:
        return !a.activiteProfessionnelle.isEmpty;
      case AnamneseChapter.stylesDeVie:
        return !a.stylesDeVie.isEmpty;
      case AnamneseChapter.activitesPhysio:
        return !a.activitesPhysiologiques.isEmpty;
      case AnamneseChapter.vieFamiliale:
        return !a.vieFamilialeSexuelle.isEmpty;
      case AnamneseChapter.personnalite:
        return !a.personnalite.isEmpty;
      case AnamneseChapter.naissanceEnfance:
        return !a.naissanceEnfance.isEmpty;
    }
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case AnamneseChapter.antecedents:
        return l10n.anamneseAntecedentsTitle;
      case AnamneseChapter.traumatismes:
        return l10n.anamneseTraumatismesTitle;
      case AnamneseChapter.activitePro:
        return l10n.anamneseActiviteProTitle;
      case AnamneseChapter.stylesDeVie:
        return l10n.anamneseStylesDeVieTitle;
      case AnamneseChapter.activitesPhysio:
        return l10n.anamneseActivitesPhysioTitle;
      case AnamneseChapter.vieFamiliale:
        return l10n.anamneseVieFamilialeTitle;
      case AnamneseChapter.personnalite:
        return l10n.anamnesePersonnaliteTitle;
      case AnamneseChapter.naissanceEnfance:
        return l10n.anamneseNaissanceEnfanceTitle;
    }
  }
}

/// Identity first, then a hub of optional anamnèse chapters.
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
  late final AnamneseFormData _data;
  _AnamnesePhase _phase = _AnamnesePhase.identity;
  AnamneseChapter? _chapter;
  bool _submitting = false;

  bool get _isEdit => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();
    _data = widget.initialPatient != null
        ? AnamneseFormData.fromPatient(widget.initialPatient!)
        : AnamneseFormData();
    if (_isEdit) {
      _phase = _AnamnesePhase.hub;
    }
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _validateIdentity() {
    if (_data.identityValid) return true;
    AppToast.showError(
      context,
      AppLocalizations.of(context).anamneseIdentityRequired,
    );
    return false;
  }

  void _goHub() {
    if (!_validateIdentity()) return;
    setState(() {
      _phase = _AnamnesePhase.hub;
      _chapter = null;
    });
  }

  void _openChapter(AnamneseChapter chapter) {
    setState(() {
      _phase = _AnamnesePhase.chapter;
      _chapter = chapter;
    });
  }

  void _back() {
    switch (_phase) {
      case _AnamnesePhase.identity:
        _cancel();
      case _AnamnesePhase.hub:
        setState(() => _phase = _AnamnesePhase.identity);
      case _AnamnesePhase.chapter:
        setState(() {
          _phase = _AnamnesePhase.hub;
          _chapter = null;
        });
    }
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

  Widget _chapterPage(AnamneseChapter chapter) {
    final onChanged = () => setState(() {});
    switch (chapter) {
      case AnamneseChapter.antecedents:
        return AnamneseAntecedentsPage(data: _data, onChanged: onChanged);
      case AnamneseChapter.traumatismes:
        return AnamneseTraumatismesPage(data: _data, onChanged: onChanged);
      case AnamneseChapter.activitePro:
        return AnamneseActiviteProPage(data: _data, onChanged: onChanged);
      case AnamneseChapter.stylesDeVie:
        return AnamneseStylesDeViePage(data: _data, onChanged: onChanged);
      case AnamneseChapter.activitesPhysio:
        return AnamneseActivitesPhysioPage(data: _data, onChanged: onChanged);
      case AnamneseChapter.vieFamiliale:
        return AnamneseVieFamilialePage(data: _data, onChanged: onChanged);
      case AnamneseChapter.personnalite:
        return AnamnesePersonnalitePage(data: _data, onChanged: onChanged);
      case AnamneseChapter.naissanceEnfance:
        return AnamneseNaissanceEnfancePage(data: _data, onChanged: onChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colorScheme;

    final title = switch (_phase) {
      _AnamnesePhase.identity =>
        _isEdit ? l10n.anamneseCarouselEditTitle : l10n.anamneseCarouselTitle,
      _AnamnesePhase.hub => l10n.anamneseHubTitle,
      _AnamnesePhase.chapter => _chapter!.title(l10n),
    };

    final backLabel = switch (_phase) {
      _AnamnesePhase.identity => widget.onCancel != null
          ? l10n.buttonCancel
          : l10n.anamneseBack,
      _AnamnesePhase.hub => l10n.anamneseBack,
      _AnamnesePhase.chapter => l10n.anamneseBackToHub,
    };

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
                  child: AppText(title, variant: AppTextVariant.title),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _submitting ? null : _cancel,
                ),
              ],
            ),
          ),
          Expanded(child: _body(l10n, colors)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: _submitting ? null : _back,
                      style: AppButtonStyle.secondary,
                      label: backLabel,
                      enabled: !_submitting,
                      expanded: true,
                    ),
                  ),
                  if (_phase == _AnamnesePhase.identity) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        onPressed: _submitting ? null : _submit,
                        style: AppButtonStyle.tertiary,
                        label: l10n.anamneseFinish,
                        enabled: !_submitting && _data.identityValid,
                        expanded: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        onPressed: _submitting ? null : _goHub,
                        label: l10n.anamneseNext,
                        enabled: !_submitting,
                        expanded: true,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        onPressed: _submitting ? null : _submit,
                        label: l10n.anamneseFinish,
                        isLoading: _submitting,
                        enabled: !_submitting,
                        expanded: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n, ColorScheme colors) {
    switch (_phase) {
      case _AnamnesePhase.identity:
        return AnamneseIdentityPage(
          data: _data,
          onChanged: () => setState(() {}),
        );
      case _AnamnesePhase.hub:
        return _Hub(
          l10n: l10n,
          colors: colors,
          data: _data,
          onOpen: _openChapter,
        );
      case _AnamnesePhase.chapter:
        return _chapterPage(_chapter!);
    }
  }
}

class _Hub extends StatelessWidget {
  const _Hub({
    required this.l10n,
    required this.colors,
    required this.data,
    required this.onOpen,
  });

  final AppLocalizations l10n;
  final ColorScheme colors;
  final AnamneseFormData data;
  final ValueChanged<AnamneseChapter> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        AppText(l10n.anamneseHubSubtitle, variant: AppTextVariant.body),
        const SizedBox(height: AppSpacing.lg),
        for (final chapter in AnamneseChapter.values) ...[
          _ChapterTile(
            title: chapter.title(l10n),
            filled: chapter.isFilled(data.anamnese),
            filledLabel: l10n.anamneseChapterFilled,
            emptyLabel: l10n.anamneseChapterEmpty,
            onTap: () => onOpen(chapter),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.title,
    required this.filled,
    required this.filledLabel,
    required this.emptyLabel,
    required this.onTap,
  });

  final String title;
  final bool filled;
  final String filledLabel;
  final String emptyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        title: AppText(title, variant: AppTextVariant.body),
        subtitle: AppText(
          filled ? filledLabel : emptyLabel,
          variant: AppTextVariant.caption,
        ),
        trailing: Icon(
          filled ? Icons.check_circle : Icons.chevron_right,
          color: filled ? colors.primary : colors.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Opens the anamnèse flow fullscreen for create or edit.
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
