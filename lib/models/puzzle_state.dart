import 'difficulty.dart';

/// Quatro dígitos + encaixes: prefix | d0 | mid0 | d1 | mid1 | d2 | mid2 | d3 | suffix
class PuzzleState {
  PuzzleState({
    required this.digits,
    required this.difficulty,
    List<String>? mids,
    this.prefix = '',
    this.suffix = '',
    this.selectedSlot = SlotId.mid0,
  }) : mids = mids ?? ['', '', ''];

  final List<int> digits; // length 4
  final Difficulty difficulty;
  final List<String> mids; // length 3
  final String prefix;
  final String suffix;
  final SlotId selectedSlot;

  int get number =>
      digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3];

  String get displayExpression {
    final b = StringBuffer(prefix);
    for (var i = 0; i < 4; i++) {
      b.write(digits[i]);
      if (i < 3) b.write(mids[i]);
    }
    b.write(suffix);
    return b.toString();
  }

  PuzzleState copyWith({
    List<String>? mids,
    String? prefix,
    String? suffix,
    SlotId? selectedSlot,
  }) {
    return PuzzleState(
      digits: digits,
      difficulty: difficulty,
      mids: mids ?? List<String>.from(this.mids),
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      selectedSlot: selectedSlot ?? this.selectedSlot,
    );
  }

  PuzzleState stamp(String op) {
    switch (selectedSlot) {
      case SlotId.prefix:
        return copyWith(prefix: prefix + op);
      case SlotId.suffix:
        return copyWith(suffix: suffix + op);
      case SlotId.mid0:
        return copyWith(mids: [mids[0] + op, mids[1], mids[2]]);
      case SlotId.mid1:
        return copyWith(mids: [mids[0], mids[1] + op, mids[2]]);
      case SlotId.mid2:
        return copyWith(mids: [mids[0], mids[1], mids[2] + op]);
    }
  }

  PuzzleState clearOperators() {
    return copyWith(prefix: '', suffix: '', mids: ['', '', '']);
  }

  String textOf(SlotId id) => switch (id) {
        SlotId.prefix => prefix,
        SlotId.suffix => suffix,
        SlotId.mid0 => mids[0],
        SlotId.mid1 => mids[1],
        SlotId.mid2 => mids[2],
      };

  PuzzleState withSlot(SlotId id, String text) => switch (id) {
        SlotId.prefix => copyWith(prefix: text),
        SlotId.suffix => copyWith(suffix: text),
        SlotId.mid0 => copyWith(mids: [text, mids[1], mids[2]]),
        SlotId.mid1 => copyWith(mids: [mids[0], text, mids[2]]),
        SlotId.mid2 => copyWith(mids: [mids[0], mids[1], text]),
      };

  PuzzleState insertAt(SlotId target, int index, String op) {
    final tokens = tokenize(textOf(target));
    final at = index.clamp(0, tokens.length);
    tokens.insert(at, op);
    return copyWith(selectedSlot: target).withSlot(target, tokens.join());
  }

  /// Soltar aqui não muda a ordem: o sinal já ocupa esse vão.
  static bool sameSpot(SlotId target, int index, {SlotId? from, int? fromIndex}) {
    return from != null &&
        fromIndex != null &&
        from == target &&
        (index == fromIndex || index == fromIndex + 1);
  }

  /// [index] é a posição na lista antes de remover a origem.
  PuzzleState place(SlotId target, int index, String op, {SlotId? from, int? fromIndex}) {
    if (sameSpot(target, index, from: from, fromIndex: fromIndex)) return this;
    var next = this;
    var dest = index;
    if (from != null && fromIndex != null) {
      next = next.removeAt(from, fromIndex);
      if (from == target && fromIndex < dest) dest -= 1;
    }
    return next.insertAt(target, dest, op);
  }

  PuzzleState removeAt(SlotId slot, int index) {
    final tokens = tokenize(textOf(slot));
    if (index < 0 || index >= tokens.length) return this;
    tokens.removeAt(index);
    return withSlot(slot, tokens.join());
  }

  PuzzleState backspace() {
    final tokens = tokenize(textOf(selectedSlot));
    if (tokens.isEmpty) return this;
    tokens.removeLast();
    return withSlot(selectedSlot, tokens.join());
  }

  static List<String> tokenize(String raw) {
    final out = <String>[];
    var i = 0;
    while (i < raw.length) {
      if (raw.startsWith('**', i)) {
        out.add('**');
        i += 2;
      } else {
        out.add(raw[i]);
        i++;
      }
    }
    return out;
  }
}

/// Sinal vindo da paleta ou já colocado num encaixe.
class OpDrag {
  const OpDrag.palette(this.op)
      : slot = null,
        index = null;
  const OpDrag.placed(this.op, this.slot, this.index);

  final String op;
  final SlotId? slot;
  final int? index;

  bool get fromPalette => slot == null;
}

enum SlotId { prefix, mid0, mid1, mid2, suffix }
