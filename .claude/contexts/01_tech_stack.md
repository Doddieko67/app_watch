# 🏗️ Stack Tecnológico

## Core

- **Framework:** Flutter 3.x (última estable)
- **Lenguaje:** Dart 3.x
- **Arquitectura:** Clean Architecture + Feature-First
- **Gestión de estado:** Riverpod 2.x
- **Base de datos:** Drift (SQLite)
- **DI:** Riverpod (sin necesidad de get_it)

---

## Librerías Principales

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Estado y arquitectura
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Base de datos
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0

  # Notificaciones
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0

  # IA
  google_generative_ai: ^0.4.0
  image_picker: ^1.0.0

  # UI/UX
  fl_chart: ^0.66.0
  table_calendar: ^3.0.0
  flutter_animate: ^4.5.0
  flutter_slidable: ^3.0.0

  # Utilidades
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  intl: ^0.19.0

  # Exportación
  share_plus: ^7.2.0
  file_picker: ^6.1.0

  # Configuración
  shared_preferences: ^2.2.0

dev_dependencies:
  # Generación de código
  build_runner: ^2.4.0
  drift_dev: ^2.16.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0

  # Testing
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Comandos Útiles

```bash
# Generar código (Drift, Riverpod, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode para desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs

# Tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
dart format .

# Build para producción
flutter build apk --release
flutter build ios --release
```

---

## Referencias de Documentación

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)
- [Table Calendar](https://pub.dev/packages/table_calendar)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)
