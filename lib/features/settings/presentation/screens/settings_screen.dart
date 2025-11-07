import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/settings_providers.dart';
import '../widgets/theme_mode_selector.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/api_key_config_widget.dart';
import '../widgets/backup_config_widget.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Apariencia'),
            const ThemeModeSelector(),
            const Divider(),
            const ColorPickerWidget(),

            const SizedBox(height: 16),

            // AI Configuration
            _buildSectionHeader(context, 'Inteligencia Artificial'),
            const ApiKeyConfigWidget(),

            const SizedBox(height: 16),

            // Backup & Data
            _buildSectionHeader(context, 'Respaldo y Datos'),
            const BackupConfigWidget(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Exportar datos'),
              subtitle: const Text('Crear backup de todos tus datos'),
              onTap: () => _exportData(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Importar datos'),
              subtitle: const Text('Restaurar desde un backup'),
              onTap: () => _importData(context, ref),
            ),

            const SizedBox(height: 16),

            // Notifications
            _buildSectionHeader(context, 'Notificaciones'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              subtitle: const Text('Permitir notificaciones de la app'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                final action = ref.read(updateNotificationsEnabledActionProvider);
                action(value);
              },
            ),

            const SizedBox(height: 16),

            // About
            _buildSectionHeader(context, 'Acerca de'),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de App Watch'),
              subtitle: const Text('Versión, licencia y créditos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Danger Zone
            _buildSectionHeader(context, 'Zona de Peligro', color: Colors.red),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.red),
              title: const Text('Restablecer ajustes', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Volver a la configuración predeterminada'),
              onTap: () => _resetSettings(context, ref),
            ),

            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar datos'),
        content: const Text(
          '⚠️ Advertencia de Privacidad\n\n'
          'El backup contendrá toda tu información personal:\n'
          '• Recordatorios y tareas\n'
          '• Entrenamientos y ejercicios\n'
          '• Comidas y datos nutricionales\n'
          '• Registros de sueño y estudio\n\n'
          'NO compartas este archivo públicamente.\n'
          'NO se incluirá tu API key de Gemini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entiendo, Exportar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final service = ref.read(exportImportServiceProvider);
        await service.shareExport();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup exportado exitosamente')),
          );

          // Update last backup date
          final repository = ref.read(settingsRepositoryProvider);
          await repository.updateLastBackupDate(DateTime.now());
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al exportar: $e')),
          );
        }
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null && context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Importar datos'),
            content: const Text(
              '¿Estás seguro de que deseas importar este backup?\n\n'
              'Esto agregará los datos al contenido existente.\n'
              'No se eliminarán datos actuales.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Importar'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          final service = ref.read(exportImportServiceProvider);
          final importResult = await service.importFromFile(result.files.single.path!);

          if (context.mounted) {
            if (importResult.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Importados ${importResult.itemsImported} elementos'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${importResult.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }

  Future<void> _resetSettings(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer ajustes'),
        content: const Text(
          '¿Estás seguro de que deseas restablecer todos los ajustes?\n\n'
          'Esto restaurará la configuración predeterminada de la app.\n'
          'Tus datos (recordatorios, entrenamientos, etc.) NO serán eliminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final repository = ref.read(settingsRepositoryProvider);
        await repository.resetToDefaults();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajustes restablecidos')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
