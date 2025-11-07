import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class ApiKeyOnboardingWidget extends ConsumerStatefulWidget {
  const ApiKeyOnboardingWidget({super.key});

  @override
  ConsumerState<ApiKeyOnboardingWidget> createState() => _ApiKeyOnboardingWidgetState();
}

class _ApiKeyOnboardingWidgetState extends ConsumerState<ApiKeyOnboardingWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _obscureText = true;
  bool _isConfigured = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isConfigured ? Icons.check_circle : Icons.smart_toy,
          size: 80,
          color: _isConfigured
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 32),
        Text(
          'Análisis Nutricional con IA',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _isConfigured
              ? '¡API Key configurada! 🎉\n\nYa puedes usar análisis nutricional con Gemini AI.'
              : 'Configura tu API key de Gemini para usar análisis nutricional con IA.\n\nEsto es opcional y puedes configurarlo más tarde.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (!_isConfigured) ...[
          TextField(
            controller: _controller,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'API Key de Gemini (Opcional)',
              hintText: 'AIza...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Obtén tu API key gratuita en ai.google.dev',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final key = _controller.text.trim();
                if (key.isNotEmpty) {
                  try {
                    final saveAction = ref.read(saveApiKeyActionProvider);
                    await saveAction(key);

                    setState(() {
                      _isConfigured = true;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API Key guardada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar API Key'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isConfigured = true;
              });
            },
            child: const Text('Saltar (configurar más tarde)'),
          ),
        ],
        if (_isConfigured) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Puedes modificar tu API key en cualquier momento desde Ajustes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
