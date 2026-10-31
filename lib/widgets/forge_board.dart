import 'package:flutter/material.dart';

import '../models/puzzle_state.dart';
import '../theme/screen_scale.dart';

/// UI única: "Forja de equações" — dígitos em lingotes, encaixes como moldes.
class ForgeBoard extends StatelessWidget {
  const ForgeBoard({
    super.key,
    required this.puzzle,
    required this.resetKey,
    required this.onSelect,
    required this.onDrop,
    required this.onRemove,
  });

  final PuzzleState puzzle;
  final int resetKey;
  final ValueChanged<SlotId> onSelect;
  final void Function(SlotId slot, OpDrag drag) onDrop;
  final void Function(SlotId slot, int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final digitSize = ScreenScale.of(context).digitSize(constraints.maxWidth);
        return TweenAnimationBuilder<double>(
          key: ValueKey(resetKey),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          builder: (context, t, child) {
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 18),
                child: child,
              ),
            );
          },
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 8,
            children: [
              _SlotChip(
                slot: SlotId.prefix,
                raw: puzzle.prefix,
                onTap: () => onSelect(SlotId.prefix),
                onDrop: (drag) => onDrop(SlotId.prefix, drag),
                onRemove: (index) => onRemove(SlotId.prefix, index),
                hint: true,
              ),
              _DigitIngot(digit: puzzle.digits[0], size: digitSize, color: scheme.primary),
              _SlotChip(
                slot: SlotId.mid0,
                raw: puzzle.mids[0],
                onTap: () => onSelect(SlotId.mid0),
                onDrop: (drag) => onDrop(SlotId.mid0, drag),
                onRemove: (index) => onRemove(SlotId.mid0, index),
              ),
              _DigitIngot(digit: puzzle.digits[1], size: digitSize, color: scheme.primary),
              _SlotChip(
                slot: SlotId.mid1,
                raw: puzzle.mids[1],
                onTap: () => onSelect(SlotId.mid1),
                onDrop: (drag) => onDrop(SlotId.mid1, drag),
                onRemove: (index) => onRemove(SlotId.mid1, index),
              ),
              _DigitIngot(digit: puzzle.digits[2], size: digitSize, color: scheme.tertiary),
              _SlotChip(
                slot: SlotId.mid2,
                raw: puzzle.mids[2],
                onTap: () => onSelect(SlotId.mid2),
                onDrop: (drag) => onDrop(SlotId.mid2, drag),
                onRemove: (index) => onRemove(SlotId.mid2, index),
              ),
              _DigitIngot(digit: puzzle.digits[3], size: digitSize, color: scheme.tertiary),
              _SlotChip(
                slot: SlotId.suffix,
                raw: puzzle.suffix,
                onTap: () => onSelect(SlotId.suffix),
                onDrop: (drag) => onDrop(SlotId.suffix, drag),
                onRemove: (index) => onRemove(SlotId.suffix, index),
                hint: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DigitIngot extends StatelessWidget {
  const _DigitIngot({
    required this.digit,
    required this.size,
    required this.color,
  });

  final int digit;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.15,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$digit',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
            ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.raw,
    required this.onTap,
    required this.onDrop,
    required this.onRemove,
    this.hint = false,
  });

  final SlotId slot;
  final String raw;
  final VoidCallback onTap;
  final ValueChanged<OpDrag> onDrop;
  final ValueChanged<int> onRemove;
  final bool hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = ScreenScale.of(context).compact;
    final tokens = PuzzleState.tokenize(raw);

    return DragTarget<OpDrag>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        final empty = tokens.isEmpty;
        final gap = empty ? (hint ? (compact ? 10.0 : 14.0) : (compact ? 22.0 : 28.0)) : 4.0;
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: BoxConstraints(minWidth: gap, minHeight: compact ? 48 : 64),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: empty ? 0 : 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: hovering ? scheme.secondary.withValues(alpha: 0.16) : null,
            ),
            child: empty
                ? SizedBox(width: gap, height: 2)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < tokens.length; i++)
                        _PlacedToken(
                          slot: slot,
                          index: i,
                          op: tokens[i],
                          onRemove: onRemove,
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _PlacedToken extends StatelessWidget {
  const _PlacedToken({
    required this.slot,
    required this.index,
    required this.op,
    required this.onRemove,
  });

  final SlotId slot;
  final int index;
  final String op;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1,
        );
    return Draggable<OpDrag>(
      data: OpDrag.placed(op, slot, index),
      feedback: _OpFeedback(op: op),
      childWhenDragging: Opacity(opacity: 0.25, child: Text(op, style: style)),
      onDragEnd: (details) {
        if (!details.wasAccepted) onRemove(index);
      },
      child: Text(op, style: style),
    );
  }
}

class OperatorStamps extends StatelessWidget {
  const OperatorStamps({
    super.key,
    required this.operators,
    required this.onStamp,
    required this.onBackspace,
  });

  final List<String> operators;
  final ValueChanged<String> onStamp;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final op in operators)
          Draggable<OpDrag>(
            data: OpDrag.palette(op),
            feedback: _OpFeedback(op: op),
            childWhenDragging: Opacity(opacity: 0.35, child: _OpFace(op: op, scheme: scheme)),
            child: _OpFace(
              op: op,
              scheme: scheme,
              onTap: () => onStamp(op),
            ),
          ),
        ActionChip(
          label: const Icon(Icons.backspace_outlined, size: 18),
          onPressed: onBackspace,
        ),
      ],
    );
  }
}

class _OpFace extends StatelessWidget {
  const _OpFace({required this.op, required this.scheme, this.onTap});

  final String op;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest,
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            op,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _OpFeedback extends StatelessWidget {
  const _OpFeedback({required this.op});

  final String op;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          op,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
