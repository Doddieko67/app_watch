# 📱 App Watch

> Aplicación móvil todo-en-uno para gestionar recordatorios, fitness, nutrición y sueño con IA integrada.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ✨ Características

- 🕒 **Recordatorios Inteligentes** - Notificaciones locales con recurrencia personalizable
- 💪 **Fitness Tracker** - Calendario de entrenamientos con gráficas de progreso
- 🍽️ **Nutrición con IA** - Análisis de alimentos con Gemini API + fallback offline
- 💤 **Sueño y Estudio** - Horarios optimizados y recomendaciones inteligentes
- 🎨 **Material 3** - Diseño moderno con tema personalizable
- 📱 **100% Offline** - Funciona sin conexión a internet
- 📊 **Exportación** - Backup completo de tus datos en JSON

---

## 🚀 Quick Start

### Requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) 3.x
- [Dart](https://dart.dev/get-dart) 3.x
- Android Studio / VS Code
- Android SDK / Xcode (para iOS)

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tuusuario/app_watch.git
cd app_watch

# 2. Instalar dependencias
flutter pub get

# 3. Generar código (Drift, Riverpod, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Ejecutar en emulador/dispositivo
flutter run
```

### Desarrollo

```bash
# Watch mode (regenera código automáticamente)
flutter pub run build_runner watch --delete-conflicting-outputs

# Ejecutar tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Formatear código
dart format .

# Analizar código
flutter analyze
```

### Build de Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🏗️ Arquitectura

```
lib/
├── core/                   # Funcionalidad compartida
│   ├── database/          # Drift (SQLite)
│   ├── services/          # Notificaciones, IA, Export
│   ├── theme/             # Material 3
│   └── providers/         # Riverpod providers
│
└── features/              # Módulos por feature
    ├── daily_reminders/   # Recordatorios
    ├── fitness/           # Entrenamientos
    ├── nutrition/         # Comidas y macros
    ├── sleep_study/       # Sueño y estudio
    └── settings/          # Configuración
```

**Stack:**
- 🏛️ Clean Architecture + Feature-First
- 🔄 Riverpod para state management
- 💾 Drift (SQLite) para base de datos
- 🔔 flutter_local_notifications
- 🤖 Gemini API para análisis de alimentos
- 📈 fl_chart para gráficas

---

## 📚 Documentación

Documentación técnica completa en `.claude/contexts/`:

- [Stack Tecnológico](.claude/contexts/01_tech_stack.md)
- [Arquitectura](.claude/contexts/02_architecture.md)
- [Base de Datos](.claude/contexts/03_database_schema.md)
- [Estrategia de IA](.claude/contexts/04_ai_strategy.md)
- [Notificaciones](.claude/contexts/05_notifications.md)
- [UI/UX](.claude/contexts/06_ui_design.md)
- [Testing](.claude/contexts/11_testing.md)
- [Seguridad](.claude/contexts/12_security.md)

Ver [CLAUDE.md](CLAUDE.md) para el índice completo.

---

## 🔑 Configuración de Gemini API (Opcional)

Para usar el análisis de alimentos con IA:

1. Obtén una API key gratuita en [ai.google.dev](https://ai.google.dev)
2. En la app, ve a **Ajustes → Configurar API Key**
3. Ingresa tu API key

> **Nota:** La app funciona 100% sin API key usando la base de datos local de alimentos.

---

## 🧪 Testing

```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widget

# Integration tests
flutter test integration_test/app_test.dart

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Meta de coverage:** >70%

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'feat: add amazing feature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

Ver [Convenciones de Código](.claude/contexts/10_conventions.md) para guías de estilo.

---

## 📊 Roadmap

### v1.0.0 (Actual)
- ✅ Recordatorios con notificaciones
- ✅ Fitness tracker con calendario
- ✅ Nutrición con IA (Gemini)
- ✅ Sueño y estudio
- ✅ Exportación/Importación de datos

### v1.1.0
- [ ] Sincronización en la nube
- [ ] Multi-idioma (inglés)
- [ ] Widgets para home screen

### v1.2.0
- [ ] Compartir entrenamientos
- [ ] Recetas con macros
- [ ] Integración con Google Fit / Apple Health

### v1.3.0
- [ ] Web app (Flutter Web)
- [ ] Desktop app (Windows/Mac/Linux)
- [ ] Estadísticas avanzadas con ML

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 👥 Autores

- **Tu Nombre** - [@tuusuario](https://github.com/tuusuario)

---

## 🙏 Agradecimientos

- [Flutter](https://flutter.dev) por el increíble framework
- [Drift](https://drift.simonbinder.eu) por la base de datos type-safe
- [Riverpod](https://riverpod.dev) por el excelente state management
- [Google Gemini](https://ai.google.dev) por la API de IA
- Comunidad de Flutter por las librerías y recursos

---

## 📞 Soporte

¿Tienes preguntas o problemas?

- 📧 Email: tu@email.com
- 🐛 Issues: [GitHub Issues](https://github.com/tuusuario/app_watch/issues)
- 💬 Discusiones: [GitHub Discussions](https://github.com/tuusuario/app_watch/discussions)

---

<div align="center">
  Hecho con ❤️ usando Flutter
</div>
