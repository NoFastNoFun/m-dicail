import 'package:medicail/features/templates/domain/entities/soap_template.dart';

abstract final class DefaultSoapTemplates {
  static final DateTime _seedDate = DateTime.utc(2026, 1, 1);

  static List<SoapTemplate> all() {
    return [
      _lombalgie,
      _entorseCheville,
      _cervicalgie,
      _tendinopathieAchille,
      _postOpLca,
      _capsuliteRetractile,
      _syndromePatelloFemoral,
      _epicondyliteLaterale,
      _postOpPth,
      _sciatalgie,
    ];
  }

  static final SoapTemplate _lombalgie = SoapTemplate(
    id: 'template_lombalgie_commune',
    pathologyName: 'Lombalgie commune',
    subjectiveDefault: '''- Motif : lombalgie commune
- Triggers musculaires identifies :
- Aggravants / soulageants :
- Impact activites quotidiennes et reprise sport :''',
    objectiveDefault: '''- Mobilites lombaires (flexion, extension, rotations) :
- Palpation paravertebrale / fessiers :
- Tests neuro-moteurs peripheriques :
- Posture et strategies de compensation :''',
    assessmentDefault: '''- Hypothese mecanique dominante :
- Niveau d'irritabilite :
- Criteres de reprise progressive d'activite :''',
    planDefault: '''- Traitement manuel / exercices cibles :
- Calendrier de reprise d'activite (etapes) :
- Education patient (gestes, positions) :
- Prochaine seance :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _entorseCheville = SoapTemplate(
    id: 'template_entorse_cheville',
    pathologyName: 'Entorse de cheville (stade 1/2)',
    subjectiveDefault: '''- Mecanisme de l'entorse :
- Douleur et gene fonctionnelle :
- Antecedents entorses :''',
    objectiveDefault: '''- Criteres d'Ottawa (si applicable) :
- Oedeme et perimetrie cheville :
- Laxite (tiroir, tilt) :
- Amplitudes et force residuelle :''',
    assessmentDefault: '''- Stade lesionnel estime (1/2) :
- Risque instabilite :
- Objectifs proprioception :''',
    planDefault: '''- Protection / decharge initiale :
- Travail proprioception et renforcement :
- Critere reprise course :
- Suivi perimetrie :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _cervicalgie = SoapTemplate(
    id: 'template_cervicalgie_chronique',
    pathologyName: 'Cervicalgie chronique / tensionnelle',
    subjectiveDefault: '''- Duree et type de cervicalgie :
- Facteurs posturaux (bureau, ecran) :
- Cephalees associees :''',
    objectiveDefault: '''- Amplitudes cervicales (flex-ext, rotations, laterales) :
- Palpation trapezes / sous-occipitaux :
- Posture cephalique et scapulaire :''',
    assessmentDefault: '''- Profil tensionnel vs mobilitaire :
- Priorites ergonomie bureau :
- Irritabilite actuelle :''',
    planDefault: '''- Mobilisation / assouplissement cible :
- Renforcement profond cervical :
- Conseils ergonomie poste de travail :
- Auto-gestion douleur :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _tendinopathieAchille = SoapTemplate(
    id: 'template_tendinopathie_achille',
    pathologyName: 'Tendinopathie du tendon d\'Achille',
    subjectiveDefault: '''- Localisation douleur (insertionnel / corps) :
- Charge sportive recente :
- Raideur matinale :''',
    objectiveDefault: '''- Douleur a la palpation (localisation) :
- Amplitudes cheville :
- Protocole Stanish (excentrique) tolerance :
- Suivi charge (volume, intensite) :''',
    assessmentDefault: '''- Stade tendinopathie :
- Tolerance charge actuelle :
- Facteurs de surcharge :''',
    planDefault: '''- Protocole excentrique progressif :
- Planification charge (semaines) :
- Modifications entrainement :
- Criteres progression :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _postOpLca = SoapTemplate(
    id: 'template_post_op_lca',
    pathologyName: 'Post-operatoire - Rupture LCA',
    subjectiveDefault: '''- Date chirurgie et type greffe :
- Protocole chirurgical / consignes :
- Douleur et gene actuelle :''',
    objectiveDefault: '''- Extension complete / flexum :
- Reveil quadriceps (activation, atrophie) :
- Trophicite membre inferieur :
- Cicatrice et oedeme :''',
    assessmentDefault: '''- Phase de recuperation post-op :
- Deficits prioritaires (extension, flexum, quad) :
- Precautions articulaires :''',
    planDefault: '''- Travail extension / flexum :
- Renforcement quadriceps progressif :
- Gestion cicatrice et oedeme :
- Objectifs phase suivante :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _capsuliteRetractile = SoapTemplate(
    id: 'template_capsulite_retractile',
    pathologyName: 'Capsulite retractile (epaule gelee)',
    subjectiveDefault: '''- Duree evolution et phase estimee :
- Douleur nocturne :
- Limitation activites :''',
    objectiveDefault: '''- Amplitudes passives (flex-ext, abduction, rotations) :
- Amplitudes actives :
- Douleur palpation capsule :''',
    assessmentDefault: '''- Phase capsulite (freezing / frozen / thawing) :
- Priorite douleur vs amplitude :
- Prognostic fonctionnel :''',
    planDefault: '''- Mobilisation passive / active assistee :
- Gestion douleur nocturne :
- Education phases de la pathologie :
- Exercices domicile :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _syndromePatelloFemoral = SoapTemplate(
    id: 'template_syndrome_patello_femoral',
    pathologyName: 'Syndrome patello-femoral (genou du coureur)',
    subjectiveDefault: '''- Activite declenchante (course, escaliers) :
- Localisation douleur (retro-patellaire) :
- Volume course recent :''',
    objectiveDefault: '''- Tracking patella / Q angle :
- Force moyen fessier (tests fonctionnels) :
- Squat qualitatif (alignement genou) :
- Tests compressif patellaire :''',
    assessmentDefault: '''- Facteurs biomecaniques dominants :
- Tolerance charge fonctionnelle :
- Objectifs retour course :''',
    planDefault: '''- Renforcement moyen fessier / chaine posterieure :
- Reeducation squat qualitatif :
- Progression course (volume, terrain) :
- Auto-surveillance symptomes :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _epicondyliteLaterale = SoapTemplate(
    id: 'template_epicondylite_laterale',
    pathologyName: 'Epicondylite laterale (tennis elbow)',
    subjectiveDefault: '''- Activites declenchantes (prise, travail) :
- Duree symptomes :
- Laterality :''',
    objectiveDefault: '''- Tests de Mills / Cozen :
- Force de prehension (dynamometrie si dispo) :
- Palpation epicondyle lateral :
- Etirements epicondyliens tolerance :''',
    assessmentDefault: '''- Irritabilite tendineuse :
- Impact fonction prehension :
- Phase recuperation :''',
    planDefault: '''- Etirements et renforcement progressif avant-bras :
- Adaptation activites professionnelles :
- Controle charge prehension :
- Criteres reprise sport raquette :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _postOpPth = SoapTemplate(
    id: 'template_post_op_pth',
    pathologyName: 'Post-operatoire - Prothese totale de hanche (PTH)',
    subjectiveDefault: '''- Date PTH et voie d'abord :
- Consignes anti-luxation rappellees :
- Douleur et autonomie actuelle :''',
    objectiveDefault: '''- Etat cicatrice :
- Boiterie d'esquive :
- Verrouillage fessier :
- Amplitudes hanche (flexion, rotations selon consignes) :''',
    assessmentDefault: '''- Phase post-op et precautions :
- Deficits moteurs prioritaires :
- Conformite consignes anti-luxation :''',
    planDefault: '''- Renforcement fessier / stabilite :
- Marche et equilibre :
- Rappel consignes anti-luxation :
- Progression activites quotidiennes :''',
    createdAt: _seedDate,
  );

  static final SoapTemplate _sciatalgie = SoapTemplate(
    id: 'template_sciatalgie_radiculopathie',
    pathologyName: 'Sciatalgie / radiculopathie lombaire',
    subjectiveDefault: '''- Topographie douleur (dermatome) :
- Paresthesies / deficit rapportes :
- Centralisation / peripherisation :''',
    objectiveDefault: '''- Test de Lasègue (SLR) :
- Deficits moteurs ou sensitifs :
- Mobilites lombaires :
- Signes d'alerte exclus :''',
    assessmentDefault: '''- Niveau radiculaire suspecte :
- Evolution centralisation :
- Criteres avis medical urgent :''',
    planDefault: '''- Exercices neuro-dynamiques / mobilisation :
- Education postures et positions :
- Surveillance deficits :
- Plan suivi selon evolution :''',
    createdAt: _seedDate,
  );
}
