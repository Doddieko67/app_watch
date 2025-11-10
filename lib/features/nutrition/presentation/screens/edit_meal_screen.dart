import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_entity.dart';
import '../providers/nutrition_providers.dart';

class EditMealScreen extends ConsumerStatefulWidget {
  final MealEntity meal;

  const EditMealScreen({
    super.key,
    required this.meal,
  });

  @override
  ConsumerState<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends ConsumerState<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.meal.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.meal.date);
    _selectedMealType = widget.meal.mealType;
    _notesController.text = widget.meal.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Combinar fecha y hora
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Crear meal actualizado
      final updatedMeal = widget.meal.copyWith(
        date: dateTime,
        mealType: _selectedMealType,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Actualizar usando el repositorio
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.updateMeal(updatedMeal);

      if (mounted) {
        // Invalidar providers para refrescar UI
        ref.invalidate(mealByIdProvider(widget.meal.id));
        ref.invalidate(todayMealsProvider);
        ref.invalidate(dailyNutritionSummaryProvider);

        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comida actualizada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Comida'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de comida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de comida',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMealType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'breakfast',
                          child: Text('🌅 Desayuno'),
                        ),
                        DropdownMenuItem(
                          value: 'lunch',
                          child: Text('🌞 Almuerzo'),
                        ),
                        DropdownMenuItem(
                          value: 'dinner',
                          child: Text('🌙 Cena'),
                        ),
                        DropdownMenuItem(
                          value: 'snack',
                          child: Text('🍎 Snack'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMealType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha y hora
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha y hora',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(_selectedDate),
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: const Text('Fecha de la comida'),
                      trailing: FilledButton.tonal(
                        onPressed: _selectDate,
                        child: const Text('Cambiar'),
                      ),
                    ),
                    const Divider(),

                    // Hora
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      title: Text(
                        _selectedTime.format(context),
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: const Text('Hora de la comida'),
                      trailing: FilledButton.tonal(
                        onPressed: _selectTime,
                        child: const Text('Cambiar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas (opcional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Comida en casa, porción grande, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveMeal,
                    child: const Text('Guardar Cambios'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
