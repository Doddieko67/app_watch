import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
import '../providers/fitness_providers.dart';

/// Pantalla de estadísticas detalladas del módulo fitness
class FitnessStatsScreen extends ConsumerStatefulWidget {
  const FitnessStatsScreen({super.key});

  @override
  ConsumerState<FitnessStatsScreen> createState() =>
      _FitnessStatsScreenState();
}

class _FitnessStatsScreenState extends ConsumerState<FitnessStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Récords'),
            Tab(text: 'Frecuencia'),
            Tab(text: 'Volumen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PersonalRecordsTab(),
          _FrequentExercisesTab(),
          _VolumeTab(),
        ],
      ),
    );
  }
}

/// Tab de récords personales
class _PersonalRecordsTab extends ConsumerWidget {
  const _PersonalRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(personalRecordsProvider);

    return prsAsync.when(
      data: (prs) {
        if (prs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay récords aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Completa algunos workouts para ver tus PRs',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final sortedPrs = prs.entries.toList()
          ..sort((a, b) => b.value.volume.compareTo(a.value.volume));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedPrs.length,
          itemBuilder: (context, index) {
            final entry = sortedPrs[index];
            final exerciseName = entry.key;
            final exercise = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  exerciseName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${exercise.sets}×${exercise.reps} @ ${exercise.weight}kg',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${exercise.volume.toStringAsFixed(0)} kg',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'volumen',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

/// Tab de ejercicios más frecuentes
class _FrequentExercisesTab extends ConsumerWidget {
  const _FrequentExercisesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequentAsync = ref.watch(mostFrequentExercisesProvider());

    return frequentAsync.when(
      data: (frequent) {
        if (frequent.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Registra algunos workouts para ver estadísticas',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final sortedFrequent = frequent.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final maxCount = sortedFrequent.first.value;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedFrequent.length,
          itemBuilder: (context, index) {
            final entry = sortedFrequent[index];
            final exerciseName = entry.key;
            final count = entry.value;
            final percentage = (count / maxCount);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '$count veces',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

/// Tab de volumen semanal
class _VolumeTab extends ConsumerWidget {
  const _VolumeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final startOfWeekRaw = now.subtract(Duration(days: now.weekday - 1));
    // Normalizar fechas a medianoche (eliminar horas/minutos/segundos)
    final startOfWeek = DateTime(
      startOfWeekRaw.year,
      startOfWeekRaw.month,
      startOfWeekRaw.day,
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final volumeAsync = ref.watch(
      weeklyVolumeProvider(start: startOfWeek, end: endOfWeek),
    );

    return volumeAsync.when(
      data: (volumeData) {
        if (volumeData.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos de volumen',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Completa workouts esta semana para ver el progreso',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Preparar datos para el gráfico
        final chartData = <String, double>{};
        final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

        for (var i = 0; i < 7; i++) {
          final date = startOfWeek.add(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          chartData[days[i]] = volumeData[dateKey] ?? 0;
        }

        final totalVolume = chartData.values.reduce((a, b) => a + b);
        final avgVolume = totalVolume / 7;
        final maxVolume = chartData.values.reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjetas de resumen
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${totalVolume.toStringAsFixed(0)} kg',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Total Semanal'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${avgVolume.toStringAsFixed(0)} kg',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Promedio Diario'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Gráfico de barras
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volumen por Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxVolume * 1.2,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < days.length) {
                                      return Text(
                                        days[value.toInt()],
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            barGroups: List.generate(
                              7,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: chartData[days[index]] ?? 0,
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 20,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
