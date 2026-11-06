// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get teamMembers => 'Pedro & Partner';

  @override
  String get loginSubtitle => 'Make true equations from four digits';

  @override
  String get signInEmail => 'Sign in with email';

  @override
  String get signIn => 'Sign in';

  @override
  String get register => 'Register';

  @override
  String get orSignInWith => 'Or sign in with';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get signOut => 'Sign out';

  @override
  String get continueAsGuest => 'Guest (offline)';

  @override
  String get authFieldsRequired => 'Enter email and password.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get language => 'Language';

  @override
  String get navGame => 'Play';

  @override
  String get navProgress => 'Progress';

  @override
  String get navHelp => 'Help';

  @override
  String get navSettings => 'Settings';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get hard => 'Hard';

  @override
  String get verify => 'Verify';

  @override
  String get skip => 'Skip';

  @override
  String get clear => 'Clear';

  @override
  String get nextPuzzle => 'Next';

  @override
  String get correct => 'Correct! Equation is true.';

  @override
  String get incorrect => 'Not equal. Try again.';

  @override
  String get nonIntegerDivision =>
      'Non-integer division is only allowed on Easy.';

  @override
  String get invalidExpression => 'Invalid expression.';

  @override
  String get missingEquals => 'Place exactly one equals sign (=).';

  @override
  String get selectSlot =>
      'Drag a sign onto a slot. Drag it off the board to remove it.';

  @override
  String get latexPreview => 'LaTeX preview';

  @override
  String get score => 'Score';

  @override
  String get solvedCount => 'Solved';

  @override
  String get skippedCount => 'Skipped';

  @override
  String get noSolvedYet => 'No puzzles solved yet.';

  @override
  String get loadingProgress => 'Loading your progress…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontFamily => 'Font';

  @override
  String get seedColor => 'Seed color';

  @override
  String get presetTheme => 'Preset themes';

  @override
  String get schemeStyle => 'Color style';

  @override
  String get moreThemeOptions => 'More theme options';

  @override
  String get schemeTonalSpot => 'Tonal spot';

  @override
  String get schemeFidelity => 'Fidelity';

  @override
  String get schemeMonochrome => 'Monochrome';

  @override
  String get schemeNeutral => 'Neutral';

  @override
  String get schemeVibrant => 'Vibrant';

  @override
  String get schemeExpressive => 'Expressive';

  @override
  String get schemeContent => 'Content';

  @override
  String get schemeRainbow => 'Rainbow';

  @override
  String get schemeFruitSalad => 'Fruit salad';

  @override
  String get sound => 'Sound';

  @override
  String get soundOn => 'On';

  @override
  String get soundOff => 'Off';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpBody =>
      'You get four digits in this order. Drag signs into the gaps before the first digit, between them, and after the last one, until both sides of = are equal.\n\n• The expression starts empty. = is not placed in the middle: put it where the equality makes sense.\n• An empty gap joins digits. 3 and 4 side by side make 34.\n• To remove a sign, drag it off the expression.\n• Easy adds square root, cube root, factorial, power, absolute value, floor, and ceiling. Only this level allows a non-integer division.\n• Intermediate drops floor and ceiling. Advanced keeps square root, factorial, and absolute value. Hard keeps +, −, ×, ÷, parentheses, and absolute value.\n• Skip replaces the number. Solved ones do not appear again.';

  @override
  String get operatorsForLevel => 'Operators for this level';

  @override
  String get puzzleNumber => 'Number';

  @override
  String get guestBanner =>
      'Guest mode — progress stays on this device until you sign in.';

  @override
  String get firebaseMissing =>
      'Firebase is not configured. Using offline guest mode.';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontGaramond => 'Garamond';

  @override
  String get fontHelvetica => 'Helvetica-like';

  @override
  String get fontMono => 'Courier';

  @override
  String get presetOcean => 'Ocean forge';

  @override
  String get presetEmber => 'Ember';

  @override
  String get presetForest => 'Forest';

  @override
  String get presetSlate => 'Slate';

  @override
  String get presetCustom => 'Custom seed';
}
