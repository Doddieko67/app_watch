import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
import '../providers/fitness_providers.dart';
import '../widgets/exercise_log_card.dart';
import '../widgets/split_selector.dart';

/// Pantalla para crear o editar un workout
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final WorkoutEntity? workout;

  const WorkoutDetailScreen({
    super.key,
    this.workout,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  late WorkoutSplit _selectedSplit;
  List<ExerciseEntity> _exercises = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout?.name ?? '');
    _durationController = TextEditingController(
      text: widget.workout?.durationMinutes?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.workout?.notes ?? '');
    _selectedDate = widget.workout?.date ?? DateTime.now();
    _selectedSplit = widget.workout?.split ?? WorkoutSplit.custom;
    _exercises = widget.workout?.exercises.toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.workout != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Workout' : 'Nuevo Workout'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveWorkout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del workout
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Workout',
                hintText: 'Ej: Push Day Morning',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Selector de split
            SplitSelector(
              selectedSplit: _selectedSplit,
              onSplitChanged: (split) {
                setState(() {
                  _selectedSplit = split;
                  // Auto-generar nombre si está vacío
                  if (_nameController.text.isEmpty) {
                    _nameController.text = '${split.displayName} - ${_formatDate(_selectedDate)}';
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Fecha del workout
            Text(
              'Fecha',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
              title: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),

            // Duración (opcional)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duración (minutos)',
                      hintText: '60',
                      prefixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notas (opcional)
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Ej: Me sentí muy fuerte hoy',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Sección de ejercicios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ejercicios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de ejercicios
            if (_exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ejercicios',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega ejercicios para completar tu workout',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return ExerciseLogCard(
                  exercise: exercise,
                  onEdit: () => _editExercise(index),
                  onDelete: () => _removeExercise(index),
                );
              }),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addExercise() async {
    final exercise = await showDialog<ExerciseEntity>(
      context: context,
      builder: (context) => ExerciseFormDialog(
        workoutId: widget.workout?.id ?? 0,
      ),
    );

    if (exercise != null) {
      setState(() {
        _exercises.add(exercise);
      });
    }
  }

  Future<void> _editExercise(int index) async {
    final exercise = await showDialog<ExerciseEntity>(
      context: context,
      builder: (context) => ExerciseFormDialog(
        exercise: _exercises[index],
        workoutId: widget.workout?.id ?? 0,
      ),
    );

    if (exercise != null) {
      setState(() {
        _exercises[index] = exercise;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el workout'),
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agrega al menos un ejercicio'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final createWorkoutUseCase = ref.read(createWorkoutProvider);
      final logExerciseUseCase = ref.read(logExerciseProvider);

      // Crear/actualizar el workout
      final workout = WorkoutEntity(
        id: widget.workout?.id ?? 0,
        name: _nameController.text.trim(),
        split: _selectedSplit,
        date: _selectedDate,
        durationMinutes: _durationController.text.isEmpty
            ? null
            : int.tryParse(_durationController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        exercises: const [],
        createdAt: widget.workout?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );

      final workoutId = await createWorkoutUseCase(workout);

      final repository = ref.read(fitnessRepositoryProvider);

      // Si estamos editando un workout existente, manejar ejercicios inteligentemente
      if (widget.workout != null && widget.workout!.id != 0) {
        final oldExercises = widget.workout!.exercises;
        final oldExerciseIds = oldExercises.map((e) => e.id).toSet();
        final currentExerciseIds = _exercises.where((e) => e.id != 0).map((e) => e.id).toSet();

        // 1. Eliminar ejercicios que ya no están en la lista
        for (final oldEx in oldExercises) {
          if (!currentExerciseIds.contains(oldEx.id)) {
            await repository.deleteExercise(oldEx.id);
          }
        }

        // 2. Actualizar o crear ejercicios
        for (final exercise in _exercises) {
          if (exercise.id != 0 && oldExerciseIds.contains(exercise.id)) {
            // Actualizar ejercicio existente (preservar ID y timestamps)
            await repository.updateExercise(
              exercise.copyWith(workoutId: workoutId),
            );
          } else {
            // Crear nuevo ejercicio
            await logExerciseUseCase(
              exercise.copyWith(
                workoutId: workoutId,
                id: 0,
              ),
            );
          }
        }
      } else {
        // Workout nuevo: crear todos los ejercicios
        for (final exercise in _exercises) {
          await logExerciseUseCase(
            exercise.copyWith(
              workoutId: workoutId,
              id: 0,
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.workout != null
                  ? 'Workout actualizado exitosamente'
                  : 'Workout guardado exitosamente',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
