import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sleep_study_providers.dart';
import 'sleep_config_screen.dart';
import 'log_sleep_record_screen.dart';
import 'study_session_screen.dart';
import 'sleep_study_charts_screen.dart';

/// Pantalla principal de Sueño y Estudio
class SleepStudyHomeScreen extends ConsumerWidget {
  const SleepStudyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepScheduleAsync = ref.watch(activeSleepScheduleProvider);
    final todaySleepAsync = ref.watch(todaySleepRecordProvider);
    final activeSessionAsync = ref.watch(activeStudySessionProvider);
    final todaySessionsAsync = ref.watch(todayStudySessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sueño y Estudio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SleepStudyChartsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SleepConfigScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeSleepScheduleProvider);
          ref.invalidate(todaySleepRecordProvider);
          ref.invalidate(activeStudySessionProvider);
          ref.invalidate(todayStudySessionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Sueño
              Text(
                'Sueño',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              sleepScheduleAsync.when(
                data: (schedule) {
                  if (schedule == null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bedtime_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text('No has configurado tu horario de sueño'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SleepConfigScreen(),
                                  ),
                                );
                              },
                              child: const Text('Configurar ahora'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bedtime),
                              const SizedBox(width: 8),
                              Text(
                                'Horario configurado',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dormir: ${_formatTime(schedule.defaultBedtime)}',
                          ),
                          Text(
                            'Despertar: ${_formatTime(schedule.defaultWakeup)}',
                          ),
                          Text(
                            'Meta: ${schedule.targetSleepHours.toStringAsFixed(1)} horas',
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Registro de sueño de hoy
              todaySleepAsync.when(
                data: (record) {
                  if (record == null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('No has registrado tu sueño de hoy'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final schedule =
                                    await ref.read(activeSleepScheduleProvider.future);
                                if (schedule == null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Primero configura tu horario de sueño'),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LogSleepRecordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Registrar sueño'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Sueño de hoy',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (record.isComplete) ...[
                            Text(
                              'Dormiste: ${record.actualHours!.toStringAsFixed(1)} horas',
                            ),
                            Text(
                              'Meta: ${record.plannedHours.toStringAsFixed(1)} horas',
                            ),
                            if (record.sleepQuality != null)
                              Text('Calidad: ${record.sleepQuality}/5'),
                          ] else ...[
                            Text(
                              'Planeado: ${record.plannedHours.toStringAsFixed(1)} horas',
                            ),
                            const Text('Pendiente de registrar horas reales'),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Sección de Estudio
              Text(
                'Estudio',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Sesión activa
              activeSessionAsync.when(
                data: (session) {
                  if (session != null) {
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer),
                                const SizedBox(width: 8),
                                Text(
                                  'Estudiando ahora',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (session.subject != null)
                              Text('Materia: ${session.subject}'),
                            Text(
                              'Inicio: ${_formatTime(session.startTime)}',
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StudySessionScreen(
                                      existingSessionId: session.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Terminar estudio'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text('No estás estudiando ahora'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StudySessionScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Comenzar a estudiar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Sesiones de hoy
              todaySessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final totalMinutes = sessions.fold<int>(
                    0,
                    (sum, s) => sum + s.calculatedDuration,
                  );

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estudio de hoy',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${sessions.length} ${sessions.length == 1 ? "sesión" : "sesiones"} - ${_formatDuration(totalMinutes)} total',
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}
