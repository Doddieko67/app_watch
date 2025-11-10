import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/food_analysis_result.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_source_badge.dart';

class AddFoodItemScreen extends ConsumerStatefulWidget {
  final int mealId;

  const AddFoodItemScreen({
    super.key,
    required this.mealId,
  });

  @override
  ConsumerState<AddFoodItemScreen> createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends ConsumerState<AddFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  bool _isAnalyzing = false;
  FoodAnalysisResult? _analysisResult;

  @override
  void dispose() {
    _inputController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFood() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      _showSnackBar('Por favor, ingresa un alimento', isError: true);
      return;
    }

    // Verificar si hay API key configurada
    final hasApiKey = await ref.read(hasApiKeyProvider.future);
    if (!hasApiKey) {
      _showSnackBar(
        'No se encontró API key de Gemini. Configúrala en Settings para usar IA.',
        isError: true,
      );
      // Aún así intentar analizar (usará DB local como fallback)
    }

    setState(() => _isAnalyzing = true);

    try {
      final analyzeFood = ref.read(analyzeFoodUseCaseProvider);
      final result = await analyzeFood(input);

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });

      // Pre-rellenar campos con el resultado
      if (result.data != null) {
        _nameController.text = result.data!.name;
        _quantityController.text = result.data!.quantity.toString();
        _caloriesController.text = result.data!.calories.toString();
        _proteinController.text = result.data!.protein.toString();
        _carbsController.text = result.data!.carbs.toString();
        _fatsController.text = result.data!.fats.toString();
      }

      // Mostrar mensaje según el source
      if (result.source == FoodAnalysisSource.error) {
        _showSnackBar(result.errorMessage ?? 'Error al analizar el alimento', isError: true);
      } else if (result.source == FoodAnalysisSource.manual) {
        _showSnackBar('No se encontró información. Por favor, ingresa manualmente.', isError: false);
      } else {
        _showSnackBar('Análisis completado. Puedes editar los valores antes de guardar.', isError: false);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final foodData = FoodData(
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: 'g', // Por ahora siempre usamos gramos
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
      );

      final addFoodItem = ref.read(addFoodItemUseCaseProvider);
      await addFoodItem(widget.mealId, foodData);

      if (mounted) {
        _showSnackBar('Alimento agregado correctamente', isError: false);
        Navigator.of(context).pop(true); // Retornar true para indicar que se guardó
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Alimento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input para análisis con IA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analizar con IA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe el alimento (ej: "200g pollo", "1 manzana", "2 huevos")',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Ej: 200g pollo a la plancha',
                        border: const OutlineInputBorder(),
                        suffixIcon: _isAnalyzing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      enabled: !_isAnalyzing,
                      onSubmitted: (_) => _analyzeFood(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeFood,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Analizar'),
                    ),
                  ],
                ),
              ),
            ),

            // Badge de source si hay resultado
            if (_analysisResult != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FoodSourceBadge(source: _analysisResult!.source),
              ),
            ],

            const SizedBox(height: 24),

            // Formulario editable
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Nutricional',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del alimento *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cantidad
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad (g) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La cantidad es requerida';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Ingresa una cantidad válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Calorías
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calorías *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'kcal',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las calorías son requeridas';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Proteína
                  TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Proteína *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La proteína es requerida';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Carbohidratos
                  TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbohidratos *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grain),
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Los carbohidratos son requeridos';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Grasas
                  TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(
                      labelText: 'Grasas *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las grasas son requeridas';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                ],
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
                    onPressed: _saveFoodItem,
                    child: const Text('Guardar'),
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
