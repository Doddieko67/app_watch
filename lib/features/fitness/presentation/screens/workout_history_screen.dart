import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/workout_entity.dart';
import '../providers/fitness_providers.dart';
import 'workout_detail_screen.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final monthWorkoutsAsync = ref.watch(
      workoutsByDateRangeProvider(
        start: startOfMonth,
        end: endOfMonth,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
      ),
      body: Column(
        children: [
          // Calendario
          Card(
            margin: const EdgeInsets.all(8),
            child: monthWorkoutsAsync.when(
              data: (monthWorkouts) {
                // Crear un mapa de fechas con workouts
                final workoutDates = <DateTime, List<WorkoutEntity>>{};
                for (final workout in monthWorkouts) {
                  final dateKey = DateTime(
                    workout.date.year,
                    workout.date.month,
                    workout.date.day,
                  );
                  workoutDates[dateKey] = [...(workoutDates[dateKey] ?? []), workout];
                }

                return TableCalendar<WorkoutEntity>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    final dateKey = DateTime(day.year, day.month, day.day);
                    return workoutDates[dateKey] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
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
          const SizedBox(height: 8),

          // Lista de workouts del día seleccionado
          Expanded(
            child: _WorkoutsList(selectedDate: _selectedDay),
          ),
        ],
      ),
    );
  }
}

class _WorkoutsList extends ConsumerWidget {
  final DateTime selectedDate;

  const _WorkoutsList({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(
      workoutsByDateRangeProvider(
        start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        end: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59),
      ),
    );

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay entrenamientos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _WorkoutCard(workout: workout);
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

class _WorkoutCard extends StatelessWidget {
  final WorkoutEntity workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSplitColor(workout.split).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSplitIcon(workout.split),
                      color: _getSplitColor(workout.split),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSplitName(workout.split),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(workout.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (workout.durationMinutes != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.durationMinutes}m',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  workout.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Estadísticas rápidas
              Row(
                children: [
                  _buildStat(
                    context,
                    Icons.fitness_center,
                    '${workout.exercises.length} ejercicios',
                  ),
                  const SizedBox(width: 16),
                  if (workout.totalVolume > 0)
                    _buildStat(
                      context,
                      Icons.scale,
                      '${workout.totalVolume.toStringAsFixed(0)} kg',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Color _getSplitColor(WorkoutSplit split) {
    switch (split) {
      case WorkoutSplit.push:
        return Colors.orange;
      case WorkoutSplit.pull:
        return Colors.blue;
      case WorkoutSplit.legs:
        return Colors.green;
      case WorkoutSplit.upperBody:
        return Colors.purple;
      case WorkoutSplit.lowerBody:
        return Colors.teal;
      case WorkoutSplit.fullBody:
        return Colors.red;
      case WorkoutSplit.custom:
        return Colors.grey;
    }
  }

  IconData _getSplitIcon(WorkoutSplit split) {
    switch (split) {
      case WorkoutSplit.push:
        return Icons.accessibility_new;
      case WorkoutSplit.pull:
        return Icons.fitness_center;
      case WorkoutSplit.legs:
        return Icons.directions_run;
      case WorkoutSplit.upperBody:
        return Icons.emoji_people;
      case WorkoutSplit.lowerBody:
        return Icons.trending_down;
      case WorkoutSplit.fullBody:
        return Icons.person;
      case WorkoutSplit.custom:
        return Icons.star;
    }
  }

  String _getSplitName(WorkoutSplit split) {
    switch (split) {
      case WorkoutSplit.push:
        return 'Push';
      case WorkoutSplit.pull:
        return 'Pull';
      case WorkoutSplit.legs:
        return 'Legs';
      case WorkoutSplit.upperBody:
        return 'Upper Body';
      case WorkoutSplit.lowerBody:
        return 'Lower Body';
      case WorkoutSplit.fullBody:
        return 'Full Body';
      case WorkoutSplit.custom:
        return 'Personalizado';
    }
  }
}
