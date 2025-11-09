import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/fitness_providers.dart';
import '../widgets/one_rm_calculator.dart';
import '../widgets/workout_card.dart';
import 'fitness_stats_screen.dart';
import 'saved_exercises_list_screen.dart';
import 'workout_detail_screen.dart';
import 'workout_history_screen.dart';

/// Pantalla principal de Fitness
///
/// Muestra estadísticas, workouts recientes y acceso a historial
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeWorkoutsAsync = ref.watch(activeWorkoutsProvider);
    final statsAsync = ref.watch(overallStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        actions: [
          // Botón para ver historial completo
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkoutHistoryScreen(),
                ),
              );
            },
          ),
          // Botón de estadísticas
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FitnessStatsScreen(),
                ),
              );
            },
          ),
          // Menú con más opciones
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exercises') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedExercisesListScreen(),
                  ),
                );
              } else if (value == '1rm') {
                showOneRMCalculator(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'exercises',
                child: Row(
                  children: [
                    Icon(Icons.fitness_center),
                    SizedBox(width: 12),
                    Text('Ejercicios Guardados'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: '1rm',
                child: Row(
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 12),
                    Text('Calculadora 1RM'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeWorkoutsProvider);
          ref.invalidate(overallStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Estadísticas generales
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _StatsSection(stats: stats),
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Encabezado de workouts recientes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Entrenamientos Recientes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de workouts
            activeWorkoutsAsync.when(
              data: (workouts) {
                if (workouts.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      onAddWorkout: () => _navigateToNewWorkout(context),
                    ),
                  );
                }

                // Mostrar solo los últimos 10
                final recentWorkouts = workouts.take(10).toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final workout = recentWorkouts[index];
                      return WorkoutCard(
                        workout: workout,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailScreen(
                                workout: workout,
                              ),
                            ),
                          ).then((_) {
                            ref.invalidate(activeWorkoutsProvider);
                            ref.invalidate(overallStatsProvider);
                          });
                        },
                        onDelete: () => _confirmDelete(context, ref, workout.id),
                      );
                    },
                    childCount: recentWorkouts.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar entrenamientos',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Espaciado inferior para el FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewWorkout(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Workout'),
      ),
    );
  }

  void _navigateToNewWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutDetailScreen(),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int workoutId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrenamiento'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este entrenamiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = ref.read(fitnessRepositoryProvider);
      await repository.deleteWorkout(workoutId);
      ref.invalidate(activeWorkoutsProvider);
      ref.invalidate(overallStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrenamiento eliminado')),
        );
      }
    }
  }
}

/// Sección de estadísticas
class _StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWorkouts = stats['totalWorkouts'] as int;
    final totalExercises = stats['totalExercises'] as int;
    final totalVolume = stats['totalVolume'] as double;
    final avgDuration = stats['avgDuration'] as double;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen General',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fitness_center,
                  label: 'Workouts',
                  value: totalWorkouts.toString(),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.list,
                  label: 'Ejercicios',
                  value: totalExercises.toString(),
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Volumen Total',
                  value: '${(totalVolume / 1000).toStringAsFixed(1)}t',
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer,
                  label: 'Duración Prom.',
                  value: '${avgDuration.toInt()}m',
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de estadística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Estado vacío cuando no hay workouts
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddWorkout;

  const _EmptyState({required this.onAddWorkout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptar el diseño según el espacio disponible
        final hasLimitedSpace = constraints.maxHeight < 400;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(hasLimitedSpace ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: hasLimitedSpace ? 48 : 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                SizedBox(height: hasLimitedSpace ? 12 : 16),
                Text(
                  'No hay entrenamientos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: hasLimitedSpace ? 20 : null,
                  ),
                ),
                SizedBox(height: hasLimitedSpace ? 6 : 8),
                Text(
                  'Comienza tu primer entrenamiento para hacer seguimiento de tu progreso',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: hasLimitedSpace ? 13 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: hasLimitedSpace ? 16 : 24),
                FilledButton.icon(
                  onPressed: onAddWorkout,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Entrenamiento'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
