import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sleep_study_providers.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  final int? existingSessionId;

  const StudySessionScreen({
    super.key,
    this.existingSessionId,
  });

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingSessionId != null) {
      // Si hay una sesión existente, cargar sus datos
      _loadExistingSession();
    }
  }

  void _loadExistingSession() async {
    final activeSession = await ref.read(activeStudySessionProvider.future);
    if (activeSession != null && mounted) {
      setState(() {
        _startTime = activeSession.startTime;
        _elapsedSeconds = DateTime.now().difference(activeSession.startTime).inSeconds;
        _subjectController.text = activeSession.subject ?? '';
        _notesController.text = activeSession.notes ?? '';
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _startTime ??= DateTime.now();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _elapsedSeconds = 0;
      _startTime = null;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Estudio'),
        actions: [
          if (_isRunning || _elapsedSeconds > 0)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _showFinishDialog(),
              tooltip: 'Terminar sesión',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cronómetro visual
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_elapsedSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isRunning
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRunning ? 'En progreso...' : 'Pausado',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isRunning)
                        FilledButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(_startTime == null ? 'Iniciar' : 'Continuar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        )
                      else
                        FilledButton.tonalIcon(
                          onPressed: _pauseTimer,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pausar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      if (_elapsedSeconds > 0) ...[
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () => _showResetDialog(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reiniciar'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Materia
          Text(
            'Materia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Matemáticas, Historia, Programación',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.school),
                ),
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
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '¿Qué estudiaste? ¿Cómo te fue?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón terminar sesión
          if (_elapsedSeconds > 0)
            FilledButton.icon(
              onPressed: _showFinishDialog,
              icon: const Icon(Icons.check),
              label: const Text('Terminar Sesión'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Cronómetro'),
        content: const Text('¿Estás seguro? Se perderá el tiempo actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _resetTimer();
    }
  }

  Future<void> _showFinishDialog() async {
    if (_elapsedSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La sesión debe durar al menos 1 minuto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar Sesión'),
        content: Text(
          'Tiempo total: ${_formatDuration(_elapsedSeconds)}\n\n'
          '¿Guardar esta sesión de estudio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _finishSession();
    }
  }

  Future<void> _finishSession() async {
    if (_startTime == null) return;

    try {
      final logStudySession = ref.read(logStudySessionProvider);

      final endTime = DateTime.now();
      await logStudySession.createComplete(
        date: _startTime!,
        startTime: _startTime!,
        endTime: endTime,
        subject: _subjectController.text.isNotEmpty ? _subjectController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Invalidar providers
      ref.invalidate(activeStudySessionProvider);
      ref.invalidate(todayStudySessionsProvider);
      ref.invalidate(weeklyStudySessionsProvider);
      ref.invalidate(weeklyStudyStatsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sesión guardada: ${_formatDuration(_elapsedSeconds)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
