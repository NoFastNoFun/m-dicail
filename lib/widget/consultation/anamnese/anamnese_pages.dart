import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/utils/date_input_formatter.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_chip_group.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_toggle_section.dart';
import 'package:medicail/widget/inputs/app_input.dart';

const int kAnamnesePageCount = 9;

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
        ..._spaced(children),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  List<Widget> _spaced(List<Widget> children) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(const SizedBox(height: AppSpacing.md));
      out.add(children[i]);
    }
    return out;
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
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.patientLastNameRequiredLabel,
          controller: _lastName,
          onChanged: (value) {
            widget.data.lastName = value;
            widget.onChanged();
          },
        ),
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
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseBirthPlaceLabel,
          controller: _birthPlace,
          onChanged: (value) {
            widget.data.birthPlace = value;
            widget.onChanged();
          },
        ),
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
        AnamneseChipGroup(
          label: l10n.patientSexLabel,
          options: [
            AnamneseChipOption(value: 'M', label: l10n.patientSexMale),
            AnamneseChipOption(value: 'F', label: l10n.patientSexFemale),
            AnamneseChipOption(value: 'Other', label: l10n.patientSexOther),
          ],
          selected: widget.data.sex,
          onChanged: (v) {
            setState(() => widget.data.sex = v as String?);
            widget.onChanged();
          },
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
  late final TextEditingController _marcheAge;
  late final TextEditingController _dentitionAge;
  late final TextEditingController _phonationAge;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final naissanceEnfance = widget.data.anamnese.naissanceEnfance;
    _poids = TextEditingController(text: naissanceEnfance.poidsNaissance ?? '');
    _marcheAge = TextEditingController(text: naissanceEnfance.marche.ageMonths ?? '');
    _dentitionAge = TextEditingController(text: naissanceEnfance.dentition.ageMonths ?? '');
    _phonationAge = TextEditingController(text: naissanceEnfance.phonation.ageMonths ?? '');
    _notes = TextEditingController(text: naissanceEnfance.notes ?? '');
  }

  @override
  void dispose() {
    _poids.dispose();
    _marcheAge.dispose();
    _dentitionAge.dispose();
    _phonationAge.dispose();
    _notes.dispose();
    super.dispose();
  }

  NaissanceEnfance get _naissanceEnfance => widget.data.anamnese.naissanceEnfance;

  void _updateAnamneseSection(NaissanceEnfance next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(naissanceEnfance: next);
    setState(() {});
    widget.onChanged();
  }

  Widget _milestone({
    required String label,
    required DevelopmentMilestone value,
    required TextEditingController ageController,
    required ValueChanged<DevelopmentMilestone> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnamneseChipGroup(
          label: label,
          options: [
            AnamneseChipOption(
              value: 'normal',
              label: l10n.anamneseMilestoneNormal,
            ),
            AnamneseChipOption(
              value: 'retard',
              label: l10n.anamneseMilestoneRetard,
            ),
            AnamneseChipOption(
              value: 'inconnu',
              label: l10n.anamneseMilestoneInconnu,
            ),
          ],
          selected: value.status,
          onChanged: (v) {
            onChanged(
              value.copyWith(
                status: v as String?,
                clearStatus: v == null,
                clearAgeMonths: v != 'retard',
              ),
            );
            if (v != 'retard') ageController.clear();
          },
        ),
        if (value.status == 'retard') ...[
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            variant: AppInputVariant.number,
            label: l10n.anamneseAgeMois,
            controller: ageController,
            onChanged: (t) => onChanged(value.copyWith(ageMonths: t)),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final naissanceEnfance = _naissanceEnfance;
    return AnamnesePageScaffold(
      title: l10n.anamneseNaissanceEnfanceTitle,
      children: [
        AppInput(
          variant: AppInputVariant.number,
          label: l10n.anamnesePoidsNaissance,
          controller: _poids,
          onChanged: (v) => _updateAnamneseSection(naissanceEnfance.copyWith(poidsNaissance: v)),
        ),
        AnamneseChipGroup(
          options: [
            AnamneseChipOption(value: 'g', label: l10n.anamnesePoidsUniteG),
            AnamneseChipOption(value: 'kg', label: l10n.anamnesePoidsUniteKg),
          ],
          selected: naissanceEnfance.poidsUnite,
          onChanged: (v) => _updateAnamneseSection(naissanceEnfance.copyWith(poidsUnite: (v as String?) ?? 'kg')),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseAllaitement,
          options: [
            AnamneseChipOption(
              value: 'maternel',
              label: l10n.anamneseAllaitementMaternel,
            ),
            AnamneseChipOption(
              value: 'artificiel',
              label: l10n.anamneseAllaitementArtificiel,
            ),
            AnamneseChipOption(
              value: 'mixte',
              label: l10n.anamneseAllaitementMixte,
            ),
          ],
          selected: naissanceEnfance.allaitement,
          onChanged: (v) => _updateAnamneseSection(
            naissanceEnfance.copyWith(
              allaitement: v as String?,
              clearAllaitement: v == null,
            ),
          ),
        ),
        _milestone(
          label: l10n.anamneseMarche,
          value: naissanceEnfance.marche,
          ageController: _marcheAge,
          onChanged: (m) => _updateAnamneseSection(naissanceEnfance.copyWith(marche: m)),
        ),
        _milestone(
          label: l10n.anamneseDentition,
          value: naissanceEnfance.dentition,
          ageController: _dentitionAge,
          onChanged: (m) => _updateAnamneseSection(naissanceEnfance.copyWith(dentition: m)),
        ),
        _milestone(
          label: l10n.anamnesePhonation,
          value: naissanceEnfance.phonation,
          ageController: _phonationAge,
          onChanged: (m) => _updateAnamneseSection(naissanceEnfance.copyWith(phonation: m)),
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (v) => _updateAnamneseSection(naissanceEnfance.copyWith(notes: v)),
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
  late final TextEditingController _coupleAnnee;
  late final TextEditingController _grossesses;
  late final TextEditingController _troublesNotes;
  late final TextEditingController _menoAnnee;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final vieFamilialeSexuelle = widget.data.anamnese.vieFamilialeSexuelle;
    _coupleAnnee = TextEditingController(text: vieFamilialeSexuelle.coupleAnnee ?? '');
    _grossesses = TextEditingController(text: vieFamilialeSexuelle.nombreGrossesses ?? '');
    _troublesNotes = TextEditingController(text: vieFamilialeSexuelle.troublesSexuels.notes ?? '');
    _menoAnnee = TextEditingController(text: vieFamilialeSexuelle.menopause.year ?? '');
    _notes = TextEditingController(text: vieFamilialeSexuelle.notes ?? '');
  }

  @override
  void dispose() {
    _coupleAnnee.dispose();
    _grossesses.dispose();
    _troublesNotes.dispose();
    _menoAnnee.dispose();
    _notes.dispose();
    super.dispose();
  }

  VieFamilialeSexuelle get _vieFamilialeSexuelle => widget.data.anamnese.vieFamilialeSexuelle;

  void _updateAnamneseSection(VieFamilialeSexuelle next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(vieFamilialeSexuelle: next);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vieFamilialeSexuelle = _vieFamilialeSexuelle;
    return AnamnesePageScaffold(
      title: l10n.anamneseVieFamilialeTitle,
      children: [
        AnamneseToggleSection(
          label: l10n.anamneseEnCouple,
          enabled: vieFamilialeSexuelle.enCouple.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            vieFamilialeSexuelle.copyWith(
              enCouple: vieFamilialeSexuelle.enCouple.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
              clearCoupleType: !on,
              clearCoupleAnnee: !on,
              clearNombreGrossesses: !on,
            ),
          ),
          children: [
            AnamneseChipGroup(
              options: [
                AnamneseChipOption(
                  value: 'mariage',
                  label: l10n.anamneseCoupleMariage,
                ),
                AnamneseChipOption(
                  value: 'pacs',
                  label: l10n.anamneseCouplePacs,
                ),
                AnamneseChipOption(
                  value: 'concubinage',
                  label: l10n.anamneseCoupleConcubinage,
                ),
              ],
              selected: vieFamilialeSexuelle.coupleType,
              onChanged: (t) => _updateAnamneseSection(vieFamilialeSexuelle.copyWith(coupleType: t as String?)),
            ),
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseCoupleAnnee,
              controller: _coupleAnnee,
              onChanged: (t) => _updateAnamneseSection(vieFamilialeSexuelle.copyWith(coupleAnnee: t)),
            ),
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseNombreGrossesses,
              controller: _grossesses,
              onChanged: (t) => _updateAnamneseSection(vieFamilialeSexuelle.copyWith(nombreGrossesses: t)),
            ),
          ],
        ),
        AnamneseToggleSection(
          label: l10n.anamneseTroublesSexuels,
          enabled: vieFamilialeSexuelle.troublesSexuels.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            vieFamilialeSexuelle.copyWith(
              troublesSexuels: vieFamilialeSexuelle.troublesSexuels.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
              troublesSexuelsTypes: on ? vieFamilialeSexuelle.troublesSexuelsTypes : const [],
            ),
          ),
          children: [
            AnamneseChipGroup(
              multi: true,
              selectedValues: vieFamilialeSexuelle.troublesSexuelsTypes.toSet(),
              options: [
                AnamneseChipOption(
                  value: 'dysfonction_erectile',
                  label: l10n.anamneseDysfonctionErectile,
                ),
                AnamneseChipOption(
                  value: 'baisse_libido',
                  label: l10n.anamneseBaisseLibido,
                ),
                AnamneseChipOption(
                  value: 'dyspareunie',
                  label: l10n.anamneseDyspareunie,
                ),
                AnamneseChipOption(
                  value: 'risque_mst',
                  label: l10n.anamneseRisqueMst,
                ),
              ],
              onChanged: (set) => _updateAnamneseSection(
                vieFamilialeSexuelle.copyWith(
                  troublesSexuelsTypes: (set as Set<String>).toList(),
                ),
              ),
            ),
            AppInput(
              variant: AppInputVariant.textarea,
              label: l10n.anamneseDetails,
              controller: _troublesNotes,
              maxLines: 2,
              onChanged: (t) => _updateAnamneseSection(
                vieFamilialeSexuelle.copyWith(
                  troublesSexuels: vieFamilialeSexuelle.troublesSexuels.copyWith(notes: t),
                ),
              ),
            ),
          ],
        ),
        AnamneseToggleSection(
          label: l10n.anamneseMenopause,
          enabled: vieFamilialeSexuelle.menopause.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            vieFamilialeSexuelle.copyWith(
              menopause: vieFamilialeSexuelle.menopause.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
              clearTraitementHormonal: !on,
            ),
          ),
          children: [
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseAnnee,
              controller: _menoAnnee,
              onChanged: (t) => _updateAnamneseSection(
                vieFamilialeSexuelle.copyWith(menopause: vieFamilialeSexuelle.menopause.copyWith(year: t)),
              ),
            ),
            AnamneseChipGroup(
              label: l10n.anamneseTraitementHormonal,
              options: [
                AnamneseChipOption(value: 'oui', label: l10n.anamneseOui),
                AnamneseChipOption(value: 'non', label: l10n.anamneseNon),
              ],
              selected: vieFamilialeSexuelle.traitementHormonal == null
                  ? null
                  : (vieFamilialeSexuelle.traitementHormonal! ? 'oui' : 'non'),
              onChanged: (t) => _updateAnamneseSection(
                vieFamilialeSexuelle.copyWith(
                  traitementHormonal: t == null ? null : t == 'oui',
                  clearTraitementHormonal: t == null,
                ),
              ),
            ),
          ],
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(vieFamilialeSexuelle.copyWith(notes: t)),
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
  late final TextEditingController _alimNotes;
  late final TextEditingController _alcoolQty;
  late final TextEditingController _alcoolNotes;
  late final TextEditingController _tabacQty;
  late final TextEditingController _tabacYears;
  late final TextEditingController _droguesNotes;
  late final TextEditingController _activite;
  late final TextEditingController _allergiesNotes;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final stylesDeVie = widget.data.anamnese.stylesDeVie;
    _alimNotes = TextEditingController(text: stylesDeVie.alimentation.notes ?? '');
    _alcoolQty = TextEditingController(text: stylesDeVie.alcool.quantity ?? '');
    _alcoolNotes = TextEditingController(text: stylesDeVie.alcool.notes ?? '');
    _tabacQty = TextEditingController(text: stylesDeVie.tabac.quantity ?? '');
    _tabacYears = TextEditingController(text: stylesDeVie.tabac.years ?? '');
    _droguesNotes = TextEditingController(text: stylesDeVie.drogues.notes ?? '');
    _activite = TextEditingController(text: stylesDeVie.activiteParSemaine ?? '');
    _allergiesNotes = TextEditingController(text: stylesDeVie.allergies.notes ?? '');
    _notes = TextEditingController(text: stylesDeVie.notes ?? '');
  }

  @override
  void dispose() {
    _alimNotes.dispose();
    _alcoolQty.dispose();
    _alcoolNotes.dispose();
    _tabacQty.dispose();
    _tabacYears.dispose();
    _droguesNotes.dispose();
    _activite.dispose();
    _allergiesNotes.dispose();
    _notes.dispose();
    super.dispose();
  }

  StylesDeVie get _stylesDeVie => widget.data.anamnese.stylesDeVie;

  void _updateAnamneseSection(StylesDeVie next) {
    widget.data.anamnese = widget.data.anamnese.copyWith(stylesDeVie: next);
    setState(() {});
    widget.onChanged();
  }

  List<AnamneseChipOption> get _freqOptions {
    final l10n = AppLocalizations.of(context);
    return [
      AnamneseChipOption(
        value: 'quotidien',
        label: l10n.anamneseFreqQuotidien,
      ),
      AnamneseChipOption(value: 'hebdo', label: l10n.anamneseFreqHebdo),
      AnamneseChipOption(
        value: 'occasionnel',
        label: l10n.anamneseFreqOccasionnel,
      ),
      AnamneseChipOption(value: 'sevre', label: l10n.anamneseFreqSevre),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stylesDeVie = _stylesDeVie;
    return AnamnesePageScaffold(
      title: l10n.anamneseStylesDeVieTitle,
      children: [
        AnamneseChipGroup(
          label: l10n.anamneseQualite,
          options: [
            AnamneseChipOption(
              value: 'equilibree',
              label: l10n.anamneseAlimEquilibree,
            ),
            AnamneseChipOption(
              value: 'desequilibree',
              label: l10n.anamneseAlimDesequilibree,
            ),
            AnamneseChipOption(
              value: 'restrictive',
              label: l10n.anamneseAlimRestrictive,
            ),
          ],
          selected: stylesDeVie.alimentation.qualite,
          onChanged: (v) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              alimentation: stylesDeVie.alimentation.copyWith(
                qualite: v as String?,
                clearQualite: v == null,
              ),
            ),
          ),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseQuantite,
          options: [
            AnamneseChipOption(
              value: 'insuffisante',
              label: l10n.anamneseAlimInsuffisante,
            ),
            AnamneseChipOption(
              value: 'normale',
              label: l10n.anamneseAlimNormale,
            ),
            AnamneseChipOption(
              value: 'excessive',
              label: l10n.anamneseAlimExcessive,
            ),
          ],
          selected: stylesDeVie.alimentation.quantite,
          onChanged: (v) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              alimentation: stylesDeVie.alimentation.copyWith(
                quantite: v as String?,
                clearQuantite: v == null,
              ),
            ),
          ),
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseAlimentation,
          controller: _alimNotes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(
            stylesDeVie.copyWith(alimentation: stylesDeVie.alimentation.copyWith(notes: t)),
          ),
        ),
        AnamneseToggleSection(
          label: l10n.anamneseAlcool,
          enabled: stylesDeVie.alcool.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              alcool: stylesDeVie.alcool.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
            ),
          ),
          children: [
            AnamneseChipGroup(
              label: l10n.anamneseFrequence,
              options: _freqOptions,
              selected: stylesDeVie.alcool.frequency,
              onChanged: (v) => _updateAnamneseSection(
                stylesDeVie.copyWith(
                  alcool: stylesDeVie.alcool.copyWith(
                    frequency: v as String?,
                    clearFrequency: v == null,
                  ),
                ),
              ),
            ),
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseVerresSemaine,
              controller: _alcoolQty,
              onChanged: (t) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(alcool: stylesDeVie.alcool.copyWith(quantity: t))),
            ),
            AnamneseChipGroup(
              label: l10n.anamneseTypeBoisson,
              multi: true,
              selectedValues: stylesDeVie.alcool.types.toSet(),
              options: [
                AnamneseChipOption(value: 'biere', label: l10n.anamneseBiere),
                AnamneseChipOption(value: 'vin', label: l10n.anamneseVin),
                AnamneseChipOption(
                  value: 'spiritueux',
                  label: l10n.anamneseSpiritueux,
                ),
              ],
              onChanged: (set) => _updateAnamneseSection(
                stylesDeVie.copyWith(
                  alcool: stylesDeVie.alcool.copyWith(types: (set as Set<String>).toList()),
                ),
              ),
            ),
            AppInput(
              variant: AppInputVariant.text,
              label: l10n.anamneseDetails,
              controller: _alcoolNotes,
              onChanged: (t) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(alcool: stylesDeVie.alcool.copyWith(notes: t))),
            ),
          ],
        ),
        AnamneseToggleSection(
          label: l10n.anamneseTabac,
          enabled: stylesDeVie.tabac.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              tabac: stylesDeVie.tabac.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
            ),
          ),
          children: [
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseCigarettesJour,
              controller: _tabacQty,
              onChanged: (t) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(tabac: stylesDeVie.tabac.copyWith(quantity: t))),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: AppText(
                l10n.anamneseAncienFumeur,
                variant: AppTextVariant.body,
              ),
              value: stylesDeVie.tabac.former,
              onChanged: (v) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(tabac: stylesDeVie.tabac.copyWith(former: v))),
            ),
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.anamneseAnnees,
              controller: _tabacYears,
              onChanged: (t) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(tabac: stylesDeVie.tabac.copyWith(years: t))),
            ),
          ],
        ),
        AnamneseToggleSection(
          label: l10n.anamneseDrogues,
          enabled: stylesDeVie.drogues.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              drogues: stylesDeVie.drogues.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
            ),
          ),
          children: [
            AnamneseChipGroup(
              multi: true,
              selectedValues: stylesDeVie.drogues.types.toSet(),
              options: [
                AnamneseChipOption(
                  value: 'cannabis',
                  label: l10n.anamneseCannabis,
                ),
                AnamneseChipOption(
                  value: 'cocaine',
                  label: l10n.anamneseCocaine,
                ),
                AnamneseChipOption(
                  value: 'opioides',
                  label: l10n.anamneseOpioides,
                ),
                AnamneseChipOption(value: 'autre', label: l10n.anamneseAutre),
              ],
              onChanged: (set) => _updateAnamneseSection(
                stylesDeVie.copyWith(
                  drogues:
                      stylesDeVie.drogues.copyWith(types: (set as Set<String>).toList()),
                ),
              ),
            ),
            AnamneseChipGroup(
              label: l10n.anamneseFrequence,
              options: _freqOptions,
              selected: stylesDeVie.drogues.frequency,
              onChanged: (v) => _updateAnamneseSection(
                stylesDeVie.copyWith(
                  drogues: stylesDeVie.drogues.copyWith(
                    frequency: v as String?,
                    clearFrequency: v == null,
                  ),
                ),
              ),
            ),
            AppInput(
              variant: AppInputVariant.text,
              label: l10n.anamneseDetails,
              controller: _droguesNotes,
              onChanged: (t) =>
                  _updateAnamneseSection(stylesDeVie.copyWith(drogues: stylesDeVie.drogues.copyWith(notes: t))),
            ),
          ],
        ),
        AnamneseChipGroup(
          label: l10n.anamneseSedentarite,
          options: [
            AnamneseChipOption(value: 'actif', label: l10n.anamneseActif),
            AnamneseChipOption(value: 'modere', label: l10n.anamneseModere),
            AnamneseChipOption(
              value: 'sedentaire',
              label: l10n.anamneseSedentaire,
            ),
          ],
          selected: stylesDeVie.sedentarite,
          onChanged: (v) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              sedentarite: v as String?,
              clearSedentarite: v == null,
              clearActivite: v != 'actif' && v != 'modere',
            ),
          ),
        ),
        if (stylesDeVie.sedentarite == 'actif' || stylesDeVie.sedentarite == 'modere')
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.anamneseActiviteSemaine,
            controller: _activite,
            onChanged: (t) => _updateAnamneseSection(stylesDeVie.copyWith(activiteParSemaine: t)),
          ),
        AnamneseChipGroup(
          label: l10n.anamneseRelationsSociales,
          options: [
            AnamneseChipOption(value: 'isole', label: l10n.anamneseIsole),
            AnamneseChipOption(value: 'limite', label: l10n.anamneseLimite),
            AnamneseChipOption(value: 'soutenu', label: l10n.anamneseSoutenu),
          ],
          selected: stylesDeVie.relationsSociales,
          onChanged: (v) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              relationsSociales: v as String?,
              clearRelations: v == null,
            ),
          ),
        ),
        AnamneseToggleSection(
          label: l10n.anamneseAllergies,
          enabled: stylesDeVie.allergies.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            stylesDeVie.copyWith(
              allergies: stylesDeVie.allergies.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
            ),
          ),
          children: [
            AnamneseChipGroup(
              multi: true,
              selectedValues: stylesDeVie.allergies.types.toSet(),
              options: [
                AnamneseChipOption(
                  value: 'medicamenteuses',
                  label: l10n.anamneseAllergieMedicamenteuses,
                ),
                AnamneseChipOption(
                  value: 'alimentaires',
                  label: l10n.anamneseAllergieAlimentaires,
                ),
                AnamneseChipOption(
                  value: 'environnementales',
                  label: l10n.anamneseAllergieEnvironnementales,
                ),
              ],
              onChanged: (set) => _updateAnamneseSection(
                stylesDeVie.copyWith(
                  allergies: stylesDeVie.allergies
                      .copyWith(types: (set as Set<String>).toList()),
                ),
              ),
            ),
            AppInput(
              variant: AppInputVariant.textarea,
              label: l10n.anamneseDetailAllergies,
              controller: _allergiesNotes,
              maxLines: 2,
              onChanged: (t) => _updateAnamneseSection(
                stylesDeVie.copyWith(allergies: stylesDeVie.allergies.copyWith(notes: t)),
              ),
            ),
          ],
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(stylesDeVie.copyWith(notes: t)),
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
  late final TextEditingController _sellesFreq;
  late final TextEditingController _mictionsFreq;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final activitesPhysiologiques = widget.data.anamnese.activitesPhysiologiques;
    _sellesFreq = TextEditingController(text: activitesPhysiologiques.selles.frequence ?? '');
    _mictionsFreq = TextEditingController(text: activitesPhysiologiques.mictions.frequence ?? '');
    _notes = TextEditingController(text: activitesPhysiologiques.notes ?? '');
  }

  @override
  void dispose() {
    _sellesFreq.dispose();
    _mictionsFreq.dispose();
    _notes.dispose();
    super.dispose();
  }

  ActivitesPhysiologiques get _activitesPhysiologiques =>
      widget.data.anamnese.activitesPhysiologiques;

  void _updateAnamneseSection(ActivitesPhysiologiques next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(activitesPhysiologiques: next);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activitesPhysiologiques = _activitesPhysiologiques;
    return AnamnesePageScaffold(
      title: l10n.anamneseActivitesPhysioTitle,
      children: [
        AnamneseChipGroup(
          label: l10n.anamneseSelles,
          options: [
            AnamneseChipOption(
              value: 'regulieres',
              label: l10n.anamneseSellesRegulieres,
            ),
            AnamneseChipOption(
              value: 'irregulieres',
              label: l10n.anamneseSellesIrregulieres,
            ),
            AnamneseChipOption(
              value: 'constipation',
              label: l10n.anamneseSellesConstipation,
            ),
            AnamneseChipOption(
              value: 'diarrhee',
              label: l10n.anamneseSellesDiarrhee,
            ),
          ],
          selected: activitesPhysiologiques.selles.rythme,
          onChanged: (v) => _updateAnamneseSection(
            activitesPhysiologiques.copyWith(
              selles: activitesPhysiologiques.selles.copyWith(
                rythme: v as String?,
                clearRythme: v == null,
              ),
            ),
          ),
        ),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseFrequenceJour,
          controller: _sellesFreq,
          onChanged: (t) =>
              _updateAnamneseSection(activitesPhysiologiques.copyWith(selles: activitesPhysiologiques.selles.copyWith(frequence: t))),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseMictions,
          multi: true,
          selectedValues: activitesPhysiologiques.mictions.symptomes.toSet(),
          options: [
            AnamneseChipOption(
              value: 'normale',
              label: l10n.anamneseMictionNormale,
            ),
            AnamneseChipOption(
              value: 'pollakiurie',
              label: l10n.anamnesePollakiurie,
            ),
            AnamneseChipOption(value: 'nycturie', label: l10n.anamneseNycturie),
            AnamneseChipOption(value: 'brulures', label: l10n.anamneseBrulures),
            AnamneseChipOption(
              value: 'hematurie',
              label: l10n.anamneseHematurie,
            ),
          ],
          onChanged: (set) => _updateAnamneseSection(
            activitesPhysiologiques.copyWith(
              mictions:
                  activitesPhysiologiques.mictions.copyWith(symptomes: (set as Set<String>).toList()),
            ),
          ),
        ),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseFrequence,
          controller: _mictionsFreq,
          onChanged: (t) =>
              _updateAnamneseSection(activitesPhysiologiques.copyWith(mictions: activitesPhysiologiques.mictions.copyWith(frequence: t))),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseCouleur,
          options: [
            AnamneseChipOption(
              value: 'claire',
              label: l10n.anamneseCouleurClaire,
            ),
            AnamneseChipOption(
              value: 'foncee',
              label: l10n.anamneseCouleurFoncee,
            ),
            AnamneseChipOption(
              value: 'sanglante',
              label: l10n.anamneseCouleurSanglante,
            ),
          ],
          selected: activitesPhysiologiques.mictions.couleur,
          onChanged: (v) => _updateAnamneseSection(
            activitesPhysiologiques.copyWith(
              mictions: activitesPhysiologiques.mictions.copyWith(
                couleur: v as String?,
                clearCouleur: v == null,
              ),
            ),
          ),
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(activitesPhysiologiques.copyWith(notes: t)),
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
  late final TextEditingController _metier;
  late final TextEditingController _expoNotes;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final activiteProfessionnelle = widget.data.anamnese.activiteProfessionnelle;
    _metier = TextEditingController(text: activiteProfessionnelle.metier ?? '');
    _expoNotes = TextEditingController(text: activiteProfessionnelle.expositions.notes ?? '');
    _notes = TextEditingController(text: activiteProfessionnelle.notes ?? '');
  }

  @override
  void dispose() {
    _metier.dispose();
    _expoNotes.dispose();
    _notes.dispose();
    super.dispose();
  }

  ActiviteProfessionnelle get _activiteProfessionnelle =>
      widget.data.anamnese.activiteProfessionnelle;

  void _updateAnamneseSection(ActiviteProfessionnelle next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(activiteProfessionnelle: next);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activiteProfessionnelle = _activiteProfessionnelle;
    return AnamnesePageScaffold(
      title: l10n.anamneseActiviteProTitle,
      children: [
        AnamneseChipGroup(
          label: l10n.anamneseTypeActivite,
          options: [
            AnamneseChipOption(value: 'bureau', label: l10n.anamneseProBureau),
            AnamneseChipOption(
              value: 'physique',
              label: l10n.anamneseProPhysique,
            ),
            AnamneseChipOption(value: 'mixte', label: l10n.anamneseProMixte),
            AnamneseChipOption(
              value: 'retraite',
              label: l10n.anamneseProRetraite,
            ),
            AnamneseChipOption(
              value: 'sans_emploi',
              label: l10n.anamneseProSansEmploi,
            ),
          ],
          selected: activiteProfessionnelle.categorie,
          onChanged: (v) => _updateAnamneseSection(
            activiteProfessionnelle.copyWith(categorie: v as String?, clearCategorie: v == null),
          ),
        ),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.anamneseMetier,
          controller: _metier,
          onChanged: (t) => _updateAnamneseSection(activiteProfessionnelle.copyWith(metier: t)),
        ),
        AnamneseToggleSection(
          label: l10n.anamneseExpositions,
          enabled: activiteProfessionnelle.expositions.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            activiteProfessionnelle.copyWith(
              expositions: activiteProfessionnelle.expositions.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
              expositionTypes: on ? activiteProfessionnelle.expositionTypes : const [],
            ),
          ),
          children: [
            AnamneseChipGroup(
              multi: true,
              selectedValues: activiteProfessionnelle.expositionTypes.toSet(),
              options: [
                AnamneseChipOption(
                  value: 'physique',
                  label: l10n.anamneseExpoPhysique,
                ),
                AnamneseChipOption(
                  value: 'chimique',
                  label: l10n.anamneseExpoChimique,
                ),
                AnamneseChipOption(
                  value: 'biologique',
                  label: l10n.anamneseExpoBiologique,
                ),
                AnamneseChipOption(value: 'autre', label: l10n.anamneseAutre),
              ],
              onChanged: (set) => _updateAnamneseSection(
                activiteProfessionnelle.copyWith(expositionTypes: (set as Set<String>).toList()),
              ),
            ),
            AppInput(
              variant: AppInputVariant.textarea,
              label: l10n.anamneseDetails,
              controller: _expoNotes,
              maxLines: 2,
              onChanged: (t) => _updateAnamneseSection(
                activiteProfessionnelle.copyWith(expositions: activiteProfessionnelle.expositions.copyWith(notes: t)),
              ),
            ),
          ],
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(activiteProfessionnelle.copyWith(notes: t)),
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
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final personnalite = widget.data.anamnese.personnalite;
    _etudes = TextEditingController(text: personnalite.etudesTravail ?? '');
    _notes = TextEditingController(text: personnalite.notes ?? '');
  }

  @override
  void dispose() {
    _etudes.dispose();
    _notes.dispose();
    super.dispose();
  }

  Personnalite get _personnalite => widget.data.anamnese.personnalite;

  void _updateAnamneseSection(Personnalite next) {
    widget.data.anamnese = widget.data.anamnese.copyWith(personnalite: next);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final personnalite = _personnalite;
    return AnamnesePageScaffold(
      title: l10n.anamnesePersonnaliteTitle,
      children: [
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseEtudesTravail,
          controller: _etudes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(personnalite.copyWith(etudesTravail: t)),
        ),
        AnamneseChipGroup(
          label: l10n.anamnesePerceptionSante,
          options: [
            AnamneseChipOption(
              value: 'sous_estime',
              label: l10n.anamneseSousEstime,
            ),
            AnamneseChipOption(
              value: 'realiste',
              label: l10n.anamneseRealiste,
            ),
            AnamneseChipOption(
              value: 'surestime',
              label: l10n.anamneseSurEstime,
            ),
          ],
          selected: personnalite.perceptionSante,
          onChanged: (v) => _updateAnamneseSection(
            personnalite.copyWith(
              perceptionSante: v as String?,
              clearPerception: v == null,
            ),
          ),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseAttitudeMaladie,
          multi: true,
          selectedValues: personnalite.attitudeMaladie.toSet(),
          options: [
            AnamneseChipOption(
              value: 'acceptation',
              label: l10n.anamneseAcceptation,
            ),
            AnamneseChipOption(
              value: 'volonte_guerir',
              label: l10n.anamneseVolonteGuerir,
            ),
            AnamneseChipOption(value: 'anxiete', label: l10n.anamneseAnxiete),
            AnamneseChipOption(value: 'deni', label: l10n.anamneseDeni),
            AnamneseChipOption(
              value: 'confiance_medecins',
              label: l10n.anamneseConfianceMedecins,
            ),
          ],
          onChanged: (set) =>
              _updateAnamneseSection(personnalite.copyWith(attitudeMaladie: (set as Set<String>).toList())),
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (t) => _updateAnamneseSection(personnalite.copyWith(notes: t)),
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
  late final TextEditingController _htaAnnee;
  late final TextEditingController _diabeteAnnee;
  late final TextEditingController _dysAnnee;
  late final TextEditingController _notes;
  late List<_MaladieControllers> _maladies;

  @override
  void initState() {
    super.initState();
    final antecedentsChroniques = widget.data.anamnese.antecedentsChroniques;
    _htaAnnee = TextEditingController(text: antecedentsChroniques.hypertension.annee ?? '');
    _diabeteAnnee = TextEditingController(text: antecedentsChroniques.diabete.annee ?? '');
    _dysAnnee = TextEditingController(text: antecedentsChroniques.dyslipidemie.annee ?? '');
    _notes = TextEditingController(text: antecedentsChroniques.notes ?? '');
    _maladies = antecedentsChroniques.maladies.isEmpty
        ? [_MaladieControllers.empty()]
        : antecedentsChroniques.maladies.map(_MaladieControllers.fromEntry).toList();
  }

  @override
  void dispose() {
    _htaAnnee.dispose();
    _diabeteAnnee.dispose();
    _dysAnnee.dispose();
    _notes.dispose();
    for (final m in _maladies) {
      m.dispose();
    }
    super.dispose();
  }

  AntecedentsChroniques get _antecedentsChroniques => widget.data.anamnese.antecedentsChroniques;

  void _updateAnamneseSection(AntecedentsChroniques next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(antecedentsChroniques: next);
    setState(() {});
    widget.onChanged();
  }

  void _syncMaladies() {
    final entries = _maladies
        .map((m) => m.toEntry())
        .where((e) => !e.isEmpty)
        .toList();
    _updateAnamneseSection(_antecedentsChroniques.copyWith(maladies: entries, notes: _notes.text));
  }

  Widget _chronicConditionSection({
    required String label,
    required ChroniqueFlag chronicCondition,
    required TextEditingController anneeController,
    required ValueChanged<ChroniqueFlag> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return AnamneseToggleSection(
      label: label,
      enabled: chronicCondition.enabled,
      onChanged: (isEnabled) => onChanged(chronicCondition.clearedDetails(enabled: isEnabled)),
      children: [
        AppInput(
          variant: AppInputVariant.number,
          label: l10n.anamneseMaladieAnnee,
          controller: anneeController,
          onChanged: (yearText) => onChanged(chronicCondition.copyWith(annee: yearText)),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseSuivi,
          options: [
            AnamneseChipOption(value: 'mt', label: l10n.anamneseSuiviMt),
            AnamneseChipOption(value: 'spe', label: l10n.anamneseSuiviSpe),
            AnamneseChipOption(
              value: 'hopital',
              label: l10n.anamneseSuiviHopital,
            ),
          ],
          selected: chronicCondition.suivi,
          onChanged: (selectedFollowUp) => onChanged(
            chronicCondition.copyWith(
              suivi: selectedFollowUp as String?,
              clearSuivi: selectedFollowUp == null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final antecedentsChroniques = _antecedentsChroniques;
    return AnamnesePageScaffold(
      title: l10n.anamneseAntecedentsTitle,
      children: [
        _chronicConditionSection(
          label: l10n.anamneseHypertension,
          chronicCondition: antecedentsChroniques.hypertension,
          anneeController: _htaAnnee,
          onChanged: (updated) => _updateAnamneseSection(antecedentsChroniques.copyWith(hypertension: updated)),
        ),
        _chronicConditionSection(
          label: l10n.anamneseDiabete,
          chronicCondition: antecedentsChroniques.diabete,
          anneeController: _diabeteAnnee,
          onChanged: (updated) => _updateAnamneseSection(antecedentsChroniques.copyWith(diabete: updated)),
        ),
        _chronicConditionSection(
          label: l10n.anamneseDyslipidemie,
          chronicCondition: antecedentsChroniques.dyslipidemie,
          anneeController: _dysAnnee,
          onChanged: (updated) => _updateAnamneseSection(antecedentsChroniques.copyWith(dyslipidemie: updated)),
        ),
        AnamneseChipGroup(
          label: l10n.anamneseAddMaladie,
          options: [
            AnamneseChipOption(
              value: 'Asthme',
              label: l10n.anamneseCommonAsthme,
            ),
            AnamneseChipOption(
              value: 'Arthrose',
              label: l10n.anamneseCommonArthrose,
            ),
            AnamneseChipOption(
              value: 'Thyroïde',
              label: l10n.anamneseCommonThyroide,
            ),
          ],
          onChanged: (v) {
            if (v is! String) return;
            setState(() {
              final empty = _maladies.where((m) => m.name.text.isEmpty);
              if (empty.isNotEmpty) {
                empty.first.name.text = v;
              } else {
                final maladieControllers = _MaladieControllers.empty();
                maladieControllers.name.text = v;
                _maladies.add(maladieControllers);
              }
            });
            _syncMaladies();
          },
        ),
        for (final m in _maladies)
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
                    controller: m.name,
                    onChanged: (_) => _syncMaladies(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.number,
                    label: l10n.anamneseMaladieAnnee,
                    controller: m.annee,
                    onChanged: (_) => _syncMaladies(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.anamneseMaladieSymptomes,
                    controller: m.symptomes,
                    onChanged: (_) => _syncMaladies(),
                  ),
                ],
              ),
            ),
          ),
        AppButton(
          onPressed: () {
            setState(() => _maladies.add(_MaladieControllers.empty()));
          },
          style: AppButtonStyle.secondary,
          label: l10n.anamneseAddMaladie,
          expanded: true,
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (_) => _syncMaladies(),
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
  late final TextEditingController _traumaNotes;
  late final TextEditingController _infectionsYear;
  late final TextEditingController _tbYear;
  late final TextEditingController _tumeursYear;
  late final TextEditingController _hepatiteYear;
  late final TextEditingController _syphilisYear;
  late final TextEditingController _fracturesYear;
  late final TextEditingController _notes;
  late List<_InterventionControllers> _interventions;

  @override
  void initState() {
    super.initState();
    final traumatismes = widget.data.anamnese.traumatismesChirurgieInfections;
    _traumaNotes =
        TextEditingController(text: traumatismes.traumatismesSequelles.notes ?? '');
    _infectionsYear =
        TextEditingController(text: traumatismes.infectionsEnfance.year ?? '');
    _tbYear = TextEditingController(text: traumatismes.tuberculose.year ?? '');
    _tumeursYear = TextEditingController(text: traumatismes.tumeurs.year ?? '');
    _hepatiteYear = TextEditingController(text: traumatismes.hepatite.year ?? '');
    _syphilisYear = TextEditingController(text: traumatismes.syphilis.year ?? '');
    _fracturesYear =
        TextEditingController(text: traumatismes.fracturesSansTraumatisme.year ?? '');
    _notes = TextEditingController(text: traumatismes.notes ?? '');
    _interventions = traumatismes.interventions.isEmpty
        ? [_InterventionControllers.empty()]
        : traumatismes.interventions.map(_InterventionControllers.fromEntry).toList();
  }

  @override
  void dispose() {
    _traumaNotes.dispose();
    _infectionsYear.dispose();
    _tbYear.dispose();
    _tumeursYear.dispose();
    _hepatiteYear.dispose();
    _syphilisYear.dispose();
    _fracturesYear.dispose();
    _notes.dispose();
    for (final i in _interventions) {
      i.dispose();
    }
    super.dispose();
  }

  TraumatismesChirurgieInfections get _traumatismes =>
      widget.data.anamnese.traumatismesChirurgieInfections;

  void _updateAnamneseSection(TraumatismesChirurgieInfections next) {
    widget.data.anamnese =
        widget.data.anamnese.copyWith(traumatismesChirurgieInfections: next);
    setState(() {});
    widget.onChanged();
  }

  void _syncInterventions() {
    final interventions = _interventions
        .map((i) => i.toEntry())
        .where((e) => !e.isEmpty)
        .toList();
    _updateAnamneseSection(_traumatismes.copyWith(interventions: interventions, notes: _notes.text));
  }

  Widget _conditionToggle({
    required String label,
    required ConditionEntry entry,
    required TextEditingController yearController,
    required ValueChanged<ConditionEntry> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return AnamneseToggleSection(
      label: label,
      enabled: entry.isEnabled,
      onChanged: (on) => onChanged(
        entry.clearedDetails(
          status: on ? PresenceStatus.present : PresenceStatus.absent,
        ),
      ),
      children: [
        AppInput(
          variant: AppInputVariant.number,
          label: l10n.anamneseAnnee,
          controller: yearController,
          onChanged: (yearText) => onChanged(entry.copyWith(year: yearText)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final traumatismes = _traumatismes;
    return AnamnesePageScaffold(
      title: l10n.anamneseTraumatismesTitle,
      children: [
        AnamneseToggleSection(
          label: l10n.anamneseTraumatismesSequelles,
          enabled: traumatismes.traumatismesSequelles.isEnabled,
          onChanged: (on) => _updateAnamneseSection(
            traumatismes.copyWith(
              traumatismesSequelles: traumatismes.traumatismesSequelles.clearedDetails(
                status: on ? PresenceStatus.present : PresenceStatus.absent,
              ),
            ),
          ),
          children: [
            AppInput(
              variant: AppInputVariant.textarea,
              label: l10n.anamneseDetails,
              controller: _traumaNotes,
              maxLines: 2,
              onChanged: (v) => _updateAnamneseSection(
                traumatismes.copyWith(
                  traumatismesSequelles:
                      traumatismes.traumatismesSequelles.copyWith(notes: v),
                ),
              ),
            ),
          ],
        ),
        AnamneseToggleSection(
          label: l10n.anamneseChirurgieAnterieure,
          enabled: traumatismes.chirurgieAnterieure,
          onChanged: (on) => _updateAnamneseSection(
            traumatismes.copyWith(
              chirurgieAnterieure: on,
              interventions: on ? traumatismes.interventions : const [],
            ),
          ),
          children: [
            for (final i in _interventions) ...[
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.anamneseInterventionDesc,
                controller: i.description,
                onChanged: (_) => _syncInterventions(),
              ),
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.anamneseInterventionDate,
                controller: i.date,
                onChanged: (_) => _syncInterventions(),
              ),
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.anamneseInterventionComplications,
                controller: i.complications,
                onChanged: (_) => _syncInterventions(),
              ),
            ],
            AppButton(
              onPressed: () {
                setState(
                  () => _interventions.add(_InterventionControllers.empty()),
                );
              },
              style: AppButtonStyle.secondary,
              label: l10n.anamneseAddIntervention,
              expanded: true,
            ),
          ],
        ),
        _conditionToggle(
          label: l10n.anamneseInfectionsEnfance,
          entry: traumatismes.infectionsEnfance,
          yearController: _infectionsYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(infectionsEnfance: e)),
        ),
        _conditionToggle(
          label: l10n.anamneseTuberculose,
          entry: traumatismes.tuberculose,
          yearController: _tbYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(tuberculose: e)),
        ),
        _conditionToggle(
          label: l10n.anamneseTumeurs,
          entry: traumatismes.tumeurs,
          yearController: _tumeursYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(tumeurs: e)),
        ),
        _conditionToggle(
          label: l10n.anamneseHepatite,
          entry: traumatismes.hepatite,
          yearController: _hepatiteYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(hepatite: e)),
        ),
        _conditionToggle(
          label: l10n.anamneseSyphilis,
          entry: traumatismes.syphilis,
          yearController: _syphilisYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(syphilis: e)),
        ),
        _conditionToggle(
          label: l10n.anamneseFracturesSansTraumatisme,
          entry: traumatismes.fracturesSansTraumatisme,
          yearController: _fracturesYear,
          onChanged: (e) => _updateAnamneseSection(traumatismes.copyWith(fracturesSansTraumatisme: e)),
        ),
        AppInput(
          variant: AppInputVariant.textarea,
          label: l10n.anamneseNotesComplementaires,
          controller: _notes,
          maxLines: 2,
          onChanged: (_) => _syncInterventions(),
        ),
      ],
    );
  }
}

class _MaladieControllers {
  _MaladieControllers({
    required this.name,
    required this.annee,
    required this.symptomes,
  });

  factory _MaladieControllers.empty() => _MaladieControllers(
        name: TextEditingController(),
        annee: TextEditingController(),
        symptomes: TextEditingController(),
      );

  factory _MaladieControllers.fromEntry(MaladieChroniqueEntry e) =>
      _MaladieControllers(
        name: TextEditingController(text: e.name ?? ''),
        annee: TextEditingController(text: e.anneeApparition ?? ''),
        symptomes: TextEditingController(text: e.symptomesDebut ?? ''),
      );

  final TextEditingController name;
  final TextEditingController annee;
  final TextEditingController symptomes;

  MaladieChroniqueEntry toEntry() => MaladieChroniqueEntry(
        name: name.text,
        anneeApparition: annee.text,
        symptomesDebut: symptomes.text,
      );

  void dispose() {
    name.dispose();
    annee.dispose();
    symptomes.dispose();
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

