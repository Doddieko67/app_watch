import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';
import 'reminder_detail_screen.dart';

/// Pantalla principal de recordatorios
///
/// Muestra la lista de recordatorios con filtros
class RemindersHomeScreen extends ConsumerWidget {
  const RemindersHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentFilter = ref.watch(currentReminderFilterProvider);
    final remindersAsync = ref.watch(filteredRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        actions: [
          // Botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(refreshRemindersProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _FilterBar(
            currentFilter: currentFilter,
            onFilterChanged: (filter) {
              ref
                  .read(currentReminderFilterProvider.notifier)
                  .setFilter(filter);
            },
          ),
          // Lista de recordatorios
          Expanded(
            child: remindersAsync.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return _EmptyState(filter: currentFilter);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(refreshRemindersProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderDetailScreen(
                                reminder: reminder,
                              ),
                            ),
                          ).then((_) {
                            // Refrescar después de volver
                            ref
                                .read(refreshRemindersProvider.notifier)
                                .refresh();
                          });
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReminderDetailScreen(),
            ),
          ).then((_) {
            // Refrescar después de volver
            ref.read(refreshRemindersProvider.notifier).refresh();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Barra de filtros
class _FilterBar extends StatelessWidget {
  final ReminderFilter currentFilter;
  final ValueChanged<ReminderFilter> onFilterChanged;

  const _FilterBar({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ReminderFilter.values.map((filter) {
            final isSelected = filter == currentFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.displayName),
                selected: isSelected,
                onSelected: (_) => onFilterChanged(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Estado vacío
class _EmptyState extends StatelessWidget {
  final ReminderFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String message;
    IconData icon;

    switch (filter) {
      case ReminderFilter.all:
        message = 'No tienes recordatorios aún.\n¡Crea tu primer recordatorio!';
        icon = Icons.event_note;
        break;
      case ReminderFilter.pending:
        message = 'No tienes recordatorios pendientes.\n¡Buen trabajo!';
        icon = Icons.check_circle_outline;
        break;
      case ReminderFilter.completed:
        message = 'No has completado ningún recordatorio todavía.';
        icon = Icons.pending_actions;
        break;
      case ReminderFilter.today:
        message = 'No tienes recordatorios para hoy.';
        icon = Icons.today;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
