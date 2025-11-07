# 📱 App Watch - Documentación del Proyecto

## 🎯 Visión General

**App Watch** es una aplicación móvil multiplataforma (Android/iOS) tipo "Microsoft To Do" mejorada con tracking avanzado de:
- 🕒 **Recordatorios diarios inteligentes** con notificaciones
- 💪 **Fitness tracker** con calendario y gráficas de progreso
- 🍽️ **Nutrición** con análisis de alimentos por IA (Gemini)
- 💤 **Sueño y estudio** con recomendaciones inteligentes

**Características clave:**
- 100% local, funciona sin internet
- IA con fallback offline (Gemini API + cache + DB local)
- Material 3 con color personalizable
- Arquitectura escalable preparada para sincronización en la nube
- Clean Architecture + Riverpod + Drift

---

## 📚 Documentación Técnica

La documentación completa está organizada en módulos en `.claude/contexts/`:

### 🏗️ Core

1. **[Stack Tecnológico](.claude/contexts/01_tech_stack.md)**
   - Librerías y dependencias
   - Comandos útiles
   - Referencias de documentación

2. **[Arquitectura](.claude/contexts/02_architecture.md)**
   - Estructura de carpetas completa
   - Clean Architecture + Feature-First
   - Flujo de datos

3. **[Esquemas de Base de Datos](.claude/contexts/03_database_schema.md)**
   - 9 tablas Drift con relaciones
   - Campos de sincronización futura
   - Índices y migraciones

### 🚀 Funcionalidad

4. **[Estrategia de IA](.claude/contexts/04_ai_strategy.md)**
   - Flujo de análisis de alimentos (Cache → Gemini → DB Local → Manual)
   - Prompts optimizados para Gemini
   - Base de datos local de 500 alimentos
   - Sistema de cache inteligente

5. **[Notificaciones](.claude/contexts/05_notifications.md)**
   - 4 tipos de notificaciones (recordatorios, sueño, estudio, comidas)
   - Configuración de canales Android/iOS
   - Scheduling y reprogramación automática

6. **[UI/UX y Diseño](.claude/contexts/06_ui_design.md)**
   - Material 3 con tema personalizable
   - Navegación adaptativa (Bottom Nav + Rail)
   - Componentes reutilizables
   - Animaciones con flutter_animate

7. **[Exportación e Importación](.claude/contexts/07_export_import.md)**
   - Formato JSON completo
   - Backup automático configurable
   - Compartir con Share API
   - Validación de importación

8. **[Estrategia de Sincronización](.claude/contexts/08_sync_strategy.md)**
   - Preparación para sincronización en la nube
   - Local-first con soft deletes
   - Resolución de conflictos
   - Endpoints de API futuros

### 🛠️ Desarrollo

9. **[Plan de Implementación](.claude/contexts/09_implementation_plan.md)**
   - 7 fases semanales con tareas detalladas
   - Checklist de cada módulo
   - Checklist final antes de release
   - Roadmap futuro (v1.1, v1.2, v1.3)

10. **[Convenciones de Código](.claude/contexts/10_conventions.md)**
    - Nomenclatura y formateo
    - Organización de imports
    - Uso de Freezed y Riverpod
    - Manejo de null safety
    - Control de versiones (Git)

11. **[Testing](.claude/contexts/11_testing.md)**
    - Unit tests, Widget tests, Integration tests
    - Mocks con Mockito
    - Coverage (meta: >70%)
    - CI/CD con GitHub Actions

12. **[Seguridad](.claude/contexts/12_security.md)**
    - Almacenamiento seguro de API keys
    - Validación de inputs
    - Permisos mínimos
    - Exportación con advertencias de privacidad
    - Checklist de seguridad

---

## 🚀 Quick Start

### Requisitos
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Android SDK / Xcode

### Instalación

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd app_watch

# 2. Instalar dependencias
flutter pub get

# 3. Generar código (Drift, Riverpod, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Ejecutar en emulador/dispositivo
flutter run
```

### Comandos Frecuentes

```bash
# Agregar nuevas dependencias (SIEMPRE usar esto en lugar de editar pubspec.yaml manualmente)
flutter pub add nombre_libreria
flutter pub add nombre_libreria --dev  # Para dev_dependencies

# Watch mode para desarrollo (regenera automáticamente)
flutter pub run build_runner watch

# Ejecutar tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Formatear código
dart format .

# Analizar código
flutter analyze

# Build de release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

> **⚠️ IMPORTANTE:** Para agregar nuevas librerías, **SIEMPRE** usa `flutter pub add` en lugar de editar `pubspec.yaml` manualmente. Esto garantiza compatibilidad de versiones automáticamente.

### ✅ Verificación de Código

**Protocolo de verificación antes de commit:**

```bash
# 1. Analizar código (busca errores estáticos)
flutter analyze

# 2. Si analyze es exitoso, construir APK debug para verificar completamente
flutter build apk --debug

# 3. Si ambos pasan, el código está listo para commit
```

> **💡 RECOMENDACIÓN:** Aunque `flutter analyze` no muestre errores, siempre ejecuta `flutter build apk --debug` antes de hacer commit. El build puede detectar errores que el análisis estático no encuentra (imports conflictivos, problemas de generación de código, etc.).

---

## 📂 Estructura del Proyecto

