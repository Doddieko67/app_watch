import 'package:flutter/material.dart';

/// Servicio de navegación global para navegar desde fuera del árbol de widgets
/// (por ejemplo, desde notificaciones)
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navegar a una ruta por nombre
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navegar usando un widget
  Future<dynamic>? navigateToWidget(Widget widget) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => widget),
    );
  }

  /// Navegar y reemplazar la ruta actual
  Future<dynamic>? navigateToAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Ir atrás
  void goBack() {
    return navigatorKey.currentState?.pop();
  }

  /// Obtener el contexto actual del navigator
  BuildContext? get context => navigatorKey.currentContext;
}
