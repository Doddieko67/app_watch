import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/reminders_summary_card.dart';
import '../widgets/fitness_summary_card.dart';
import '../widgets/nutrition_summary_card.dart';
import '../widgets/sleep_study_summary_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Watch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh all providers
              ref.invalidate(remindersSummaryCardProvider);
              ref.invalidate(fitnessSummaryCardProvider);
              ref.invalidate(nutritionSummaryCardProvider);
              ref.invalidate(sleepStudySummaryCardProvider);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(remindersSummaryCardProvider);
          ref.invalidate(fitnessSummaryCardProvider);
          ref.invalidate(nutritionSummaryCardProvider);
          ref.invalidate(sleepStudySummaryCardProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome message
            _buildWelcomeSection(context),
            const SizedBox(height: 24),

            // Quick summary cards
            const RemindersSummaryCard(),
            const SizedBox(height: 16),
            const FitnessSummaryCard(),
            const SizedBox(height: 16),
            const NutritionSummaryCard(),
            const SizedBox(height: 16),
            const SleepStudySummaryCard(),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                'Desliza hacia abajo para actualizar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = 'Buenos días';
      icon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      icon = Icons.wb_cloudy;
    } else {
      greeting = 'Buenas noches';
      icon = Icons.nightlight_round;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí está tu resumen del día',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder providers (will be used by summary cards)
final remindersSummaryCardProvider = Provider<void>((ref) {});
final fitnessSummaryCardProvider = Provider<void>((ref) {});
final nutritionSummaryCardProvider = Provider<void>((ref) {});
final sleepStudySummaryCardProvider = Provider<void>((ref) {});