```
app_watch/
├── .claude/
│   ├── contexts/           # Documentación modular
│   └── agents/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/               # Database, services, theme, utils
│   └── features/           # Módulos por feature
│       ├── daily_reminders/
│       ├── fitness/
│       ├── nutrition/
│       ├── sleep_study/
│       ├── settings/
│       └── home/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── assets/
│   ├── images/
│   ├── icons/
│   └── nutrition_database.json
├── pubspec.yaml
└── README.md
```

---

## 🎯 Estado Actual

### Fase Actual: **Fase 3 Completada ✅ - Listo para Fase 4**

**Implementado:**

#### Fase 1 - Infraestructura Base
- ✅ Proyecto Flutter creado y compilando
- ✅ 11 tablas Drift con DAOs básicos
- ✅ Riverpod configurado (database + theme + notification providers)
- ✅ Material 3 Theme con colores personalizables
- ✅ Navegación adaptativa (Bottom Nav + Rail)
- ✅ Assets base (nutrition_database.json con 5 alimentos)
- ✅ analysis_options.yaml con lints estrictos
- ✅ Estructura completa de carpetas (Clean Architecture)

#### Fase 2 - Módulo de Recordatorios
- ✅ Domain Layer completo (entities, repositories, use cases)
- ✅ Data Layer completo (local datasource, repository impl, mappers)
- ✅ Presentation Layer completo (providers, screens, widgets)
- ✅ Sistema de notificaciones locales integrado
- ✅ CRUD completo con recurrencias (diaria/semanal/custom)
- ✅ Prioridades, tags y filtros funcionales
- ✅ Integrado a navegación principal
- ✅ 23 archivos creados (~2,500+ líneas de código)

#### Fase 3 - Módulo de Fitness Tracker
- ✅ Domain Layer completo (WorkoutEntity, ExerciseEntity, 4 use cases)
- ✅ Data Layer completo (mappers, datasource, repository impl)
- ✅ Presentation Layer completo (15+ providers, screens, widgets)
- ✅ FitnessHomeScreen con estadísticas generales
- ✅ WorkoutDetailScreen para crear/editar entrenamientos
- ✅ CRUD de workouts y ejercicios
- ✅ 7 tipos de splits (Push/Pull/Legs/Upper/Lower/Full/Custom)
- ✅ Cálculo de volumen, PRs, ejercicios frecuentes
- ✅ Integrado a navegación principal
- ✅ 15 archivos creados (~2,000+ líneas de código)
- ✅ APK debug generado exitosamente
- ✅ 0 errores de compilación

**Total archivos:** 38 archivos (~4,500+ líneas de código)

### Próximos Pasos

**Fase 4: Módulo de Nutrición** (Semana 4)
1. Implementar domain/data/presentation layers
2. Integración con Gemini AI para análisis de alimentos
3. Sistema de fallback (Cache → Gemini → DB Local → Manual)
4. Tracking de comidas y macros diarios
5. Gráficas de nutrición con fl_chart

Ver detalles completos en [Plan de Implementación](.claude/contexts/09_implementation_plan.md).

---

## 🤝 Contribuir

### Flujo de Trabajo

1. Leer documentación relevante en `.claude/contexts/`
2. Crear branch desde `develop`: `feature/nombre-feature`
3. Seguir convenciones en [Convenciones de Código](.claude/contexts/10_conventions.md)
4. Escribir tests (ver [Testing](.claude/contexts/11_testing.md))
5. Crear Pull Request a `develop`

### Commits

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: agregar análisis de alimentos con IA
fix: corregir crash al eliminar recordatorio
docs: actualizar documentación de API
test: agregar tests para FitnessRepository
refactor: extraer lógica de notificaciones
chore: actualizar dependencias
```

---

## 📖 Recursos Adicionales

### Documentación Externa
- [Flutter Documentation](https://docs.flutter.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Gemini API Documentation](https://ai.google.dev/docs)

### Librerías Principales
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [table_calendar](https://pub.dev/packages/table_calendar)
- [flutter_animate](https://pub.dev/packages/flutter_animate)

---

## 📊 Métricas de Éxito

- ⚡ Inicio de app: <2 segundos
- 💾 Soporte para 10,000+ registros
- 🔔 Confiabilidad de notificaciones: 99.9%
- 🤖 Análisis de IA: <3 segundos (online)
- 📱 Funcionalidad offline: 100%
- 🎨 Rendimiento: 60 FPS constante
- 🧪 Coverage de tests: >70%

---

## 📝 Notas

### Decisiones de Arquitectura

- **Riverpod sobre BLoC:** Menos boilerplate, más flexible
- **Drift sobre Sqflite:** Type-safe, mejor DX
- **Gemini sobre modelos locales:** Balance precisión/privacidad con fallback
- **Feature-First:** Facilita escalabilidad y mantenimiento
- **Soft Deletes:** Preparación para sync y recuperación de datos

### Próximas Versiones

**v1.1.0:** Sincronización en la nube
**v1.2.0:** Compartir entrenamientos, recetas
**v1.3.0:** Web app, desktop app, ML avanzado

Ver [Roadmap](.claude/contexts/09_implementation_plan.md#post-release-roadmap-futuro).

---

## 📄 Licencia

[Por definir]

---

## 👥 Equipo

[Por definir]

---

**Última actualización:** 2025-11-06
**Versión de documentación:** 3.0.0 (Fase 3 completada - Fitness Tracker)
