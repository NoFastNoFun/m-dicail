import 'package:equatable/equatable.dart';

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
    this.allaitement,
    this.marche,
    this.dentition,
    this.phonation,
    this.notes,
  });

  final String? poidsNaissance;
  /// maternel | artificiel | mixte
  final String? allaitement;
  final String? marche;
  final String? dentition;
  final String? phonation;
  final String? notes;

  bool get isEmpty =>
      _empty(poidsNaissance) &&
      _empty(allaitement) &&
      _empty(marche) &&
      _empty(dentition) &&
      _empty(phonation) &&
      _empty(notes);

  NaissanceEnfance copyWith({
    String? poidsNaissance,
    String? allaitement,
    String? marche,
    String? dentition,
    String? phonation,
    String? notes,
  }) {
    return NaissanceEnfance(
      poidsNaissance: poidsNaissance ?? this.poidsNaissance,
      allaitement: allaitement ?? this.allaitement,
      marche: marche ?? this.marche,
      dentition: dentition ?? this.dentition,
      phonation: phonation ?? this.phonation,
      notes: notes ?? this.notes,
    );
  }

  factory NaissanceEnfance.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NaissanceEnfance();
    return NaissanceEnfance(
      poidsNaissance: json['poids_naissance'] as String?,
      allaitement: json['allaitement'] as String?,
      marche: json['marche'] as String?,
      dentition: json['dentition'] as String?,
      phonation: json['phonation'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'poids_naissance': poidsNaissance,
        'allaitement': allaitement,
        'marche': marche,
        'dentition': dentition,
        'phonation': phonation,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [poidsNaissance, allaitement, marche, dentition, phonation, notes];
}

class VieFamilialeSexuelle extends Equatable {
  const VieFamilialeSexuelle({
    this.mariageGrossesses,
    this.sexualite,
    this.menopause,
    this.notes,
  });

  final String? mariageGrossesses;
  final String? sexualite;
  final String? menopause;
  final String? notes;

  bool get isEmpty =>
      _empty(mariageGrossesses) &&
      _empty(sexualite) &&
      _empty(menopause) &&
      _empty(notes);

  VieFamilialeSexuelle copyWith({
    String? mariageGrossesses,
    String? sexualite,
    String? menopause,
    String? notes,
  }) {
    return VieFamilialeSexuelle(
      mariageGrossesses: mariageGrossesses ?? this.mariageGrossesses,
      sexualite: sexualite ?? this.sexualite,
      menopause: menopause ?? this.menopause,
      notes: notes ?? this.notes,
    );
  }

  factory VieFamilialeSexuelle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VieFamilialeSexuelle();
    return VieFamilialeSexuelle(
      mariageGrossesses: json['mariage_grossesses'] as String?,
      sexualite: json['sexualite'] as String?,
      menopause: json['menopause'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mariage_grossesses': mariageGrossesses,
        'sexualite': sexualite,
        'menopause': menopause,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [mariageGrossesses, sexualite, menopause, notes];
}

class StylesDeVie extends Equatable {
  const StylesDeVie({
    this.alimentation,
    this.alcool,
    this.tabac,
    this.drogues,
    this.sedentarite,
    this.relationsSociales,
    this.allergies,
    this.notes,
  });

  final String? alimentation;
  final String? alcool;
  final String? tabac;
  final String? drogues;
  final String? sedentarite;
  final String? relationsSociales;
  final String? allergies;
  final String? notes;

  bool get isEmpty =>
      _empty(alimentation) &&
      _empty(alcool) &&
      _empty(tabac) &&
      _empty(drogues) &&
      _empty(sedentarite) &&
      _empty(relationsSociales) &&
      _empty(allergies) &&
      _empty(notes);

  StylesDeVie copyWith({
    String? alimentation,
    String? alcool,
    String? tabac,
    String? drogues,
    String? sedentarite,
    String? relationsSociales,
    String? allergies,
    String? notes,
  }) {
    return StylesDeVie(
      alimentation: alimentation ?? this.alimentation,
      alcool: alcool ?? this.alcool,
      tabac: tabac ?? this.tabac,
      drogues: drogues ?? this.drogues,
      sedentarite: sedentarite ?? this.sedentarite,
      relationsSociales: relationsSociales ?? this.relationsSociales,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
    );
  }

  factory StylesDeVie.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StylesDeVie();
    return StylesDeVie(
      alimentation: json['alimentation'] as String?,
      alcool: json['alcool'] as String?,
      tabac: json['tabac'] as String?,
      drogues: json['drogues'] as String?,
      sedentarite: json['sedentarite'] as String?,
      relationsSociales: json['relations_sociales'] as String?,
      allergies: json['allergies'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'alimentation': alimentation,
        'alcool': alcool,
        'tabac': tabac,
        'drogues': drogues,
        'sedentarite': sedentarite,
        'relations_sociales': relationsSociales,
        'allergies': allergies,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        alimentation,
        alcool,
        tabac,
        drogues,
        sedentarite,
        relationsSociales,
        allergies,
        notes,
      ];
}

class ActivitesPhysiologiques extends Equatable {
  const ActivitesPhysiologiques({
    this.selles,
    this.mictions,
    this.notes,
  });

  final String? selles;
  final String? mictions;
  final String? notes;

  bool get isEmpty =>
      _empty(selles) && _empty(mictions) && _empty(notes);

  ActivitesPhysiologiques copyWith({
    String? selles,
    String? mictions,
    String? notes,
  }) {
    return ActivitesPhysiologiques(
      selles: selles ?? this.selles,
      mictions: mictions ?? this.mictions,
      notes: notes ?? this.notes,
    );
  }

  factory ActivitesPhysiologiques.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActivitesPhysiologiques();
    return ActivitesPhysiologiques(
      selles: json['selles'] as String?,
      mictions: json['mictions'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'selles': selles,
        'mictions': mictions,
        'notes': notes,
      };

  @override
  List<Object?> get props => [selles, mictions, notes];
}

class ActiviteProfessionnelle extends Equatable {
  const ActiviteProfessionnelle({
    this.typeActivite,
    this.expositions,
    this.notes,
  });

  final String? typeActivite;
  final String? expositions;
  final String? notes;

  bool get isEmpty =>
      _empty(typeActivite) && _empty(expositions) && _empty(notes);

  ActiviteProfessionnelle copyWith({
    String? typeActivite,
    String? expositions,
    String? notes,
  }) {
    return ActiviteProfessionnelle(
      typeActivite: typeActivite ?? this.typeActivite,
      expositions: expositions ?? this.expositions,
      notes: notes ?? this.notes,
    );
  }

  factory ActiviteProfessionnelle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActiviteProfessionnelle();
    return ActiviteProfessionnelle(
      typeActivite: json['type_activite'] as String?,
      expositions: json['expositions'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type_activite': typeActivite,
        'expositions': expositions,
        'notes': notes,
      };

  @override
  List<Object?> get props => [typeActivite, expositions, notes];
}

class Personnalite extends Equatable {
  const Personnalite({
    this.etudesTravail,
    this.perceptionSante,
    this.attitudeMaladie,
    this.notes,
  });

  final String? etudesTravail;
  final String? perceptionSante;
  final String? attitudeMaladie;
  final String? notes;

  bool get isEmpty =>
      _empty(etudesTravail) &&
      _empty(perceptionSante) &&
      _empty(attitudeMaladie) &&
      _empty(notes);

  Personnalite copyWith({
    String? etudesTravail,
    String? perceptionSante,
    String? attitudeMaladie,
    String? notes,
  }) {
    return Personnalite(
      etudesTravail: etudesTravail ?? this.etudesTravail,
      perceptionSante: perceptionSante ?? this.perceptionSante,
      attitudeMaladie: attitudeMaladie ?? this.attitudeMaladie,
      notes: notes ?? this.notes,
    );
  }

  factory Personnalite.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Personnalite();
    return Personnalite(
      etudesTravail: json['etudes_travail'] as String?,
      perceptionSante: json['perception_sante'] as String?,
      attitudeMaladie: json['attitude_maladie'] as String?,
      notes: json['notes'] as String?,
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
    this.hypertension = false,
    this.diabete = false,
    this.dyslipidemie = false,
    this.maladies = const [],
    this.notes,
  });

  final bool hypertension;
  final bool diabete;
  final bool dyslipidemie;
  final List<MaladieChroniqueEntry> maladies;
  final String? notes;

  bool get isEmpty =>
      !hypertension &&
      !diabete &&
      !dyslipidemie &&
      maladies.every((m) => m.isEmpty) &&
      _empty(notes);

  AntecedentsChroniques copyWith({
    bool? hypertension,
    bool? diabete,
    bool? dyslipidemie,
    List<MaladieChroniqueEntry>? maladies,
    String? notes,
  }) {
    return AntecedentsChroniques(
      hypertension: hypertension ?? this.hypertension,
      diabete: diabete ?? this.diabete,
      dyslipidemie: dyslipidemie ?? this.dyslipidemie,
      maladies: maladies ?? this.maladies,
      notes: notes ?? this.notes,
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
      hypertension: json['hypertension'] as bool? ?? false,
      diabete: json['diabete'] as bool? ?? false,
      dyslipidemie: json['dyslipidemie'] as bool? ?? false,
      maladies: maladies,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'hypertension': hypertension,
        'diabete': diabete,
        'dyslipidemie': dyslipidemie,
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
    this.traumatismesSequelles,
    this.interventions = const [],
    this.infectionsEnfance,
    this.tuberculose,
    this.tumeurs,
    this.hepatite,
    this.syphilis,
    this.fracturesSansTraumatisme,
    this.notes,
  });

  final String? traumatismesSequelles;
  final List<InterventionChirurgicaleEntry> interventions;
  final String? infectionsEnfance;
  final String? tuberculose;
  final String? tumeurs;
  final String? hepatite;
  final String? syphilis;
  final String? fracturesSansTraumatisme;
  final String? notes;

  bool get isEmpty =>
      _empty(traumatismesSequelles) &&
      interventions.every((i) => i.isEmpty) &&
      _empty(infectionsEnfance) &&
      _empty(tuberculose) &&
      _empty(tumeurs) &&
      _empty(hepatite) &&
      _empty(syphilis) &&
      _empty(fracturesSansTraumatisme) &&
      _empty(notes);

  TraumatismesChirurgieInfections copyWith({
    String? traumatismesSequelles,
    List<InterventionChirurgicaleEntry>? interventions,
    String? infectionsEnfance,
    String? tuberculose,
    String? tumeurs,
    String? hepatite,
    String? syphilis,
    String? fracturesSansTraumatisme,
    String? notes,
  }) {
    return TraumatismesChirurgieInfections(
      traumatismesSequelles:
          traumatismesSequelles ?? this.traumatismesSequelles,
      interventions: interventions ?? this.interventions,
      infectionsEnfance: infectionsEnfance ?? this.infectionsEnfance,
      tuberculose: tuberculose ?? this.tuberculose,
      tumeurs: tumeurs ?? this.tumeurs,
      hepatite: hepatite ?? this.hepatite,
      syphilis: syphilis ?? this.syphilis,
      fracturesSansTraumatisme:
          fracturesSansTraumatisme ?? this.fracturesSansTraumatisme,
      notes: notes ?? this.notes,
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
      traumatismesSequelles: json['traumatismes_sequelles'] as String?,
      interventions: interventions,
      infectionsEnfance: json['infections_enfance'] as String?,
      tuberculose: json['tuberculose'] as String?,
      tumeurs: json['tumeurs'] as String?,
      hepatite: json['hepatite'] as String?,
      syphilis: json['syphilis'] as String?,
      fracturesSansTraumatisme: json['fractures_sans_traumatisme'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'traumatismes_sequelles': traumatismesSequelles,
        'interventions': interventions.map((i) => i.toJson()).toList(),
        'infections_enfance': infectionsEnfance,
        'tuberculose': tuberculose,
        'tumeurs': tumeurs,
        'hepatite': hepatite,
        'syphilis': syphilis,
        'fractures_sans_traumatisme': fracturesSansTraumatisme,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        traumatismesSequelles,
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
