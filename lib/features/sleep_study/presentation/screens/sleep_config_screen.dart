import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sleep_study_providers.dart';

/// Pantalla para configurar el horario de sueño
class SleepConfigScreen extends ConsumerStatefulWidget {
  const SleepConfigScreen({super.key});

  @override
  ConsumerState<SleepConfigScreen> createState() => _SleepConfigScreenState();
}

class _SleepConfigScreenState extends ConsumerState<SleepConfigScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeup = const TimeOfDay(hour: 7, minute: 0);
  int _preSleepMinutes = 30;
  bool _enableOptimalStudy = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  Future<void> _loadCurrentSchedule() async {
    final schedule = await ref.read(activeSleepScheduleProvider.future);
    if (schedule != null && mounted) {
      setState(() {
        _bedtime = TimeOfDay.fromDateTime(schedule.defaultBedtime);
        _wakeup = TimeOfDay.fromDateTime(schedule.defaultWakeup);
        _preSleepMinutes = schedule.preSleepNotificationMinutes;
        _enableOptimalStudy = schedule.enableOptimalStudyTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horario de Sueño'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Establece tu horario ideal de sueño',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),

                  // Hora de dormir
                  ListTile(
                    leading: const Icon(Icons.bedtime),
                    title: const Text('Hora de dormir'),
                    subtitle: Text(_formatTime(_bedtime)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectTime(context, true),
                  ),
                  const Divider(),

                  // Hora de despertar
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Hora de despertar'),
                    subtitle: Text(_formatTime(_wakeup)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectTime(context, false),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Resumen de horas de sueño
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.timelapse),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horas de sueño objetivo',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${_calculateSleepHours().toStringAsFixed(1)} horas',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notificaciones
                  Text(
                    'Notificaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Recordatorio antes de dormir'),
                    subtitle: Text('$_preSleepMinutes minutos antes'),
                    trailing: SizedBox(
                      width: 100,
                      child: DropdownButton<int>(
                        value: _preSleepMinutes,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Ninguno')),
                          DropdownMenuItem(value: 15, child: Text('15 min')),
                          DropdownMenuItem(value: 30, child: Text('30 min')),
                          DropdownMenuItem(value: 45, child: Text('45 min')),
                          DropdownMenuItem(value: 60, child: Text('60 min')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _preSleepMinutes = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Estudio óptimo
                  Text(
                    'Estudio',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    secondary: const Icon(Icons.lightbulb_outline),
                    title: const Text('Notificar hora óptima de estudio'),
                    subtitle: Text(
                      _enableOptimalStudy
                          ? 'Te avisaremos cuando sea el mejor momento'
                          : 'Desactivado',
                    ),
                    value: _enableOptimalStudy,
                    onChanged: (value) {
                      setState(() {
                        _enableOptimalStudy = value;
                      });
                    },
                  ),

                  if (_enableOptimalStudy)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hora óptima: ${_calculateOptimalStudyTime()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Guardar configuración'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeup,
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeup = picked;
        }
      });
    }
  }

  double _calculateSleepHours() {
    final bedtimeMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeupMinutes = _wakeup.hour * 60 + _wakeup.minute;

    int diff = wakeupMinutes - bedtimeMinutes;
    if (diff < 0) {
      diff += 24 * 60; // Add 24 hours if wake up is next day
    }

    return diff / 60.0;
  }

  String _calculateOptimalStudyTime() {
    final wakeupMinutes = _wakeup.hour * 60 + _wakeup.minute;
    final optimalMinutes = wakeupMinutes + 150; // 2.5 hours after waking
    final hours = (optimalMinutes ~/ 60) % 24;
    final minutes = optimalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final bedtime = DateTime(
        now.year,
        now.month,
        now.day,
        _bedtime.hour,
        _bedtime.minute,
      );

      DateTime wakeup = DateTime(
        now.year,
        now.month,
        now.day,
        _wakeup.hour,
        _wakeup.minute,
      );

      // Si la hora de despertar es antes que la hora de dormir, es al día siguiente
      if (wakeup.isBefore(bedtime)) {
        wakeup = wakeup.add(const Duration(days: 1));
      }

      final useCase = ref.read(configureSleepScheduleProvider);
      await useCase(
        defaultBedtime: bedtime,
        defaultWakeup: wakeup,
        preSleepNotificationMinutes: _preSleepMinutes,
        enableOptimalStudyTime: _enableOptimalStudy,
      );

      // Invalidar providers para refrescar datos
      ref.invalidate(activeSleepScheduleProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
