import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/nutrition_providers.dart';

class NutritionChartsScreen extends ConsumerWidget {
  const NutritionChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyDataAsync = ref.watch(weeklyNutritionSummaryProvider);
    final todayDataAsync = ref.watch(dailyNutritionSummaryProvider);
    final todayMealsAsync = ref.watch(todayMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Nutrición'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weeklyNutritionSummaryProvider);
          ref.invalidate(dailyNutritionSummaryProvider);
          ref.invalidate(todayMealsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfica de calorías semanales (LineChart)
              Text(
                'Calorías esta semana',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              weeklyDataAsync.when(
                data: (weeklyData) {
                  if (weeklyData.isEmpty) {
                    return _buildEmptyCard(context, 'No hay datos de esta semana');
                  }
                  return _buildCaloriesLineChart(context, weeklyData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => _buildErrorCard(context, 'Error: $e'),
              ),
              const SizedBox(height: 32),

              // Gráfica de distribución de macros (PieChart)
              Text(
                'Distribución de Macros (Hoy)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              todayDataAsync.when(
                data: (todayData) {
                  if (todayData.totalCalories == 0) {
                    return _buildEmptyCard(context, 'No hay comidas registradas hoy');
                  }
                  return _buildMacrosPieChart(context, todayData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => _buildErrorCard(context, 'Error: $e'),
              ),
              const SizedBox(height: 32),

              // Gráfica de comparación de comidas (BarChart)
              Text(
                'Calorías por Comida (Hoy)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              todayMealsAsync.when(
                data: (meals) {
                  if (meals.isEmpty) {
                    return _buildEmptyCard(context, 'No hay comidas registradas hoy');
                  }
                  return _buildMealsBarChart(context, meals);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => _buildErrorCard(context, 'Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesLineChart(BuildContext context, List<dynamic> weeklyData) {
    final spots = <FlSpot>[];
    for (int i = 0; i < weeklyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), weeklyData[i].totalCalories));
    }

    // Encontrar el máximo para escalar el gráfico
    final maxCalories = weeklyData.fold<double>(
      0,
      (max, day) => day.totalCalories > max ? day.totalCalories : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: (maxCalories * 1.2).ceilToDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.orange,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withOpacity(0.2),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyData.length) {
                        final date = weeklyData[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E', 'es').format(date).substring(0, 1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxCalories > 2000 ? 500 : 200,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacrosPieChart(BuildContext context, dynamic todayData) {
    final totalProtein = todayData.totalProtein;
    final totalCarbs = todayData.totalCarbs;
    final totalFats = todayData.totalFats;

    // Convertir a calorías (proteína: 4 kcal/g, carbos: 4 kcal/g, grasas: 9 kcal/g)
    final proteinCals = totalProtein * 4;
    final carbsCals = totalCarbs * 4;
    final fatsCals = totalFats * 9;
    final totalCals = proteinCals + carbsCals + fatsCals;

    if (totalCals == 0) {
      return _buildEmptyCard(context, 'No hay datos de macros');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: proteinCals,
                      title: '${((proteinCals / totalCals) * 100).toStringAsFixed(0)}%',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: carbsCals,
                      title: '${((carbsCals / totalCals) * 100).toStringAsFixed(0)}%',
                      color: Colors.blue,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: fatsCals,
                      title: '${((fatsCals / totalCals) * 100).toStringAsFixed(0)}%',
                      color: Colors.amber,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(context, 'Proteína', Colors.red, '${totalProtein.toStringAsFixed(0)}g'),
                _buildLegendItem(context, 'Carbos', Colors.blue, '${totalCarbs.toStringAsFixed(0)}g'),
                _buildLegendItem(context, 'Grasas', Colors.amber, '${totalFats.toStringAsFixed(0)}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, String value) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMealsBarChart(BuildContext context, List<dynamic> meals) {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < meals.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: meals[i].totalCalories,
              color: _getMealTypeColor(meals[i].mealType),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    final maxCalories = meals.fold<double>(
      0,
      (max, meal) => meal.totalCalories > max ? meal.totalCalories : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: (maxCalories * 1.2).ceilToDouble(),
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < meals.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getMealTypeShortName(meals[value.toInt()].mealType),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxCalories > 500 ? 200 : 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${meals[groupIndex].mealType}\n${rod.toY.toStringAsFixed(0)} kcal',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMealTypeShortName(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Des';
      case 'lunch':
        return 'Alm';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Snack';
      default:
        return mealType.substring(0, 3);
    }
  }
}
