import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget calculadora de 1RM (One Rep Max)
/// Usa las fórmulas de Epley y Brzycki
class OneRMCalculatorSheet extends StatefulWidget {
  const OneRMCalculatorSheet({super.key});

  @override
  State<OneRMCalculatorSheet> createState() => _OneRMCalculatorSheetState();
}

class _OneRMCalculatorSheetState extends State<OneRMCalculatorSheet> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  double? _oneRepMax;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || reps < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa valores válidos'),
        ),
      );
      return;
    }

    if (reps == 1) {
      setState(() => _oneRepMax = weight);
      return;
    }

    // Fórmula de Epley: 1RM = weight × (1 + reps/30)
    // Fórmula de Brzycki: 1RM = weight × (36 / (37 - reps))
    // Usamos el promedio de ambas para mayor precisión
    final epley = weight * (1 + reps / 30);
    final brzycki = weight * (36 / (37 - reps));
    final average = (epley + brzycki) / 2;

    setState(() => _oneRepMax = average);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Calculadora de 1RM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Calcula tu máximo de una repetición (1RM)',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Inputs
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso levantado (kg)',
                hintText: '100',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Repeticiones completadas',
                hintText: '8',
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 24),

            // Botón calcular
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular 1RM'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Resultados
            if (_oneRepMax != null) ...[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '1RM Estimado',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_oneRepMax!.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tabla de porcentajes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Porcentajes de Trabajo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PercentageRow(
                        percentage: 50,
                        weight: _oneRepMax! * 0.5,
                        description: 'Calentamiento',
                        color: Colors.green,
                      ),
                      _PercentageRow(
                        percentage: 60,
                        weight: _oneRepMax! * 0.6,
                        description: 'Técnica',
                        color: Colors.blue,
                      ),
                      _PercentageRow(
                        percentage: 70,
                        weight: _oneRepMax! * 0.7,
                        description: 'Volumen',
                        color: Colors.orange,
                      ),
                      _PercentageRow(
                        percentage: 80,
                        weight: _oneRepMax! * 0.8,
                        description: 'Hipertrofia',
                        color: Colors.deepOrange,
                      ),
                      _PercentageRow(
                        percentage: 90,
                        weight: _oneRepMax! * 0.9,
                        description: 'Fuerza',
                        color: Colors.red,
                      ),
                      _PercentageRow(
                        percentage: 95,
                        weight: _oneRepMax! * 0.95,
                        description: 'Potencia',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nota
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estos valores son estimaciones. Se usa el promedio '
                          'de las fórmulas de Epley y Brzycki.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una fila de porcentaje
class _PercentageRow extends StatelessWidget {
  final int percentage;
  final double weight;
  final String description;
  final Color color;

  const _PercentageRow({
    required this.percentage,
    required this.weight,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 45,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${weight.toStringAsFixed(1)} kg',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Función helper para mostrar la calculadora como bottom sheet
void showOneRMCalculator(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const OneRMCalculatorSheet(),
  );
}
