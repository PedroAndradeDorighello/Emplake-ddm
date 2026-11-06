import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Pedro & Partner'**
  String get teamMembers;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make true equations from four digits'**
  String get loginSubtitle;

  /// No description provided for @signInEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get signInEmail;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest (offline)'**
  String get continueAsGuest;

  /// No description provided for @authFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter email and password.'**
  String get authFieldsRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @navGame.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navGame;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @nextPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPuzzle;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct! Equation is true.'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Not equal. Try again.'**
  String get incorrect;

  /// No description provided for @nonIntegerDivision.
  ///
  /// In en, this message translates to:
  /// **'Non-integer division is only allowed on Easy.'**
  String get nonIntegerDivision;

  /// No description provided for @invalidExpression.
  ///
  /// In en, this message translates to:
  /// **'Invalid expression.'**
  String get invalidExpression;

  /// No description provided for @missingEquals.
  ///
  /// In en, this message translates to:
  /// **'Place exactly one equals sign (=).'**
  String get missingEquals;

  /// No description provided for @selectSlot.
  ///
  /// In en, this message translates to:
  /// **'Drag a sign onto a slot. Drag it off the board to remove it.'**
  String get selectSlot;

  /// No description provided for @latexPreview.
  ///
  /// In en, this message translates to:
  /// **'LaTeX preview'**
  String get latexPreview;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @solvedCount.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solvedCount;

  /// No description provided for @skippedCount.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedCount;

  /// No description provided for @noSolvedYet.
  ///
  /// In en, this message translates to:
  /// **'No puzzles solved yet.'**
  String get noSolvedYet;

  /// No description provided for @loadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading your progress…'**
  String get loadingProgress;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontFamily;

  /// No description provided for @seedColor.
  ///
  /// In en, this message translates to:
  /// **'Seed color'**
  String get seedColor;

  /// No description provided for @presetTheme.
  ///
  /// In en, this message translates to:
  /// **'Preset themes'**
  String get presetTheme;

  /// No description provided for @schemeStyle.
  ///
  /// In en, this message translates to:
  /// **'Color style'**
  String get schemeStyle;

  /// No description provided for @schemeTonalSpot.
  ///
  /// In en, this message translates to:
  /// **'Tonal spot'**
  String get schemeTonalSpot;

  /// No description provided for @schemeFidelity.
  ///
  /// In en, this message translates to:
  /// **'Fidelity'**
  String get schemeFidelity;

  /// No description provided for @schemeMonochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get schemeMonochrome;

  /// No description provided for @schemeNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get schemeNeutral;

  /// No description provided for @schemeVibrant.
  ///
  /// In en, this message translates to:
  /// **'Vibrant'**
  String get schemeVibrant;

  /// No description provided for @schemeExpressive.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get schemeExpressive;

  /// No description provided for @schemeContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get schemeContent;

  /// No description provided for @schemeRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get schemeRainbow;

  /// No description provided for @schemeFruitSalad.
  ///
  /// In en, this message translates to:
  /// **'Fruit salad'**
  String get schemeFruitSalad;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get soundOff;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpTitle;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'You get four digits in this order. Drag signs into the gaps before the first digit, between them, and after the last one, until both sides of = are equal.\n\n• The expression starts empty. = is not placed in the middle: put it where the equality makes sense.\n• An empty gap joins digits. 3 and 4 side by side make 34.\n• To remove a sign, drag it off the expression.\n• Easy adds square root, cube root, factorial, power, absolute value, floor, and ceiling. Only this level allows a non-integer division.\n• Intermediate drops floor and ceiling. Advanced keeps square root, factorial, and absolute value. Hard keeps +, −, ×, ÷, parentheses, and absolute value.\n• Skip replaces the number. Solved ones do not appear again.'**
  String get helpBody;

  /// No description provided for @operatorsForLevel.
  ///
  /// In en, this message translates to:
  /// **'Operators for this level'**
  String get operatorsForLevel;

  /// No description provided for @puzzleNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get puzzleNumber;

  /// No description provided for @guestBanner.
  ///
  /// In en, this message translates to:
  /// **'Guest mode — progress stays on this device until you sign in.'**
  String get guestBanner;

  /// No description provided for @firebaseMissing.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured. Using offline guest mode.'**
  String get firebaseMissing;

  /// No description provided for @fontRoboto.
  ///
  /// In en, this message translates to:
  /// **'Roboto'**
  String get fontRoboto;

  /// No description provided for @fontGaramond.
  ///
  /// In en, this message translates to:
  /// **'Garamond'**
  String get fontGaramond;

  /// No description provided for @fontHelvetica.
  ///
  /// In en, this message translates to:
  /// **'Helvetica-like'**
  String get fontHelvetica;

  /// No description provided for @fontMono.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get fontMono;

  /// No description provided for @presetOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean forge'**
  String get presetOcean;

  /// No description provided for @presetEmber.
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get presetEmber;

  /// No description provided for @presetForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get presetForest;

  /// No description provided for @presetSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get presetSlate;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom seed'**
  String get presetCustom;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
