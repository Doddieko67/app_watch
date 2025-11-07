import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.watch,
                    size: 60,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'App Watch',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (_packageInfo != null)
                  Text(
                    'Versión ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acerca de la app',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'App Watch es tu asistente personal para gestionar recordatorios, '
                    'entrenamientos, nutrición, sueño y estudio. Todo en un solo lugar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Características',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeature(
                    context,
                    Icons.task_alt,
                    'Recordatorios inteligentes',
                    'Gestiona tareas con recurrencias personalizadas',
                  ),
                  _buildFeature(
                    context,
                    Icons.fitness_center,
                    'Fitness Tracker',
                    'Registra entrenamientos y visualiza tu progreso',
                  ),
                  _buildFeature(
                    context,
                    Icons.restaurant,
                    'Nutrición con IA',
                    'Analiza alimentos con inteligencia artificial',
                  ),
                  _buildFeature(
                    context,
                    Icons.bedtime,
                    'Sueño y Estudio',
                    'Optimiza tu descanso y sesiones de estudio',
                  ),
                  _buildFeature(
                    context,
                    Icons.cloud_off,
                    '100% Offline',
                    'Todos tus datos están en tu dispositivo',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tech Stack
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tecnologías',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildTechItem(context, 'Flutter', 'UI Framework'),
                  _buildTechItem(context, 'Riverpod', 'State Management'),
                  _buildTechItem(context, 'Drift', 'Local Database'),
                  _buildTechItem(context, 'Gemini AI', 'Análisis nutricional'),
                  _buildTechItem(context, 'Material 3', 'Design System'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Links
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Código fuente'),
                  subtitle: const Text('GitHub'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('https://github.com'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Reportar un problema'),
                  subtitle: const Text('GitHub Issues'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('https://github.com'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Política de privacidad'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Credits
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créditos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desarrollado con ❤️ usando Flutter\n'
                    '© 2025 App Watch\n\n'
                    'Todos los derechos reservados.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(BuildContext context, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Text(' • '),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'App Watch respeta tu privacidad:\n\n'
            '• Todos tus datos se almacenan localmente en tu dispositivo\n'
            '• No recopilamos ni compartimos información personal\n'
            '• Tu API key de Gemini se almacena de forma segura\n'
            '• No enviamos datos a servidores externos\n'
            '• No hay seguimiento ni análisis de usuario\n\n'
            'Los únicos datos que salen de tu dispositivo son:\n'
            '• Consultas a Gemini AI (solo si configuras tu API key)\n'
            '• Backups que tú mismo exportes\n\n'
            'Tienes control total sobre tus datos.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
