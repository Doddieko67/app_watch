import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Tema'),
      subtitle: Text(_getThemeModeLabel(themeMode)),
      onTap: () async {
        final selected = await showDialog<ThemeMode>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seleccionar tema'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Oscuro'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Sistema'),
                  subtitle: const Text('Seguir el tema del sistema'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              ],
            ),
          ),
        );

        if (selected != null) {
          final action = ref.read(updateThemeModeActionProvider);
          await action(selected);
        }
      },
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
      ThemeMode.system => 'Sistema',
    };
  }
}
