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

### Fase Actual: **Fase 6.5 Completada ✅ - Listo para Fase 6.8 (Mejoras Funcionales)**

**Implementado:**

#### Fase 1 - Infraestructura Base
- ✅ Proyecto Flutter creado y compilando
- ✅ 13 tablas Drift con DAOs básicos (incluye SavedExercises, SavedWorkouts)
- ✅ Riverpod configurado (database + theme + notification providers)
- ✅ Material 3 Theme con colores personalizables
- ✅ Navegación adaptativa (Bottom Nav + Rail) - Solo iconos, sin labels
- ✅ Assets base (nutrition_database.json con 15 alimentos)
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
- ✅ Domain Layer completo (WorkoutEntity, ExerciseEntity, MuscleGroup enum, 4 use cases)
- ✅ Data Layer completo (mappers con JSON encoding, datasource, repository impl)
- ✅ Presentation Layer completo (20+ providers, screens, widgets)
- ✅ FitnessHomeScreen con estadísticas generales y menú de utilidades
- ✅ WorkoutDetailScreen con autocompletado de templates y edición inteligente
- ✅ CRUD de workouts y ejercicios con preservación de IDs
- ✅ Sistema de Grupos Musculares (12 grupos: chest, back, shoulders, biceps, triceps, forearms, abs, quads, hamstrings, glutes, calves, cardio)
- ✅ Selección múltiple de grupos musculares con emojis
- ✅ SavedWorkouts: Templates reutilizables con ejercicios completos
- ✅ WorkoutAutocompleteField: Carga automática de templates con ejercicios
- ✅ ExerciseAutocompleteField: Autocompletado de ejercicios guardados
- ✅ FitnessStatsScreen con 3 tabs (PRs, Frecuencia, Volumen semanal)
- ✅ SavedExercisesListScreen: Gestión completa de ejercicios guardados
- ✅ OneRMCalculator: Calculadora 1RM con fórmulas Epley y Brzycki
- ✅ WorkoutHistoryScreen con calendario y filtrado por fecha
- ✅ Cálculo de volumen, PRs, ejercicios frecuentes (con filtro de soft-delete)
- ✅ Integrado a navegación principal
- ✅ 23 archivos creados (~3,500+ líneas de código)

#### Fase 4 - Módulo de Nutrición (BÁSICO)
- ✅ Domain Layer completo (MealEntity, FoodItemEntity, NutritionGoalsEntity, 6 use cases)
- ✅ Data Layer completo (models, mappers, datasource, repository impl)
- ✅ AI Service con flujo de fallback preparado (Cache → Gemini → DB Local → Manual)
- ✅ LocalNutritionDatabase con búsqueda fuzzy (Levenshtein)
- ✅ Base de datos local con 15 alimentos de ejemplo
- ✅ Presentation Layer básico (providers, NutritionHomeScreen, LogMealScreen)
- ✅ CRUD básico de comidas y objetivos nutricionales
- ✅ Resumen nutricional diario con progress indicators
- ✅ Integrado a navegación principal
- ✅ 20+ archivos creados (~2,500+ líneas de código)
- ✅ APK debug generado exitosamente
- ✅ 0 errores de compilación críticos

#### Fase 5 - Módulo de Sueño y Estudio
- ✅ Domain Layer completo (SleepRecordEntity, StudySessionEntity, SleepScheduleEntity)
- ✅ Repository interface con métodos para estadísticas (SleepStats, StudyStats)
- ✅ 5 use cases (ConfigureSleepSchedule, LogSleepRecord, LogStudySession, CalculateOptimalStudyTime, GetSleepStats)
- ✅ Data Layer completo (models, mappers, datasource, repository impl)
- ✅ SleepStudyLocalDataSource con CRUD completo y cálculo de estadísticas
- ✅ Presentation Layer (13+ providers, SleepStudyHomeScreen, SleepConfigScreen)
- ✅ Configuración de horario de sueño con notificaciones
- ✅ Registro de sueño planificado vs real con métricas
- ✅ Sistema de sesiones de estudio con cronómetro
- ✅ Cálculo de hora óptima de estudio (2.5h después de despertar)
- ✅ Estadísticas semanales de sueño y estudio
- ✅ Integrado a navegación principal
- ✅ 16 archivos creados (~2,400+ líneas de código)
- ✅ APK debug generado exitosamente
- ✅ 0 errores de compilación

#### Fase 6 - Settings, Onboarding y Exportación
- ✅ Domain Layer completo (AppSettingsEntity, repository, 3 use cases)
- ✅ Data Layer completo (models, mappers, datasource, repository impl)
- ✅ Core Services (ExportImportService, SecureStorageService)
- ✅ SettingsScreen completo con todas las secciones:
  - Configuración de tema (light/dark/system)
  - Selector de color primario personalizable
  - Gestión segura de API key de Gemini (flutter_secure_storage)
  - Configuración de auto-backup
  - Exportación/Importación de datos JSON
  - Gestión de permisos y notificaciones
- ✅ OnboardingScreen de 3 pantallas con introducción a la app
- ✅ AboutScreen con información de versión y enlaces
- ✅ 5 widgets especializados (ThemeModeSelector, ColorPicker, ApiKeyConfig, etc.)
- ✅ Sistema de exportación completo con compartir vía Share API
- ✅ Sistema de importación con validación de datos
- ✅ Integrado a navegación principal
- ✅ 24 archivos creados (~3,400+ líneas de código)
- ✅ APK debug generado exitosamente
- ✅ 0 errores de compilación

