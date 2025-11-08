import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../nutrition/presentation/screens/nutrition_home_screen.dart';

class NutritionSummaryCard extends ConsumerWidget {
  const NutritionSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider);
    final goalsAsync = ref.watch(activeNutritionGoalsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionHomeScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nutrición',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              summaryAsync.when(
                data: (summary) => goalsAsync.when(
                  data: (goals) {
                    final caloriesGoal = goals?.dailyCalories ?? 2000;
                    final proteinGoal = goals?.dailyProtein ?? 150;
                    final carbsGoal = goals?.dailyCarbs ?? 200;
                    final fatsGoal = goals?.dailyFats ?? 65;

                    final caloriesPercent = summary.totalCalories / caloriesGoal;
                    final proteinPercent = summary.totalProtein / proteinGoal;
                    final carbsPercent = summary.totalCarbs / carbsGoal;
                    final fatsPercent = summary.totalFats / fatsGoal;

                    return Column(
                      children: [
                        // Calories bar
                        _buildMacroBar(
                          context,
                          'Calorías',
                          summary.totalCalories.toStringAsFixed(0),
                          caloriesGoal.toStringAsFixed(0),
                          caloriesPercent,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),

                        // Macros
                        Row(
                          children: [
                            Expanded(
                              child: _buildMacroIndicator(
                                context,
                                'Proteína',
                                summary.totalProtein.toStringAsFixed(0),
                                proteinGoal.toStringAsFixed(0),
                                proteinPercent,
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMacroIndicator(
                                context,
                                'Carbos',
                                summary.totalCarbs.toStringAsFixed(0),
                                carbsGoal.toStringAsFixed(0),
                                carbsPercent,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMacroIndicator(
                                context,
                                'Grasas',
                                summary.totalFats.toStringAsFixed(0),
                                fatsGoal.toStringAsFixed(0),
                                fatsPercent,
                                Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        if (summary.mealsCount > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            '${summary.mealsCount} comida${summary.mealsCount != 1 ? 's' : ''} registrada${summary.mealsCount != 1 ? 's' : ''} hoy',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              '¡Registra tu primera comida! 🍽️',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    BuildContext context,
    String label,
    String current,
    String goal,
    double percent,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$current / $goal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroIndicator(
    BuildContext context,
    String label,
    String current,
    String goal,
    double percent,
    Color color,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: 3,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${(percent * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
        ),
        Text(
          '${current}g',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
