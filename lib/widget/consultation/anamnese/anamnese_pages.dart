import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/utils/date_input_formatter.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_checkbox.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/inputs/app_input.dart';

const int kAnamnesePageCount = 9;

String anamnesePageTitle(AppLocalizations l10n, int index) {
  switch (index) {
    case 0:
      return l10n.anamneseIdentityTitle;
    case 1:
      return l10n.anamneseNaissanceEnfanceTitle;
    case 2:
      return l10n.anamneseVieFamilialeTitle;
    case 3:
      return l10n.anamneseStylesDeVieTitle;
    case 4:
      return l10n.anamneseActivitesPhysioTitle;
    case 5:
      return l10n.anamneseActiviteProTitle;
    case 6:
      return l10n.anamnesePersonnaliteTitle;
    case 7:
      return l10n.anamneseAntecedentsTitle;
    case 8:
      return l10n.anamneseTraumatismesTitle;
    default:
      return '';
  }
}

class AnamnesePageScaffold extends StatelessWidget {
  const AnamnesePageScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        AppText(title, variant: AppTextVariant.title),
        const SizedBox(height: AppSpacing.lg),
        ...children,
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class AnamneseIdentityPage extends StatefulWidget {
  const AnamneseIdentityPage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseIdentityPage> createState() => _AnamneseIdentityPageState();
}

class _AnamneseIdentityPageState extends State<AnamneseIdentityPage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _birthDate;
  late final TextEditingController _birthPlace;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    _firstName = TextEditingController(text: data.firstName);
    _lastName = TextEditingController(text: data.lastName);
    _birthDate = TextEditingController(
      text: data.birthDate == null
          ? ''
          : '${data.birthDate!.day.toString().padLeft(2, '0')}/'
              '${data.birthDate!.month.toString().padLeft(2, '0')}/'
              '${data.birthDate!.year}',
    );
    _birthPlace = TextEditingController(text: data.birthPlace);
    _address = TextEditingController(text: data.address);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _birthDate.dispose();
    _birthPlace.dispose();
    _address.dispose();
    super.dispose();
  }

  void _syncBirthDateFromText() {
    final dateStr = _birthDate.text.trim();
    if (dateStr.length != 10) {
      widget.data.birthDate = null;
      widget.onChanged();
      return;
    }
    final parts = dateStr.split('/');
    if (parts.length != 3) return;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return;
    widget.data.birthDate = DateTime(year, month, day);
    widget.onChanged();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.data.birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked == null) return;
    setState(() {
      widget.data.birthDate = picked;
      _birthDate.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseIdentityTitle,
      children: [
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.patientFirstNameRequiredLabel,
          controller: _firstName,
          onChanged: (value) {
            widget.data.firstName = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.patientLastNameRequiredLabel,
          controller: _lastName,
          onChanged: (value) {
            widget.data.lastName = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseBirthDateRequiredLabel,
          controller: _birthDate,
          keyboardType: TextInputType.number,
          inputFormatters: [DateInputFormatter()],
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickDate,
          ),
          onChanged: (_) => _syncBirthDateFromText(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseBirthPlaceLabel,
          controller: _birthPlace,
          onChanged: (value) {
            widget.data.birthPlace = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.patientAddressLabel,
          controller: _address,
          maxLines: 2,
          onChanged: (value) {
            widget.data.address = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(l10n.patientSexLabel, variant: AppTextVariant.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            _ChoiceChip(
              label: l10n.patientSexMale,
              selected: widget.data.sex == 'M',
              onSelected: () {
                setState(() {
                  widget.data.sex = widget.data.sex == 'M' ? null : 'M';
                });
                widget.onChanged();
              },
            ),
            _ChoiceChip(
              label: l10n.patientSexFemale,
              selected: widget.data.sex == 'F',
              onSelected: () {
                setState(() {
                  widget.data.sex = widget.data.sex == 'F' ? null : 'F';
                });
                widget.onChanged();
              },
            ),
            _ChoiceChip(
              label: l10n.patientSexOther,
              selected: widget.data.sex == 'Other',
              onSelected: () {
                setState(() {
                  widget.data.sex =
                      widget.data.sex == 'Other' ? null : 'Other';
                });
                widget.onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class AnamneseNaissanceEnfancePage extends StatefulWidget {
  const AnamneseNaissanceEnfancePage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseNaissanceEnfancePage> createState() =>
      _AnamneseNaissanceEnfancePageState();
}

class _AnamneseNaissanceEnfancePageState
    extends State<AnamneseNaissanceEnfancePage> {
  late final TextEditingController _poids;
  late final TextEditingController _marche;
  late final TextEditingController _dentition;
  late final TextEditingController _phonation;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final n = widget.data.anamnese.naissanceEnfance;
    _poids = TextEditingController(text: n.poidsNaissance ?? '');
    _marche = TextEditingController(text: n.marche ?? '');
    _dentition = TextEditingController(text: n.dentition ?? '');
    _phonation = TextEditingController(text: n.phonation ?? '');
    _notes = TextEditingController(text: n.notes ?? '');
  }

  @override
  void dispose() {
    _poids.dispose();
    _marche.dispose();
    _dentition.dispose();
    _phonation.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(NaissanceEnfance Function(NaissanceEnfance) update) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      naissanceEnfance: update(widget.data.anamnese.naissanceEnfance),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allaitement = widget.data.anamnese.naissanceEnfance.allaitement;
    return AnamnesePageScaffold(
      title: l10n.anamneseNaissanceEnfanceTitle,
      children: [
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamnesePoidsNaissance,
          controller: _poids,
          onChanged: (v) => _patch((n) => n.copyWith(poidsNaissance: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(l10n.anamneseAllaitement, variant: AppTextVariant.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            _ChoiceChip(
              label: l10n.anamneseAllaitementMaternel,
              selected: allaitement == 'maternel',
              onSelected: () {
                final n = widget.data.anamnese.naissanceEnfance;
                setState(() {
                  widget.data.anamnese = widget.data.anamnese.copyWith(
                    naissanceEnfance: NaissanceEnfance(
                      poidsNaissance: n.poidsNaissance,
                      allaitement:
                          allaitement == 'maternel' ? null : 'maternel',
                      marche: n.marche,
                      dentition: n.dentition,
                      phonation: n.phonation,
                      notes: n.notes,
                    ),
                  );
                  widget.onChanged();
                });
              },
            ),
            _ChoiceChip(
              label: l10n.anamneseAllaitementArtificiel,
              selected: allaitement == 'artificiel',
              onSelected: () {
                final n = widget.data.anamnese.naissanceEnfance;
                setState(() {
                  widget.data.anamnese = widget.data.anamnese.copyWith(
                    naissanceEnfance: NaissanceEnfance(
                      poidsNaissance: n.poidsNaissance,
                      allaitement:
                          allaitement == 'artificiel' ? null : 'artificiel',
                      marche: n.marche,
                      dentition: n.dentition,
                      phonation: n.phonation,
                      notes: n.notes,
                    ),
                  );
                  widget.onChanged();
                });
              },
            ),
            _ChoiceChip(
              label: l10n.anamneseAllaitementMixte,
              selected: allaitement == 'mixte',
              onSelected: () {
                final n = widget.data.anamnese.naissanceEnfance;
                setState(() {
                  widget.data.anamnese = widget.data.anamnese.copyWith(
                    naissanceEnfance: NaissanceEnfance(
                      poidsNaissance: n.poidsNaissance,
                      allaitement: allaitement == 'mixte' ? null : 'mixte',
                      marche: n.marche,
                      dentition: n.dentition,
                      phonation: n.phonation,
                      notes: n.notes,
                    ),
                  );
                  widget.onChanged();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseMarche,
          controller: _marche,
          onChanged: (v) => _patch((n) => n.copyWith(marche: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseDentition,
          controller: _dentition,
          onChanged: (v) => _patch((n) => n.copyWith(dentition: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamnesePhonation,
          controller: _phonation,
          onChanged: (v) => _patch((n) => n.copyWith(phonation: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamneseVieFamilialePage extends StatefulWidget {
  const AnamneseVieFamilialePage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseVieFamilialePage> createState() =>
      _AnamneseVieFamilialePageState();
}

class _AnamneseVieFamilialePageState extends State<AnamneseVieFamilialePage> {
  late final TextEditingController _mariage;
  late final TextEditingController _sexualite;
  late final TextEditingController _menopause;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final v = widget.data.anamnese.vieFamilialeSexuelle;
    _mariage = TextEditingController(text: v.mariageGrossesses ?? '');
    _sexualite = TextEditingController(text: v.sexualite ?? '');
    _menopause = TextEditingController(text: v.menopause ?? '');
    _notes = TextEditingController(text: v.notes ?? '');
  }

  @override
  void dispose() {
    _mariage.dispose();
    _sexualite.dispose();
    _menopause.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(VieFamilialeSexuelle Function(VieFamilialeSexuelle) update) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      vieFamilialeSexuelle: update(widget.data.anamnese.vieFamilialeSexuelle),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseVieFamilialeTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseMariageGrossesses,
          controller: _mariage,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(mariageGrossesses: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseSexualite,
          controller: _sexualite,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(sexualite: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseMenopause,
          controller: _menopause,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(menopause: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamneseStylesDeViePage extends StatefulWidget {
  const AnamneseStylesDeViePage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseStylesDeViePage> createState() =>
      _AnamneseStylesDeViePageState();
}

class _AnamneseStylesDeViePageState extends State<AnamneseStylesDeViePage> {
  late final TextEditingController _alimentation;
  late final TextEditingController _alcool;
  late final TextEditingController _tabac;
  late final TextEditingController _drogues;
  late final TextEditingController _sedentarite;
  late final TextEditingController _relations;
  late final TextEditingController _allergies;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final s = widget.data.anamnese.stylesDeVie;
    _alimentation = TextEditingController(text: s.alimentation ?? '');
    _alcool = TextEditingController(text: s.alcool ?? '');
    _tabac = TextEditingController(text: s.tabac ?? '');
    _drogues = TextEditingController(text: s.drogues ?? '');
    _sedentarite = TextEditingController(text: s.sedentarite ?? '');
    _relations = TextEditingController(text: s.relationsSociales ?? '');
    _allergies = TextEditingController(text: s.allergies ?? '');
    _notes = TextEditingController(text: s.notes ?? '');
  }

  @override
  void dispose() {
    _alimentation.dispose();
    _alcool.dispose();
    _tabac.dispose();
    _drogues.dispose();
    _sedentarite.dispose();
    _relations.dispose();
    _allergies.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(StylesDeVie Function(StylesDeVie) update) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      stylesDeVie: update(widget.data.anamnese.stylesDeVie),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseStylesDeVieTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseAlimentation,
          controller: _alimentation,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(alimentation: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseAlcool,
          controller: _alcool,
          onChanged: (v) => _patch((n) => n.copyWith(alcool: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseTabac,
          controller: _tabac,
          onChanged: (v) => _patch((n) => n.copyWith(tabac: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseDrogues,
          controller: _drogues,
          onChanged: (v) => _patch((n) => n.copyWith(drogues: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseSedentarite,
          controller: _sedentarite,
          onChanged: (v) => _patch((n) => n.copyWith(sedentarite: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseRelationsSociales,
          controller: _relations,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(relationsSociales: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseAllergies,
          controller: _allergies,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(allergies: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamneseActivitesPhysioPage extends StatefulWidget {
  const AnamneseActivitesPhysioPage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseActivitesPhysioPage> createState() =>
      _AnamneseActivitesPhysioPageState();
}

class _AnamneseActivitesPhysioPageState
    extends State<AnamneseActivitesPhysioPage> {
  late final TextEditingController _selles;
  late final TextEditingController _mictions;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final a = widget.data.anamnese.activitesPhysiologiques;
    _selles = TextEditingController(text: a.selles ?? '');
    _mictions = TextEditingController(text: a.mictions ?? '');
    _notes = TextEditingController(text: a.notes ?? '');
  }

  @override
  void dispose() {
    _selles.dispose();
    _mictions.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(ActivitesPhysiologiques Function(ActivitesPhysiologiques) u) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      activitesPhysiologiques: u(widget.data.anamnese.activitesPhysiologiques),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseActivitesPhysioTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseSelles,
          controller: _selles,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(selles: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseMictions,
          controller: _mictions,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(mictions: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamneseActiviteProPage extends StatefulWidget {
  const AnamneseActiviteProPage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseActiviteProPage> createState() =>
      _AnamneseActiviteProPageState();
}

class _AnamneseActiviteProPageState extends State<AnamneseActiviteProPage> {
  late final TextEditingController _type;
  late final TextEditingController _exposures;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final a = widget.data.anamnese.activiteProfessionnelle;
    _type = TextEditingController(text: a.typeActivite ?? '');
    _exposures = TextEditingController(text: a.expositions ?? '');
    _notes = TextEditingController(text: a.notes ?? '');
  }

  @override
  void dispose() {
    _type.dispose();
    _exposures.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(ActiviteProfessionnelle Function(ActiviteProfessionnelle) u) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      activiteProfessionnelle: u(widget.data.anamnese.activiteProfessionnelle),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseActiviteProTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseTypeActivite,
          controller: _type,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(typeActivite: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseExpositions,
          controller: _exposures,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(expositions: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamnesePersonnalitePage extends StatefulWidget {
  const AnamnesePersonnalitePage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamnesePersonnalitePage> createState() =>
      _AnamnesePersonnalitePageState();
}

class _AnamnesePersonnalitePageState extends State<AnamnesePersonnalitePage> {
  late final TextEditingController _etudes;
  late final TextEditingController _perception;
  late final TextEditingController _attitude;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final p = widget.data.anamnese.personnalite;
    _etudes = TextEditingController(text: p.etudesTravail ?? '');
    _perception = TextEditingController(text: p.perceptionSante ?? '');
    _attitude = TextEditingController(text: p.attitudeMaladie ?? '');
    _notes = TextEditingController(text: p.notes ?? '');
  }

  @override
  void dispose() {
    _etudes.dispose();
    _perception.dispose();
    _attitude.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _patch(Personnalite Function(Personnalite) u) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      personnalite: u(widget.data.anamnese.personnalite),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamnesePersonnaliteTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseEtudesTravail,
          controller: _etudes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(etudesTravail: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamnesePerceptionSante,
          controller: _perception,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(perceptionSante: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseAttitudeMaladie,
          controller: _attitude,
          maxLines: 3,
          onChanged: (v) => _patch((n) => n.copyWith(attitudeMaladie: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _patch((n) => n.copyWith(notes: v)),
        ),
      ],
    );
  }
}

class AnamneseAntecedentsPage extends StatefulWidget {
  const AnamneseAntecedentsPage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseAntecedentsPage> createState() =>
      _AnamneseAntecedentsPageState();
}

class _AnamneseAntecedentsPageState extends State<AnamneseAntecedentsPage> {
  late final TextEditingController _notes;
  late List<_MaladieControllers> _maladies;

  @override
  void initState() {
    super.initState();
    final a = widget.data.anamnese.antecedentsChroniques;
    _notes = TextEditingController(text: a.notes ?? '');
    _maladies = a.maladies.isEmpty
        ? [_MaladieControllers.empty()]
        : a.maladies.map(_MaladieControllers.fromEntry).toList();
  }

  @override
  void dispose() {
    _notes.dispose();
    for (final m in _maladies) {
      m.dispose();
    }
    super.dispose();
  }

  void _sync() {
    final entries = _maladies
        .map((m) => m.toEntry())
        .where((e) => !e.isEmpty)
        .toList();
    final current = widget.data.anamnese.antecedentsChroniques;
    widget.data.anamnese = widget.data.anamnese.copyWith(
      antecedentsChroniques: current.copyWith(
        maladies: entries,
        notes: _notes.text,
      ),
    );
    widget.onChanged();
  }

  void _patchFlags(AntecedentsChroniques Function(AntecedentsChroniques) u) {
    widget.data.anamnese = widget.data.anamnese.copyWith(
      antecedentsChroniques: u(widget.data.anamnese.antecedentsChroniques),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = widget.data.anamnese.antecedentsChroniques;
    return AnamnesePageScaffold(
      title: l10n.anamneseAntecedentsTitle,
      children: [
        AppCheckbox(
          label: l10n.anamneseHypertension,
          value: a.hypertension,
          onChanged: (v) =>
              _patchFlags((n) => n.copyWith(hypertension: v ?? false)),
        ),
        AppCheckbox(
          label: l10n.anamneseDiabete,
          value: a.diabete,
          onChanged: (v) => _patchFlags((n) => n.copyWith(diabete: v ?? false)),
        ),
        AppCheckbox(
          label: l10n.anamneseDyslipidemie,
          value: a.dyslipidemie,
          onChanged: (v) =>
              _patchFlags((n) => n.copyWith(dyslipidemie: v ?? false)),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _maladies.length; i++) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: AppRadius.mdBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieName,
                    controller: _maladies[i].name,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieAnnee,
                    controller: _maladies[i].annee,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieSymptomes,
                    controller: _maladies[i].symptomes,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieLieuSuivi,
                    controller: _maladies[i].lieu,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieModaliteSuivi,
                    controller: _maladies[i].modalite,
                    onChanged: (_) => _sync(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          onPressed: () {
            setState(() {
              _maladies.add(_MaladieControllers.empty());
            });
          },
          style: AppButtonStyle.secondary,
          label: l10n.anamneseAddMaladie,
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (_) => _sync(),
        ),
      ],
    );
  }
}

class AnamneseTraumatismesPage extends StatefulWidget {
  const AnamneseTraumatismesPage({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AnamneseFormData data;
  final VoidCallback onChanged;

  @override
  State<AnamneseTraumatismesPage> createState() =>
      _AnamneseTraumatismesPageState();
}

class _AnamneseTraumatismesPageState extends State<AnamneseTraumatismesPage> {
  late final TextEditingController _sequelles;
  late final TextEditingController _infections;
  late final TextEditingController _tb;
  late final TextEditingController _tumeurs;
  late final TextEditingController _hepatite;
  late final TextEditingController _syphilis;
  late final TextEditingController _fractures;
  late final TextEditingController _notes;
  late List<_InterventionControllers> _interventions;

  @override
  void initState() {
    super.initState();
    final t = widget.data.anamnese.traumatismesChirurgieInfections;
    _sequelles = TextEditingController(text: t.traumatismesSequelles ?? '');
    _infections = TextEditingController(text: t.infectionsEnfance ?? '');
    _tb = TextEditingController(text: t.tuberculose ?? '');
    _tumeurs = TextEditingController(text: t.tumeurs ?? '');
    _hepatite = TextEditingController(text: t.hepatite ?? '');
    _syphilis = TextEditingController(text: t.syphilis ?? '');
    _fractures = TextEditingController(text: t.fracturesSansTraumatisme ?? '');
    _notes = TextEditingController(text: t.notes ?? '');
    _interventions = t.interventions.isEmpty
        ? [_InterventionControllers.empty()]
        : t.interventions.map(_InterventionControllers.fromEntry).toList();
  }

  @override
  void dispose() {
    _sequelles.dispose();
    _infections.dispose();
    _tb.dispose();
    _tumeurs.dispose();
    _hepatite.dispose();
    _syphilis.dispose();
    _fractures.dispose();
    _notes.dispose();
    for (final i in _interventions) {
      i.dispose();
    }
    super.dispose();
  }

  void _sync() {
    final interventions = _interventions
        .map((i) => i.toEntry())
        .where((e) => !e.isEmpty)
        .toList();
    widget.data.anamnese = widget.data.anamnese.copyWith(
      traumatismesChirurgieInfections: TraumatismesChirurgieInfections(
        traumatismesSequelles: _sequelles.text,
        interventions: interventions,
        infectionsEnfance: _infections.text,
        tuberculose: _tb.text,
        tumeurs: _tumeurs.text,
        hepatite: _hepatite.text,
        syphilis: _syphilis.text,
        fracturesSansTraumatisme: _fractures.text,
        notes: _notes.text,
      ),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnamnesePageScaffold(
      title: l10n.anamneseTraumatismesTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseTraumatismesSequelles,
          controller: _sequelles,
          maxLines: 2,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _interventions.length; i++) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: AppRadius.mdBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseInterventionDesc,
                    controller: _interventions[i].description,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseInterventionDate,
                    controller: _interventions[i].date,
                    onChanged: (_) => _sync(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseInterventionComplications,
                    controller: _interventions[i].complications,
                    onChanged: (_) => _sync(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          onPressed: () {
            setState(() {
              _interventions.add(_InterventionControllers.empty());
            });
          },
          style: AppButtonStyle.secondary,
          label: l10n.anamneseAddIntervention,
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseInfectionsEnfance,
          controller: _infections,
          maxLines: 2,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseTuberculose,
          controller: _tb,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseTumeurs,
          controller: _tumeurs,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseHepatite,
          controller: _hepatite,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseSyphilis,
          controller: _syphilis,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseFracturesSansTraumatisme,
          controller: _fractures,
          maxLines: 2,
          onChanged: (_) => _sync(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (_) => _sync(),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _MaladieControllers {
  _MaladieControllers({
    required this.name,
    required this.annee,
    required this.symptomes,
    required this.lieu,
    required this.modalite,
  });

  factory _MaladieControllers.empty() => _MaladieControllers(
        name: TextEditingController(),
        annee: TextEditingController(),
        symptomes: TextEditingController(),
        lieu: TextEditingController(),
        modalite: TextEditingController(),
      );

  factory _MaladieControllers.fromEntry(MaladieChroniqueEntry e) =>
      _MaladieControllers(
        name: TextEditingController(text: e.name ?? ''),
        annee: TextEditingController(text: e.anneeApparition ?? ''),
        symptomes: TextEditingController(text: e.symptomesDebut ?? ''),
        lieu: TextEditingController(text: e.lieuSuivi ?? ''),
        modalite: TextEditingController(text: e.modaliteSuivi ?? ''),
      );

  final TextEditingController name;
  final TextEditingController annee;
  final TextEditingController symptomes;
  final TextEditingController lieu;
  final TextEditingController modalite;

  MaladieChroniqueEntry toEntry() => MaladieChroniqueEntry(
        name: name.text,
        anneeApparition: annee.text,
        symptomesDebut: symptomes.text,
        lieuSuivi: lieu.text,
        modaliteSuivi: modalite.text,
      );

  void dispose() {
    name.dispose();
    annee.dispose();
    symptomes.dispose();
    lieu.dispose();
    modalite.dispose();
  }
}

class _InterventionControllers {
  _InterventionControllers({
    required this.description,
    required this.date,
    required this.complications,
  });

  factory _InterventionControllers.empty() => _InterventionControllers(
        description: TextEditingController(),
        date: TextEditingController(),
        complications: TextEditingController(),
      );

  factory _InterventionControllers.fromEntry(
    InterventionChirurgicaleEntry e,
  ) =>
      _InterventionControllers(
        description: TextEditingController(text: e.description ?? ''),
        date: TextEditingController(text: e.date ?? ''),
        complications: TextEditingController(text: e.complications ?? ''),
      );

  final TextEditingController description;
  final TextEditingController date;
  final TextEditingController complications;

  InterventionChirurgicaleEntry toEntry() => InterventionChirurgicaleEntry(
        description: description.text,
        date: date.text,
        complications: complications.text,
      );

  void dispose() {
    description.dispose();
    date.dispose();
    complications.dispose();
  }
}
