import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/settings/presentation/screens/onboarding_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final primaryColorAsync = ref.watch(primaryColorProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    final themeMode = themeModeAsync;
    final primaryColor = primaryColorAsync;

    return MaterialApp(
      title: 'App Watch',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      theme: AppTheme.lightTheme(primaryColor),
      darkTheme: AppTheme.darkTheme(primaryColor),
      themeMode: themeMode,
      // Show onboarding if not completed
      home: onboardingCompleted ? const MainNavigationScreen() : const OnboardingScreen(),
    );
  }
}
