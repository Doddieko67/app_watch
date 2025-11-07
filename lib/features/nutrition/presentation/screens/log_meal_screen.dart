import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_entity.dart';
import '../providers/nutrition_providers.dart';

/// Pantalla para registrar una nueva comida
class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  MealType _selectedMealType = MealType.breakfast;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createMeal() async {
    setState(() => _isLoading = true);

    try {
      final useCase = ref.read(logMealUseCaseProvider);
      await useCase(
        date: DateTime.now(),
        mealType: _selectedMealType.name,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        // Invalidar providers para refrescar
        ref.invalidate(todayMealsProvider);
        ref.invalidate(dailyNutritionSummaryProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comida creada exitosamente')),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar comida'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tipo de comida',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<MealType>(
              segments: const [
                ButtonSegment(
                  value: MealType.breakfast,
                  label: Text('Desayuno'),
                  icon: Icon(Icons.breakfast_dining),
                ),
                ButtonSegment(
                  value: MealType.lunch,
                  label: Text('Almuerzo'),
                  icon: Icon(Icons.lunch_dining),
                ),
                ButtonSegment(
                  value: MealType.dinner,
                  label: Text('Cena'),
                  icon: Icon(Icons.dinner_dining),
                ),
                ButtonSegment(
                  value: MealType.snack,
                  label: Text('Snack'),
                  icon: Icon(Icons.cookie),
                ),
              ],
              selected: {_selectedMealType},
              onSelectionChanged: (Set<MealType> newSelection) {
                setState(() {
                  _selectedMealType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Agrega notas sobre esta comida',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _createMeal,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isLoading ? 'Creando...' : 'Crear comida'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Próximamente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Análisis de alimentos con IA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Escribe el nombre de un alimento y la IA calculará automáticamente sus valores nutricionales',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
