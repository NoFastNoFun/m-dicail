import 'package:equatable/equatable.dart';

enum PresenceStatus { unknown, absent, present }

PresenceStatus presenceFromJson(Object? value) {
  if (value is String) {
    switch (value) {
      case 'absent':
        return PresenceStatus.absent;
      case 'present':
        return PresenceStatus.present;
    }
  }
  return PresenceStatus.unknown;
}

String? presenceToJson(PresenceStatus status) {
  switch (status) {
    case PresenceStatus.unknown:
      return null;
    case PresenceStatus.absent:
      return 'absent';
    case PresenceStatus.present:
      return 'present';
  }
}

/// Structured habit (alcool / tabac / drogues) with expandable details.
class HabitEntry extends Equatable {
  const HabitEntry({
    this.status = PresenceStatus.unknown,
    this.frequency,
    this.quantity,
    this.types = const [],
    this.former = false,
    this.years,
    this.notes,
  });

  final PresenceStatus status;
  final String? frequency;
  final String? quantity;
  final List<String> types;
  final bool former;
  final String? years;
  final String? notes;

  bool get isEmpty =>
      status == PresenceStatus.unknown &&
      _empty(frequency) &&
      _empty(quantity) &&
      types.isEmpty &&
      !former &&
      _empty(years) &&
      _empty(notes);

  bool get isEnabled => status == PresenceStatus.present;

