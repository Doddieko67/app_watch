import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class ApiKeyConfigWidget extends ConsumerWidget {
  const ApiKeyConfigWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasApiKeyAsync = ref.watch(hasApiKeyProvider);

    return hasApiKeyAsync.when(
      data: (hasKey) => ListTile(
        leading: Icon(
          hasKey ? Icons.key : Icons.key_off,
          color: hasKey ? Colors.green : null,
        ),
        title: const Text('API Key de Gemini'),
        subtitle: Text(
          hasKey
              ? 'Configurada ✓ - Tap para editar o eliminar'
              : 'No configurada - Análisis nutricional con IA deshabilitado',
        ),
        trailing: hasKey ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: () => _showApiKeyDialog(context, ref, hasKey),
      ),
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

  Future<void> _showApiKeyDialog(BuildContext context, WidgetRef ref, bool hasKey) async {
    if (hasKey) {
      // Show options: view masked, edit, or delete
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key de Gemini'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu API key está configurada y segura.'),
              const SizedBox(height: 16),
              const Text(
                'Opciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'edit'),
              child: const Text('Editar'),
            ),
          ],
        ),
      );

      if (action == 'delete' && context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar API Key'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu API key?\n\n'
              'El análisis nutricional con IA dejará de funcionar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          final deleteAction = ref.read(deleteApiKeyActionProvider);
          await deleteAction();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('API Key eliminada')),
            );
          }
        }
      } else if (action == 'edit' && context.mounted) {
        await _showEditApiKeyDialog(context, ref);
      }
    } else {
      // Show input dialog to add API key
      await _showEditApiKeyDialog(context, ref);
    }
  }

  Future<void> _showEditApiKeyDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final obscureText = ValueNotifier<bool>(true);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar API Key de Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obtén tu API key gratuita en:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            SelectableText(
              'https://ai.google.dev',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: obscureText,
              builder: (context, obscure, _) {
                return TextField(
                  controller: controller,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'AIza...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        obscureText.value = !obscureText.value;
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tu API key se almacenará de forma segura en tu dispositivo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final key = controller.text.trim();
              Navigator.pop(context, key);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      try {
        final saveAction = ref.read(saveApiKeyActionProvider);
        await saveAction(result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API Key guardada exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
          );
        }
      }
    }

    controller.dispose();
    obscureText.dispose();
  }
}
