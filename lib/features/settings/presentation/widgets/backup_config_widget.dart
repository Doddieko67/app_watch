import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/settings_providers.dart';

class BackupConfigWidget extends ConsumerWidget {
  const BackupConfigWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final lastBackupText = settings.lastBackupDate != null
            ? 'Último backup: ${DateFormat('dd/MM/yyyy HH:mm').format(settings.lastBackupDate!)}'
            : 'Nunca se ha creado un backup';

        return ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Auto-backup'),
          subtitle: Text(
            '${_getFrequencyLabel(settings.backupFrequency)}\n$lastBackupText',
          ),
          onTap: () async {
            final selected = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Frecuencia de backup automático'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Nunca'),
                      subtitle: const Text('Solo backup manual'),
                      value: 'never',
                      groupValue: settings.backupFrequency,
                      onChanged: (value) => Navigator.pop(context, value),
                    ),
                    RadioListTile<String>(
                      title: const Text('Diario'),
                      subtitle: const Text('Backup automático cada día'),
                      value: 'daily',
                      groupValue: settings.backupFrequency,
                      onChanged: (value) => Navigator.pop(context, value),
                    ),
                    RadioListTile<String>(
                      title: const Text('Semanal'),
                      subtitle: const Text('Backup automático cada semana'),
                      value: 'weekly',
                      groupValue: settings.backupFrequency,
                      onChanged: (value) => Navigator.pop(context, value),
                    ),
                  ],
                ),
              ),
            );

            if (selected != null) {
              final action = ref.read(updateBackupFrequencyActionProvider);
              await action(selected);
            }
          },
        );
      },
      loading: () => const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Cargando...'),
      ),
      error: (_, __) => const ListTile(
        leading: Icon(Icons.error),
        title: Text('Error al cargar configuración'),
      ),
    );
  }

  String _getFrequencyLabel(String frequency) {
    return switch (frequency) {
      'never' => 'Nunca',
      'daily' => 'Diario',
      'weekly' => 'Semanal',
      _ => 'Desconocido',
    };
  }
}
