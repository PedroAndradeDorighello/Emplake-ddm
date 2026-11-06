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
  final void Function(SlotId slot, OpDrag drag, int index) onDrop;
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SlotChip(
                height: digitSize * 1.15,
                slot: SlotId.prefix,
                raw: puzzle.prefix,
                onTap: () => onSelect(SlotId.prefix),
                onDrop: (drag, index) => onDrop(SlotId.prefix, drag, index),
                onRemove: (index) => onRemove(SlotId.prefix, index),
                hint: true,
              ),
              _DigitIngot(digit: puzzle.digits[0], size: digitSize, color: scheme.primary),
              _SlotChip(
                height: digitSize * 1.15,
                slot: SlotId.mid0,
                raw: puzzle.mids[0],
                onTap: () => onSelect(SlotId.mid0),
                onDrop: (drag, index) => onDrop(SlotId.mid0, drag, index),
                onRemove: (index) => onRemove(SlotId.mid0, index),
              ),
              _DigitIngot(digit: puzzle.digits[1], size: digitSize, color: scheme.primary),
              _SlotChip(
                height: digitSize * 1.15,
                slot: SlotId.mid1,
                raw: puzzle.mids[1],
                onTap: () => onSelect(SlotId.mid1),
                onDrop: (drag, index) => onDrop(SlotId.mid1, drag, index),
                onRemove: (index) => onRemove(SlotId.mid1, index),
              ),
              _DigitIngot(digit: puzzle.digits[2], size: digitSize, color: scheme.primary),
              _SlotChip(
                height: digitSize * 1.15,
                slot: SlotId.mid2,
                raw: puzzle.mids[2],
                onTap: () => onSelect(SlotId.mid2),
                onDrop: (drag, index) => onDrop(SlotId.mid2, drag, index),
                onRemove: (index) => onRemove(SlotId.mid2, index),
              ),
              _DigitIngot(digit: puzzle.digits[3], size: digitSize, color: scheme.primary),
              _SlotChip(
                height: digitSize * 1.15,
                slot: SlotId.suffix,
                raw: puzzle.suffix,
                onTap: () => onSelect(SlotId.suffix),
                onDrop: (drag, index) => onDrop(SlotId.suffix, drag, index),
                onRemove: (index) => onRemove(SlotId.suffix, index),
                hint: true,
              ),
            ],
            ),
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
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FittedBox(
          child: Text(
            '$digit',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatefulWidget {
  const _SlotChip({
    required this.height,
    required this.slot,
    required this.raw,
    required this.onTap,
    required this.onDrop,
    required this.onRemove,
    this.hint = false,
  });

  final double height;
  final SlotId slot;
  final String raw;
  final VoidCallback onTap;
  final void Function(OpDrag drag, int index) onDrop;
  final ValueChanged<int> onRemove;
  final bool hint;

  @override
  State<_SlotChip> createState() => _SlotChipState();
}

class _SlotChipState extends State<_SlotChip> {
  int? _hover;

  double get _tokenSize => widget.height / 1.15 * 0.78;

  double _restGap(int count, bool compact) {
    if (count > 0) return 16;
    return widget.hint ? (compact ? 36.0 : 48.0) : (compact ? 22.0 : 28.0);
  }

  int _indexAt(Offset global, int count, bool compact) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || count == 0) return 0;
    final x = box.globalToLocal(global).dx;
    final gap = _restGap(count, compact);
    final tokenW = _tokenSize;
    var cursor = 0.0;
    for (var i = 0; i <= count; i++) {
      final gapW = _hover == i ? (gap > tokenW ? gap : tokenW) : gap;
      if (i == count) return count;
      final mid = cursor + gapW + tokenW / 2;
      if (x < mid) return i;
      cursor += gapW + tokenW;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = ScreenScale.of(context).compact;
    final tokens = PuzzleState.tokenize(widget.raw);
    final gap = _restGap(tokens.length, compact);

    return DragTarget<OpDrag>(
      onMove: (details) {
        final next = _indexAt(details.offset, tokens.length, compact);
        if (next != _hover) setState(() => _hover = next);
      },
      onLeave: (_) {
        if (_hover != null) setState(() => _hover = null);
      },
      onAcceptWithDetails: (details) {
        final index = _indexAt(details.offset, tokens.length, compact);
        setState(() => _hover = null);
        widget.onDrop(details.data, index);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        final preview = hovering ? candidate.first?.op : null;
        return GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: widget.height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < tokens.length; i++) ...[
                  _InsertGap(
                    width: _hover == i && preview != null
                        ? (gap > _tokenSize ? gap : _tokenSize)
                        : gap,
                    height: widget.height,
                    op: _hover == i ? preview : null,
                    size: _tokenSize,
                    color: scheme.onSurface,
                  ),
                  _PlacedToken(
                    size: _tokenSize,
                    slot: widget.slot,
                    index: i,
                    op: tokens[i],
                    onRemove: widget.onRemove,
                  ),
                ],
                _InsertGap(
                  width: _hover == tokens.length && preview != null
                      ? (gap > _tokenSize ? gap : _tokenSize)
                      : gap,
                  height: widget.height,
                  op: _hover == tokens.length ? preview : null,
                  size: _tokenSize,
                  color: scheme.onSurface,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InsertGap extends StatelessWidget {
  const _InsertGap({
    required this.width,
    required this.height,
    required this.size,
    required this.color,
    this.op,
  });

  final double width;
  final double height;
  final double size;
  final Color color;
  final String? op;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: op == null
          ? null
          : Center(
              child: Opacity(
                opacity: 0.45,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SizedBox(
                    width: size,
                    height: size * 1.15,
                    child: FittedBox(
                      child: Text(
                        op!,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          height: 1,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _PlacedToken extends StatelessWidget {
  const _PlacedToken({
    required this.size,
    required this.slot,
    required this.index,
    required this.op,
    required this.onRemove,
  });

  final double size;
  final SlotId slot;
  final int index;
  final String op;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final tile = SizedBox(
      width: size,
      height: size * 1.15,
      child: FittedBox(
        child: Text(
          op,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 32,
            height: 1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
    return Draggable<OpDrag>(
      data: OpDrag.placed(op, slot, index),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _OpFeedback(op: op),
      childWhenDragging: Opacity(opacity: 0.25, child: tile),
      onDragEnd: (details) {
        if (!details.wasAccepted) onRemove(index);
      },
      child: tile,
    );
  }
}

class OperatorStamps extends StatelessWidget {
  const OperatorStamps({
    super.key,
    required this.operators,
    required this.onStamp,
  });

  final List<String> operators;
  final ValueChanged<String> onStamp;

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
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: _OpFeedback(op: op),
            childWhenDragging: Opacity(opacity: 0.35, child: _OpFace(op: op, scheme: scheme)),
            child: _OpFace(
              op: op,
              scheme: scheme,
              onTap: () => onStamp(op),
            ),
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
