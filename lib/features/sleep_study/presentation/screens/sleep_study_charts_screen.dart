import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sleep_study_providers.dart';

class SleepStudyChartsScreen extends ConsumerWidget {
  const SleepStudyChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bedtime), text: 'Sueño'),
              Tab(icon: Icon(Icons.school), text: 'Estudio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SleepChartsTab(),
            _StudyChartsTab(),
          ],
        ),
      ),
    );
  }
}

// ==================== SUEÑO ====================

class _SleepChartsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyRecordsAsync = ref.watch(weeklySleepRecordsProvider);
    final statsAsync = ref.watch(weeklySleepStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weeklySleepRecordsProvider);
        ref.invalidate(weeklySleepStatsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas generales
            statsAsync.when(
              data: (stats) {
                if (stats.totalRecords == 0) {
                  return _buildEmptyCard(context, 'No hay registros de sueño esta semana');
                }
                return _buildStatsCard(context, stats);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
            const SizedBox(height: 24),

            // Gráfica de horas de sueño (LineChart)
            Text(
              'Horas de Sueño (Semana)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            weeklyRecordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return _buildEmptyCard(context, 'No hay registros de sueño');
                }
                return _buildSleepHoursLineChart(context, records);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
            const SizedBox(height: 24),

            // Gráfica de calidad de sueño (BarChart)
            Text(
              'Calidad de Sueño (Semana)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            weeklyRecordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return _buildEmptyCard(context, 'No hay registros de sueño');
                }
                final completeRecords = records.where((r) => r.isComplete && r.sleepQuality != null).toList();
                if (completeRecords.isEmpty) {
                  return _buildEmptyCard(context, 'No hay registros completos con calidad');
                }
                return _buildSleepQualityBarChart(context, completeRecords);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, dynamic stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Semanal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Promedio',
                  '${stats.averageActualHours?.toStringAsFixed(1) ?? '-'}h',
                  Icons.bedtime,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Calidad',
                  stats.averageSleepQuality != null
                      ? '${stats.averageSleepQuality!.toStringAsFixed(1)}/5'
                      : '-',
                  Icons.star,
                  Colors.amber,
                ),
                _buildStatItem(
                  context,
                  'Meta cumplida',
                  '${stats.recordsMetPlan}/${stats.completeRecords}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSleepHoursLineChart(BuildContext context, List<dynamic> records) {
    final plannedSpots = <FlSpot>[];
    final actualSpots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      plannedSpots.add(FlSpot(i.toDouble(), records[i].plannedHours));
      if (records[i].isComplete && records[i].actualHours != null) {
        actualSpots.add(FlSpot(i.toDouble(), records[i].actualHours!));
      }
    }

    final maxHours = records.fold<double>(
      0,
      (max, r) => [max, r.plannedHours, r.actualHours ?? 0].reduce((a, b) => a > b ? a : b),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (maxHours * 1.2).ceilToDouble(),
                  lineBarsData: [
                    // Línea de horas planeadas
                    LineChartBarData(
                      spots: plannedSpots,
                      isCurved: true,
                      color: Colors.blue.withOpacity(0.5),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                    // Línea de horas reales
                    if (actualSpots.isNotEmpty)
                      LineChartBarData(
                        spots: actualSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < records.length) {
                            final date = records[value.toInt()].date;
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
                    horizontalInterval: 2,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'Planeado', Colors.blue.withOpacity(0.5)),
                const SizedBox(width: 24),
                _buildLegendItem(context, 'Real', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityBarChart(BuildContext context, List<dynamic> records) {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < records.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: records[i].sleepQuality!.toDouble(),
              color: _getQualityColor(records[i].sleepQuality!),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: 5,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < records.length) {
                        final date = records[value.toInt()].date;
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
                horizontalInterval: 1,
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
                      '${_getQualityLabel(rod.toY.toInt())}\n${rod.toY.toInt()}/5',
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

  Color _getQualityColor(int quality) {
    if (quality >= 4) return Colors.green;
    if (quality == 3) return Colors.orange;
    return Colors.red;
  }

  String _getQualityLabel(int quality) {
    switch (quality) {
      case 1:
        return 'Muy Malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ==================== ESTUDIO ====================

class _StudyChartsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySessionsAsync = ref.watch(weeklyStudySessionsProvider);
    final statsAsync = ref.watch(weeklyStudyStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weeklyStudySessionsProvider);
        ref.invalidate(weeklyStudyStatsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas generales
            statsAsync.when(
              data: (stats) {
                if (stats.totalSessions == 0) {
                  return _buildEmptyCard(context, 'No hay sesiones de estudio esta semana');
                }
                return _buildStudyStatsCard(context, stats);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
            const SizedBox(height: 24),

            // Gráfica de minutos por día (BarChart)
            Text(
              'Tiempo de Estudio Diario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            weeklySessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return _buildEmptyCard(context, 'No hay sesiones de estudio');
                }
                return _buildStudyTimeBarChart(context, sessions);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
            const SizedBox(height: 24),

            // Gráfica de distribución por materia (PieChart)
            Text(
              'Distribución por Materia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) {
                if (stats.subjectMinutes.isEmpty) {
                  return _buildEmptyCard(context, 'No hay materias registradas');
                }
                return _buildSubjectPieChart(context, stats.subjectMinutes);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => _buildErrorCard(context, 'Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyStatsCard(BuildContext context, dynamic stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Semanal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total',
                  '${stats.totalHours.toStringAsFixed(1)}h',
                  Icons.schedule,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Sesiones',
                  '${stats.totalSessions}',
                  Icons.school,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Promedio',
                  '${(stats.averageSessionMinutes).toStringAsFixed(0)}m',
                  Icons.timelapse,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudyTimeBarChart(BuildContext context, List<dynamic> sessions) {
    // Agrupar sesiones por día
    final Map<String, double> dayMinutes = {};
    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.date);
      dayMinutes[dateKey] = (dayMinutes[dateKey] ?? 0) + session.calculatedDuration;
    }

    final sortedDays = dayMinutes.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedDays.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayMinutes[sortedDays[i]]!,
              color: Colors.purple,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    final maxMinutes = dayMinutes.values.fold<double>(0, (max, mins) => mins > max ? mins : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: (maxMinutes * 1.2).ceilToDouble(),
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}m',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < sortedDays.length) {
                        final date = DateTime.parse(sortedDays[value.toInt()]);
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
                horizontalInterval: maxMinutes > 120 ? 60 : 30,
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
                    final hours = rod.toY ~/ 60;
                    final mins = rod.toY.toInt() % 60;
                    return BarTooltipItem(
                      hours > 0 ? '${hours}h ${mins}m' : '${mins}m',
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

  Widget _buildSubjectPieChart(BuildContext context, Map<String, int> subjectMinutes) {
    final totalMinutes = subjectMinutes.values.fold<int>(0, (sum, mins) => sum + mins);

    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    int colorIndex = 0;
    for (final entry in subjectMinutes.entries) {
      final percentage = (entry.value / totalMinutes) * 100;
      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
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
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: subjectMinutes.entries.map((entry) {
                final index = subjectMinutes.keys.toList().indexOf(entry.key);
                final hours = entry.value ~/ 60;
                final mins = entry.value % 60;
                final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

                return _buildSubjectLegendItem(
                  context,
                  entry.key,
                  timeStr,
                  colors[index % colors.length],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectLegendItem(BuildContext context, String subject, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== HELPERS ====================

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
