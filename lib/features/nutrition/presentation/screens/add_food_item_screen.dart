import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ai_service.dart';
import '../../domain/entities/food_analysis_result.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_source_badge.dart';
import '../widgets/image_picker_section.dart';

class AddFoodItemScreen extends ConsumerStatefulWidget {
  final int mealId;

  const AddFoodItemScreen({
    super.key,
    required this.mealId,
  });

  @override
  ConsumerState<AddFoodItemScreen> createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends ConsumerState<AddFoodItemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers para análisis de texto
  final _inputController = TextEditingController();

  // Controllers para formulario nutricional
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  // Controllers para análisis de imagen
  final _contextController = TextEditingController();
  File? _selectedImage;
  String _imageAnalysisMode = 'plate'; // 'plate', 'portion', 'label'

  bool _isAnalyzing = false;
  FoodAnalysisResult? _analysisResult;
  List<FoodAnalysisResult>? _multipleResults; // Para platos con múltiples alimentos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _contextController.dispose();
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
        _multipleResults = null;
        _isAnalyzing = false;
      });

      _fillFormWithResult(result);

      // Mostrar mensaje según el source
      if (result.source == FoodAnalysisSource.error) {
        _showSnackBar(result.errorMessage ?? 'Error al analizar el alimento',
            isError: true);
      } else if (result.source == FoodAnalysisSource.manual) {
        _showSnackBar('No se encontró información. Por favor, ingresa manualmente.',
            isError: false);
      } else {
        _showSnackBar('Análisis completado. Puedes editar los valores antes de guardar.',
            isError: false);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      _showSnackBar('Por favor, selecciona una imagen', isError: true);
      return;
    }

    // Verificar si hay API key configurada
    final hasApiKey = await ref.read(hasApiKeyProvider.future);
    if (!hasApiKey) {
      _showSnackBar(
        'No se encontró API key de Gemini. Configúrala en Settings para usar IA.',
        isError: true,
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final context = _contextController.text.trim();

      if (_imageAnalysisMode == 'plate') {
        // Analizar plato completo (puede detectar múltiples alimentos)
        final results = await aiService.analyzeFullPlate(
          image: _selectedImage!,
          context: context.isEmpty ? null : context,
        );

        setState(() {
          _multipleResults = results;
          _analysisResult = results.isNotEmpty ? results.first : null;
          _isAnalyzing = false;
        });

        if (results.isNotEmpty) {
          _fillFormWithResult(results.first);
          _showSnackBar(
              '${results.length} alimento(s) detectado(s). Mostrando el primero.',
              isError: false);
        }
      } else if (_imageAnalysisMode == 'portion') {
        // Analizar porción individual
        final result = await aiService.analyzePortionSize(
          image: _selectedImage!,
          foodName: context.isEmpty ? null : context,
        );

        setState(() {
          _analysisResult = result;
          _multipleResults = null;
          _isAnalyzing = false;
        });

        _fillFormWithResult(result);
        _showSnackBar('Porción analizada exitosamente.', isError: false);
      } else {
        // Leer etiqueta nutricional
        final result = await aiService.analyzeNutritionLabel(
          image: _selectedImage!,
        );

        setState(() {
          _analysisResult = result;
          _multipleResults = null;
          _isAnalyzing = false;
        });

        _fillFormWithResult(result);
        _showSnackBar('Etiqueta nutricional leída exitosamente.', isError: false);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackBar('Error al analizar imagen: $e', isError: true);
    }
  }

  void _fillFormWithResult(FoodAnalysisResult result) {
    if (result.data != null) {
      _nameController.text = result.data!.name;
      _quantityController.text = result.data!.quantity.toString();
      _caloriesController.text = result.data!.calories.toString();
      _proteinController.text = result.data!.protein.toString();
      _carbsController.text = result.data!.carbs.toString();
      _fatsController.text = result.data!.fats.toString();
    }
  }

  Future<void> _saveFoodItem({bool continueAdding = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final foodData = FoodData(
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: 'g',
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
      );

      final addFoodItem = ref.read(addFoodItemUseCaseProvider);
      await addFoodItem(widget.mealId, foodData);

      if (mounted) {
        if (continueAdding) {
          _showSnackBar('✓ Alimento agregado', isError: false);
          _clearForm();
        } else {
          _showSnackBar('Alimento agregado correctamente', isError: false);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
    }
  }

  Future<void> _saveAllDetectedFoods() async {
    if (_multipleResults == null || _multipleResults!.isEmpty) {
      return;
    }

    try {
      final addFoodItem = ref.read(addFoodItemUseCaseProvider);

      for (final result in _multipleResults!) {
        if (result.data != null) {
          await addFoodItem(widget.mealId, result.data!);
        }
      }

      if (mounted) {
        _showSnackBar(
            '${_multipleResults!.length} alimentos agregados correctamente',
            isError: false);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
    }
  }

  void _clearForm() {
    _inputController.clear();
    _nameController.clear();
    _quantityController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatsController.clear();
    _contextController.clear();
    setState(() {
      _analysisResult = null;
      _multipleResults = null;
      _selectedImage = null;
    });
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Texto'),
            Tab(icon: Icon(Icons.photo_camera), text: 'Imagen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextTab(theme),
          _buildImageTab(theme),
        ],
      ),
    );
  }

  Widget _buildTextTab(ThemeData theme) {
    return SingleChildScrollView(
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

          _buildNutritionForm(theme),

          const SizedBox(height: 32),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de modo de análisis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo de Análisis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'plate',
                        label: Text('Plato'),
                        icon: Icon(Icons.restaurant),
                      ),
                      ButtonSegment(
                        value: 'portion',
                        label: Text('Porción'),
                        icon: Icon(Icons.scale),
                      ),
                      ButtonSegment(
                        value: 'label',
                        label: Text('Etiqueta'),
                        icon: Icon(Icons.qr_code_scanner),
                      ),
                    ],
                    selected: {_imageAnalysisMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _imageAnalysisMode = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getAnalysisModeDescription(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selector de imagen
          ImagePickerSection(
            initialImage: _selectedImage,
            onImageSelected: (File? image) {
              setState(() {
                _selectedImage = image;
              });
            },
          ),

          const SizedBox(height: 16),

          // Contexto opcional
          TextField(
            controller: _contextController,
            decoration: InputDecoration(
              labelText: 'Contexto opcional',
              hintText: _imageAnalysisMode == 'portion'
                  ? 'Ej: pollo, arroz, ensalada'
                  : 'Ej: con salsa, 200g',
              border: const OutlineInputBorder(),
              helperText: _imageAnalysisMode == 'label'
                  ? 'No necesario para etiquetas'
                  : 'Ayuda a mejorar la precisión',
            ),
            enabled: !_isAnalyzing,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Botón de analizar
          FilledButton.icon(
            onPressed: _isAnalyzing || _selectedImage == null
                ? null
                : _analyzeImage,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isAnalyzing ? 'Analizando...' : 'Analizar Imagen'),
          ),

          // Badge de source si hay resultado
          if (_analysisResult != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FoodSourceBadge(source: _analysisResult!.source),
            ),
          ],

          // Alimentos múltiples detectados
          if (_multipleResults != null && _multipleResults!.length > 1) ...[
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: theme.colorScheme.onTertiaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_multipleResults!.length} alimentos detectados',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_multipleResults!.length, (index) {
                      final result = _multipleResults![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${index + 1}. ${result.data?.name ?? "Desconocido"} (${result.data?.quantity.toStringAsFixed(0) ?? 0}g)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _saveAllDetectedFoods,
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text('Guardar Todos'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          _buildNutritionForm(theme),

          const SizedBox(height: 32),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNutritionForm(ThemeData theme) {
    return Form(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            onPressed: () => _saveFoodItem(continueAdding: true),
            child: const Text('Guardar + Otro'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => _saveFoodItem(continueAdding: false),
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  String _getAnalysisModeDescription() {
    switch (_imageAnalysisMode) {
      case 'plate':
        return 'Detecta todos los alimentos en el plato y estima sus cantidades';
      case 'portion':
        return 'Estima el tamaño de una porción individual';
      case 'label':
        return 'Lee la información nutricional de la etiqueta del producto';
      default:
        return '';
    }
  }
}
