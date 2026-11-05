import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../l10n/app_localizations.dart';
import '../services/latex_converter.dart';
import '../theme/screen_scale.dart';

class LatexPreview extends StatelessWidget {
  const LatexPreview({super.key, required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    final latex = expressionToLatex(expression);
    final scheme = Theme.of(context).colorScheme;

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
          SelectableText(
            AppLocalizations.of(context).latexPreview,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex.isEmpty ? r'\,' : latex,
              mathStyle: MathStyle.display,
              textStyle: TextStyle(
                fontSize: ScreenScale.of(context).compact ? 18 : 26,
                color: scheme.onSurface,
              ),
              onErrorFallback: (_) => SelectableText(
                latex,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
