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

  /// No description provided for @navigateToPatients.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers patients'**
  String get navigateToPatients;

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

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note pour le moment'**
  String get historyEmpty;

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

  /// No description provided for @debugToastError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get debugToastError;

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
  /// **'Connectez-vous pour accéder à vos dossiers.'**
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

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginCreateAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccountButton;

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
