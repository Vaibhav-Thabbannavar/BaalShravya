import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BaalShravya'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Early Hearing Screening'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship to infant'**
  String get relationship;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user? Register here'**
  String get newUser;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @roleAnm.
  ///
  /// In en, this message translates to:
  /// **'ANM / Healthcare Worker'**
  String get roleAnm;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent / Guardian'**
  String get roleParent;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectRole;

  /// No description provided for @healthCenter.
  ///
  /// In en, this message translates to:
  /// **'Health Center'**
  String get healthCenter;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrict;

  /// No description provided for @selectHealthCenter.
  ///
  /// In en, this message translates to:
  /// **'Select health center'**
  String get selectHealthCenter;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @awareness.
  ///
  /// In en, this message translates to:
  /// **'Awareness'**
  String get awareness;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myInfants.
  ///
  /// In en, this message translates to:
  /// **'My Infants'**
  String get myInfants;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @totalScreenings.
  ///
  /// In en, this message translates to:
  /// **'Total Screenings'**
  String get totalScreenings;

  /// No description provided for @totalReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get totalReferrals;

  /// No description provided for @totalPass.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get totalPass;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @recentCases.
  ///
  /// In en, this message translates to:
  /// **'Recent Cases'**
  String get recentCases;

  /// No description provided for @myCases.
  ///
  /// In en, this message translates to:
  /// **'My Cases'**
  String get myCases;

  /// No description provided for @newScreening.
  ///
  /// In en, this message translates to:
  /// **'New Screening'**
  String get newScreening;

  /// No description provided for @startScreening.
  ///
  /// In en, this message translates to:
  /// **'Start Screening'**
  String get startScreening;

  /// No description provided for @completeSession.
  ///
  /// In en, this message translates to:
  /// **'Complete Session'**
  String get completeSession;

  /// No description provided for @screeningSession.
  ///
  /// In en, this message translates to:
  /// **'Screening Session'**
  String get screeningSession;

  /// No description provided for @sessionDashboard.
  ///
  /// In en, this message translates to:
  /// **'Session Dashboard'**
  String get sessionDashboard;

  /// No description provided for @questionnaire.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire'**
  String get questionnaire;

  /// No description provided for @questionnaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Hearing Risk Questionnaire'**
  String get questionnaireTitle;

  /// No description provided for @boaScreening.
  ///
  /// In en, this message translates to:
  /// **'BOA Screening'**
  String get boaScreening;

  /// No description provided for @boaTitle.
  ///
  /// In en, this message translates to:
  /// **'Behavioral Observation Audiometry'**
  String get boaTitle;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get pass;

  /// No description provided for @refer.
  ///
  /// In en, this message translates to:
  /// **'REFER'**
  String get refer;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get ongoing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @infantDetails.
  ///
  /// In en, this message translates to:
  /// **'Infant Details'**
  String get infantDetails;

  /// No description provided for @infantName.
  ///
  /// In en, this message translates to:
  /// **'Infant Name'**
  String get infantName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @birthWeight.
  ///
  /// In en, this message translates to:
  /// **'Birth Weight (kg)'**
  String get birthWeight;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @cesarean.
  ///
  /// In en, this message translates to:
  /// **'Cesarean'**
  String get cesarean;

  /// No description provided for @assisted.
  ///
  /// In en, this message translates to:
  /// **'Assisted'**
  String get assisted;

  /// No description provided for @addInfant.
  ///
  /// In en, this message translates to:
  /// **'Add Infant'**
  String get addInfant;

  /// No description provided for @registerInfant.
  ///
  /// In en, this message translates to:
  /// **'Register Infant'**
  String get registerInfant;

  /// No description provided for @parentDetails.
  ///
  /// In en, this message translates to:
  /// **'Parent Details'**
  String get parentDetails;

  /// No description provided for @parentName.
  ///
  /// In en, this message translates to:
  /// **'Parent Name'**
  String get parentName;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @playingSound.
  ///
  /// In en, this message translates to:
  /// **'Playing sound...'**
  String get playingSound;

  /// No description provided for @didInfantRespond.
  ///
  /// In en, this message translates to:
  /// **'Did infant respond?'**
  String get didInfantRespond;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @startle.
  ///
  /// In en, this message translates to:
  /// **'Startle'**
  String get startle;

  /// No description provided for @eyeBlink.
  ///
  /// In en, this message translates to:
  /// **'Eye Blink'**
  String get eyeBlink;

  /// No description provided for @headTurn.
  ///
  /// In en, this message translates to:
  /// **'Head Turn'**
  String get headTurn;

  /// No description provided for @arousal.
  ///
  /// In en, this message translates to:
  /// **'Arousal'**
  String get arousal;

  /// No description provided for @noResponse.
  ///
  /// In en, this message translates to:
  /// **'No Response'**
  String get noResponse;

  /// No description provided for @stimulus.
  ///
  /// In en, this message translates to:
  /// **'Stimulus'**
  String get stimulus;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @submitBoa.
  ///
  /// In en, this message translates to:
  /// **'Submit BOA Results'**
  String get submitBoa;

  /// No description provided for @boaOutcome.
  ///
  /// In en, this message translates to:
  /// **'BOA Outcome'**
  String get boaOutcome;

  /// No description provided for @screeningReport.
  ///
  /// In en, this message translates to:
  /// **'Screening Report'**
  String get screeningReport;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharePdf;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printReport;

  /// No description provided for @referForOae.
  ///
  /// In en, this message translates to:
  /// **'Refer for OAE diagnosis'**
  String get referForOae;

  /// No description provided for @referForAabr.
  ///
  /// In en, this message translates to:
  /// **'Refer for AABR diagnosis'**
  String get referForAabr;

  /// No description provided for @referralType.
  ///
  /// In en, this message translates to:
  /// **'Referral Type'**
  String get referralType;

  /// No description provided for @referralNotes.
  ///
  /// In en, this message translates to:
  /// **'Referral Notes'**
  String get referralNotes;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get kannada;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorSomethingWentWrong;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternet;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errorSessionExpired;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get errorInvalidPhone;

  /// No description provided for @errorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordShort;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// Label text for the title input field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Early Hearing Detection'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Screen newborns for hearing loss in low-resource communities using just a smartphone.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Answer a simple questionnaire to identify infants at risk of hearing loss.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'BOA Screening'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Play calibrated sounds and observe infant responses to assess hearing.'**
  String get onboarding3Desc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @noInfantsYet.
  ///
  /// In en, this message translates to:
  /// **'No infants registered yet'**
  String get noInfantsYet;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No screening sessions yet'**
  String get noSessionsYet;

  /// No description provided for @noAwarenessContent.
  ///
  /// In en, this message translates to:
  /// **'No awareness content available'**
  String get noAwarenessContent;

  /// No description provided for @sessionStarted.
  ///
  /// In en, this message translates to:
  /// **'Screening session started'**
  String get sessionStarted;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session completed successfully'**
  String get sessionCompleted;

  /// No description provided for @questionnaireSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire submitted'**
  String get questionnaireSubmitted;

  /// No description provided for @boaSubmitted.
  ///
  /// In en, this message translates to:
  /// **'BOA results submitted'**
  String get boaSubmitted;

  /// No description provided for @infantRegistered.
  ///
  /// In en, this message translates to:
  /// **'Infant registered successfully'**
  String get infantRegistered;

  /// No description provided for @anmOf.
  ///
  /// In en, this message translates to:
  /// **'ANM · {healthCenter}'**
  String anmOf(String healthCenter);

  /// No description provided for @stimulusProgress.
  ///
  /// In en, this message translates to:
  /// **'Stimulus {current} of {total}'**
  String stimulusProgress(int current, int total);

  /// No description provided for @hz.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hz(int value);

  /// No description provided for @db.
  ///
  /// In en, this message translates to:
  /// **'{value} dB'**
  String db(int value);
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
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
