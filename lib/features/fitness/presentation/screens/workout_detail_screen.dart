import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/workout_entity.dart';
import '../providers/fitness_providers.dart';
import '../widgets/exercise_log_card.dart';
import '../widgets/muscle_group_selector.dart';
import '../widgets/workout_autocomplete_field.dart';

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
  List<MuscleGroup> _selectedMuscleGroups = [];
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
    _selectedMuscleGroups = widget.workout?.muscleGroups.toList() ?? [];
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
            // Nombre del workout con autocompletado
            WorkoutAutocompleteField(
              controller: _nameController,
              onWorkoutSelected: (savedWorkout) async {
                // Cargar datos del workout guardado
                setState(() {
                  _nameController.text = savedWorkout.name;
                  _selectedMuscleGroups = _decodeMuscleGroups(savedWorkout.muscleGroups);
                  if (savedWorkout.avgDurationMinutes != null) {
                    _durationController.text = savedWorkout.avgDurationMinutes.toString();
                  }
                  if (savedWorkout.notes != null) {
                    _notesController.text = savedWorkout.notes!;
                  }
                  // Cargar ejercicios del template
                  _exercises = _decodeExercises(savedWorkout.exercises);
                });

                // Actualizar contador de uso
                final database = ref.read(appDatabaseProvider);
                await database.updateSavedWorkout(
                  savedWorkout.copyWith(
                    usageCount: savedWorkout.usageCount + 1,
                    lastUsed: DateTime.now(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Selector de grupos musculares
            MuscleGroupSelector(
              selectedGroups: _selectedMuscleGroups,
              onChanged: (groups) {
                setState(() {
                  _selectedMuscleGroups = groups;
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

    if (_selectedMuscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un grupo muscular'),
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
      final database = ref.read(appDatabaseProvider);

      // Crear/actualizar el workout
      final workout = WorkoutEntity(
        id: widget.workout?.id ?? 0,
        name: _nameController.text.trim(),
        muscleGroups: _selectedMuscleGroups,
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

      // Guardar o actualizar como workout template (SavedWorkout)
      await _saveSavedWorkout(database);

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

  /// Guarda o actualiza el workout como template (SavedWorkout)
  Future<void> _saveSavedWorkout(AppDatabase database) async {
    final workoutName = _nameController.text.trim();
    final existing = await database.getSavedWorkoutByName(workoutName);

    final muscleGroupsJson = _encodeMuscleGroups(_selectedMuscleGroups);
    final exercisesJson = _encodeExercises(_exercises);
    final duration = _durationController.text.isEmpty
        ? null
        : int.tryParse(_durationController.text);

    if (existing != null) {
      // Actualizar existente
      await database.updateSavedWorkout(
        existing.copyWith(
          muscleGroups: muscleGroupsJson,
          exercises: exercisesJson,
          avgDurationMinutes: duration != null ? drift.Value(duration) : drift.Value(existing.avgDurationMinutes),
          notes: drift.Value(
            _notesController.text.trim().isEmpty
                ? existing.notes
                : _notesController.text.trim(),
          ),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      // Crear nuevo
      await database.insertSavedWorkout(
        SavedWorkoutsCompanion.insert(
          name: workoutName,
          muscleGroups: muscleGroupsJson,
          exercises: drift.Value(exercisesJson),
          avgDurationMinutes: drift.Value(duration),
          notes: drift.Value(
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        ),
      );
    }
  }

  /// Decodifica muscleGroups desde JSON string a List<MuscleGroup>
  List<MuscleGroup> _decodeMuscleGroups(String json) {
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((value) => MuscleGroup.fromValue(value.toString()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Codifica List<MuscleGroup> a JSON string
  String _encodeMuscleGroups(List<MuscleGroup> groups) {
    final List<String> values = groups.map((g) => g.value).toList();
    return jsonEncode(values);
  }

  /// Codifica List<ExerciseEntity> a JSON string
  String _encodeExercises(List<ExerciseEntity> exercises) {
    final List<Map<String, dynamic>> exercisesList = exercises.map((e) {
      return {
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'weight': e.weight,
        'notes': e.notes,
      };
    }).toList();
    return jsonEncode(exercisesList);
  }

  /// Decodifica exercises desde JSON string a List<ExerciseEntity>
  List<ExerciseEntity> _decodeExercises(String json) {
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((item) {
        return ExerciseEntity(
          id: 0, // ID temporal, se asignará al guardar
          workoutId: 0, // Se asignará al guardar
          name: item['name'] as String,
          sets: item['sets'] as int,
          reps: item['reps'] as int,
          weight: (item['weight'] as num).toDouble(),
          notes: item['notes'] as String?,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
