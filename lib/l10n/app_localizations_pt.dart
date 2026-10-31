// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get teamMembers => 'Pedro & Parceiro';

  @override
  String get loginSubtitle => 'Monte equações verdadeiras com quatro dígitos';

  @override
  String get signInEmail => 'Entrar com e-mail';

  @override
  String get signInGoogle => 'Entrar com Google';

  @override
  String get signOut => 'Sair';

  @override
  String get continueAsGuest => 'Continuar como convidado (offline)';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get language => 'Idioma';

  @override
  String get navGame => 'Jogar';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get easy => 'Fácil';

  @override
  String get intermediate => 'Intermediário';

  @override
  String get advanced => 'Avançado';

  @override
  String get hard => 'Difícil';

  @override
  String get verify => 'Verificar';

  @override
  String get skip => 'Pular';

  @override
  String get clear => 'Limpar';

  @override
  String get nextPuzzle => 'Próximo';

  @override
  String get correct => 'Correto! A equação é verdadeira.';

  @override
  String get incorrect => 'Não é igual. Tente de novo.';

  @override
  String get nonIntegerDivision =>
      'Divisão não inteira só é permitida no nível Fácil.';

  @override
  String get invalidExpression => 'Expressão inválida.';

  @override
  String get missingEquals => 'Coloque exatamente um sinal de igual (=).';

  @override
  String get selectSlot =>
      'Arraste um sinal até o encaixe. Arraste para fora para remover.';

  @override
  String get latexPreview => 'Prévia LaTeX';

  @override
  String get score => 'Pontuação';

  @override
  String get solvedCount => 'Resolvidos';

  @override
  String get skippedCount => 'Pulados';

  @override
  String get noSolvedYet => 'Nenhum desafio resolvido ainda.';

  @override
  String get loadingProgress => 'Carregando seu progresso…';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get fontFamily => 'Fonte';

  @override
  String get seedColor => 'Cor semente';

  @override
  String get presetTheme => 'Temas prontos';

  @override
  String get sound => 'Som';

  @override
  String get soundOn => 'Ligado';

  @override
  String get soundOff => 'Desligado';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get helpBody =>
      'Você recebe quatro dígitos em ordem. Carimbe operadores matemáticos nos encaixes para que os dois lados de = fiquem iguais.\n\n• Toque num encaixe brilhante e depois num carimbo de operador.\n• Os dígitos mantêm a ordem; encaixe vazio concatena (ex.: 34).\n• O = começa no meio — você pode limpar e movê-lo.\n• Fácil permite divisão não inteira; os outros níveis não.\n• Pule um número difícil; os resolvidos não voltam a aparecer.';

  @override
  String get operatorsForLevel => 'Operadores deste nível';

  @override
  String get puzzleNumber => 'Número';

  @override
  String get guestBanner =>
      'Modo convidado — o progresso fica neste dispositivo até você entrar.';

  @override
  String get firebaseMissing =>
      'Firebase não configurado. Usando modo convidado offline.';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontGaramond => 'Garamond';

  @override
  String get fontHelvetica => 'Estilo Helvetica';

  @override
  String get fontMono => 'Courier';

  @override
  String get presetOcean => 'Forja oceânica';

  @override
  String get presetEmber => 'Brasa';

  @override
  String get presetForest => 'Floresta';

  @override
  String get presetSlate => 'Ardósia';

  @override
  String get presetCustom => 'Semente custom';
}