  HabitEntry copyWith({
    PresenceStatus? status,
    String? frequency,
    String? quantity,
    List<String>? types,
    bool? former,
    String? years,
    String? notes,
    bool clearFrequency = false,
    bool clearQuantity = false,
    bool clearYears = false,
    bool clearNotes = false,
  }) {
    return HabitEntry(
      status: status ?? this.status,
      frequency: clearFrequency ? null : frequency ?? this.frequency,
      quantity: clearQuantity ? null : quantity ?? this.quantity,
      types: types ?? this.types,
      former: former ?? this.former,
      years: clearYears ? null : years ?? this.years,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  HabitEntry clearedDetails({required PresenceStatus status}) {
    return HabitEntry(status: status);
  }

  factory HabitEntry.fromJson(Object? json) {
    if (json == null) return const HabitEntry();
    if (json is String) {
      if (json.trim().isEmpty) {
        return const HabitEntry(status: PresenceStatus.absent);
      }
      return HabitEntry(status: PresenceStatus.present, notes: json);
    }
    if (json is! Map<String, dynamic>) return const HabitEntry();
    final rawTypes = json['types'];
    return HabitEntry(
      status: presenceFromJson(json['status']),
      frequency: json['frequency'] as String?,
      quantity: json['quantity'] as String?,
      types: rawTypes is List
          ? rawTypes.whereType<String>().toList()
          : const [],
      former: json['former'] as bool? ?? false,
      years: json['years'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': presenceToJson(status),
        'frequency': frequency,
        'quantity': quantity,
        'types': types,
        'former': former,
        'years': years,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [status, frequency, quantity, types, former, years, notes];
}

/// Milestone such as marche / dentition / phonation.
class DevelopmentMilestone extends Equatable {
  const DevelopmentMilestone({
    this.status,
    this.ageMonths,
    this.notes,
  });

  /// normal | retard | inconnu
  final String? status;
  final String? ageMonths;
  final String? notes;

  bool get isEmpty =>
      _empty(status) && _empty(ageMonths) && _empty(notes);

  DevelopmentMilestone copyWith({
    String? status,
    String? ageMonths,
    String? notes,
    bool clearStatus = false,
    bool clearAgeMonths = false,
    bool clearNotes = false,
  }) {
    return DevelopmentMilestone(
      status: clearStatus ? null : status ?? this.status,
      ageMonths: clearAgeMonths ? null : ageMonths ?? this.ageMonths,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory DevelopmentMilestone.fromJson(Object? json) {
    if (json == null) return const DevelopmentMilestone();
    if (json is String) {
      if (json.trim().isEmpty) return const DevelopmentMilestone();
      return DevelopmentMilestone(notes: json);
    }
    if (json is! Map<String, dynamic>) return const DevelopmentMilestone();
    return DevelopmentMilestone(
      status: json['status'] as String?,
      ageMonths: json['age_months'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'age_months': ageMonths,
        'notes': notes,
      };

  @override
  List<Object?> get props => [status, ageMonths, notes];
}

/// Condition with optional year + notes (infections, TB, etc.).
class ConditionEntry extends Equatable {
  const ConditionEntry({
    this.status = PresenceStatus.unknown,
    this.year,
    this.notes,
  });

  final PresenceStatus status;
  final String? year;
  final String? notes;

  bool get isEmpty =>
      status == PresenceStatus.unknown && _empty(year) && _empty(notes);

  bool get isEnabled => status == PresenceStatus.present;

  ConditionEntry copyWith({
    PresenceStatus? status,
    String? year,
    String? notes,
    bool clearYear = false,
    bool clearNotes = false,
  }) {
    return ConditionEntry(
      status: status ?? this.status,
      year: clearYear ? null : year ?? this.year,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  ConditionEntry clearedDetails({required PresenceStatus status}) {
    return ConditionEntry(status: status);
  }

  factory ConditionEntry.fromJson(Object? json) {
    if (json == null) return const ConditionEntry();
    if (json is String) {
      if (json.trim().isEmpty) {
        return const ConditionEntry(status: PresenceStatus.absent);
      }
      return ConditionEntry(status: PresenceStatus.present, notes: json);
    }
    if (json is! Map<String, dynamic>) return const ConditionEntry();
    return ConditionEntry(
      status: presenceFromJson(json['status']),
      year: json['year'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': presenceToJson(status),
        'year': year,
        'notes': notes,
      };

  @override
  List<Object?> get props => [status, year, notes];
}

/// Typed physiological anamnèse stored under [Patient.metadata] `anamnese`.
class Anamnese extends Equatable {
  const Anamnese({
    this.naissanceEnfance = const NaissanceEnfance(),
    this.vieFamilialeSexuelle = const VieFamilialeSexuelle(),
    this.stylesDeVie = const StylesDeVie(),
    this.activitesPhysiologiques = const ActivitesPhysiologiques(),
    this.activiteProfessionnelle = const ActiviteProfessionnelle(),
    this.personnalite = const Personnalite(),
    this.antecedentsChroniques = const AntecedentsChroniques(),
    this.traumatismesChirurgieInfections =
        const TraumatismesChirurgieInfections(),
  });

  final NaissanceEnfance naissanceEnfance;
  final VieFamilialeSexuelle vieFamilialeSexuelle;
  final StylesDeVie stylesDeVie;
  final ActivitesPhysiologiques activitesPhysiologiques;
  final ActiviteProfessionnelle activiteProfessionnelle;
  final Personnalite personnalite;
  final AntecedentsChroniques antecedentsChroniques;
  final TraumatismesChirurgieInfections traumatismesChirurgieInfections;

  bool get isEmpty =>
      naissanceEnfance.isEmpty &&
      vieFamilialeSexuelle.isEmpty &&
      stylesDeVie.isEmpty &&
      activitesPhysiologiques.isEmpty &&
      activiteProfessionnelle.isEmpty &&
      personnalite.isEmpty &&
      antecedentsChroniques.isEmpty &&
      traumatismesChirurgieInfections.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Anamnese copyWith({
    NaissanceEnfance? naissanceEnfance,
    VieFamilialeSexuelle? vieFamilialeSexuelle,
    StylesDeVie? stylesDeVie,
    ActivitesPhysiologiques? activitesPhysiologiques,
    ActiviteProfessionnelle? activiteProfessionnelle,
    Personnalite? personnalite,
    AntecedentsChroniques? antecedentsChroniques,
    TraumatismesChirurgieInfections? traumatismesChirurgieInfections,
  }) {
    return Anamnese(
      naissanceEnfance: naissanceEnfance ?? this.naissanceEnfance,
      vieFamilialeSexuelle:
          vieFamilialeSexuelle ?? this.vieFamilialeSexuelle,
      stylesDeVie: stylesDeVie ?? this.stylesDeVie,
      activitesPhysiologiques:
          activitesPhysiologiques ?? this.activitesPhysiologiques,
      activiteProfessionnelle:
          activiteProfessionnelle ?? this.activiteProfessionnelle,
      personnalite: personnalite ?? this.personnalite,
      antecedentsChroniques:
          antecedentsChroniques ?? this.antecedentsChroniques,
      traumatismesChirurgieInfections: traumatismesChirurgieInfections ??
          this.traumatismesChirurgieInfections,
    );
  }

  factory Anamnese.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Anamnese();
    return Anamnese(
      naissanceEnfance: NaissanceEnfance.fromJson(
        json['naissance_enfance'] as Map<String, dynamic>?,
      ),
      vieFamilialeSexuelle: VieFamilialeSexuelle.fromJson(
        json['vie_familiale_sexuelle'] as Map<String, dynamic>?,
      ),
      stylesDeVie: StylesDeVie.fromJson(
        json['styles_de_vie'] as Map<String, dynamic>?,
      ),
      activitesPhysiologiques: ActivitesPhysiologiques.fromJson(
        json['activites_physiologiques'] as Map<String, dynamic>?,
      ),
      activiteProfessionnelle: ActiviteProfessionnelle.fromJson(
        json['activite_professionnelle'] as Map<String, dynamic>?,
      ),
      personnalite: Personnalite.fromJson(
        json['personnalite'] as Map<String, dynamic>?,
      ),
      antecedentsChroniques: AntecedentsChroniques.fromJson(
        json['antecedents_chroniques'] as Map<String, dynamic>?,
      ),
      traumatismesChirurgieInfections: TraumatismesChirurgieInfections.fromJson(
        json['traumatismes_chirurgie_infections'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'naissance_enfance': naissanceEnfance.toJson(),
      'vie_familiale_sexuelle': vieFamilialeSexuelle.toJson(),
      'styles_de_vie': stylesDeVie.toJson(),
      'activites_physiologiques': activitesPhysiologiques.toJson(),
      'activite_professionnelle': activiteProfessionnelle.toJson(),
      'personnalite': personnalite.toJson(),
      'antecedents_chroniques': antecedentsChroniques.toJson(),
      'traumatismes_chirurgie_infections':
          traumatismesChirurgieInfections.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        naissanceEnfance,
        vieFamilialeSexuelle,
        stylesDeVie,
        activitesPhysiologiques,
        activiteProfessionnelle,
        personnalite,
        antecedentsChroniques,
        traumatismesChirurgieInfections,
      ];
}

class NaissanceEnfance extends Equatable {
  const NaissanceEnfance({
    this.poidsNaissance,
    this.poidsUnite = 'kg',
    this.allaitement,
    this.marche = const DevelopmentMilestone(),
    this.dentition = const DevelopmentMilestone(),
    this.phonation = const DevelopmentMilestone(),
    this.notes,
  });

  final String? poidsNaissance;
  final String poidsUnite;
  final String? allaitement;
  final DevelopmentMilestone marche;
  final DevelopmentMilestone dentition;
  final DevelopmentMilestone phonation;
  final String? notes;

  bool get isEmpty =>
      _empty(poidsNaissance) &&
      _empty(allaitement) &&
      marche.isEmpty &&
      dentition.isEmpty &&
      phonation.isEmpty &&
      _empty(notes);

  NaissanceEnfance copyWith({
    String? poidsNaissance,
    String? poidsUnite,
    String? allaitement,
    DevelopmentMilestone? marche,
    DevelopmentMilestone? dentition,
    DevelopmentMilestone? phonation,
    String? notes,
    bool clearPoids = false,
    bool clearAllaitement = false,
    bool clearNotes = false,
  }) {
    return NaissanceEnfance(
      poidsNaissance: clearPoids ? null : poidsNaissance ?? this.poidsNaissance,
      poidsUnite: poidsUnite ?? this.poidsUnite,
      allaitement: clearAllaitement ? null : allaitement ?? this.allaitement,
      marche: marche ?? this.marche,
      dentition: dentition ?? this.dentition,
      phonation: phonation ?? this.phonation,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory NaissanceEnfance.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NaissanceEnfance();
    return NaissanceEnfance(
      poidsNaissance: json['poids_naissance'] as String?,
      poidsUnite: json['poids_unite'] as String? ?? 'kg',
      allaitement: json['allaitement'] as String?,
      marche: DevelopmentMilestone.fromJson(json['marche']),
      dentition: DevelopmentMilestone.fromJson(json['dentition']),
      phonation: DevelopmentMilestone.fromJson(json['phonation']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'poids_naissance': poidsNaissance,
        'poids_unite': poidsUnite,
        'allaitement': allaitement,
        'marche': marche.toJson(),
        'dentition': dentition.toJson(),
        'phonation': phonation.toJson(),
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [poidsNaissance, poidsUnite, allaitement, marche, dentition, phonation, notes];
}

class VieFamilialeSexuelle extends Equatable {
  const VieFamilialeSexuelle({
    this.enCouple = const ConditionEntry(),
    this.coupleType,
    this.coupleAnnee,
    this.nombreGrossesses,
    this.troublesSexuels = const ConditionEntry(),
    this.troublesSexuelsTypes = const [],
    this.menopause = const ConditionEntry(),
    this.traitementHormonal,
    this.notes,
  });

  final ConditionEntry enCouple;
  final String? coupleType;
  final String? coupleAnnee;
  final String? nombreGrossesses;
  final ConditionEntry troublesSexuels;
  final List<String> troublesSexuelsTypes;
  final ConditionEntry menopause;
  final bool? traitementHormonal;
  final String? notes;

  bool get isEmpty =>
      enCouple.isEmpty &&
      _empty(coupleType) &&
      _empty(coupleAnnee) &&
      _empty(nombreGrossesses) &&
      troublesSexuels.isEmpty &&
      troublesSexuelsTypes.isEmpty &&
      menopause.isEmpty &&
      traitementHormonal == null &&
      _empty(notes);

  VieFamilialeSexuelle copyWith({
    ConditionEntry? enCouple,
    String? coupleType,
    String? coupleAnnee,
    String? nombreGrossesses,
    ConditionEntry? troublesSexuels,
    List<String>? troublesSexuelsTypes,
    ConditionEntry? menopause,
    bool? traitementHormonal,
    String? notes,
    bool clearCoupleType = false,
    bool clearCoupleAnnee = false,
    bool clearNombreGrossesses = false,
    bool clearTraitementHormonal = false,
    bool clearNotes = false,
  }) {
    return VieFamilialeSexuelle(
      enCouple: enCouple ?? this.enCouple,
      coupleType: clearCoupleType ? null : coupleType ?? this.coupleType,
      coupleAnnee: clearCoupleAnnee ? null : coupleAnnee ?? this.coupleAnnee,
      nombreGrossesses: clearNombreGrossesses
          ? null
          : nombreGrossesses ?? this.nombreGrossesses,
      troublesSexuels: troublesSexuels ?? this.troublesSexuels,
      troublesSexuelsTypes:
          troublesSexuelsTypes ?? this.troublesSexuelsTypes,
      menopause: menopause ?? this.menopause,
      traitementHormonal: clearTraitementHormonal
          ? null
          : traitementHormonal ?? this.traitementHormonal,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory VieFamilialeSexuelle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VieFamilialeSexuelle();
    // Legacy flat strings
    final legacyMariage = json['mariage_grossesses'];
    final legacySexualite = json['sexualite'];
    final legacyMenopause = json['menopause'];

    ConditionEntry enCouple = ConditionEntry.fromJson(json['en_couple']);
    String? coupleType = json['couple_type'] as String?;
    String? coupleAnnee = json['couple_annee'] as String?;
    String? nombreGrossesses = json['nombre_grossesses'] as String?;
    if (legacyMariage is String && legacyMariage.trim().isNotEmpty) {
      enCouple = ConditionEntry(
        status: PresenceStatus.present,
        notes: legacyMariage,
      );
    }

    ConditionEntry troubles =
        ConditionEntry.fromJson(json['troubles_sexuels']);
    final rawTypes = json['troubles_sexuels_types'];
    var types = rawTypes is List
        ? rawTypes.whereType<String>().toList()
        : <String>[];
    if (legacySexualite is String && legacySexualite.trim().isNotEmpty) {
      troubles = ConditionEntry(
        status: PresenceStatus.present,
        notes: legacySexualite,
      );
    }

    ConditionEntry menopause = ConditionEntry.fromJson(
      json['menopause_entry'] ??
          (legacyMenopause is Map ? legacyMenopause : null),
    );
    if (legacyMenopause is String && legacyMenopause.trim().isNotEmpty) {
      menopause = ConditionEntry(
        status: PresenceStatus.present,
        notes: legacyMenopause,
      );
    }

    return VieFamilialeSexuelle(
      enCouple: enCouple,
      coupleType: coupleType,
      coupleAnnee: coupleAnnee,
      nombreGrossesses: nombreGrossesses,
      troublesSexuels: troubles,
      troublesSexuelsTypes: types,
      menopause: menopause,
      traitementHormonal: json['traitement_hormonal'] as bool?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'en_couple': enCouple.toJson(),
        'couple_type': coupleType,
        'couple_annee': coupleAnnee,
        'nombre_grossesses': nombreGrossesses,
        'troubles_sexuels': troublesSexuels.toJson(),
        'troubles_sexuels_types': troublesSexuelsTypes,
        'menopause_entry': menopause.toJson(),
        'traitement_hormonal': traitementHormonal,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        enCouple,
        coupleType,
        coupleAnnee,
        nombreGrossesses,
        troublesSexuels,
        troublesSexuelsTypes,
        menopause,
        traitementHormonal,
        notes,
      ];
}

class AlimentationEntry extends Equatable {
  const AlimentationEntry({
    this.qualite,
    this.quantite,
    this.notes,
  });

  final String? qualite;
  final String? quantite;
  final String? notes;

  bool get isEmpty =>
      _empty(qualite) && _empty(quantite) && _empty(notes);

  AlimentationEntry copyWith({
    String? qualite,
    String? quantite,
    String? notes,
    bool clearQualite = false,
    bool clearQuantite = false,
    bool clearNotes = false,
  }) {
    return AlimentationEntry(
      qualite: clearQualite ? null : qualite ?? this.qualite,
      quantite: clearQuantite ? null : quantite ?? this.quantite,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory AlimentationEntry.fromJson(Object? json) {
    if (json == null) return const AlimentationEntry();
    if (json is String) {
      if (json.trim().isEmpty) return const AlimentationEntry();
      return AlimentationEntry(notes: json);
    }
    if (json is! Map<String, dynamic>) return const AlimentationEntry();
    return AlimentationEntry(
      qualite: json['qualite'] as String?,
      quantite: json['quantite'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'qualite': qualite,
        'quantite': quantite,
        'notes': notes,
      };

  @override
  List<Object?> get props => [qualite, quantite, notes];
}

class AllergiesEntry extends Equatable {
  const AllergiesEntry({
    this.status = PresenceStatus.unknown,
    this.types = const [],
    this.notes,
  });

  final PresenceStatus status;
  final List<String> types;
  final String? notes;

  bool get isEmpty =>
      status == PresenceStatus.unknown && types.isEmpty && _empty(notes);

  bool get isEnabled => status == PresenceStatus.present;

  AllergiesEntry copyWith({
    PresenceStatus? status,
    List<String>? types,
    String? notes,
    bool clearNotes = false,
  }) {
    return AllergiesEntry(
      status: status ?? this.status,
      types: types ?? this.types,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  AllergiesEntry clearedDetails({required PresenceStatus status}) {
    return AllergiesEntry(status: status);
  }

  factory AllergiesEntry.fromJson(Object? json) {
    if (json == null) return const AllergiesEntry();
    if (json is String) {
      if (json.trim().isEmpty) {
        return const AllergiesEntry(status: PresenceStatus.absent);
      }
      return AllergiesEntry(status: PresenceStatus.present, notes: json);
    }
    if (json is! Map<String, dynamic>) return const AllergiesEntry();
    final raw = json['types'];
    return AllergiesEntry(
      status: presenceFromJson(json['status']),
      types: raw is List ? raw.whereType<String>().toList() : const [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': presenceToJson(status),
        'types': types,
        'notes': notes,
      };

  @override
  List<Object?> get props => [status, types, notes];
}

class StylesDeVie extends Equatable {
  const StylesDeVie({
    this.alimentation = const AlimentationEntry(),
    this.alcool = const HabitEntry(),
    this.tabac = const HabitEntry(),
    this.drogues = const HabitEntry(),
    this.sedentarite,
    this.activiteParSemaine,
    this.relationsSociales,
    this.allergies = const AllergiesEntry(),
    this.notes,
  });

  final AlimentationEntry alimentation;
  final HabitEntry alcool;
  final HabitEntry tabac;
  final HabitEntry drogues;
  final String? sedentarite;
  final String? activiteParSemaine;
  final String? relationsSociales;
  final AllergiesEntry allergies;
  final String? notes;

  bool get isEmpty =>
      alimentation.isEmpty &&
      alcool.isEmpty &&
      tabac.isEmpty &&
      drogues.isEmpty &&
      _empty(sedentarite) &&
      _empty(activiteParSemaine) &&
      _empty(relationsSociales) &&
      allergies.isEmpty &&
      _empty(notes);

  StylesDeVie copyWith({
    AlimentationEntry? alimentation,
    HabitEntry? alcool,
    HabitEntry? tabac,
    HabitEntry? drogues,
    String? sedentarite,
    String? activiteParSemaine,
    String? relationsSociales,
    AllergiesEntry? allergies,
    String? notes,
    bool clearSedentarite = false,
    bool clearActivite = false,
    bool clearRelations = false,
    bool clearNotes = false,
  }) {
    return StylesDeVie(
      alimentation: alimentation ?? this.alimentation,
      alcool: alcool ?? this.alcool,
      tabac: tabac ?? this.tabac,
      drogues: drogues ?? this.drogues,
      sedentarite: clearSedentarite ? null : sedentarite ?? this.sedentarite,
      activiteParSemaine:
          clearActivite ? null : activiteParSemaine ?? this.activiteParSemaine,
      relationsSociales:
          clearRelations ? null : relationsSociales ?? this.relationsSociales,
      allergies: allergies ?? this.allergies,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory StylesDeVie.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StylesDeVie();
    return StylesDeVie(
      alimentation: AlimentationEntry.fromJson(json['alimentation']),
      alcool: HabitEntry.fromJson(json['alcool']),
      tabac: HabitEntry.fromJson(json['tabac']),
      drogues: HabitEntry.fromJson(json['drogues']),
      sedentarite: json['sedentarite'] as String?,
      activiteParSemaine: json['activite_par_semaine'] as String?,
      relationsSociales: json['relations_sociales'] as String?,
      allergies: AllergiesEntry.fromJson(json['allergies']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'alimentation': alimentation.toJson(),
        'alcool': alcool.toJson(),
        'tabac': tabac.toJson(),
        'drogues': drogues.toJson(),
        'sedentarite': sedentarite,
        'activite_par_semaine': activiteParSemaine,
        'relations_sociales': relationsSociales,
        'allergies': allergies.toJson(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        alimentation,
        alcool,
        tabac,
        drogues,
        sedentarite,
        activiteParSemaine,
        relationsSociales,
        allergies,
        notes,
      ];
}

class SellesEntry extends Equatable {
  const SellesEntry({
    this.rythme,
    this.frequence,
    this.notes,
  });

  final String? rythme;
  final String? frequence;
  final String? notes;

  bool get isEmpty =>
      _empty(rythme) && _empty(frequence) && _empty(notes);

  SellesEntry copyWith({
    String? rythme,
    String? frequence,
    String? notes,
    bool clearRythme = false,
    bool clearFrequence = false,
    bool clearNotes = false,
  }) {
    return SellesEntry(
      rythme: clearRythme ? null : rythme ?? this.rythme,
      frequence: clearFrequence ? null : frequence ?? this.frequence,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory SellesEntry.fromJson(Object? json) {
    if (json == null) return const SellesEntry();
    if (json is String) {
      if (json.trim().isEmpty) return const SellesEntry();
      return SellesEntry(notes: json);
    }
    if (json is! Map<String, dynamic>) return const SellesEntry();
    return SellesEntry(
      rythme: json['rythme'] as String?,
      frequence: json['frequence'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'rythme': rythme,
        'frequence': frequence,
        'notes': notes,
      };

  @override
  List<Object?> get props => [rythme, frequence, notes];
}

class MictionsEntry extends Equatable {
  const MictionsEntry({
    this.symptomes = const [],
    this.frequence,
    this.couleur,
    this.notes,
  });

  final List<String> symptomes;
  final String? frequence;
  final String? couleur;
  final String? notes;

  bool get isEmpty =>
      symptomes.isEmpty &&
      _empty(frequence) &&
      _empty(couleur) &&
      _empty(notes);

  MictionsEntry copyWith({
    List<String>? symptomes,
    String? frequence,
    String? couleur,
    String? notes,
    bool clearFrequence = false,
    bool clearCouleur = false,
    bool clearNotes = false,
  }) {
    return MictionsEntry(
      symptomes: symptomes ?? this.symptomes,
      frequence: clearFrequence ? null : frequence ?? this.frequence,
      couleur: clearCouleur ? null : couleur ?? this.couleur,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory MictionsEntry.fromJson(Object? json) {
    if (json == null) return const MictionsEntry();
    if (json is String) {
      if (json.trim().isEmpty) return const MictionsEntry();
      return MictionsEntry(notes: json);
    }
    if (json is! Map<String, dynamic>) return const MictionsEntry();
    final raw = json['symptomes'];
    return MictionsEntry(
      symptomes: raw is List ? raw.whereType<String>().toList() : const [],
      frequence: json['frequence'] as String?,
      couleur: json['couleur'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'symptomes': symptomes,
        'frequence': frequence,
        'couleur': couleur,
        'notes': notes,
      };

  @override
  List<Object?> get props => [symptomes, frequence, couleur, notes];
}

class ActivitesPhysiologiques extends Equatable {
  const ActivitesPhysiologiques({
    this.selles = const SellesEntry(),
    this.mictions = const MictionsEntry(),
    this.notes,
  });

  final SellesEntry selles;
  final MictionsEntry mictions;
  final String? notes;

  bool get isEmpty => selles.isEmpty && mictions.isEmpty && _empty(notes);

  ActivitesPhysiologiques copyWith({
    SellesEntry? selles,
    MictionsEntry? mictions,
    String? notes,
    bool clearNotes = false,
  }) {
    return ActivitesPhysiologiques(
      selles: selles ?? this.selles,
      mictions: mictions ?? this.mictions,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory ActivitesPhysiologiques.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActivitesPhysiologiques();
    return ActivitesPhysiologiques(
      selles: SellesEntry.fromJson(json['selles']),
      mictions: MictionsEntry.fromJson(json['mictions']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'selles': selles.toJson(),
        'mictions': mictions.toJson(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [selles, mictions, notes];
}

class ActiviteProfessionnelle extends Equatable {
  const ActiviteProfessionnelle({
    this.categorie,
    this.metier,
    this.expositions = const ConditionEntry(),
    this.expositionTypes = const [],
    this.notes,
  });

  final String? categorie;
  final String? metier;
  final ConditionEntry expositions;
  final List<String> expositionTypes;
  final String? notes;

  bool get isEmpty =>
      _empty(categorie) &&
      _empty(metier) &&
      expositions.isEmpty &&
      expositionTypes.isEmpty &&
      _empty(notes);

  ActiviteProfessionnelle copyWith({
    String? categorie,
    String? metier,
    ConditionEntry? expositions,
    List<String>? expositionTypes,
    String? notes,
    bool clearCategorie = false,
    bool clearMetier = false,
    bool clearNotes = false,
  }) {
    return ActiviteProfessionnelle(
      categorie: clearCategorie ? null : categorie ?? this.categorie,
      metier: clearMetier ? null : metier ?? this.metier,
      expositions: expositions ?? this.expositions,
      expositionTypes: expositionTypes ?? this.expositionTypes,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory ActiviteProfessionnelle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActiviteProfessionnelle();
    final legacyType = json['type_activite'];
    final legacyExpo = json['expositions'];
    var categorie = json['categorie'] as String?;
    var metier = json['metier'] as String?;
    if (legacyType is String && legacyType.trim().isNotEmpty && metier == null) {
      metier = legacyType;
    }
    ConditionEntry expositions = ConditionEntry.fromJson(
      legacyExpo is Map ? legacyExpo : json['expositions_entry'],
    );
    if (legacyExpo is String && legacyExpo.trim().isNotEmpty) {
      expositions = ConditionEntry(
        status: PresenceStatus.present,
        notes: legacyExpo,
      );
    }
    final raw = json['exposition_types'];
    return ActiviteProfessionnelle(
      categorie: categorie,
      metier: metier,
      expositions: expositions,
      expositionTypes:
          raw is List ? raw.whereType<String>().toList() : const [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'categorie': categorie,
        'metier': metier,
        'expositions_entry': expositions.toJson(),
        'exposition_types': expositionTypes,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [categorie, metier, expositions, expositionTypes, notes];
}

class Personnalite extends Equatable {
  const Personnalite({
    this.etudesTravail,
    this.perceptionSante,
    this.attitudeMaladie = const [],
    this.notes,
  });

  final String? etudesTravail;
  final String? perceptionSante;
  final List<String> attitudeMaladie;
  final String? notes;

  bool get isEmpty =>
      _empty(etudesTravail) &&
      _empty(perceptionSante) &&
      attitudeMaladie.isEmpty &&
      _empty(notes);

  Personnalite copyWith({
    String? etudesTravail,
    String? perceptionSante,
    List<String>? attitudeMaladie,
    String? notes,
    bool clearEtudes = false,
    bool clearPerception = false,
    bool clearNotes = false,
  }) {
    return Personnalite(
      etudesTravail:
          clearEtudes ? null : etudesTravail ?? this.etudesTravail,
      perceptionSante:
          clearPerception ? null : perceptionSante ?? this.perceptionSante,
      attitudeMaladie: attitudeMaladie ?? this.attitudeMaladie,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory Personnalite.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Personnalite();
    final raw = json['attitude_maladie'];
    List<String> attitudes;
    if (raw is List) {
      attitudes = raw.whereType<String>().toList();
    } else if (raw is String && raw.trim().isNotEmpty) {
      attitudes = const [];
    } else {
      attitudes = const [];
    }
    final legacyAttitude = raw is String ? raw : null;
    return Personnalite(
      etudesTravail: json['etudes_travail'] as String?,
      perceptionSante: json['perception_sante'] as String?,
      attitudeMaladie: attitudes,
      notes: json['notes'] as String? ??
          (legacyAttitude != null && legacyAttitude.trim().isNotEmpty
              ? legacyAttitude
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'etudes_travail': etudesTravail,
        'perception_sante': perceptionSante,
        'attitude_maladie': attitudeMaladie,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [etudesTravail, perceptionSante, attitudeMaladie, notes];
}

class ChroniqueFlag extends Equatable {
  const ChroniqueFlag({
    this.enabled = false,
    this.annee,
    this.suivi,
    this.notes,
  });

  final bool enabled;
  final String? annee;
  final String? suivi;
  final String? notes;

  bool get isEmpty =>
      !enabled && _empty(annee) && _empty(suivi) && _empty(notes);

  ChroniqueFlag copyWith({
    bool? enabled,
    String? annee,
    String? suivi,
    String? notes,
    bool clearAnnee = false,
    bool clearSuivi = false,
    bool clearNotes = false,
  }) {
    return ChroniqueFlag(
      enabled: enabled ?? this.enabled,
      annee: clearAnnee ? null : annee ?? this.annee,
      suivi: clearSuivi ? null : suivi ?? this.suivi,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  ChroniqueFlag clearedDetails({required bool enabled}) {
    return ChroniqueFlag(enabled: enabled);
  }

  factory ChroniqueFlag.fromJson(Object? json, {bool legacyBool = false}) {
    if (json is bool) {
      return ChroniqueFlag(enabled: json);
    }
    if (json is Map<String, dynamic>) {
      return ChroniqueFlag(
        enabled: json['enabled'] as bool? ?? legacyBool,
        annee: json['annee'] as String?,
        suivi: json['suivi'] as String?,
        notes: json['notes'] as String?,
      );
    }
    return ChroniqueFlag(enabled: legacyBool);
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'annee': annee,
        'suivi': suivi,
        'notes': notes,
      };

  @override
  List<Object?> get props => [enabled, annee, suivi, notes];
}

class MaladieChroniqueEntry extends Equatable {
  const MaladieChroniqueEntry({
    this.name,
    this.anneeApparition,
    this.symptomesDebut,
    this.lieuSuivi,
    this.modaliteSuivi,
  });

  final String? name;
  final String? anneeApparition;
  final String? symptomesDebut;
  final String? lieuSuivi;
  final String? modaliteSuivi;

  bool get isEmpty =>
      _empty(name) &&
      _empty(anneeApparition) &&
      _empty(symptomesDebut) &&
      _empty(lieuSuivi) &&
      _empty(modaliteSuivi);

  factory MaladieChroniqueEntry.fromJson(Map<String, dynamic> json) {
    return MaladieChroniqueEntry(
      name: json['name'] as String?,
      anneeApparition: json['annee_apparition'] as String?,
      symptomesDebut: json['symptomes_debut'] as String?,
      lieuSuivi: json['lieu_suivi'] as String?,
      modaliteSuivi: json['modalite_suivi'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'annee_apparition': anneeApparition,
        'symptomes_debut': symptomesDebut,
        'lieu_suivi': lieuSuivi,
        'modalite_suivi': modaliteSuivi,
      };

  @override
  List<Object?> get props =>
      [name, anneeApparition, symptomesDebut, lieuSuivi, modaliteSuivi];
}

class AntecedentsChroniques extends Equatable {
  const AntecedentsChroniques({
    this.hypertension = const ChroniqueFlag(),
    this.diabete = const ChroniqueFlag(),
    this.dyslipidemie = const ChroniqueFlag(),
    this.maladies = const [],
    this.notes,
  });

  final ChroniqueFlag hypertension;
  final ChroniqueFlag diabete;
  final ChroniqueFlag dyslipidemie;
  final List<MaladieChroniqueEntry> maladies;
  final String? notes;

  bool get isEmpty =>
      hypertension.isEmpty &&
      diabete.isEmpty &&
      dyslipidemie.isEmpty &&
      maladies.every((m) => m.isEmpty) &&
      _empty(notes);

  AntecedentsChroniques copyWith({
    ChroniqueFlag? hypertension,
    ChroniqueFlag? diabete,
    ChroniqueFlag? dyslipidemie,
    List<MaladieChroniqueEntry>? maladies,
    String? notes,
    bool clearNotes = false,
  }) {
    return AntecedentsChroniques(
      hypertension: hypertension ?? this.hypertension,
      diabete: diabete ?? this.diabete,
      dyslipidemie: dyslipidemie ?? this.dyslipidemie,
      maladies: maladies ?? this.maladies,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory AntecedentsChroniques.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AntecedentsChroniques();
    final raw = json['maladies'];
    final maladies = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(MaladieChroniqueEntry.fromJson)
            .toList()
        : <MaladieChroniqueEntry>[];
    return AntecedentsChroniques(
      hypertension: ChroniqueFlag.fromJson(
        json['hypertension_entry'] ?? json['hypertension'],
        legacyBool: json['hypertension'] == true,
      ),
      diabete: ChroniqueFlag.fromJson(
        json['diabete_entry'] ?? json['diabete'],
        legacyBool: json['diabete'] == true,
      ),
      dyslipidemie: ChroniqueFlag.fromJson(
        json['dyslipidemie_entry'] ?? json['dyslipidemie'],
        legacyBool: json['dyslipidemie'] == true,
      ),
      maladies: maladies,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'hypertension_entry': hypertension.toJson(),
        'diabete_entry': diabete.toJson(),
        'dyslipidemie_entry': dyslipidemie.toJson(),
        'maladies': maladies.map((m) => m.toJson()).toList(),
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [hypertension, diabete, dyslipidemie, maladies, notes];
}

class InterventionChirurgicaleEntry extends Equatable {
  const InterventionChirurgicaleEntry({
    this.description,
    this.date,
    this.complications,
  });

  final String? description;
  final String? date;
  final String? complications;

  bool get isEmpty =>
      _empty(description) && _empty(date) && _empty(complications);

  factory InterventionChirurgicaleEntry.fromJson(Map<String, dynamic> json) {
    return InterventionChirurgicaleEntry(
      description: json['description'] as String?,
      date: json['date'] as String?,
      complications: json['complications'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'date': date,
        'complications': complications,
      };

  @override
  List<Object?> get props => [description, date, complications];
}

class TraumatismesChirurgieInfections extends Equatable {
  const TraumatismesChirurgieInfections({
    this.traumatismesSequelles = const ConditionEntry(),
    this.chirurgieAnterieure = false,
    this.interventions = const [],
    this.infectionsEnfance = const ConditionEntry(),
    this.tuberculose = const ConditionEntry(),
    this.tumeurs = const ConditionEntry(),
    this.hepatite = const ConditionEntry(),
    this.syphilis = const ConditionEntry(),
    this.fracturesSansTraumatisme = const ConditionEntry(),
    this.notes,
  });

  final ConditionEntry traumatismesSequelles;
  final bool chirurgieAnterieure;
  final List<InterventionChirurgicaleEntry> interventions;
  final ConditionEntry infectionsEnfance;
  final ConditionEntry tuberculose;
  final ConditionEntry tumeurs;
  final ConditionEntry hepatite;
  final ConditionEntry syphilis;
  final ConditionEntry fracturesSansTraumatisme;
  final String? notes;

  bool get isEmpty =>
      traumatismesSequelles.isEmpty &&
      !chirurgieAnterieure &&
      interventions.every((i) => i.isEmpty) &&
      infectionsEnfance.isEmpty &&
      tuberculose.isEmpty &&
      tumeurs.isEmpty &&
      hepatite.isEmpty &&
      syphilis.isEmpty &&
      fracturesSansTraumatisme.isEmpty &&
      _empty(notes);

  TraumatismesChirurgieInfections copyWith({
    ConditionEntry? traumatismesSequelles,
    bool? chirurgieAnterieure,
    List<InterventionChirurgicaleEntry>? interventions,
    ConditionEntry? infectionsEnfance,
    ConditionEntry? tuberculose,
    ConditionEntry? tumeurs,
    ConditionEntry? hepatite,
    ConditionEntry? syphilis,
    ConditionEntry? fracturesSansTraumatisme,
    String? notes,
    bool clearNotes = false,
  }) {
    return TraumatismesChirurgieInfections(
      traumatismesSequelles:
          traumatismesSequelles ?? this.traumatismesSequelles,
      chirurgieAnterieure: chirurgieAnterieure ?? this.chirurgieAnterieure,
      interventions: interventions ?? this.interventions,
      infectionsEnfance: infectionsEnfance ?? this.infectionsEnfance,
      tuberculose: tuberculose ?? this.tuberculose,
      tumeurs: tumeurs ?? this.tumeurs,
      hepatite: hepatite ?? this.hepatite,
      syphilis: syphilis ?? this.syphilis,
      fracturesSansTraumatisme:
          fracturesSansTraumatisme ?? this.fracturesSansTraumatisme,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  factory TraumatismesChirurgieInfections.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return const TraumatismesChirurgieInfections();
    final raw = json['interventions'];
    final interventions = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(InterventionChirurgicaleEntry.fromJson)
            .toList()
        : <InterventionChirurgicaleEntry>[];
    return TraumatismesChirurgieInfections(
      traumatismesSequelles: ConditionEntry.fromJson(
        json['traumatismes_sequelles'],
      ),
      chirurgieAnterieure: json['chirurgie_anterieure'] as bool? ??
          interventions.any((i) => !i.isEmpty),
      interventions: interventions,
      infectionsEnfance:
          ConditionEntry.fromJson(json['infections_enfance']),
      tuberculose: ConditionEntry.fromJson(json['tuberculose']),
      tumeurs: ConditionEntry.fromJson(json['tumeurs']),
      hepatite: ConditionEntry.fromJson(json['hepatite']),
      syphilis: ConditionEntry.fromJson(json['syphilis']),
      fracturesSansTraumatisme:
          ConditionEntry.fromJson(json['fractures_sans_traumatisme']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'traumatismes_sequelles': traumatismesSequelles.toJson(),
        'chirurgie_anterieure': chirurgieAnterieure,
        'interventions': interventions.map((i) => i.toJson()).toList(),
        'infections_enfance': infectionsEnfance.toJson(),
        'tuberculose': tuberculose.toJson(),
        'tumeurs': tumeurs.toJson(),
        'hepatite': hepatite.toJson(),
        'syphilis': syphilis.toJson(),
        'fractures_sans_traumatisme': fracturesSansTraumatisme.toJson(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        traumatismesSequelles,
        chirurgieAnterieure,
        interventions,
        infectionsEnfance,
        tuberculose,
        tumeurs,
        hepatite,
        syphilis,
        fracturesSansTraumatisme,
        notes,
      ];
}

bool _empty(String? value) => value == null || value.trim().isEmpty;

/// Helpers for birth place + anamnèse stored in [Patient.metadata].
abstract final class PatientMetadataKeys {
  static const birthPlace = 'birthPlace';
  static const anamnese = 'anamnese';
}

extension PatientAnamneseMetadata on Map<String, dynamic>? {
  String? get birthPlace {
    final value = this?[PatientMetadataKeys.birthPlace];
    return value is String && value.isNotEmpty ? value : null;
  }

  Anamnese get anamnese {
    final raw = this?[PatientMetadataKeys.anamnese];
    if (raw is Map<String, dynamic>) {
      return Anamnese.fromJson(raw);
    }
    return const Anamnese();
  }

  Map<String, dynamic> withBirthPlace(String? birthPlace) {
    final next = Map<String, dynamic>.from(this ?? {});
    if (birthPlace == null || birthPlace.trim().isEmpty) {
      next.remove(PatientMetadataKeys.birthPlace);
    } else {
      next[PatientMetadataKeys.birthPlace] = birthPlace.trim();
    }
    return next;
  }

  Map<String, dynamic> withAnamnese(Anamnese anamnese) {
    final next = Map<String, dynamic>.from(this ?? {});
    if (anamnese.isEmpty) {
      next.remove(PatientMetadataKeys.anamnese);
    } else {
      next[PatientMetadataKeys.anamnese] = anamnese.toJson();
    }
    return next;
  }
}
