import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Medicail'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeTitle;

  /// No description provided for @homeSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get homeSignIn;

  /// No description provided for @recordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement'**
  String get recordTitle;

  /// No description provided for @buttonStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get buttonStart;

  /// No description provided for @buttonStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get buttonStop;

  /// No description provided for @buttonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get buttonSave;

  /// No description provided for @buttonFinishConsultation.
  ///
  /// In fr, this message translates to:
  /// **'Terminer consultation'**
  String get buttonFinishConsultation;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Problème de connexion'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur'**
  String get errorServer;

  /// No description provided for @errorAudio.
  ///
  /// In fr, this message translates to:
  /// **'Microphone indisponible'**
  String get errorAudio;

  /// No description provided for @labelHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get labelHistory;

  /// No description provided for @navigateToRecord.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel enregistrement'**
  String get navigateToRecord;

  /// No description provided for @transcriptLabel.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get transcriptLabel;

  /// No description provided for @transcriptEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Aucune parole captee pour le moment'**
  String get transcriptEmptyHint;

  /// No description provided for @transcriptEmptyFallback.
  ///
  /// In fr, this message translates to:
  /// **'Transcription vide'**
  String get transcriptEmptyFallback;

  /// No description provided for @buttonClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get buttonClear;

  /// No description provided for @recordStatusReady.
  ///
  /// In fr, this message translates to:
  /// **'Pret a ecouter'**
  String get recordStatusReady;

  /// No description provided for @recordStatusInitializing.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation du micro'**
  String get recordStatusInitializing;

  /// No description provided for @recordStatusListening.
  ///
  /// In fr, this message translates to:
  /// **'Ecoute en cours'**
  String get recordStatusListening;

  /// No description provided for @recordStatusPaused.
  ///
  /// In fr, this message translates to:
  /// **'Ecoute en pause'**
  String get recordStatusPaused;

  /// No description provided for @recordStatusEnded.
  ///
  /// In fr, this message translates to:
  /// **'Session terminee'**
  String get recordStatusEnded;

  /// No description provided for @recordNotificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ecoute en cours'**
  String get recordNotificationTitle;

  /// No description provided for @recordNotificationBody.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour revenir a Medicail'**
  String get recordNotificationBody;

  /// No description provided for @recordNotificationBackgroundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement en arriere-plan'**
  String get recordNotificationBackgroundTitle;

  /// No description provided for @recordNotificationBackgroundBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'ecoute continue pendant que l\'ecran est eteint'**
  String get recordNotificationBackgroundBody;

  /// No description provided for @recordStatusTranscribingBackground.
  ///
  /// In fr, this message translates to:
  /// **'Transcription du passage en veille…'**
  String get recordStatusTranscribingBackground;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note pour le moment'**
  String get historyEmpty;

  /// No description provided for @appointmentsTodayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous du jour'**
  String get appointmentsTodayTitle;

  /// No description provided for @appointmentsUpcomingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prochains rendez-vous'**
  String get appointmentsUpcomingTitle;

  /// No description provided for @appointmentsDayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get appointmentsDayTitle;

  /// No description provided for @appointmentsSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get appointmentsSeeAll;

  /// No description provided for @appointmentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous pour cette journee'**
  String get appointmentsEmpty;

  /// No description provided for @appointmentsUpcomingEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prochain rendez-vous'**
  String get appointmentsUpcomingEmpty;

  /// No description provided for @appointmentCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau rendez-vous'**
  String get appointmentCreateTitle;

  /// No description provided for @appointmentEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le rendez-vous'**
  String get appointmentEditTitle;

  /// No description provided for @appointmentCreateSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Creer le rendez-vous'**
  String get appointmentCreateSubmit;

  /// No description provided for @appointmentSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get appointmentSaveChanges;

  /// No description provided for @appointmentSaved.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous enregistre'**
  String get appointmentSaved;

  /// No description provided for @appointmentEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get appointmentEdit;

  /// No description provided for @appointmentCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get appointmentCancel;

  /// No description provided for @appointmentDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get appointmentDelete;

  /// No description provided for @appointmentNotesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get appointmentNotesLabel;

  /// No description provided for @appointmentPatientRequired.
  ///
  /// In fr, this message translates to:
  /// **'Selectionnez un patient'**
  String get appointmentPatientRequired;

  /// No description provided for @appointmentEndBeforeStart.
  ///
  /// In fr, this message translates to:
  /// **'L\'heure de fin doit etre apres l\'heure de debut'**
  String get appointmentEndBeforeStart;

  /// No description provided for @appointmentKeepPatientHint.
  ///
  /// In fr, this message translates to:
  /// **'Laissez le patient actuel, ou choisissez-en un autre ci-dessous.'**
  String get appointmentKeepPatientHint;

  /// No description provided for @appointmentStatusScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Planifie'**
  String get appointmentStatusScheduled;

  /// No description provided for @appointmentStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annule'**
  String get appointmentStatusCancelled;

  /// No description provided for @appointmentStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Termine'**
  String get appointmentStatusCompleted;

  /// No description provided for @appointmentStartTime.
  ///
  /// In fr, this message translates to:
  /// **'Debut {time}'**
  String appointmentStartTime(String time);

  /// No description provided for @appointmentEndTime.
  ///
  /// In fr, this message translates to:
  /// **'Fin {time}'**
  String appointmentEndTime(String time);

  /// No description provided for @patientsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @patientsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers patients'**
  String get patientsSectionTitle;

  /// No description provided for @patientsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun patient pour le moment'**
  String get patientsEmpty;

  /// No description provided for @patientFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prenom'**
  String get patientFirstNameLabel;

  /// No description provided for @patientLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get patientLastNameLabel;

  /// No description provided for @patientCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Creer le patient'**
  String get patientCreateButton;

  /// No description provided for @patientOpenButton.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le dossier'**
  String get patientOpenButton;

  /// No description provided for @patientDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier patient'**
  String get patientDetailTitle;

  /// No description provided for @patientNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Patient introuvable'**
  String get patientNotFound;

  /// No description provided for @patientMrnConflict.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro de dossier (MRN) existe déjà.'**
  String get patientMrnConflict;

  /// No description provided for @patientNewConsultationButton.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle consultation'**
  String get patientNewConsultationButton;

  /// No description provided for @patientSessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consultations'**
  String get patientSessionsTitle;

  /// No description provided for @patientSessionsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune consultation pour ce patient'**
  String get patientSessionsEmpty;

  /// No description provided for @recordingStatusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get recordingStatusLabel;

  /// No description provided for @recordingAudioLabel.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get recordingAudioLabel;

  /// No description provided for @inputErrorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get inputErrorRequired;

  /// No description provided for @inputErrorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide'**
  String get inputErrorEmail;

  /// No description provided for @inputErrorNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get inputErrorNumber;

  /// No description provided for @inputErrorPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get inputErrorPassword;

  /// No description provided for @inputPasswordToggle.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get inputPasswordToggle;

  /// No description provided for @debugShakeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode développeur'**
  String get debugShakeTitle;

  /// No description provided for @debugShakeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la page de démonstration des composants ?'**
  String get debugShakeMessage;

  /// No description provided for @debugShakeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get debugShakeConfirm;

  /// No description provided for @debugShakeCancel.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get debugShakeCancel;

  /// No description provided for @debugPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Composants UI'**
  String get debugPageTitle;

  /// No description provided for @debugSectionButtons.
  ///
  /// In fr, this message translates to:
  /// **'Boutons'**
  String get debugSectionButtons;

  /// No description provided for @debugSectionInputs.
  ///
  /// In fr, this message translates to:
  /// **'Champs'**
  String get debugSectionInputs;

  /// No description provided for @debugSectionBottomSheet.
  ///
  /// In fr, this message translates to:
  /// **'Bottom sheet'**
  String get debugSectionBottomSheet;

  /// No description provided for @debugSectionDialog.
  ///
  /// In fr, this message translates to:
  /// **'Dialogues'**
  String get debugSectionDialog;

  /// No description provided for @debugSectionToast.
  ///
  /// In fr, this message translates to:
  /// **'Toasts'**
  String get debugSectionToast;

  /// No description provided for @debugButtonPrimary.
  ///
  /// In fr, this message translates to:
  /// **'Primaire'**
  String get debugButtonPrimary;

  /// No description provided for @debugButtonSecondary.
  ///
  /// In fr, this message translates to:
  /// **'Secondaire'**
  String get debugButtonSecondary;

  /// No description provided for @debugButtonWarning.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement'**
  String get debugButtonWarning;

  /// No description provided for @debugButtonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get debugButtonError;

  /// No description provided for @debugButtonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get debugButtonLoading;

  /// No description provided for @debugButtonDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get debugButtonDisabled;

  /// No description provided for @debugButtonIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get debugButtonIcon;

  /// No description provided for @debugButtonTextIcon.
  ///
  /// In fr, this message translates to:
  /// **'Texte + icône'**
  String get debugButtonTextIcon;

  /// No description provided for @debugInputText.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get debugInputText;

  /// No description provided for @debugInputNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre'**
  String get debugInputNumber;

  /// No description provided for @debugInputEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get debugInputEmail;

  /// No description provided for @debugInputPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get debugInputPassword;

  /// No description provided for @debugInputTextarea.
  ///
  /// In fr, this message translates to:
  /// **'Zone de texte'**
  String get debugInputTextarea;

  /// No description provided for @debugOpenBottomSheet.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir bottom sheet'**
  String get debugOpenBottomSheet;

  /// No description provided for @debugBottomSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bottom sheet personnalisé'**
  String get debugBottomSheetTitle;

  /// No description provided for @debugBottomSheetBody.
  ///
  /// In fr, this message translates to:
  /// **'Contenu personnalisable du bottom sheet.'**
  String get debugBottomSheetBody;

  /// No description provided for @debugOpenFullscreenDialog.
  ///
  /// In fr, this message translates to:
  /// **'Dialogue plein écran'**
  String get debugOpenFullscreenDialog;

  /// No description provided for @debugOpenLockDialog.
  ///
  /// In fr, this message translates to:
  /// **'Dialogue verrouillé'**
  String get debugOpenLockDialog;

  /// No description provided for @debugFullscreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran'**
  String get debugFullscreenTitle;

  /// No description provided for @debugFullscreenBody.
  ///
  /// In fr, this message translates to:
  /// **'Exemple de dialogue plein écran.'**
  String get debugFullscreenBody;

  /// No description provided for @debugLockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écran verrouillé'**
  String get debugLockTitle;

  /// No description provided for @debugLockBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce dialogue ne peut pas être fermé par un tap extérieur.'**
  String get debugLockBody;

  /// No description provided for @debugLockDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller'**
  String get debugLockDismiss;

  /// No description provided for @debugToastSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Opération réussie'**
  String get debugToastSuccess;

  /// No description provided for @debugToastWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention requise'**
  String get debugToastWarning;

  /// No description provided for @debugToastInfo.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get debugToastInfo;

  /// No description provided for @debugShowToastSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Toast succès'**
  String get debugShowToastSuccess;

  /// No description provided for @debugShowToastWarning.
  ///
  /// In fr, this message translates to:
  /// **'Toast avertissement'**
  String get debugShowToastWarning;

  /// No description provided for @debugShowToastError.
  ///
  /// In fr, this message translates to:
  /// **'Toast erreur'**
  String get debugShowToastError;

  /// No description provided for @debugShowToastInfo.
  ///
  /// In fr, this message translates to:
  /// **'Toast info'**
  String get debugShowToastInfo;

  /// No description provided for @debugClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get debugClose;

  /// No description provided for @debugSectionBackend.
  ///
  /// In fr, this message translates to:
  /// **'Backend (debug)'**
  String get debugSectionBackend;

  /// No description provided for @debugBackendUrlSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Surcharge l\'URL de l\'API. Disponible uniquement en debug sur bureau.'**
  String get debugBackendUrlSubtitle;

  /// No description provided for @debugBackendUrlLabel.
  ///
  /// In fr, this message translates to:
  /// **'URL de l\'API'**
  String get debugBackendUrlLabel;

  /// No description provided for @debugBackendUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'http://localhost:3000/api/v1'**
  String get debugBackendUrlHint;

  /// No description provided for @debugBackendUrlSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get debugBackendUrlSave;

  /// No description provided for @debugBackendUrlReset.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser'**
  String get debugBackendUrlReset;

  /// No description provided for @debugBackendUrlSaved.
  ///
  /// In fr, this message translates to:
  /// **'URL backend mise a jour'**
  String get debugBackendUrlSaved;

  /// No description provided for @debugBackendUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'URL invalide (http ou https requis)'**
  String get debugBackendUrlInvalid;

  /// No description provided for @soapNoteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Note SOAP'**
  String get soapNoteTitle;

  /// No description provided for @soapNoteSubjective.
  ///
  /// In fr, this message translates to:
  /// **'Subjectif'**
  String get soapNoteSubjective;

  /// No description provided for @soapNoteObjective.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get soapNoteObjective;

  /// No description provided for @soapNoteAssessment.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation'**
  String get soapNoteAssessment;

  /// No description provided for @soapNotePlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get soapNotePlan;

  /// No description provided for @soapNoteSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la note'**
  String get soapNoteSave;

  /// No description provided for @soapNoteViewAction.
  ///
  /// In fr, this message translates to:
  /// **'Voir la note SOAP'**
  String get soapNoteViewAction;

  /// No description provided for @patientSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un patient'**
  String get patientSearchPlaceholder;

  /// No description provided for @patientCreateErrorRequired.
  ///
  /// In fr, this message translates to:
  /// **'MRN, Prénom et Nom sont requis.'**
  String get patientCreateErrorRequired;

  /// No description provided for @patientCreateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Dossier patient créé avec succès.'**
  String get patientCreateSuccess;

  /// No description provided for @patientCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Patient'**
  String get patientCreateTitle;

  /// No description provided for @patientMrnLabel.
  ///
  /// In fr, this message translates to:
  /// **'MRN (Numéro de dossier) *'**
  String get patientMrnLabel;

  /// No description provided for @patientFirstNameRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom *'**
  String get patientFirstNameRequiredLabel;

  /// No description provided for @patientLastNameRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom *'**
  String get patientLastNameRequiredLabel;

  /// No description provided for @patientBirthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get patientBirthDateLabel;

  /// No description provided for @patientBirthDateSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get patientBirthDateSelect;

  /// No description provided for @patientSexLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get patientSexLabel;

  /// No description provided for @patientSexMale.
  ///
  /// In fr, this message translates to:
  /// **'Homme'**
  String get patientSexMale;

  /// No description provided for @patientSexFemale.
  ///
  /// In fr, this message translates to:
  /// **'Femme'**
  String get patientSexFemale;

  /// No description provided for @patientSexOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get patientSexOther;

  /// No description provided for @patientEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get patientEmailLabel;

  /// No description provided for @patientPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get patientPhoneLabel;

  /// No description provided for @patientAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get patientAddressLabel;

  /// No description provided for @patientNotesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get patientNotesLabel;

  /// No description provided for @patientCreateSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le dossier'**
  String get patientCreateSubmit;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Medicail'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour synchroniser vos dossiers, ou continuez sans compte. Vos donnees restent chiffrees sur cet appareil.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginCreateAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Creer un compte'**
  String get loginCreateAccountButton;

  /// No description provided for @loginContinueWithoutAccount.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get loginContinueWithoutAccount;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Medicail pour gérer vos consultations.'**
  String get registerSubtitle;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet (optionnel)'**
  String get registerFullNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get registerSubmit;

  /// No description provided for @recordingDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get recordingDateLabel;

  /// No description provided for @assignPatientTitle.
  ///
  /// In fr, this message translates to:
  /// **'Associer à un patient'**
  String get assignPatientTitle;

  /// No description provided for @assignPatientSearchTab.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get assignPatientSearchTab;

  /// No description provided for @assignPatientNewTab.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau patient'**
  String get assignPatientNewTab;

  /// No description provided for @assignPatientError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'association'**
  String get assignPatientError;

  /// No description provided for @recordLeaveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'enregistrement ?'**
  String get recordLeaveTitle;

  /// No description provided for @recordLeaveMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette consultation n\'est pas enregistree. Voulez-vous la sauvegarder et l\'associer a un patient ?'**
  String get recordLeaveMessage;

  /// No description provided for @recordLeaveMessageWithPatient.
  ///
  /// In fr, this message translates to:
  /// **'Cette consultation n\'est pas enregistree. Voulez-vous la sauvegarder dans le dossier du patient ?'**
  String get recordLeaveMessageWithPatient;

  /// No description provided for @recordLeaveSaveAndAssign.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et associer'**
  String get recordLeaveSaveAndAssign;

  /// No description provided for @recordLeaveDiscard.
  ///
  /// In fr, this message translates to:
  /// **'Quitter sans enregistrer'**
  String get recordLeaveDiscard;

  /// No description provided for @recordLeaveCancel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'enregistrement'**
  String get recordLeaveCancel;

  /// No description provided for @radialActionNewRecord.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel enregistrement'**
  String get radialActionNewRecord;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSolarized.
  ///
  /// In fr, this message translates to:
  /// **'Solarized'**
  String get settingsThemeSolarized;

  /// No description provided for @settingsFontSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get settingsFontSize;

  /// No description provided for @settingsFontSizeSmall.
  ///
  /// In fr, this message translates to:
  /// **'Petit'**
  String get settingsFontSizeSmall;

  /// No description provided for @settingsFontSizeDefault.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get settingsFontSizeDefault;

  /// No description provided for @settingsFontSizeLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grand'**
  String get settingsFontSizeLarge;

  /// No description provided for @settingsFontSizeExtraLarge.
  ///
  /// In fr, this message translates to:
  /// **'Tres grand'**
  String get settingsFontSizeExtraLarge;

  /// No description provided for @settingsDefaultSessionLength.
  ///
  /// In fr, this message translates to:
  /// **'Duree de seance par defaut'**
  String get settingsDefaultSessionLength;

  /// No description provided for @settingsSessionLength30m.
  ///
  /// In fr, this message translates to:
  /// **'30 min'**
  String get settingsSessionLength30m;

  /// No description provided for @settingsSessionLength45m.
  ///
  /// In fr, this message translates to:
  /// **'45 min'**
  String get settingsSessionLength45m;

  /// No description provided for @settingsSessionLength1h.
  ///
  /// In fr, this message translates to:
  /// **'1 h'**
  String get settingsSessionLength1h;

  /// No description provided for @settingsSessionLength1h30.
  ///
  /// In fr, this message translates to:
  /// **'1 h 30'**
  String get settingsSessionLength1h30;

  /// No description provided for @settingsSessionLength2h.
  ///
  /// In fr, this message translates to:
  /// **'2 h'**
  String get settingsSessionLength2h;

  /// No description provided for @settingsTemplates.
  ///
  /// In fr, this message translates to:
  /// **'Modeles'**
  String get settingsTemplates;

  /// No description provided for @settingsRestartOnboarding.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer l\'introduction'**
  String get settingsRestartOnboarding;

  /// No description provided for @settingsTbd.
  ///
  /// In fr, this message translates to:
  /// **'TBD'**
  String get settingsTbd;

  /// No description provided for @settingsLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se deconnecter'**
  String get settingsLogout;

  /// No description provided for @tutorialIntroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Decouvrir Medicail'**
  String get tutorialIntroTitle;

  /// No description provided for @tutorialIntroDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un tutoriel rapide peut vous guider dans la creation d\'un dossier patient, une premiere consultation, puis un enregistrement rapide depuis l\'accueil.'**
  String get tutorialIntroDesc;

  /// No description provided for @tutorialIntroStart.
  ///
  /// In fr, this message translates to:
  /// **'Faire le tutoriel'**
  String get tutorialIntroStart;

  /// No description provided for @tutorialIntroSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get tutorialIntroSkip;

  /// No description provided for @tutorialHomePatientsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers Patients'**
  String get tutorialHomePatientsTitle;

  /// No description provided for @tutorialHomePatientsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez ici pour acceder a la liste de vos patients ou en creer un nouveau.\n\n👉 Appuyez sur l\'onglet \'Patients\' ci-dessous pour continuer.'**
  String get tutorialHomePatientsDesc;

  /// No description provided for @tutorialHomeRecordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consultation Rapide'**
  String get tutorialHomeRecordTitle;

  /// No description provided for @tutorialHomeRecordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Depuis l\'ecran d\'accueil, utilisez ce bouton pour demarrer immediatement une consultation vocale.\n\n👉 Appuyez sur ce bouton d\'enregistrement pour continuer.'**
  String get tutorialHomeRecordDesc;

  /// No description provided for @tutorialPatientAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un patient'**
  String get tutorialPatientAddTitle;

  /// No description provided for @tutorialPatientAddDesc.
  ///
  /// In fr, this message translates to:
  /// **'C\'est ici que vous pouvez creer un nouveau dossier patient en renseignant ses informations de base.\n\n👉 Appuyez sur le bouton \'+\' en haut a droite pour continuer.'**
  String get tutorialPatientAddDesc;

  /// No description provided for @tutorialPatientMrnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Numero de dossier'**
  String get tutorialPatientMrnTitle;

  /// No description provided for @tutorialPatientMrnDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le numero de dossier (MRN) identifie chaque patient de maniere unique.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.'**
  String get tutorialPatientMrnDesc;

  /// No description provided for @tutorialPatientFirstNameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du patient'**
  String get tutorialPatientFirstNameTitle;

  /// No description provided for @tutorialPatientFirstNameDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le prenom fait partie des informations de base du dossier patient.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.'**
  String get tutorialPatientFirstNameDesc;

  /// No description provided for @tutorialPatientLastNameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom du patient'**
  String get tutorialPatientLastNameTitle;

  /// No description provided for @tutorialPatientLastNameDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le nom complete l\'identite du patient. Les autres champs sont optionnels.\n\n👉 Appuyez sur le champ en surbrillance pour continuer.'**
  String get tutorialPatientLastNameDesc;

  /// No description provided for @tutorialPatientCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Creer le dossier'**
  String get tutorialPatientCreateTitle;

  /// No description provided for @tutorialPatientCreateDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ce bouton enregistre le dossier patient une fois les informations saisies.\n\n👉 Appuyez sur \'Creer le dossier\' pour continuer la demonstration.'**
  String get tutorialPatientCreateDesc;

  /// No description provided for @tutorialDetailConsultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle consultation'**
  String get tutorialDetailConsultTitle;

  /// No description provided for @tutorialDetailConsultDesc.
  ///
  /// In fr, this message translates to:
  /// **'Lancez l\'enregistrement vocal pour demarrer une nouvelle consultation avec ce patient.\n\n👉 Appuyez sur \'Nouvelle consultation\' pour continuer.'**
  String get tutorialDetailConsultDesc;

  /// No description provided for @tutorialRecordTitle.
  ///
  /// In fr, this message translates to:
  /// **'La Dictee'**
  String get tutorialRecordTitle;

  /// No description provided for @tutorialRecordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur ce bouton pour lancer l\'enregistrement vocal. L\'IA transcrira automatiquement vos paroles et anonymisera les donnees.\n\n👉 Appuyez sur le micro en surbrillance pour demarrer.'**
  String get tutorialRecordDesc;

  /// No description provided for @tutorialRecordStopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arreter l\'ecoute'**
  String get tutorialRecordStopTitle;

  /// No description provided for @tutorialRecordStopDesc.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez ici quand la consultation vocale est terminee pour mettre l\'ecoute en pause.\n\n👉 Appuyez sur le bouton d\'arret pour mettre en pause.'**
  String get tutorialRecordStopDesc;

  /// No description provided for @tutorialRecordFinishTitle.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la consultation'**
  String get tutorialRecordFinishTitle;

  /// No description provided for @tutorialRecordFinishDesc.
  ///
  /// In fr, this message translates to:
  /// **'Validez la fin de la consultation. Vous reviendrez ensuite a l\'accueil pour voir le workflow Nouvel enregistrement.\n\n👉 Appuyez sur la zone en surbrillance pour enregistrer.'**
  String get tutorialRecordFinishDesc;

  /// No description provided for @tutorialRecordTranscriptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transcription en temps reel'**
  String get tutorialRecordTranscriptTitle;

  /// No description provided for @tutorialRecordTranscriptDesc.
  ///
  /// In fr, this message translates to:
  /// **'Pendant l\'enregistrement, le texte apparait ici en direct pour vous permettre de suivre la dictee.\n\n👉 Attendez ou appuyez sur l\'ecran pour continuer.'**
  String get tutorialRecordTranscriptDesc;

  /// No description provided for @tutorialAssignPatientTitle.
  ///
  /// In fr, this message translates to:
  /// **'Associer a un patient'**
  String get tutorialAssignPatientTitle;

  /// No description provided for @tutorialAssignPatientDesc.
  ///
  /// In fr, this message translates to:
  /// **'Apres un nouvel enregistrement, vous pouvez choisir un patient existant avec l\'onglet Rechercher, ou creer un nouveau dossier avec l\'onglet Nouveau patient.\n\n👉 Appuyez sur \'Associer a un patient\' pour continuer.'**
  String get tutorialAssignPatientDesc;

  /// No description provided for @tutorialRestarted.
  ///
  /// In fr, this message translates to:
  /// **'Le tutoriel a ete reinitialise.'**
  String get tutorialRestarted;

  /// No description provided for @templatesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modeles de pathologie'**
  String get templatesTitle;

  /// No description provided for @templatesBuiltInSection.
  ///
  /// In fr, this message translates to:
  /// **'Modeles par defaut'**
  String get templatesBuiltInSection;

  /// No description provided for @templatesUserSection.
  ///
  /// In fr, this message translates to:
  /// **'Mes variantes'**
  String get templatesUserSection;

  /// No description provided for @templatesUserEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune variante enregistree.'**
  String get templatesUserEmpty;

  /// No description provided for @templatesDefaultBadge.
  ///
  /// In fr, this message translates to:
  /// **'Defaut'**
  String get templatesDefaultBadge;

  /// No description provided for @templatesVariantBadge.
  ///
  /// In fr, this message translates to:
  /// **'Variante'**
  String get templatesVariantBadge;

  /// No description provided for @templateDuplicateAction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier en variante'**
  String get templateDuplicateAction;

  /// No description provided for @templateDuplicated.
  ///
  /// In fr, this message translates to:
  /// **'Variante creee.'**
  String get templateDuplicated;

  /// No description provided for @templateSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modele enregistre.'**
  String get templateSaved;

  /// No description provided for @templateDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la variante ?'**
  String get templateDeleteTitle;

  /// No description provided for @templateDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le modele \"{name}\" ?'**
  String templateDeleteMessage(String name);

  /// No description provided for @templateDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get templateDeleteConfirm;

  /// No description provided for @templateEditorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Editer le modele'**
  String get templateEditorTitle;

  /// No description provided for @templateNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Modele introuvable.'**
  String get templateNotFound;

  /// No description provided for @templateSectionTitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre de section'**
  String get templateSectionTitleLabel;

  /// No description provided for @templateSectionPromptLabel.
  ///
  /// In fr, this message translates to:
  /// **'Structure / puces'**
  String get templateSectionPromptLabel;

  /// No description provided for @templateAddSection.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une section'**
  String get templateAddSection;

  /// No description provided for @templateSaveAsVariant.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer comme variante'**
  String get templateSaveAsVariant;

  /// No description provided for @templateUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre a jour'**
  String get templateUpdate;

  /// No description provided for @templateReset.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser depuis le parent'**
  String get templateReset;

  /// No description provided for @templatePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un modele'**
  String get templatePickerTitle;

  /// No description provided for @templatePickerSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une pathologie'**
  String get templatePickerSearch;

  /// No description provided for @templatePickerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modele trouve.'**
  String get templatePickerEmpty;

  /// No description provided for @templatePickerAction.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un modele'**
  String get templatePickerAction;

  /// No description provided for @templateActiveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Modele : {name}'**
  String templateActiveLabel(String name);

  /// No description provided for @templateNoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modele selectionne'**
  String get templateNoneLabel;

  /// No description provided for @templateRetry.
  ///
  /// In fr, this message translates to:
  /// **'Reessayer'**
  String get templateRetry;

  /// No description provided for @templatesBuiltInEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modele par defaut disponible. Reinstallez l application.'**
  String get templatesBuiltInEmpty;

  /// No description provided for @settingsSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get settingsSignIn;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In fr, this message translates to:
  /// **'Session expiree, veuillez vous reconnecter'**
  String get sessionExpiredMessage;

  /// No description provided for @errorToastCopied.
  ///
  /// In fr, this message translates to:
  /// **'Details de l\'erreur copies'**
  String get errorToastCopied;

  /// No description provided for @errorToastReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler l\'erreur'**
  String get errorToastReport;

  /// No description provided for @punctuationWordPeriod.
  ///
  /// In fr, this message translates to:
  /// **'point'**
  String get punctuationWordPeriod;

  /// No description provided for @punctuationWordComma.
  ///
  /// In fr, this message translates to:
  /// **'virgule'**
  String get punctuationWordComma;

  /// No description provided for @punctuationTransitions.
  ///
  /// In fr, this message translates to:
  /// **'le patient,la patiente,à l\'examen,a l\'examen,au niveau,pour le traitement,pour la suite,mon diagnostic,ensuite,enfin'**
  String get punctuationTransitions;

  /// No description provided for @medicalWatchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Veille medicale'**
  String get medicalWatchTitle;

  /// No description provided for @medicalWatchSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher sur PubMed…'**
  String get medicalWatchSearchPlaceholder;

  /// No description provided for @medicalWatchFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get medicalWatchFilterAll;

  /// No description provided for @medicalWatchSpecialtyRehabilitation.
  ///
  /// In fr, this message translates to:
  /// **'Reeducation'**
  String get medicalWatchSpecialtyRehabilitation;

  /// No description provided for @medicalWatchSpecialtyMusculoskeletal.
  ///
  /// In fr, this message translates to:
  /// **'Musculo-squelettique'**
  String get medicalWatchSpecialtyMusculoskeletal;

  /// No description provided for @medicalWatchSpecialtyExerciseTherapy.
  ///
  /// In fr, this message translates to:
  /// **'Therapie par l\'exercice'**
  String get medicalWatchSpecialtyExerciseTherapy;

  /// No description provided for @medicalWatchSpecialtyManualTherapy.
  ///
  /// In fr, this message translates to:
  /// **'Therapie manuelle'**
  String get medicalWatchSpecialtyManualTherapy;

  /// No description provided for @medicalWatchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article pour le moment'**
  String get medicalWatchEmpty;

  /// No description provided for @medicalWatchSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun resultat pour cette recherche'**
  String get medicalWatchSearchEmpty;

  /// No description provided for @medicalWatchErrorLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les articles'**
  String get medicalWatchErrorLoad;

  /// No description provided for @medicalWatchErrorSearch.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la recherche PubMed'**
  String get medicalWatchErrorSearch;

  /// No description provided for @medicalWatchReadMore.
  ///
  /// In fr, this message translates to:
  /// **'Lire la suite'**
  String get medicalWatchReadMore;

  /// No description provided for @medicalWatchReadLess.
  ///
  /// In fr, this message translates to:
  /// **'Reduire'**
  String get medicalWatchReadLess;

  /// No description provided for @medicalWatchOpenPubmed.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans PubMed'**
  String get medicalWatchOpenPubmed;

  /// No description provided for @medicalWatchCopyReference.
  ///
  /// In fr, this message translates to:
  /// **'Copier la reference'**
  String get medicalWatchCopyReference;

  /// No description provided for @medicalWatchReferenceCopied.
  ///
  /// In fr, this message translates to:
  /// **'Reference copiee'**
  String get medicalWatchReferenceCopied;

  /// No description provided for @medicalWatchArticleCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun article} =1{1 article} other{{count} articles}}'**
  String medicalWatchArticleCount(int count);

  /// No description provided for @medicalWatchSyncSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Veille synchronisee'**
  String get medicalWatchSyncSuccess;

  /// No description provided for @medicalWatchOfflineHint.
  ///
  /// In fr, this message translates to:
  /// **'Resultats hors-ligne (derniere synchronisation)'**
  String get medicalWatchOfflineHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
