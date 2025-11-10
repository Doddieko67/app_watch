# 🎨 UI/UX y Diseño

## Material 3

### Tema con Color Personalizable

```dart
class AppTheme {
  static ThemeData getTheme(Color seedColor, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',

      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
```

### Colores Predefinidos

```dart
class AppColors {
  static const List<Color> themeColors = [
    Color(0xFF6750A4), // Purple (default)
    Color(0xFF0061A4), // Blue
    Color(0xFF006D3B), // Green
    Color(0xFF8B0000), // Red
    Color(0xFFFF6B00), // Orange
    Color(0xFF5F6368), // Gray
  ];

  static Color fromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
```

---

## Navegación

### Navegación Adaptativa

**Móviles pequeños:** Bottom Navigation Bar
**Tablets/Plegables:** Navigation Rail

```dart
class MainNavigationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Usar Navigation Rail en pantallas anchas
        if (constraints.maxWidth >= 640) {
          return Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  ref.read(navigationIndexProvider.notifier).state = index;
                },
                labelType: NavigationRailLabelType.all,
                destinations: _destinations,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _getScreen(selectedIndex)),
            ],
          );
        }

        // Usar Bottom Navigation Bar en móviles
        return Scaffold(
          body: _getScreen(selectedIndex),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            destinations: _destinations,
          ),
        );
      },
    );
  }

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt),
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
  ];

  Widget _getScreen(int index) {
    return switch (index) {
      0 => const RemindersHomeScreen(),
      1 => const FitnessHomeScreen(),
      2 => const NutritionHomeScreen(),
      3 => const SleepStudyHomeScreen(),
      4 => const SettingsScreen(),
      _ => const RemindersHomeScreen(),
    };
  }
}
```

---

## Tipografía

```dart
class AppTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
}
```

---

## Componentes Comunes

### Priority Badge

```dart
class PriorityBadge extends StatelessWidget {
  final int priority; // 1=baja, 2=media, 3=alta

  const PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      1 => (Colors.green, 'Baja'),
      2 => (Colors.orange, 'Media'),
      3 => (Colors.red, 'Alta'),
      _ => (Colors.grey, 'Sin prioridad'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
```

### Empty State

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Loading Overlay

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
```

---

## Animaciones

### Hero Animations

Para transiciones entre pantallas:

```dart
// En lista
Hero(
  tag: 'reminder_${reminder.id}',
  child: ReminderCard(reminder: reminder),
)

// En detalle
Hero(
  tag: 'reminder_${reminder.id}',
  child: ReminderDetailHeader(reminder: reminder),
)
```

### Animaciones con flutter_animate

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Fade in + slide up
child
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.2, end: 0);

// Lista con stagger
ListView.builder(
  itemBuilder: (context, index) {
    return ReminderCard(reminder: reminders[index])
      .animate()
      .fadeIn(delay: (100 * index).ms)
      .slideX(begin: 0.2);
  },
)

// Shake para errores
textField
  .animate(onComplete: (controller) => controller.reset())
  .shake(hz: 4, curve: Curves.easeInOutCubic);
```

### Swipe Actions con flutter_slidable

```dart
import 'package:flutter_slidable/flutter_slidable.dart';

// Swipe para completar/eliminar
Slidable(
  key: ValueKey(item.id),
  startActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => _toggleCompletion(),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: theme.colorScheme.onTertiary,
        icon: Icons.check,
        label: 'Completar',
      ),
    ],
  ),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => _deleteItem(),
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        icon: Icons.delete,
        label: 'Eliminar',
      ),
    ],
  ),
  child: ItemCard(item: item),
)
```

---

## Responsive Design

### Breakpoints

```dart
class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 1024;
  static const double desktop = 1440;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}
```

### Padding Adaptativo

```dart
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({required this.child});

  @override
  Widget build(BuildContext context) {
    final padding = Breakpoints.isMobile(context) ? 16.0 : 24.0;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}
```

---

## Gráficas (fl_chart)

### Line Chart para Progreso

```dart
class ProgressLineChart extends StatelessWidget {
  final List<DataPoint> dataPoints;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints.map((p) => FlSpot(p.x, p.y)).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
```

### Bar Chart para Macros

```dart
class MacrosBarChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          _makeBar(0, protein, Colors.red),
          _makeBar(1, carbs, Colors.green),
          _makeBar(2, fats, Colors.blue),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(['Proteína', 'Carbos', 'Grasas'][value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
        ),
      ],
    );
  }
}
```

---

## Dark Mode

### Detección Automática

```dart
final themeMode = ref.watch(themeModeProvider);

return MaterialApp(
  themeMode: themeMode, // ThemeMode.system, light, dark
  theme: AppTheme.getTheme(seedColor, Brightness.light),
  darkTheme: AppTheme.getTheme(seedColor, Brightness.dark),
);
```

---

## Accesibilidad

- **Semantics:** Agregar labels a todos los botones e imágenes
- **Contraste:** Usar colores con contraste mínimo AA (4.5:1)
- **Touch targets:** Mínimo 48x48 dp
- **Font scaling:** Respetar preferencias del sistema
- **Screen readers:** Testear con TalkBack/VoiceOver
