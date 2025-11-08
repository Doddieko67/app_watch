import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_entity.dart';
import '../providers/nutrition_providers.dart';
import 'log_meal_screen.dart';
import 'meal_detail_screen.dart';
import 'nutrition_charts_screen.dart';

/// Pantalla principal del módulo de nutrición
class NutritionHomeScreen extends ConsumerWidget {
  const NutritionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider);
    final mealsAsync = ref.watch(todayMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrición'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NutritionChartsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyNutritionSummaryProvider);
          ref.invalidate(todayMealsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Resumen del día
            SliverToBoxAdapter(
              child: summaryAsync.when(
                data: (summary) => _DailySummaryCard(summary: summary),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),

            // Selector de fecha
            SliverToBoxAdapter(
              child: _DateSelector(),
            ),

            // Lista de comidas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Comidas del día',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            mealsAsync.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('No hay comidas registradas'),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final meal = meals[index];
                      return _MealCard(meal: meal);
                    },
                    childCount: meals.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LogMealScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar comida'),
      ),
    );
  }
}

/// Card con resumen nutricional del día
class _DailySummaryCard extends StatelessWidget {
  final dynamic summary;

  const _DailySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del día',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Calorías
            _MacroRow(
              label: 'Calorías',
              value: summary.totalCalories,
              goal: summary.goals?.dailyCalories ?? 0,
              unit: 'kcal',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),

            // Proteínas
            _MacroRow(
              label: 'Proteínas',
              value: summary.totalProtein,
              goal: summary.goals?.dailyProtein ?? 0,
              unit: 'g',
              color: Colors.red,
            ),
            const SizedBox(height: 8),

            // Carbohidratos
            _MacroRow(
              label: 'Carbohidratos',
              value: summary.totalCarbs,
              goal: summary.goals?.dailyCarbs ?? 0,
              unit: 'g',
              color: Colors.blue,
            ),
            const SizedBox(height: 8),

            // Grasas
            _MacroRow(
              label: 'Grasas',
              value: summary.totalFats,
              goal: summary.goals?.dailyFats ?? 0,
              unit: 'g',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

/// Row con información de un macro
class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${value.toStringAsFixed(1)} / ${goal.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }
}

/// Selector de fecha
class _DateSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state =
                  selectedDate.subtract(const Duration(days: 1));
            },
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                ref.read(selectedDateProvider.notifier).state = date;
              }
            },
            child: Text(
              _formatDate(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              if (!newDate.isAfter(DateTime.now())) {
                ref.read(selectedDateProvider.notifier).state = newDate;
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Card de comida
class _MealCard extends StatelessWidget {
  final MealEntity meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(_getMealIcon(meal.mealTypeEnum)),
        title: Text(meal.mealTypeEnum.displayName),
        subtitle: Text(
          '${meal.totalCalories.toStringAsFixed(0)} kcal • '
          '${meal.foodItems.length} alimentos',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealDetailScreen(mealId: meal.id),
            ),
          );
        },
      ),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}
