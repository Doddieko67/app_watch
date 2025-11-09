import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../sleep_study/presentation/providers/sleep_study_providers.dart';
import '../../../sleep_study/presentation/screens/sleep_study_home_screen.dart';

class SleepStudySummaryCard extends ConsumerWidget {
  final VoidCallback onTap;

  const SleepStudySummaryCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepRecordAsync = ref.watch(todaySleepRecordProvider);
    final studySessionsAsync = ref.watch(todayStudySessionsProvider);
    final activeSessionAsync = ref.watch(activeStudySessionProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bedtime,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sueño y Estudio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),

              // Sleep section
              sleepRecordAsync.when(
                data: (sleepRecord) {
                  if (sleepRecord != null && sleepRecord.actualHours != null) {
                    final hoursSlept = sleepRecord.actualHours!;
                    final quality = sleepRecord.sleepQuality ?? 0;

                    return _buildSleepSection(context, hoursSlept, quality);
                  } else {
                    return _buildNoSleepData(context);
                  }
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text('Error: $e'),
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Study section
              studySessionsAsync.when(
                data: (sessions) => activeSessionAsync.when(
                  data: (activeSession) {
                    final totalMinutes = sessions.fold<int>(
                      0,
                      (sum, session) => sum + session.calculatedDuration,
                    );
                    final completedCount = sessions.length;

                    return _buildStudySection(
                      context,
                      totalMinutes,
                      completedCount,
                      activeSession != null,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildSleepSection(BuildContext context, double hoursSlept, int quality) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.nightlight_round,
                size: 32,
                color: Colors.indigo,
              ),
              const SizedBox(height: 4),
              Text(
                '${hoursSlept.toStringAsFixed(1)}h',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
              ),
              Text(
                'Dormiste',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < quality ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Calidad',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoSleepData(BuildContext context) {
    return Center(
      child: Text(
        '¿Cómo dormiste anoche? 😴',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildStudySection(
    BuildContext context,
    int totalMinutes,
    int completedCount,
    bool hasActiveSession,
  ) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.school,
                size: 32,
                color: Colors.indigo,
              ),
              const SizedBox(height: 4),
              Text(
                hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
              ),
              Text(
                'Estudiaste',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              if (hasActiveSession)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '${completedCount} sesión${completedCount != 1 ? 'es' : ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              const SizedBox(height: 4),
              if (!hasActiveSession && completedCount == 0)
                Text(
                  '¡Comienza a estudiar! 📚',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
