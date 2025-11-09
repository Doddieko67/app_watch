import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../daily_reminders/presentation/providers/reminder_providers.dart';
import '../../../daily_reminders/presentation/screens/reminders_home_screen.dart';

class RemindersSummaryCard extends ConsumerWidget {
  final VoidCallback onTap;

  const RemindersSummaryCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRemindersAsync = ref.watch(todayRemindersProvider);
    final pendingRemindersAsync = ref.watch(pendingRemindersProvider);

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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recordatorios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              todayRemindersAsync.when(
                data: (todayReminders) => pendingRemindersAsync.when(
                  data: (pendingReminders) {
                    final todayCount = todayReminders.length;
                    final pendingCount = pendingReminders.length;
                    final todayPending = todayReminders
                        .where((r) => !r.isCompleted)
                        .toList();

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStat(
                                context,
                                todayCount.toString(),
                                'Hoy',
                                Icons.today,
                              ),
                            ),
                            Expanded(
                              child: _buildStat(
                                context,
                                pendingCount.toString(),
                                'Pendientes',
                                Icons.pending_actions,
                              ),
                            ),
                          ],
                        ),
                        if (todayPending.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Próximo:',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          ...todayPending.take(2).map((reminder) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: _getPriorityColor(context, reminder.priority.name),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reminder.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.Hm().format(reminder.scheduledTime),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (todayPending.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '+${todayPending.length - 2} más',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '¡Todo listo por hoy! 🎉',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
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

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Color _getPriorityColor(BuildContext context, String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
