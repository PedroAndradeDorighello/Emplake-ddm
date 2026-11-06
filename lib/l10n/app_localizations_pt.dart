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
  String get signIn => 'Entrar';

  @override
  String get register => 'Registrar';

  @override
  String get orSignInWith => 'Ou entre com';

  @override
  String get signInGoogle => 'Entrar com Google';

  @override
  String get signOut => 'Sair';

  @override
  String get continueAsGuest => 'Convidado (offline)';

  @override
  String get authFieldsRequired => 'Informe e-mail e senha.';

  @override
  String get passwordTooShort => 'A senha precisa ter pelo menos 6 caracteres.';

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
  String get schemeStyle => 'Estilo de cor';

  @override
  String get moreThemeOptions => 'Mais opções de tema';

  @override
  String get schemeTonalSpot => 'Tonal';

  @override
  String get schemeFidelity => 'Fidelidade';

  @override
  String get schemeMonochrome => 'Monocromático';

  @override
  String get schemeNeutral => 'Neutro';

  @override
  String get schemeVibrant => 'Vibrante';

  @override
  String get schemeExpressive => 'Expressivo';

  @override
  String get schemeContent => 'Conteúdo';

  @override
  String get schemeRainbow => 'Arco-íris';

  @override
  String get schemeFruitSalad => 'Salada de frutas';

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
      'Você recebe quatro dígitos nesta ordem. Arraste sinais para os espaços antes do primeiro, entre eles e depois do último, até os dois lados do = ficarem iguais.\n\n• A expressão começa sem sinais. O = não vem no meio: coloque-o onde a igualdade fizer sentido.\n• Um espaço vazio junta os dígitos. 3 e 4 lado a lado formam 34.\n• Para remover um sinal, arraste-o para fora da expressão.\n• Fácil traz raiz quadrada, raiz cúbica, fatorial, potência, módulo, chão e teto. Só nesse nível a divisão pode não ser inteira.\n• Intermediário tira chão e teto. Avançado fica com raiz quadrada, fatorial e módulo. Difícil fica com +, −, ×, ÷, parênteses e módulo.\n• Pular troca o número. Os que você já resolveu não aparecem de novo.';

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
