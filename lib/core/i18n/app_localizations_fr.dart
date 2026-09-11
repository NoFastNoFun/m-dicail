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
  String get recordErrorInvalidSoapNote =>
      'La note SOAP reçue est incomplète ou invalide. Veuillez réessayer.';

  @override
  String get errorAudio => 'Microphone indisponible';

  @override
  String get audioPlayerTitle => 'Audio brut';

  @override
  String get audioPlayerPlay => 'Lire';

  @override
  String get audioPlayerPause => 'Pause';

  @override
  String get audioPlayerStop => 'Stop';

  @override
  String get audioPlayerAvailable => 'Audio disponible';

  @override
  String get audioPlayerUnavailable => 'Audio indisponible';

  @override
  String get audioPlayerLoading => 'Chargement...';

  @override
  String get audioPlayerError => 'Lecture impossible';

  @override
  String get audioPlayerPlaying => 'Lecture en cours';

  @override
  String get templateSectionCustom => 'Section';

  @override
  String get recordStatusEnhancing => 'Amélioration de la transcription...';

  @override
  String get recordStatusGeneratingSOAP =>
      'Génération de la note SOAP par l\'IA...';

  @override
  String get routerErrorNotFound => 'Route introuvable:';

  @override
  String get labelHistory => 'Historique';

  @override
  String get navigateToRecord => 'Nouvel enregistrement';

  @override
  String get transcriptLabel => 'Transcription';

  @override
  String get transcriptEmptyHint => 'Aucune parole captée pour le moment';

  @override
  String get transcriptEmptyFallback => 'Transcription vide';

  @override
  String get transcriptAiGeneratedLabel => 'Transcription IA';

  @override
  String get recordTranscriptCompareTitle => 'Choisir la transcription';

  @override
  String get recordTranscriptCompareHint =>
      'Comparez la version locale et la version IA. Les mots différents sont surlignés (majuscules et ponctuation ignorées, sauf les traits d\'union). Choisissez celle à conserver et relisez toujours avant de valider.';

  @override
  String get recordTranscriptCompareLocal => 'Locale';

  @override
  String get recordTranscriptCompareAi => 'IA';

  @override
  String get recordTranscriptCompareChooseLocal => 'Choisir locale';

  @override
  String get recordTranscriptCompareChooseAi => 'Choisir IA';

  @override
  String get buttonClear => 'Effacer';

  @override
  String get recordStatusReady => 'Prêt à écouter';

  @override
  String get recordStatusInitializing => 'Initialisation du micro';

  @override
  String get recordStatusListening => 'Écoute en cours';

  @override
  String get recordStatusPaused => 'Écoute en pause';

  @override
  String get recordStatusEnded => 'Session terminée';

  @override
  String get recordNotificationTitle => 'Écoute en cours';

  @override
  String get recordNotificationBody => 'Touchez pour revenir à Medicail';

  @override
  String get recordNotificationBackgroundTitle =>
      'Enregistrement en arrière-plan';

  @override
  String get recordNotificationBackgroundBody =>
      'L\'écoute continue pendant que l\'écran est éteint';

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
  String get appointmentsEmpty => 'Aucun rendez-vous pour cette journée';

  @override
  String get appointmentsUpcomingEmpty => 'Aucun prochain rendez-vous';

  @override
  String get appointmentCreateTitle => 'Nouveau rendez-vous';

  @override
  String get appointmentEditTitle => 'Modifier le rendez-vous';

  @override
  String get appointmentCreateSubmit => 'Créer le rendez-vous';

  @override
  String get appointmentSaveChanges => 'Enregistrer';

  @override
  String get appointmentSaved => 'Rendez-vous enregistré';

  @override
  String get appointmentEdit => 'Modifier';

  @override
  String get appointmentCancel => 'Annuler';

  @override
  String get appointmentDelete => 'Supprimer';

  @override
  String get appointmentNotesLabel => 'Notes';

  @override
  String get appointmentPatientRequired => 'Sélectionnez un patient';

  @override
  String get appointmentEndBeforeStart =>
      'L\'heure de fin doit être après l\'heure de début';

  @override
  String get appointmentKeepPatientHint =>
      'Laissez le patient actuel, ou choisissez-en un autre ci-dessous.';

  @override
  String get appointmentStatusScheduled => 'Planifié';

  @override
  String get appointmentStatusCancelled => 'Annulé';

  @override
  String get appointmentStatusCompleted => 'Terminé';

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
  String get patientsArchivedTitle => 'Patients archivés';

  @override
  String get patientsArchivedEmpty => 'Aucun patient archivé';

  @override
  String get patientsArchivedOpenTooltip => 'Patients archivés';

  @override
  String get patientFirstNameLabel => 'Prénom';

  @override
  String get patientLastNameLabel => 'Nom';

  @override
  String get patientCreateButton => 'Créer le patient';

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
  String get patientArchiveTitle => 'Archiver le patient ?';

  @override
  String get patientArchiveBody =>
      'Le patient sera déplacé dans les archives. Vous pourrez le restaurer plus tard.';

  @override
  String get patientArchiveConfirm => 'Archiver';

  @override
  String get patientArchiveSuccess => 'Patient archivé';

  @override
  String get patientUnarchiveTitle => 'Restaurer le patient ?';

  @override
  String get patientUnarchiveBody =>
      'Le patient réapparaîtra dans la liste active.';

  @override
  String get patientUnarchiveConfirm => 'Restaurer';

  @override
  String get patientUnarchiveSuccess => 'Patient restauré';

  @override
  String get patientDeleteTitle => 'Supprimer le patient ?';

  @override
  String get patientDeleteBody =>
      'Cette action est irréversible. Le patient, ses rendez-vous et ses consultations seront définitivement supprimés.';

  @override
  String get patientDeleteConfirm => 'Supprimer';

  @override
  String get patientDeleteSuccess => 'Patient supprimé';

  @override
  String get patientRestoreButton => 'Restaurer';

  @override
  String get sessionDeleteTitle => 'Supprimer la consultation ?';

  @override
  String get sessionDeleteBody =>
      'Cette action est irréversible. La transcription et la note associées seront perdues.';

  @override
  String get sessionDeleteConfirm => 'Supprimer';

  @override
  String get sessionDeleteSuccess => 'Consultation supprimée';

  @override
  String get sessionStatusDraft => 'Brouillon';

  @override
  String get sessionStatusRecording => 'En cours';

  @override
  String get sessionStatusCompleted => 'Terminée';

  @override
  String get sessionStatusFailed => 'Échec';

  @override
  String get patientAgeLabel => 'Âge';

  @override
  String get appointmentCancelTitle => 'Annuler le rendez-vous ?';

  @override
  String get appointmentCancelBody =>
      'Êtes-vous sûr de vouloir annuler ce rendez-vous ?';

  @override
  String get appointmentDeleteTitle => 'Supprimer le rendez-vous ?';

  @override
  String get appointmentDeleteBody =>
      'Cette action est irréversible. Voulez-vous supprimer ce rendez-vous ?';

  @override
  String get buttonConfirm => 'Confirmer';

  @override
  String get buttonCancel => 'Annuler';

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
  String get debugBackendUrlReset => 'Réinitialiser';

  @override
  String get debugBackendUrlSaved => 'URL backend mise à jour';

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
  String get patientUpdateTitle => 'Modifier le patient';

  @override
  String get patientUpdateSubmit => 'Enregistrer';

  @override
  String get patientUpdateSuccess => 'Patient modifié avec succès.';

  @override
  String get loginWelcomeTitle => 'Bienvenue sur Medicail';

  @override
  String get loginWelcomeSubtitle =>
      'Connectez-vous pour synchroniser vos dossiers, ou continuez sans compte. Vos données restent chiffrées sur cet appareil.';

  @override
  String get loginEmailLabel => 'Adresse email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginCreateAccountButton => 'Créer un compte';

  @override
  String get loginRememberEmail => 'Se souvenir de l\'adresse email';

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
  String get authForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authForgotPasswordHint =>
      'Entrez votre adresse email. Si un compte existe, vous recevrez un lien de réinitialisation.';

  @override
  String get authForgotPasswordSubmit => 'Envoyer le lien';

  @override
  String get authForgotPasswordSent =>
      'Si un compte existe pour cette adresse, un email vient d\'être envoyé.';

  @override
  String get authResetPasswordTitle => 'Nouveau mot de passe';

  @override
  String get authResetPasswordHint =>
      'Choisissez un nouveau mot de passe pour votre compte.';

  @override
  String get authResetPasswordSubmit => 'Réinitialiser';

  @override
  String get authResetPasswordSuccess => 'Mot de passe mis à jour.';

  @override
  String get authRecoveryTitle => 'Récupération de compte';

  @override
  String get authRecoveryHint =>
      'Confirmez la récupération pour désactiver l\'authentification TOTP. Vos passkeys restent actives.';

  @override
  String get authRecoveryConfirm => 'Confirmer la récupération';

  @override
  String get authRecoverySuccess =>
      'Récupération terminée. Vous pouvez vous reconnecter.';

  @override
  String get authRecoveryRequest => 'Demander un lien de récupération';

  @override
  String get authRecoveryRequestSent =>
      'Si un compte existe, un email de récupération vient d\'être envoyé.';

  @override
  String get authRecoveryCodesTitle => 'Codes de récupération';

  @override
  String get authBackToLogin => 'Retour à la connexion';

  @override
  String get authMfaTitle => 'Vérification en deux étapes';

  @override
  String get authMfaHint =>
      'Entrez le code de votre application d\'authentification ou un code de récupération.';

  @override
  String get authMfaCodeLabel => 'Code';

  @override
  String get authMfaVerify => 'Vérifier';

  @override
  String get authMfaEnroll => 'Activer TOTP';

  @override
  String get authMfaConfirm => 'Confirmer TOTP';

  @override
  String get authMfaDisable => 'Désactiver TOTP';

  @override
  String get authMfaEnabled => 'Activé';

  @override
  String get authMfaDisabled => 'Désactivé';

  @override
  String get authMfaManualHint =>
      'Sur mobile, copiez la clé secrète dans votre application d\'authentification.';

  @override
  String get authMfaSecretLabel => 'Clé secrète';

  @override
  String get authMfaCopySecret => 'Copier la clé';

  @override
  String get authMfaCopyUri => 'Copier le lien otpauth';

  @override
  String get authMfaSecretCopied => 'Clé secrète copiée';

  @override
  String get authMfaUriCopied => 'Lien otpauth copié';

  @override
  String get authPasskeyLogin => 'Se connecter avec une passkey';

  @override
  String get authPasskeysTitle => 'Passkeys';

  @override
  String get authPasskeyAdd => 'Ajouter une passkey';

  @override
  String get authPasskeyUnsupported =>
      'Passkeys non disponibles sur cette plateforme.';

  @override
  String get authBiometricLockTitle => 'Verrouillage biométrique';

  @override
  String get authBiometricLockSubtitle =>
      'Déverrouillez l\'application pour accéder à vos données.';

  @override
  String get authBiometricLockSettingsSubtitle =>
      'Verrouiller l\'application au démarrage et au retour depuis l\'arrière-plan.';

  @override
  String get authBiometricUnlock => 'Déverrouiller';

  @override
  String get authBiometricUnlockReason => 'Déverrouiller Medicail';

  @override
  String get authBiometricEnableReason => 'Activer le verrouillage biométrique';

  @override
  String get authBiometricDisableReason =>
      'Désactiver le verrouillage biométrique';

  @override
  String get authBiometricAuthFailed => 'Authentification biométrique échouée.';

  @override
  String get authBiometricUnavailable =>
      'Biométrie non disponible sur cet appareil.';

  @override
  String get authSecurityTitle => 'Sécurité';

  @override
  String get settingsProfileTitle => 'Profil';

  @override
  String get settingsProfileName => 'Nom';

  @override
  String get settingsProfileNameHint => 'Votre nom affiché';

  @override
  String get settingsProfileEmail => 'Email';

  @override
  String get settingsProfileEmailHint => 'Nouvel email';

  @override
  String get settingsProfileCurrentPassword => 'Mot de passe actuel';

  @override
  String get settingsProfileNewPassword => 'Nouveau mot de passe';

  @override
  String get settingsProfileConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get settingsProfilePasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get settingsProfileSaveName => 'Enregistrer le nom';

  @override
  String get settingsProfileChangeEmail => 'Changer l\'email';

  @override
  String get settingsProfileChangePassword => 'Changer le mot de passe';

  @override
  String get settingsProfileUsePasskey => 'Confirmer avec une passkey';

  @override
  String get settingsProfileUsePassword => 'Confirmer avec le mot de passe';

  @override
  String get settingsProfileTotpRequired => 'Code TOTP';

  @override
  String get settingsProfileNameSaved => 'Nom mis à jour';

  @override
  String get settingsProfileEmailSaved => 'Email mis à jour';

  @override
  String get settingsProfilePasswordSaved => 'Mot de passe mis à jour';

  @override
  String get authDigestTitle => 'Veille médicale';

  @override
  String get authDigestHint =>
      'Recevoir un digest par email (bientôt disponible).';

  @override
  String get authDigestOptIn => 'Activer le digest email';

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
      'Cette consultation n\'est pas enregistrée. Voulez-vous la sauvegarder et l\'associer à un patient ?';

  @override
  String get recordLeaveMessageWithPatient =>
      'Cette consultation n\'est pas enregistrée. Voulez-vous la sauvegarder dans le dossier du patient ?';

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
  String get settingsSectionDisplay => 'Affichage';

  @override
  String get settingsSectionSession => 'Consultations';

  @override
  String get settingsSectionAi => 'Intelligence artificielle';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSolarized => 'Solarized';

  @override
  String get settingsThemeCustom => 'Perso';

  @override
  String get settingsThemeBackground => 'Arriere-plan';

  @override
  String get settingsThemePrimary => 'Primaire';

  @override
  String get settingsFontSize => 'Taille du texte';

  @override
  String get settingsFontSizeSmall => 'Petit';

  @override
  String get settingsFontSizeDefault => 'Normal';

  @override
  String get settingsFontSizeLarge => 'Grand';

  @override
  String get settingsFontSizeExtraLarge => 'Très grand';

  @override
  String get settingsDefaultSessionLength => 'Durée de séance par défaut';

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
  String get settingsSessionLengthCustom => 'Personnalisée';

  @override
  String get settingsSessionLengthHours => 'Heures';

  @override
  String get settingsSessionLengthMinutes => 'Minutes';

  @override
  String get settingsSessionLengthHoursUnit => 'h';

  @override
  String get settingsSessionLengthMinutesUnit => 'min';

  @override
  String get settingsTemplates => 'Pathologies';

  @override
  String get settingsAiEnhance => 'Amélioration IA de la transcription';

  @override
  String get settingsAiEnhanceSubtitle =>
      'Enregistre l’audio et l’envoie au cloud à la fin de la consultation. La transcription s’affiche ensuite.';

  @override
  String get transcriptAiPendingHint =>
      'Mode IA : la transcription sera disponible après avoir terminé la consultation.';

  @override
  String get settingsAiEnhanceWarning =>
      'L\'IA peut halluciner et reste peu fiable. Relisez toujours la transcription avant de valider.';

  @override
  String get settingsRestartOnboarding => 'Recommencer l\'introduction';

  @override
  String get settingsComingSoon => 'Bientôt disponible';

  @override
  String get settingsTbd => 'TBD';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsAppVersion => 'Version';

  @override
  String get settingsAboutProductTitle => 'Assistant clinique';

  @override
  String get settingsAboutProductSubtitle =>
      'Aide mains libres pour les kinésithérapeutes, pendant la séance.';

  @override
  String get settingsAboutDataTitle => 'Vos données';

  @override
  String get settingsAboutDataSubtitle =>
      'Chiffrées sur cet appareil. Fonctionne hors ligne autant que possible.';

  @override
  String get euAiLabelGenerated => 'Contenu généré par l\'IA';

  @override
  String get euAiLabelModified => 'Contenu modifié par l\'IA';

  @override
  String get tutorialIntroTitle => 'Découvrir Medicail';

  @override
  String get tutorialIntroDesc =>
      'Un tutoriel rapide peut vous guider dans la création d\'un dossier patient, une première consultation, puis un enregistrement rapide depuis l\'accueil.';

  @override
  String get tutorialIntroStart => 'Faire le tutoriel';

  @override
  String get tutorialIntroSkip => 'Passer';

  @override
  String get tutorialHomePatientsTitle => 'Dossiers Patients';

  @override
  String get tutorialHomePatientsDesc =>
      'Cliquez ici pour accéder à la liste de vos patients ou en créer un nouveau.\n\n👉 Appuyez sur l\'onglet \'Patients\' ci-dessous pour continuer.';

  @override
  String get tutorialHomeRecordTitle => 'Consultation Rapide';

  @override
  String get tutorialHomeRecordDesc =>
      'Depuis l\'écran d\'accueil, utilisez ce bouton pour démarrer immédiatement une consultation vocale.\n\n👉 Appuyez sur ce bouton d\'enregistrement pour continuer.';

  @override
  String get tutorialPatientAddTitle => 'Ajouter un patient';

  @override
  String get tutorialPatientAddDesc =>
      'C\'est ici que vous pouvez créer un nouveau dossier patient en renseignant ses informations de base.\n\n👉 Appuyez sur le bouton \'+\' en haut à droite pour continuer.';

  @override
  String get tutorialPatientMrnTitle => 'Numéro de dossier';

  @override
  String get tutorialPatientMrnDesc =>
      'Le numéro de dossier (MRN) identifie chaque patient de manière unique.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientFirstNameTitle => 'Prénom du patient';

  @override
  String get tutorialPatientFirstNameDesc =>
      'Le prénom fait partie des informations de base du dossier patient.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientLastNameTitle => 'Nom du patient';

  @override
  String get tutorialPatientLastNameDesc =>
      'Le nom complète l\'identité du patient. Les autres champs sont optionnels.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.';

  @override
  String get tutorialPatientCreateTitle => 'Créer le dossier';

  @override
  String get tutorialPatientCreateDesc =>
      'Ce bouton enregistre le dossier patient une fois les informations saisies.\n\n👉 Appuyez sur \'Créer le dossier\' pour continuer la démonstration.';

  @override
  String get tutorialDetailConsultTitle => 'Nouvelle consultation';

  @override
  String get tutorialDetailConsultDesc =>
      'Lancez l\'enregistrement vocal pour démarrer une nouvelle consultation avec ce patient.\n\n👉 Appuyez sur \'Nouvelle consultation\' pour continuer.';

  @override
  String get tutorialRecordTitle => 'La Dictée';

  @override
  String get tutorialRecordDesc =>
      'Appuyez sur ce bouton pour lancer l\'enregistrement vocal. L\'IA transcrira automatiquement vos paroles et anonymisera les données.\n\n👉 Appuyez sur le micro en surbrillance pour démarrer.';

  @override
  String get tutorialRecordStopTitle => 'Arrêter l\'écoute';

  @override
  String get tutorialRecordStopDesc =>
      'Appuyez ici quand la consultation vocale est terminée pour mettre l\'écoute en pause.\n\n👉 Appuyez sur le bouton d\'arrêt pour mettre en pause.';

  @override
  String get tutorialRecordFinishTitle => 'Terminer la consultation';

  @override
  String get tutorialRecordFinishDesc =>
      'Validez la fin de la consultation. Vous reviendrez ensuite à l\'accueil pour voir le workflow Nouvel enregistrement.\n\n👉 Appuyez sur la zone en surbrillance pour enregistrer.';

  @override
  String get tutorialRecordTranscriptTitle => 'Transcription en temps réel';

  @override
  String get tutorialRecordTranscriptDesc =>
      'Pendant l\'enregistrement, le texte apparaît ici en direct pour vous permettre de suivre la dictée.\n\n👉 Attendez ou appuyez sur l\'écran pour continuer.';

  @override
  String get tutorialAssignPatientTitle => 'Associer à un patient';

  @override
  String get tutorialAssignPatientDesc =>
      'Après un nouvel enregistrement, vous pouvez choisir un patient existant avec l\'onglet Rechercher, ou créer un nouveau dossier avec l\'onglet Nouveau patient.\n\n👉 Appuyez sur \'Associer à un patient\' pour continuer.';

  @override
  String get tutorialRestarted => 'Le tutoriel a été réinitialisé.';

  @override
  String get templatesTitle => 'Pathologies';

  @override
  String get templatesBuiltInSection => 'Pathologies par défaut';

  @override
  String get templatesUserSection => 'Mes pathologies';

  @override
  String get templatesUserEmpty =>
      'Aucune pathologie personnalisée enregistrée.';

  @override
  String get templatesDefaultBadge => 'Défaut';

  @override
  String get templatesVariantBadge => 'Variante';

  @override
  String get templatesCustomBadge => 'Personnalisé';

  @override
  String get templateDuplicateAction => 'Modifier en variante';

  @override
  String get templateDuplicated => 'Variante créée.';

  @override
  String get templateSaved => 'Pathologie enregistrée.';

  @override
  String get templateCreateAction => 'Créer une pathologie';

  @override
  String get templateCreateTitle => 'Nouvelle pathologie';

  @override
  String get templateNameLabel => 'Nom de la pathologie';

  @override
  String get templateNameRequired => 'Le nom de la pathologie est obligatoire.';

  @override
  String get templateDeleteTitle => 'Supprimer la pathologie ?';

  @override
  String templateDeleteMessage(String name) {
    return 'Supprimer la pathologie \"$name\" ?';
  }

  @override
  String get templateDeleteConfirm => 'Supprimer';

  @override
  String get templateEditorTitle => 'Modifier pathologie';

  @override
  String get templateNotFound => 'Pathologie introuvable.';

  @override
  String get templateSectionTitleLabel => 'Titre de section';

  @override
  String get templateSectionPromptLabel => 'Structure / puces';

  @override
  String get templateAddSection => 'Ajouter une section';

  @override
  String get templateSaveAsVariant => 'Enregistrer comme variante';

  @override
  String get templateUpdate => 'Mettre à jour';

  @override
  String get templateSaveCreate => 'Créer la pathologie';

  @override
  String get templateReset => 'Réinitialiser depuis le parent';

  @override
  String get templatePickerTitle => 'Choisir une pathologie';

  @override
  String get templatePickerSearch => 'Rechercher une pathologie';

  @override
  String get templatePickerEmpty => 'Aucune pathologie trouvée.';

  @override
  String get templatePickerAction => 'Choisir une pathologie';

  @override
  String templateActiveLabel(String name) {
    return 'Pathologie : $name';
  }

  @override
  String get templateNoneLabel => 'Aucune pathologie sélectionnée';

  @override
  String get templateRetry => 'Réessayer';

  @override
  String get templatesBuiltInEmpty =>
      'Aucune pathologie par défaut disponible. Réinstallez l\'application.';

  @override
  String get patientDossierOralTab => 'Oral';

  @override
  String get patientDossierWrittenTab => 'Écrit';

  @override
  String get patientDossierOralEmpty => 'Aucune transcription pour ce patient';

  @override
  String get patientDossierWrittenEmpty => 'Aucune note écrite pour ce patient';

  @override
  String get patientDossierTranscriptTitle => 'Transcription';

  @override
  String patientDossierPathologyLabel(String name) {
    return 'Pathologie : $name';
  }

  @override
  String get pathologySuggestionTitle => 'Pathologie suggérée';

  @override
  String get pathologySuggestionDesc =>
      'D\'après la transcription, cette pathologie semble correspondre à la consultation.';

  @override
  String get pathologySuggestionApply => 'Appliquer cette pathologie';

  @override
  String get pathologySuggestionChooseOther => 'Choisir une autre pathologie';

  @override
  String get pathologySuggestionSkip => 'Ignorer';

  @override
  String get pathologyMultiSuggestionTitle => 'Pathologies suggérées';

  @override
  String get pathologyMultiSuggestionDesc =>
      'D\'après la transcription, plusieurs pathologies semblent correspondre. Cochez celles à associer à l\'enregistrement.';

  @override
  String get pathologyMultiSuggestionApply =>
      'Associer les pathologies sélectionnées';

  @override
  String get pathologyNoneSuggestionTitle => 'Aucune pathologie détectée';

  @override
  String get pathologyNoneSuggestionDesc =>
      'Aucune pathologie n\'a été détectée dans la transcription. Souhaitez-vous en associer une manuellement ?';

  @override
  String get pathologyNoneSuggestionAttach => 'Associer une pathologie';

  @override
  String get pathologyDomainLabel => 'Domaine clinique';

  @override
  String get pathologyCustomizeSoapAction => 'Personnaliser le SOAP';

  @override
  String pathologyPubmedSearchAction(String query) {
    return 'Rechercher \"$query\" sur PubMed';
  }

  @override
  String get pathologyPubmedResultsSection => 'Résultats PubMed';

  @override
  String get settingsSignIn => 'Se connecter';

  @override
  String get sessionExpiredMessage =>
      'Session expirée, veuillez vous reconnecter';

  @override
  String get errorToastCopied => 'Détails de l\'erreur copiés';

  @override
  String get errorToastReport => 'Signaler l\'erreur';

  @override
  String get bugReportCopied => 'Bug copié dans le presse papier';

  @override
  String get screenshotBugTitle => 'Un bug détecté ?';

  @override
  String get screenshotBugReport => 'Signaler le bug';

  @override
  String get screenshotBugReportMessage => 'Screenshot bug report';

  @override
  String get punctuationWordPeriod => 'point';

  @override
  String get punctuationWordComma => 'virgule';

  @override
  String get punctuationTransitions =>
      'le patient,la patiente,à l\'examen,a l\'examen,au niveau,pour le traitement,pour la suite,mon diagnostic,ensuite,enfin';

  @override
  String get medicalWatchTitle => 'News';

  @override
  String get medicalWatchNavTitle => 'News';

  @override
  String get medicalWatchSearchPlaceholder => 'Rechercher sur PubMed…';

  @override
  String get medicalWatchFilterAll => 'Tous';

  @override
  String get medicalWatchSpecialtyRehabilitation => 'Rééducation';

  @override
  String get medicalWatchSpecialtyMusculoskeletal => 'Musculo-squelettique';

  @override
  String get medicalWatchSpecialtyExerciseTherapy => 'Thérapie par l\'exercice';

  @override
  String get medicalWatchSpecialtyManualTherapy => 'Thérapie manuelle';

  @override
  String get medicalWatchEmpty => 'Aucun article pour le moment';

  @override
  String get medicalWatchSearchEmpty => 'Aucun résultat pour cette recherche';

  @override
  String get medicalWatchErrorLoad => 'Impossible de charger les articles';

  @override
  String get medicalWatchErrorSearch => 'Erreur lors de la recherche PubMed';

  @override
  String get medicalWatchReadMore => 'Lire la suite';

  @override
  String get medicalWatchReadLess => 'Réduire';

  @override
  String get medicalWatchOpenPubmed => 'Ouvrir dans PubMed';

  @override
  String get medicalWatchCopyReference => 'Copier la référence';

  @override
  String get medicalWatchReferenceCopied => 'Référence copiée';

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
  String get medicalWatchSyncSuccess => 'News mises à jour';

  @override
  String get medicalWatchOfflineHint =>
      'Résultats hors-ligne (dernière synchronisation)';

  @override
  String homeGreeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get homeGreetingGuest => 'Bienvenue';

  @override
  String get homeQuickRecord => 'Enregistrement rapide';

  @override
  String get homeNewPatient => 'Nouveau patient';

  @override
  String get homeViewAgenda => 'Agenda';

  @override
  String get homeRecentConsultationsTitle => 'Consultations récentes';

  @override
  String get homeRecentConsultationsEmpty =>
      'Aucune consultation pour le moment';

  @override
  String get homeRecentConsultationsSeeAll => 'Voir tout';

  @override
  String get homeEmptyTitle => 'Bienvenue sur Medicail';

  @override
  String get homeEmptySubtitle =>
      'Planifiez votre première consultation ou démarrez un enregistrement rapide';

  @override
  String homeConsultationsToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count consultations prévues',
      one: '1 consultation prévue',
      zero: 'Aucune consultation aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get attachPatientDialogTitle => 'Associer un patient';

  @override
  String get attachPatientSearchLabel => 'Rechercher un patient';

  @override
  String get attachPatientSearchHint => 'Nom, prénom ou MRN';

  @override
  String get attachPatientConfirm => 'Continuer la consultation';

  @override
  String get attachPatientNewButton => 'Nouveau patient';

  @override
  String get attachPatientSelectRequired =>
      'Sélectionnez un patient pour continuer';

  @override
  String get attachPatientNoResults => 'Aucun patient trouvé';

  @override
  String get anamneseCarouselTitle => 'Nouveau patient';

  @override
  String get anamneseCarouselEditTitle => 'Anamnèse';

  @override
  String anamnesePageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get anamneseBack => 'Retour';

  @override
  String get anamneseNext => 'Suivant';

  @override
  String get anamneseSkip => 'Passer';

  @override
  String get anamneseFinish => 'Terminer';

  @override
  String get anamneseIdentityRequired =>
      'Prénom, nom et date de naissance sont requis.';

  @override
  String get anamneseBirthDateRequiredLabel => 'Date de naissance *';

  @override
  String get anamneseBirthPlaceLabel => 'Lieu de naissance';

  @override
  String get anamneseIdentityTitle => 'Identité';

  @override
  String get anamneseNaissanceEnfanceTitle => 'Naissance et enfance';

  @override
  String get anamneseVieFamilialeTitle => 'Vie familiale et sexuelle';

  @override
  String get anamneseStylesDeVieTitle => 'Styles de vie';

  @override
  String get anamneseActivitesPhysioTitle => 'Activités physiologiques';

  @override
  String get anamneseActiviteProTitle => 'Activité professionnelle';

  @override
  String get anamnesePersonnaliteTitle => 'Personnalité';

  @override
  String get anamneseAntecedentsTitle => 'Antécédents chroniques';

  @override
  String get anamneseTraumatismesTitle =>
      'Traumatismes, chirurgie et infections';

  @override
  String get anamnesePoidsNaissance => 'Poids à la naissance';

  @override
  String get anamnesePoidsUniteG => 'g';

  @override
  String get anamnesePoidsUniteKg => 'kg';

  @override
  String get anamneseAllaitement => 'Mode d\'allaitement';

  @override
  String get anamneseAllaitementMaternel => 'Maternel';

  @override
  String get anamneseAllaitementArtificiel => 'Artificiel';

  @override
  String get anamneseAllaitementMixte => 'Mixte';

  @override
  String get anamneseMarche => 'Marche';

  @override
  String get anamneseDentition => 'Dentition';

  @override
  String get anamnesePhonation => 'Phonation';

  @override
  String get anamneseMilestoneNormal => 'Normal';

  @override
  String get anamneseMilestoneRetard => 'Retard';

  @override
  String get anamneseMilestoneInconnu => 'Inconnu';

  @override
  String get anamneseAgeMois => 'Âge (mois)';

  @override
  String get anamneseEnCouple => 'En couple / marié(e)';

  @override
  String get anamneseCoupleMariage => 'Mariage';

  @override
  String get anamneseCouplePacs => 'PACS';

  @override
  String get anamneseCoupleConcubinage => 'Concubinage';

  @override
  String get anamneseCoupleAnnee => 'Année';

  @override
  String get anamneseNombreGrossesses => 'Nombre de grossesses';

  @override
  String get anamneseTroublesSexuels => 'Troubles sexuels';

  @override
  String get anamneseDysfonctionErectile => 'Dysfonction érectile';

  @override
  String get anamneseBaisseLibido => 'Baisse de libido';

  @override
  String get anamneseDyspareunie => 'Dyspareunie';

  @override
  String get anamneseRisqueMst => 'Comportements à risque MST';

  @override
  String get anamneseMenopause => 'Ménopause';

  @override
  String get anamneseTraitementHormonal => 'Traitement hormonal';

  @override
  String get anamneseOui => 'Oui';

  @override
  String get anamneseNon => 'Non';

  @override
  String get anamneseAlimentation => 'Habitudes alimentaires';

  @override
  String get anamneseAlimEquilibree => 'Équilibrée';

  @override
  String get anamneseAlimDesequilibree => 'Déséquilibrée';

  @override
  String get anamneseAlimRestrictive => 'Restrictive';

  @override
  String get anamneseAlimInsuffisante => 'Insuffisante';

  @override
  String get anamneseAlimNormale => 'Normale';

  @override
  String get anamneseAlimExcessive => 'Excessive';

  @override
  String get anamneseQualite => 'Qualité';

  @override
  String get anamneseQuantite => 'Quantité';

  @override
  String get anamneseAlcool => 'Alcool';

  @override
  String get anamneseTabac => 'Tabac';

  @override
  String get anamneseDrogues => 'Drogues';

  @override
  String get anamneseFrequence => 'Fréquence';

  @override
  String get anamneseFreqQuotidien => 'Quotidien';

  @override
  String get anamneseFreqHebdo => 'Hebdomadaire';

  @override
  String get anamneseFreqOccasionnel => 'Occasionnel';

  @override
  String get anamneseFreqSevre => 'Sevré';

  @override
  String get anamneseVerresSemaine => 'Verres / semaine';

  @override
  String get anamneseTypeBoisson => 'Type';

  @override
  String get anamneseBiere => 'Bière';

  @override
  String get anamneseVin => 'Vin';

  @override
  String get anamneseSpiritueux => 'Spiritueux';

  @override
  String get anamneseCigarettesJour => 'Cigarettes / jour';

  @override
  String get anamneseAncienFumeur => 'Ancien fumeur';

  @override
  String get anamneseAnnees => 'Années';

  @override
  String get anamneseCannabis => 'Cannabis';

  @override
  String get anamneseCocaine => 'Cocaïne';

  @override
  String get anamneseOpioides => 'Opioïdes';

  @override
  String get anamneseAutre => 'Autre';

  @override
  String get anamneseSedentarite => 'Niveau d\'activité';

  @override
  String get anamneseActif => 'Actif';

  @override
  String get anamneseModere => 'Modéré';

  @override
  String get anamneseSedentaire => 'Sédentaire';

  @override
  String get anamneseActiviteSemaine => 'Activité / semaine';

  @override
  String get anamneseRelationsSociales => 'Relations sociales';

  @override
  String get anamneseIsole => 'Isolé';

  @override
  String get anamneseLimite => 'Limité';

  @override
  String get anamneseSoutenu => 'Soutenu';

  @override
  String get anamneseAllergies => 'Allergies';

  @override
  String get anamneseAllergieMedicamenteuses => 'Médicamenteuses';

  @override
  String get anamneseAllergieAlimentaires => 'Alimentaires';

  @override
  String get anamneseAllergieEnvironnementales => 'Environnementales';

  @override
  String get anamneseDetailAllergies => 'Précisions';

  @override
  String get anamneseSelles => 'Selles';

  @override
  String get anamneseSellesRegulieres => 'Régulières';

  @override
  String get anamneseSellesIrregulieres => 'Irrégulières';

  @override
  String get anamneseSellesConstipation => 'Constipation';

  @override
  String get anamneseSellesDiarrhee => 'Diarrhée';

  @override
  String get anamneseFrequenceJour => 'Fréquence / jour';

  @override
  String get anamneseMictions => 'Mictions';

  @override
  String get anamneseMictionNormale => 'Normale';

  @override
  String get anamnesePollakiurie => 'Pollakiurie';

  @override
  String get anamneseNycturie => 'Nycturie';

  @override
  String get anamneseBrulures => 'Brûlures';

  @override
  String get anamneseHematurie => 'Hématurie';

  @override
  String get anamneseCouleur => 'Couleur';

  @override
  String get anamneseCouleurClaire => 'Claire';

  @override
  String get anamneseCouleurFoncee => 'Foncée';

  @override
  String get anamneseCouleurSanglante => 'Sanglante';

  @override
  String get anamneseTypeActivite => 'Catégorie d\'activité';

  @override
  String get anamneseProBureau => 'Bureau / sédentaire';

  @override
  String get anamneseProPhysique => 'Physique';

  @override
  String get anamneseProMixte => 'Mixte';

  @override
  String get anamneseProRetraite => 'Retraité';

  @override
  String get anamneseProSansEmploi => 'Sans emploi';

  @override
  String get anamneseMetier => 'Métier';

  @override
  String get anamneseExpositions => 'Expositions professionnelles';

  @override
  String get anamneseExpoPhysique => 'Physique';

  @override
  String get anamneseExpoChimique => 'Chimique';

  @override
  String get anamneseExpoBiologique => 'Biologique';

  @override
  String get anamneseEtudesTravail => 'Bénéfices des études ou du travail';

  @override
  String get anamnesePerceptionSante => 'Perception de l\'état de santé';

  @override
  String get anamneseSousEstime => 'Sous-estime';

  @override
  String get anamneseRealiste => 'Réaliste';

  @override
  String get anamneseSurEstime => 'Surestime';

  @override
  String get anamneseAttitudeMaladie => 'Attitude face à la maladie';

  @override
  String get anamneseAcceptation => 'Acceptation';

  @override
  String get anamneseVolonteGuerir => 'Volonté de guérir';

  @override
  String get anamneseAnxiete => 'Anxiété';

  @override
  String get anamneseDeni => 'Déni';

  @override
  String get anamneseConfianceMedecins => 'Confiance dans les médecins';

  @override
  String get anamneseHypertension => 'Hypertension artérielle';

  @override
  String get anamneseDiabete => 'Diabète sucré';

  @override
  String get anamneseDyslipidemie => 'Dyslipidémie';

  @override
  String get anamneseSuivi => 'Suivi';

  @override
  String get anamneseSuiviMt => 'Médecin traitant';

  @override
  String get anamneseSuiviSpe => 'Spécialiste';

  @override
  String get anamneseSuiviHopital => 'Hôpital';

  @override
  String get anamneseMaladieName => 'Maladie';

  @override
  String get anamneseMaladieAnnee => 'Année d\'apparition';

  @override
  String get anamneseMaladieSymptomes => 'Symptômes de début';

  @override
  String get anamneseMaladieLieuSuivi => 'Lieu de suivi';

  @override
  String get anamneseMaladieModaliteSuivi => 'Modalité de suivi';

  @override
  String get anamneseAddMaladie => 'Ajouter une maladie';

  @override
  String get anamneseCommonAsthme => 'Asthme';

  @override
  String get anamneseCommonArthrose => 'Arthrose';

  @override
  String get anamneseCommonThyroide => 'Thyroïde';

  @override
  String get anamneseTraumatismesSequelles => 'Traumatismes et séquelles';

  @override
  String get anamneseChirurgieAnterieure => 'Chirurgie antérieure';

  @override
  String get anamneseInterventionDesc => 'Intervention chirurgicale';

  @override
  String get anamneseInterventionDate => 'Date';

  @override
  String get anamneseInterventionComplications => 'Complications';

  @override
  String get anamneseAddIntervention => 'Ajouter une intervention';

  @override
  String get anamneseInfectionsEnfance => 'Maladies infectieuses (enfance)';

  @override
  String get anamneseTuberculose => 'Tuberculose';

  @override
  String get anamneseTumeurs => 'Tumeurs';

  @override
  String get anamneseHepatite => 'Hépatite virale';

  @override
  String get anamneseSyphilis => 'Syphilis';

  @override
  String get anamneseFracturesSansTraumatisme =>
      'Fractures sans traumatisme apparent';

  @override
  String get anamneseAnnee => 'Année';

  @override
  String get anamneseDetails => 'Précisions';

  @override
  String get anamneseNotesComplementaires => 'Notes complémentaires';

  @override
  String get anamneseCardTitle => 'Anamnèse';

  @override
  String get anamneseCardEmpty => 'Aucune anamnèse renseignée';

  @override
  String get anamneseCardComplete => 'Compléter l\'anamnèse';

  @override
  String get anamneseCardEdit => 'Modifier l\'anamnèse';

  @override
  String get anamneseCardFilled => 'Anamnèse renseignée';

  @override
  String get anamneseSaveSuccess => 'Anamnèse enregistrée';

  @override
  String get anamneseSaveError => 'Impossible d\'enregistrer l\'anamnèse';
}
