import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';
import 'reminder_detail_screen.dart';

/// Pantalla de historial de recordatorios con calendario
///
/// Muestra un calendario donde el usuario puede ver qué recordatorios
/// estaban programados para cada día y cuáles fueron completados
class ReminderHistoryScreen extends ConsumerStatefulWidget {
  const ReminderHistoryScreen({super.key});

  @override
  ConsumerState<ReminderHistoryScreen> createState() =>
      _ReminderHistoryScreenState();
}

class _ReminderHistoryScreenState extends ConsumerState<ReminderHistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Cache de recordatorios para marcadores del mes visible
  Map<DateTime, List<ReminderEntity>> _reminderCache = {};

  @override
  void initState() {
    super.initState();
    _loadMonthReminders();
  }

  Future<void> _loadMonthReminders() async {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final datasource = ReminderLocalDataSource(ref.read(appDatabaseProvider));
    final reminders = await datasource.getRemindersByDateRange(firstDay, lastDay);

    // Agrupar por día
    final Map<DateTime, List<ReminderEntity>> grouped = {};
    for (final reminder in reminders) {
      final day = DateTime(
        reminder.nextOccurrence.year,
        reminder.nextOccurrence.month,
        reminder.nextOccurrence.day,
      );
      grouped[day] = [...(grouped[day] ?? []), reminder];
    }

    setState(() {
      _reminderCache = grouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(remindersByDateProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
            tooltip: 'Ir a hoy',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendario
          Card(
            margin: const EdgeInsets.all(8),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                _loadMonthReminders();
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markersAlignment: Alignment.bottomCenter,
                markerDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
              // Marcadores para días con recordatorios
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final dayKey = DateTime(day.year, day.month, day.day);
                  final reminders = _reminderCache[dayKey];

                  if (reminders == null || reminders.isEmpty) {
                    return null;
                  }

                  // Agrupar por prioridad
                  final highPriority = reminders.where((r) => r.priority == Priority.high).toList();
                  final mediumPriority = reminders.where((r) => r.priority == Priority.medium).toList();
                  final lowPriority = reminders.where((r) => r.priority == Priority.low).toList();

                  final List<Widget> markers = [];

                  // Mostrar máximo 3 marcadores (uno por prioridad)
                  if (highPriority.isNotEmpty) {
                    markers.add(_buildMarker(
                      theme.colorScheme.error,
                      highPriority.every((r) => r.isCompleted),
                    ));
                  }
                  if (mediumPriority.isNotEmpty && markers.length < 3) {
                    markers.add(_buildMarker(
                      theme.colorScheme.secondary,
                      mediumPriority.every((r) => r.isCompleted),
                    ));
                  }
                  if (lowPriority.isNotEmpty && markers.length < 3) {
                    markers.add(_buildMarker(
                      theme.colorScheme.tertiary,
                      lowPriority.every((r) => r.isCompleted),
                    ));
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: markers.map((m) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: m,
                    )).toList(),
                  );
                },
              ),
            ),
          ),

          // Fecha seleccionada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getFormattedSelectedDate(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de recordatorios del día seleccionado
          Expanded(
            child: remindersAsync.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return ReminderCard(
                      reminder: reminder,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReminderDetailScreen(reminder: reminder),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        'Error al cargar recordatorios',
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isPast = _selectedDay.isBefore(DateTime.now());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.check_circle_outline : Icons.event_available,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isToday
                  ? 'No hay recordatorios para hoy'
                  : isPast
                      ? 'No hubo recordatorios este día'
                      : 'No hay recordatorios programados',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? '¡Disfruta tu día libre de tareas!'
                  : isPast
                      ? 'Este día no tenías recordatorios programados'
                      : 'No hay recordatorios programados para esta fecha',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (selected == today) {
      return 'Hoy - ${DateFormat('EEEE d MMMM', 'es').format(_selectedDay)}';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Ayer - ${DateFormat('EEEE d MMMM', 'es').format(_selectedDay)}';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Mañana - ${DateFormat('EEEE d MMMM', 'es').format(_selectedDay)}';
    } else {
      return DateFormat('EEEE d MMMM y', 'es').format(_selectedDay);
    }
  }

  Widget _buildMarker(Color color, bool isCompleted) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isCompleted ? color : color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