#### Fase 6.5 - Completando Funcionalidades Pre-Release
- ✅ Home Dashboard completo con 4 summary cards:
  - RemindersSummaryCard (recordatorios de hoy + pendientes + próximos 2)
  - FitnessSummaryCard (workouts de hoy + stats generales)
  - NutritionSummaryCard (calorías y macros del día con progress)
  - SleepStudySummaryCard (calidad de sueño + minutos estudiados)
- ✅ MealDetailScreen con visualización completa de comidas:
  - Breakdown nutricional detallado (calorías, proteína, carbos, grasas)
  - Lista de alimentos con cantidades
  - Funcionalidad de eliminar comida
  - Navegación desde NutritionHomeScreen
- ✅ LogSleepRecordScreen - Formulario completo de registro de sueño:
  - Selectores de fecha y hora (dormir/despertar)
  - Sistema de calificación con estrellas (1-5)
  - Validación de datos (despertar después de dormir)
  - Action provider para crear y registrar en un solo paso
  - Muestra horario planificado vs real
- ✅ StudySessionScreen - Sesión de estudio con cronómetro:
  - Timer con play/pause/reset (formato HH:MM:SS o MM:SS)
  - Campos de materia y notas opcionales
  - Validación de duración mínima (60 segundos)
  - Diálogo de confirmación con resumen de tiempo
  - Integración con LogStudySession use case
  - Navegación para iniciar o continuar sesión
- ✅ NutritionChartsScreen - Gráficas de nutrición (fl_chart):
  - LineChart de calorías semanales con gradiente
  - PieChart de distribución de macros (% proteína/carbos/grasas)
  - BarChart de comparación de comidas por tipo
  - Empty states y manejo de errores
  - Navegación desde NutritionHomeScreen (botón insights)
- ✅ SleepStudyChartsScreen - Gráficas de sueño y estudio:
  - TabBar con 2 tabs (Sueño / Estudio)
  - Sleep: LineChart horas (planeado vs real), BarChart calidad (color-coded)
  - Study: BarChart tiempo diario, PieChart distribución por materia
  - Tarjetas de estadísticas semanales (promedio, calidad, sesiones, etc.)
  - Navegación desde SleepStudyHomeScreen (botón insights)
- ✅ WorkoutHistoryScreen - Historial con calendario:
  - Integración con table_calendar (vista mes/semana/2 semanas)
  - Marcadores en días con entrenamientos
  - Lista de workouts filtrada por fecha seleccionada
  - Cards con muscle groups (emojis), duración, ejercicios, volumen
  - Navegación a WorkoutDetailScreen para editar
  - Navegación desde FitnessHomeScreen (botón history)
- ✅ NavigationService - Infraestructura de navegación global:
  - Global navigator key para acceso desde servicios
  - Parsing de payloads de notificaciones ("type:id")
  - Base preparada para deep linking futuro
  - Manejo de taps en notificaciones con debug logs
- ✅ Correcciones y ajustes de propiedades de entidades
- ✅ 11 archivos nuevos creados (~3,500+ líneas de código)
- ✅ 7 commits exitosos con APK debug generado en cada uno
- ✅ 0 errores de compilación

#### Fase 6.8 - Mejoras Funcionales UX (COMPLETADA ✅)
- ✅ **FITNESS - Sistema de Templates Completo:**
  - Tabla SavedWorkouts para guardar plantillas de entrenamientos
  - WorkoutAutocompleteField con carga de templates
  - Replicación completa de ejercicios al seleccionar template
  - Sistema de Grupos Musculares (reemplaza Splits)
  - MuscleGroupSelector con 12 grupos y emojis
  - ExerciseAutocompleteField para ejercicios guardados
  - Edición inteligente de ejercicios (preserva IDs, no destructiva)
  - FitnessStatsScreen con 3 tabs (PRs, Frecuencia, Volumen)
  - SavedExercisesListScreen con CRUD completo
  - OneRMCalculator profesional (Epley + Brzycki)
  - Contador de uso de templates
- ✅ **NUTRITION - Optimizaciones:**
  - Eliminado loading innecesario al cambiar de día
  - FoodAutocompleteField para alimentos guardados
  - Sistema de alimentos frecuentes
- ✅ **NAVIGATION - Simplificación:**
  - Barra de navegación solo con iconos (sin labels)
  - Iconos más grandes para mejor UX táctil
- ✅ 10 archivos nuevos creados (~2,000+ líneas de código)
- ✅ Schema v2 → v4 (migraciones de SavedExercises y SavedWorkouts)
- ✅ 3 commits exitosos con APK debug generado
- ✅ 0 errores de compilación

**Total archivos:** ~130 archivos (~20,500+ líneas de código)

### Próximos Pasos

**Fase 7.0: Pulido Técnico** (ACTUAL)
- Animaciones con flutter_animate
- Optimización de performance (DB, paginación, lazy loading)
- Manejo robusto de errores
- Optimización y limpieza de base de datos

**Fase 7.5: Preparación para Release** (Segunda mitad Semana 7)
- Testing completo (unit, widget, integration - 80%+ coverage)
- Documentación final (README, ARCHITECTURE, CONTRIBUTING)
- Configuración de release (icons, splash, signing)
- Preparación para stores (screenshots, descripciones)

**Post-Release: Mejoras UI/UX** (Futuro)
- Rediseño completo con Brutalist Dark UI
- Tipografía bold y amigable (estilo Duolingo)
- Temas predefinidos (Sakura, Capuccino, Tokyo Night)
- Widgets más grandes, más iconos, menos texto
- Ver NOTITAS.md para detalles completos

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

**Última actualización:** 2025-11-08
**Versión de documentación:** 6.5.1 (Fase 6.5 completada - Todas las funcionalidades implementadas)
