import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sleep_study_providers.dart';

class LogSleepRecordScreen extends ConsumerStatefulWidget {
  const LogSleepRecordScreen({super.key});

  @override
  ConsumerState<LogSleepRecordScreen> createState() => _LogSleepRecordScreenState();
}

class _LogSleepRecordScreenState extends ConsumerState<LogSleepRecordScreen> {
  DateTime? _actualBedtime;
  DateTime? _actualWakeup;
  int _sleepQuality = 3;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(activeSleepScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Sueño'),
      ),
      body: scheduleAsync.when(
        data: (schedule) {
          if (schedule == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bedtime_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay horario configurado',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura tu horario de sueño primero',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildForm(context, schedule.defaultBedtime, schedule.defaultWakeup);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, DateTime plannedBedtime, DateTime plannedWakeup) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info del plan
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tu horario planificado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Dormir',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(plannedBedtime),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    Column(
                      children: [
                        Text(
                          'Despertar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(plannedWakeup),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Hora real de dormir
        Text(
          '¿A qué hora te dormiste?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bedtime),
            title: Text(
              _actualBedtime == null
                  ? 'Seleccionar hora'
                  : DateFormat('dd/MM/yyyy HH:mm').format(_actualBedtime!),
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectBedtime(context),
          ),
        ),
        const SizedBox(height: 16),

        // Hora real de despertar
        Text(
          '¿A qué hora despertaste?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: Text(
              _actualWakeup == null
                  ? 'Seleccionar hora'
                  : DateFormat('dd/MM/yyyy HH:mm').format(_actualWakeup!),
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectWakeup(context),
          ),
        ),
        const SizedBox(height: 24),

        // Calidad del sueño
        Text(
          'Calidad del sueño',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 40,
                      icon: Icon(
                        index < _sleepQuality ? Icons.star : Icons.star_border,
                        color: index < _sleepQuality
                            ? Colors.amber
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _sleepQuality = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _getQualityLabel(_sleepQuality),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Notas
        Text(
          'Notas (opcional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '¿Cómo te sientes? ¿Tuviste sueños?',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Botón guardar
        FilledButton.icon(
          onPressed: _actualBedtime != null && _actualWakeup != null
              ? () => _saveSleepRecord(context)
              : null,
          icon: const Icon(Icons.check),
          label: const Text('Guardar Registro'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectBedtime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 22, minute: 0),
      );

      if (time != null) {
        setState(() {
          _actualBedtime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectWakeup(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 7, minute: 0),
      );

      if (time != null) {
        setState(() {
          _actualWakeup = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
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
        return 'Regular';
    }
  }

  Future<void> _saveSleepRecord(BuildContext context) async {
    if (_actualBedtime == null || _actualWakeup == null) return;

    // Validation: wakeup must be after bedtime
    if (_actualWakeup!.isBefore(_actualBedtime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de despertar debe ser después de la hora de dormir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final createAndLogSleepRecord = ref.read(createAndLogSleepRecordProvider);
      await createAndLogSleepRecord(
        actualBedtime: _actualBedtime!,
        actualWakeup: _actualWakeup!,
        sleepQuality: _sleepQuality,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro de sueño guardado')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
