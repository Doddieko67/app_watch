import 'package:flutter/material.dart';

import '../../domain/entities/food_analysis_result.dart';

/// Badge que muestra la fuente del análisis de alimentos
class FoodSourceBadge extends StatelessWidget {
  final FoodAnalysisSource source;

  const FoodSourceBadge({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(theme),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getEmoji(),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getTextColor(theme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji() {
    switch (source) {
      case FoodAnalysisSource.cache:
        return '✓';
      case FoodAnalysisSource.gemini:
        return '🤖';
      case FoodAnalysisSource.localDb:
        return '📚';
      case FoodAnalysisSource.manual:
        return '✏️';
      case FoodAnalysisSource.error:
        return '⚠️';
    }
  }

  String _getLabel() {
    switch (source) {
      case FoodAnalysisSource.cache:
        return 'Cache';
      case FoodAnalysisSource.gemini:
        return 'IA';
      case FoodAnalysisSource.localDb:
        return 'Base Local';
      case FoodAnalysisSource.manual:
        return 'Manual';
      case FoodAnalysisSource.error:
        return 'Error';
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (source) {
      case FoodAnalysisSource.cache:
        return theme.colorScheme.primaryContainer.withOpacity(0.3);
      case FoodAnalysisSource.gemini:
        return theme.colorScheme.secondaryContainer.withOpacity(0.3);
      case FoodAnalysisSource.localDb:
        return theme.colorScheme.tertiaryContainer.withOpacity(0.3);
      case FoodAnalysisSource.manual:
        return theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
      case FoodAnalysisSource.error:
        return theme.colorScheme.errorContainer.withOpacity(0.3);
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (source) {
      case FoodAnalysisSource.cache:
        return theme.colorScheme.primary;
      case FoodAnalysisSource.gemini:
        return theme.colorScheme.secondary;
      case FoodAnalysisSource.localDb:
        return theme.colorScheme.tertiary;
      case FoodAnalysisSource.manual:
        return theme.colorScheme.outline;
      case FoodAnalysisSource.error:
        return theme.colorScheme.error;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (source) {
      case FoodAnalysisSource.cache:
        return theme.colorScheme.onPrimaryContainer;
      case FoodAnalysisSource.gemini:
        return theme.colorScheme.onSecondaryContainer;
      case FoodAnalysisSource.localDb:
        return theme.colorScheme.onTertiaryContainer;
      case FoodAnalysisSource.manual:
        return theme.colorScheme.onSurface;
      case FoodAnalysisSource.error:
        return theme.colorScheme.onErrorContainer;
    }
  }
}
