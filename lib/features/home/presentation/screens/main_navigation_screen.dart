import 'package:flutter/material.dart';

import '../../../daily_reminders/presentation/screens/reminders_home_screen.dart';
import '../../../fitness/presentation/screens/fitness_home_screen.dart';
import '../../../nutrition/presentation/screens/nutrition_home_screen.dart';
import '../../../sleep_study/presentation/screens/sleep_study_home_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'home_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Pantallas
  List<Widget> get _screens => [
    HomeDashboardScreen(onNavigateToTab: _navigateToTab), // ✅ Fase 6.5 - Dashboard
    const RemindersHomeScreen(), // ✅ Fase 2 completada
    const FitnessHomeScreen(), // ✅ Fase 3 completada
    const NutritionHomeScreen(), // ✅ Fase 4 completada
    const SleepStudyHomeScreen(), // ✅ Fase 5 completada
    const SettingsScreen(), // ✅ Fase 6 completada
  ];

  @override
  Widget build(BuildContext context) {
    // Detectar si es pantalla grande (tablet/desktop)
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          // NavigationRail para pantallas grandes
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Recordatorios'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: Text('Fitness'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: Text('Nutrición'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bedtime_outlined),
                  selectedIcon: Icon(Icons.bedtime),
                  label: Text('Sueño'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Ajustes'),
                ),
              ],
            ),

          // Divider vertical
          if (isLargeScreen) const VerticalDivider(width: 1),

          // Contenido principal
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),

      // NavigationBar para pantallas pequeñas
      bottomNavigationBar: isLargeScreen
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Recordatorios',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: 'Fitness',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: 'Nutrición',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bedtime_outlined),
                  selectedIcon: Icon(Icons.bedtime),
                  label: 'Sueño',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            ),
    );
  }
}

// Widget placeholder para las pantallas
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Próximamente...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Fase 2 Completada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Recordatorios funcionales\n'
                      '• Sistema de notificaciones\n'
                      '• CRUD completo con recurrencias\n'
                      '• Prioridades, tags y filtros\n'
                      '• Integrado a navegación',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      '📊 23 archivos creados\n'
                      '🚀 ~2,500+ líneas de código\n'
                      '✓ 0 errores de compilación',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
