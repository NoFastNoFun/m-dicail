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
  String get homeSignIn => 'Se connecter';

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
  String get recordNotificationTitle => 'Ecoute en cours';

  @override
  String get recordNotificationBody => 'Touchez pour revenir a Medicail';

  @override
  String get recordNotificationBackgroundTitle =>
      'Enregistrement en arriere-plan';

  @override
  String get recordNotificationBackgroundBody =>
      'L\'ecoute continue pendant que l\'ecran est eteint';

  @override
  String get recordStatusTranscribingBackground =>
      'Transcription du passage en veille…';

  @override
  String get historyEmpty => 'Aucune note pour le moment';

  @override
  String get appointmentsTodayTitle => 'Rendez-vous du jour';

  @override
  String get appointmentsUpcomingTitle => 'Prochains rendez-vous';

  @override
  String get appointmentsDayTitle => 'Agenda';

  @override
  String get appointmentsSeeAll => 'Voir tout';

  @override
  String get appointmentsEmpty => 'Aucun rendez-vous pour cette journee';

  @override
  String get appointmentsUpcomingEmpty => 'Aucun prochain rendez-vous';

  @override
  String get appointmentCreateTitle => 'Nouveau rendez-vous';

  @override
  String get appointmentEditTitle => 'Modifier le rendez-vous';

  @override
  String get appointmentCreateSubmit => 'Creer le rendez-vous';

  @override
  String get appointmentSaveChanges => 'Enregistrer';

  @override
  String get appointmentSaved => 'Rendez-vous enregistre';

  @override
  String get appointmentEdit => 'Modifier';

  @override
  String get appointmentCancel => 'Annuler';

  @override
  String get appointmentDelete => 'Supprimer';

  @override
  String get appointmentNotesLabel => 'Notes';

  @override
  String get appointmentPatientRequired => 'Selectionnez un patient';

  @override
  String get appointmentEndBeforeStart =>
      'L\'heure de fin doit etre apres l\'heure de debut';

  @override
  String get appointmentKeepPatientHint =>
      'Laissez le patient actuel, ou choisissez-en un autre ci-dessous.';

  @override
  String get appointmentStatusScheduled => 'Planifie';

  @override
  String get appointmentStatusCancelled => 'Annule';

  @override
  String get appointmentStatusCompleted => 'Termine';

  @override
  String appointmentStartTime(String time) {
    return 'Debut $time';
  }

  @override
  String appointmentEndTime(String time) {
    return 'Fin $time';
  }

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
  String get debugSectionBackend => 'Backend (debug)';

  @override
  String get debugBackendUrlSubtitle =>
      'Surcharge l\'URL de l\'API. Disponible uniquement en debug sur bureau.';

  @override
  String get debugBackendUrlLabel => 'URL de l\'API';

  @override
  String get debugBackendUrlHint => 'http://localhost:3000/api/v1';

  @override
  String get debugBackendUrlSave => 'Enregistrer';

  @override
  String get debugBackendUrlReset => 'Reinitialiser';

  @override
  String get debugBackendUrlSaved => 'URL backend mise a jour';

  @override
  String get debugBackendUrlInvalid => 'URL invalide (http ou https requis)';

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
      'Connectez-vous pour synchroniser vos dossiers, ou continuez sans compte. Vos donnees restent chiffrees sur cet appareil.';

  @override
  String get loginEmailLabel => 'Adresse email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginCreateAccountButton => 'Creer un compte';

  @override
  String get loginContinueWithoutAccount => 'Continuer sans compte';

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
  String get recordLeaveTitle => 'Quitter l\'enregistrement ?';

  @override
  String get recordLeaveMessage =>
      'Cette consultation n\'est pas enregistree. Voulez-vous la sauvegarder et l\'associer a un patient ?';

  @override
  String get recordLeaveMessageWithPatient =>
      'Cette consultation n\'est pas enregistree. Voulez-vous la sauvegarder dans le dossier du patient ?';

  @override
  String get recordLeaveSaveAndAssign => 'Enregistrer et associer';

  @override
  String get recordLeaveDiscard => 'Quitter sans enregistrer';

  @override
  String get recordLeaveCancel => 'Continuer l\'enregistrement';

  @override
  String get radialActionNewRecord => 'Nouvel enregistrement';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSolarized => 'Solarized';

  @override
  String get settingsFontSize => 'Taille du texte';

  @override
  String get settingsFontSizeSmall => 'Petit';

  @override
  String get settingsFontSizeDefault => 'Normal';

  @override
  String get settingsFontSizeLarge => 'Grand';

  @override
  String get settingsFontSizeExtraLarge => 'Tres grand';

  @override
  String get settingsDefaultSessionLength => 'Duree de seance par defaut';

  @override
  String get settingsSessionLength30m => '30 min';

  @override
  String get settingsSessionLength45m => '45 min';

  @override
  String get settingsSessionLength1h => '1 h';

  @override
  String get settingsSessionLength1h30 => '1 h 30';

  @override
  String get settingsSessionLength2h => '2 h';

  @override
  String get settingsTemplates => 'Modeles';

  @override
  String get settingsRestartOnboarding => 'Recommencer l\'introduction';

  @override
  String get settingsTbd => 'TBD';

  @override
  String get settingsLogout => 'Se deconnecter';

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
      'Cliquez ici pour acceder a la liste de vos patients ou en creer un nouveau.\n\n👉 Appuyez sur l\'onglet \'Patients\' ci-dessous pour continuer.';

  @override
  String get tutorialHomeRecordTitle => 'Consultation Rapide';

  @override
  String get tutorialHomeRecordDesc =>
      'Depuis l\'ecran d\'accueil, utilisez ce bouton pour demarrer immediatement une consultation vocale.\n\n👉 Appuyez sur ce bouton d\'enregistrement pour continuer.';

  @override
  String get tutorialPatientAddTitle => 'Ajouter un patient';

  @override
  String get tutorialPatientAddDesc =>
      'C\'est ici que vous pouvez creer un nouveau dossier patient en renseignant ses informations de base.\n\n👉 Appuyez sur le bouton \'+\' en haut a droite pour continuer.';

  @override
  String get tutorialPatientMrnTitle => 'Numero de dossier';

  @override
  String get tutorialPatientMrnDesc =>
      'Le numero de dossier (MRN) identifie chaque patient de maniere unique.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientFirstNameTitle => 'Prenom du patient';

  @override
  String get tutorialPatientFirstNameDesc =>
      'Le prenom fait partie des informations de base du dossier patient.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientLastNameTitle => 'Nom du patient';

  @override
  String get tutorialPatientLastNameDesc =>
      'Le nom complete l\'identite du patient. Les autres champs sont optionnels.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientCreateTitle => 'Creer le dossier';

  @override
  String get tutorialPatientCreateDesc =>
      'Ce bouton enregistre le dossier patient une fois les informations saisies.\n\n👉 Appuyez sur \'Creer le dossier\' pour continuer la demonstration.';

  @override
  String get tutorialDetailConsultTitle => 'Nouvelle consultation';

  @override
  String get tutorialDetailConsultDesc =>
      'Lancez l\'enregistrement vocal pour demarrer une nouvelle consultation avec ce patient.\n\n👉 Appuyez sur \'Nouvelle consultation\' pour continuer.';

  @override
  String get tutorialRecordTitle => 'La Dictee';

  @override
  String get tutorialRecordDesc =>
      'Appuyez sur ce bouton pour lancer l\'enregistrement vocal. L\'IA transcrira automatiquement vos paroles et anonymisera les donnees.\n\n👉 Appuyez sur le micro en surbrillance pour demarrer.';

  @override
  String get tutorialRecordStopTitle => 'Arreter l\'ecoute';

  @override
  String get tutorialRecordStopDesc =>
      'Appuyez ici quand la consultation vocale est terminee pour mettre l\'ecoute en pause.\n\n👉 Appuyez sur le bouton d\'arret pour mettre en pause.';

  @override
  String get tutorialRecordFinishTitle => 'Terminer la consultation';

  @override
  String get tutorialRecordFinishDesc =>
      'Validez la fin de la consultation. Vous reviendrez ensuite a l\'accueil pour voir le workflow Nouvel enregistrement.\n\n👉 Appuyez sur la zone en surbrillance pour enregistrer.';

  @override
  String get tutorialRecordTranscriptTitle => 'Transcription en temps reel';

  @override
  String get tutorialRecordTranscriptDesc =>
      'Pendant l\'enregistrement, le texte apparait ici en direct pour vous permettre de suivre la dictee.\n\n👉 Attendez ou appuyez sur l\'ecran pour continuer.';

  @override
  String get tutorialAssignPatientTitle => 'Associer a un patient';

  @override
  String get tutorialAssignPatientDesc =>
      'Apres un nouvel enregistrement, vous pouvez choisir un patient existant avec l\'onglet Rechercher, ou creer un nouveau dossier avec l\'onglet Nouveau patient.\n\n👉 Appuyez sur \'Associer a un patient\' pour continuer.';

  @override
  String get tutorialRestarted => 'Le tutoriel a ete reinitialise.';

  @override
  String get templatesTitle => 'Modeles de pathologie';

  @override
  String get templatesBuiltInSection => 'Modeles par defaut';

  @override
  String get templatesUserSection => 'Mes variantes';

  @override
  String get templatesUserEmpty => 'Aucune variante enregistree.';

  @override
  String get templatesDefaultBadge => 'Defaut';

  @override
  String get templatesVariantBadge => 'Variante';

  @override
  String get templateDuplicateAction => 'Modifier en variante';

  @override
  String get templateDuplicated => 'Variante creee.';

  @override
  String get templateSaved => 'Modele enregistre.';

  @override
  String get templateDeleteTitle => 'Supprimer la variante ?';

  @override
  String templateDeleteMessage(String name) {
    return 'Supprimer le modele \"$name\" ?';
  }

  @override
  String get templateDeleteConfirm => 'Supprimer';

  @override
  String get templateEditorTitle => 'Editer le modele';

  @override
  String get templateNotFound => 'Modele introuvable.';

  @override
  String get templateSectionTitleLabel => 'Titre de section';

  @override
  String get templateSectionPromptLabel => 'Structure / puces';

  @override
  String get templateAddSection => 'Ajouter une section';

  @override
  String get templateSaveAsVariant => 'Enregistrer comme variante';

  @override
  String get templateUpdate => 'Mettre a jour';

  @override
  String get templateReset => 'Reinitialiser depuis le parent';

  @override
  String get templatePickerTitle => 'Choisir un modele';

  @override
  String get templatePickerSearch => 'Rechercher une pathologie';

  @override
  String get templatePickerEmpty => 'Aucun modele trouve.';

  @override
  String get templatePickerAction => 'Choisir un modele';

  @override
  String templateActiveLabel(String name) {
    return 'Modele : $name';
  }

  @override
  String get templateNoneLabel => 'Aucun modele selectionne';

  @override
  String get templateRetry => 'Reessayer';

  @override
  String get templatesBuiltInEmpty =>
      'Aucun modele par defaut disponible. Reinstallez l application.';

  @override
  String get settingsSignIn => 'Se connecter';

  @override
  String get sessionExpiredMessage =>
      'Session expiree, veuillez vous reconnecter';

  @override
  String get punctuationWordPeriod => 'point';

  @override
  String get punctuationWordComma => 'virgule';

  @override
  String get punctuationTransitions =>
      'le patient,la patiente,à l\'examen,a l\'examen,au niveau,pour le traitement,pour la suite,mon diagnostic,ensuite,enfin';

  @override
  String get medicalWatchTitle => 'Veille medicale';

  @override
  String get medicalWatchSearchPlaceholder => 'Rechercher sur PubMed…';

  @override
  String get medicalWatchFilterAll => 'Tous';

  @override
  String get medicalWatchSpecialtyRehabilitation => 'Reeducation';

  @override
  String get medicalWatchSpecialtyMusculoskeletal => 'Musculo-squelettique';

  @override
  String get medicalWatchSpecialtyExerciseTherapy => 'Therapie par l\'exercice';

  @override
  String get medicalWatchSpecialtyManualTherapy => 'Therapie manuelle';

  @override
  String get medicalWatchEmpty => 'Aucun article pour le moment';

  @override
  String get medicalWatchSearchEmpty => 'Aucun resultat pour cette recherche';

  @override
  String get medicalWatchErrorLoad => 'Impossible de charger les articles';

  @override
  String get medicalWatchErrorSearch => 'Erreur lors de la recherche PubMed';

  @override
  String get medicalWatchReadMore => 'Lire la suite';

  @override
  String get medicalWatchReadLess => 'Reduire';

  @override
  String get medicalWatchOpenPubmed => 'Ouvrir dans PubMed';

  @override
  String get medicalWatchCopyReference => 'Copier la reference';

  @override
  String get medicalWatchReferenceCopied => 'Reference copiee';

  @override
  String medicalWatchArticleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get medicalWatchSyncSuccess => 'Veille synchronisee';

  @override
  String get medicalWatchOfflineHint =>
      'Resultats hors-ligne (derniere synchronisation)';
}
