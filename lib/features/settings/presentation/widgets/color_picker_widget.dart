import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class ColorPickerWidget extends ConsumerWidget {
  const ColorPickerWidget({super.key});

  static const List<Color> presetColors = [
    Color(0xFF6750A4), // Purple (default)
    Color(0xFF0061A4), // Blue
    Color(0xFF006D3B), // Green
    Color(0xFFB3261E), // Red
    Color(0xFFFF6B00), // Orange
    Color(0xFF7D5260), // Pink
    Color(0xFF5F6368), // Gray
    Color(0xFF00897B), // Teal
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(primaryColorProvider);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primaryColor,
        radius: 16,
      ),
      title: const Text('Color primario'),
      subtitle: const Text('Personaliza el color de la app'),
      onTap: () async {
        final selected = await showDialog<Color>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seleccionar color'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: presetColors.length,
                itemBuilder: (context, index) {
                  final color = presetColors[index];
                  final isSelected = color.value == primaryColor.value;

                  return InkWell(
                    onTap: () => Navigator.pop(context, color),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );

        if (selected != null) {
          final colorHex = '#${selected.value.toRadixString(16).substring(2).toUpperCase()}';
          final action = ref.read(updatePrimaryColorActionProvider);
          await action(colorHex);
        }
      },
    );
  }
}
