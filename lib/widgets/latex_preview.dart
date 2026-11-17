import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../l10n/app_localizations.dart';
import '../models/difficulty.dart';
import '../services/latex_converter.dart';
import '../services/solution_steps.dart';
import '../theme/screen_scale.dart';

class LatexPreview extends StatefulWidget {
  const LatexPreview({
    super.key,
    required this.expression,
    required this.difficulty,
    this.canShowSteps = false,
  });

  final String expression;
  final Difficulty difficulty;
  /// Só após acertar a equação.
  final bool canShowSteps;

  @override
  State<LatexPreview> createState() => _LatexPreviewState();
}

class _LatexPreviewState extends State<LatexPreview> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant LatexPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression ||
        oldWidget.canShowSteps && !widget.canShowSteps) {
      _expanded = false;
    }
  }

  Future<void> _copy(String latex) async {
    final text = latex.trim().isEmpty ? '' : latex;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.latexCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latex = expressionToLatex(widget.expression);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final fontSize = ScreenScale.of(context).compact ? 18.0 : 26.0;
    final showToggle = widget.canShowSteps;
    final steps = _expanded && showToggle
        ? solutionLatexSteps(widget.expression, widget.difficulty)
        : const <String>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outlineVariant),
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.08),
            scheme.tertiary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  l10n.latexPreview,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
              IconButton(
                tooltip: l10n.copyLatex,
                onPressed: () => _copy(latex),
                icon: const Icon(Icons.copy_outlined, size: 20),
              ),
              if (showToggle)
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(
                    _expanded ? l10n.hideSolutionSteps : l10n.showSolutionSteps,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _MathLine(latex: latex, fontSize: fontSize, color: scheme.onSurface),
          if (_expanded && showToggle) ...[
            const SizedBox(height: 12),
            if (steps.isEmpty)
              SelectableText(
                l10n.invalidExpression,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
              )
            else
              for (var i = 0; i < steps.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2),
                  child: Text(
                    '⇒',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _MathLine(
                  latex: steps[i],
                  fontSize: fontSize * 0.85,
                  color: i == steps.length - 1
                      ? scheme.primary
                      : scheme.onSurface,
                  onCopy: () => _copy(steps[i]),
                  copyTooltip: l10n.copyLatex,
                ),
              ],
          ],
        ],
      ),
    );
  }
}

class _MathLine extends StatelessWidget {
  const _MathLine({
    required this.latex,
    required this.fontSize,
    required this.color,
    this.onCopy,
    this.copyTooltip,
  });

  final String latex;
  final double fontSize;
  final Color color;
  final VoidCallback? onCopy;
  final String? copyTooltip;

  @override
  Widget build(BuildContext context) {
    final source = latex.isEmpty ? r'\,' : latex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              source,
              mathStyle: MathStyle.display,
              textStyle: TextStyle(fontSize: fontSize, color: color),
              onErrorFallback: (_) => SelectableText(
                source,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              ),
            ),
          ),
        ),
        if (onCopy != null)
          IconButton(
            tooltip: copyTooltip,
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined, size: 18),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
