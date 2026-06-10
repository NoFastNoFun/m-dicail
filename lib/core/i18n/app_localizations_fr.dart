// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Medicail';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get recordTitle => 'Enregistrement';

  @override
  String get buttonStart => 'Démarrer';

  @override
  String get buttonStop => 'Arrêter';

  @override
  String get buttonSave => 'Enregistrer';

  @override
  String get buttonFinishConsultation => 'Terminer consultation';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get errorNetwork => 'Problème de connexion';

  @override
  String get errorServer => 'Erreur serveur';

  @override
  String get errorAudio => 'Microphone indisponible';

  @override
  String get labelHistory => 'Historique';

  @override
  String get navigateToPatients => 'Dossiers patients';

  @override
  String get navigateToRecord => 'Nouvel enregistrement';

  @override
  String get transcriptLabel => 'Transcription';

  @override
  String get transcriptEmptyHint => 'Aucune parole captee pour le moment';

  @override
  String get transcriptEmptyFallback => 'Transcription vide';

  @override
  String get buttonClear => 'Effacer';

  @override
  String get recordStatusReady => 'Pret a ecouter';

  @override
  String get recordStatusInitializing => 'Initialisation du micro';

  @override
  String get recordStatusListening => 'Ecoute en cours';

  @override
  String get recordStatusPaused => 'Ecoute en pause';

  @override
  String get recordStatusEnded => 'Session terminee';

  @override
  String get historyEmpty => 'Aucune note pour le moment';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsSectionTitle => 'Dossiers patients';

  @override
  String get patientsEmpty => 'Aucun patient pour le moment';

  @override
  String get patientFirstNameLabel => 'Prenom';

  @override
  String get patientLastNameLabel => 'Nom';

  @override
  String get patientCreateButton => 'Creer le patient';

  @override
  String get patientOpenButton => 'Ouvrir le dossier';

  @override
  String get patientDetailTitle => 'Dossier patient';

  @override
  String get patientNotFound => 'Patient introuvable';

  @override
  String get patientMrnConflict => 'Le numéro de dossier (MRN) existe déjà.';

  @override
  String get patientNewConsultationButton => 'Nouvelle consultation';

  @override
  String get patientSessionsTitle => 'Consultations';

  @override
  String get patientSessionsEmpty => 'Aucune consultation pour ce patient';

  @override
  String get recordingStatusLabel => 'Statut';

  @override
  String get recordingAudioLabel => 'Audio';

  @override
  String get inputErrorRequired => 'Ce champ est obligatoire';

  @override
  String get inputErrorEmail => 'Adresse e-mail invalide';

  @override
  String get inputErrorNumber => 'Nombre invalide';

  @override
  String get inputErrorPassword =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get inputPasswordToggle => 'Afficher le mot de passe';

  @override
  String get debugShakeTitle => 'Mode développeur';

  @override
  String get debugShakeMessage =>
      'Ouvrir la page de démonstration des composants ?';

  @override
  String get debugShakeConfirm => 'Oui';

  @override
  String get debugShakeCancel => 'Non';

  @override
  String get debugPageTitle => 'Composants UI';

  @override
  String get debugSectionButtons => 'Boutons';

  @override
  String get debugSectionInputs => 'Champs';

  @override
  String get debugSectionBottomSheet => 'Bottom sheet';

  @override
  String get debugSectionDialog => 'Dialogues';

  @override
  String get debugSectionToast => 'Toasts';

  @override
  String get debugButtonPrimary => 'Primaire';

  @override
  String get debugButtonSecondary => 'Secondaire';

  @override
  String get debugButtonWarning => 'Avertissement';

  @override
  String get debugButtonError => 'Erreur';

  @override
  String get debugButtonLoading => 'Chargement';

  @override
  String get debugButtonDisabled => 'Désactivé';

  @override
  String get debugButtonIcon => 'Icône';

  @override
  String get debugButtonTextIcon => 'Texte + icône';

  @override
  String get debugInputText => 'Texte';

  @override
  String get debugInputNumber => 'Nombre';

  @override
  String get debugInputEmail => 'E-mail';

  @override
  String get debugInputPassword => 'Mot de passe';

  @override
  String get debugInputTextarea => 'Zone de texte';

  @override
  String get debugOpenBottomSheet => 'Ouvrir bottom sheet';

  @override
  String get debugBottomSheetTitle => 'Bottom sheet personnalisé';

  @override
  String get debugBottomSheetBody => 'Contenu personnalisable du bottom sheet.';

  @override
  String get debugOpenFullscreenDialog => 'Dialogue plein écran';

  @override
  String get debugOpenLockDialog => 'Dialogue verrouillé';

  @override
  String get debugFullscreenTitle => 'Plein écran';

  @override
  String get debugFullscreenBody => 'Exemple de dialogue plein écran.';

  @override
  String get debugLockTitle => 'Écran verrouillé';

  @override
  String get debugLockBody =>
      'Ce dialogue ne peut pas être fermé par un tap extérieur.';

  @override
  String get debugLockDismiss => 'Déverrouiller';

  @override
  String get debugToastSuccess => 'Opération réussie';

  @override
  String get debugToastWarning => 'Attention requise';

  @override
  String get debugToastError => 'Une erreur est survenue';

  @override
  String get debugToastInfo => 'Information';

  @override
  String get debugShowToastSuccess => 'Toast succès';

  @override
  String get debugShowToastWarning => 'Toast avertissement';

  @override
  String get debugShowToastError => 'Toast erreur';

  @override
  String get debugShowToastInfo => 'Toast info';

  @override
  String get debugClose => 'Fermer';

  @override
  String get soapNoteTitle => 'Note SOAP';

  @override
  String get soapNoteSubjective => 'Subjectif';

  @override
  String get soapNoteObjective => 'Objectif';

  @override
  String get soapNoteAssessment => 'Évaluation';

  @override
  String get soapNotePlan => 'Plan';

  @override
  String get soapNoteSave => 'Enregistrer la note';

  @override
  String get soapNoteViewAction => 'Voir la note SOAP';

  @override
  String get patientSearchPlaceholder => 'Rechercher un patient';

  @override
  String get patientCreateErrorRequired => 'MRN, Prénom et Nom sont requis.';

  @override
  String get patientCreateSuccess => 'Dossier patient créé avec succès.';

  @override
  String get patientCreateTitle => 'Nouveau Patient';

  @override
  String get patientMrnLabel => 'MRN (Numéro de dossier) *';

  @override
  String get patientFirstNameRequiredLabel => 'Prénom *';

  @override
  String get patientLastNameRequiredLabel => 'Nom *';

  @override
  String get patientBirthDateLabel => 'Date de naissance';

  @override
  String get patientBirthDateSelect => 'Sélectionner';

  @override
  String get patientSexLabel => 'Sexe';

  @override
  String get patientSexMale => 'Homme';

  @override
  String get patientSexFemale => 'Femme';

  @override
  String get patientSexOther => 'Autre';

  @override
  String get patientEmailLabel => 'Email';

  @override
  String get patientPhoneLabel => 'Téléphone';

  @override
  String get patientAddressLabel => 'Adresse';

  @override
  String get patientNotesLabel => 'Notes';

  @override
  String get patientCreateSubmit => 'Créer le dossier';

  @override
  String get loginWelcomeTitle => 'Bienvenue sur Medicail';

  @override
  String get loginWelcomeSubtitle =>
      'Connectez-vous pour accéder à vos dossiers.';

  @override
  String get loginEmailLabel => 'Adresse email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginCreateAccountButton => 'Créer un compte';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Rejoignez Medicail pour gérer vos consultations.';

  @override
  String get registerFullNameLabel => 'Nom complet (optionnel)';

  @override
  String get registerEmailLabel => 'Adresse email';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerSubmit => 'S\'inscrire';

  @override
  String get recordingDateLabel => 'Date';

  @override
  String get assignPatientTitle => 'Associer à un patient';

  @override
  String get assignPatientSearchTab => 'Rechercher';

  @override
  String get assignPatientNewTab => 'Nouveau patient';

  @override
  String get assignPatientError => 'Erreur lors de l\'association';

  @override
  String get tutorialIntroTitle => 'Decouvrir Medicail';

  @override
  String get tutorialIntroDesc =>
      'Un tutoriel rapide peut vous guider dans la creation d\'un dossier patient, une premiere consultation, puis un enregistrement rapide depuis l\'accueil.';

  @override
  String get tutorialIntroStart => 'Faire le tutoriel';

  @override
  String get tutorialIntroSkip => 'Passer';

  @override
  String get tutorialHomePatientsTitle => 'Dossiers Patients';

  @override
  String get tutorialHomePatientsDesc =>
      'Cliquez ici pour accéder à la liste de vos patients ou en créer un nouveau.';

  @override
  String get tutorialHomeRecordTitle => 'Consultation Rapide';

  @override
  String get tutorialHomeRecordDesc =>
      'Depuis l\'ecran d\'accueil, utilisez ce bouton pour demarrer immediatement une consultation vocale.';

  @override
  String get tutorialPatientAddTitle => 'Ajouter un patient';

  @override
  String get tutorialPatientAddDesc =>
      'C\'est ici que vous pouvez créer un nouveau dossier patient en renseignant ses informations de base.';

  @override
  String get tutorialPatientMrnTitle => 'Numero de dossier';

  @override
  String get tutorialPatientMrnDesc =>
      'Renseignez l\'identifiant unique du patient. Ce champ est obligatoire.';

  @override
  String get tutorialPatientFirstNameTitle => 'Prenom du patient';

  @override
  String get tutorialPatientFirstNameDesc =>
      'Saisissez le prenom du patient pour completer son dossier.';

  @override
  String get tutorialPatientLastNameTitle => 'Nom du patient';

  @override
  String get tutorialPatientLastNameDesc =>
      'Saisissez le nom du patient. Les autres champs peuvent etre completes plus tard.';

  @override
  String get tutorialPatientCreateTitle => 'Creer le dossier';

  @override
  String get tutorialPatientCreateDesc =>
      'Une fois les champs obligatoires remplis, creez le dossier pour continuer vers la premiere consultation.';

  @override
  String get tutorialDetailConsultTitle => 'Nouvelle consultation';

  @override
  String get tutorialDetailConsultDesc =>
      'Lancez l\'enregistrement vocal pour démarrer une nouvelle consultation avec ce patient.';

  @override
  String get tutorialRecordTitle => 'La Dictée';

  @override
  String get tutorialRecordDesc =>
      'Appuyez sur ce bouton pour lancer l\'enregistrement vocal. L\'IA transcrira automatiquement vos paroles et anonymisera les données.';

  @override
  String get tutorialRecordStopTitle => 'Arreter l\'ecoute';

  @override
  String get tutorialRecordStopDesc =>
      'Appuyez ici quand la consultation vocale est terminee pour mettre l\'ecoute en pause.';

  @override
  String get tutorialRecordFinishTitle => 'Terminer la consultation';

  @override
  String get tutorialRecordFinishDesc =>
      'Validez la fin de la consultation. Vous reviendrez ensuite a l\'accueil pour voir le workflow Nouvel enregistrement.';

  @override
  String get tutorialRecordTranscriptTitle => 'Transcription en temps reel';

  @override
  String get tutorialRecordTranscriptDesc =>
      'Pendant l\'enregistrement, le texte apparait ici en direct pour vous permettre de suivre la dictee.';
}
