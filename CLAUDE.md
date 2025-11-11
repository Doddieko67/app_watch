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
   - Prompts optimizados para Gemini (Gemini 2.5 Flash)
   - Base de datos local de alimentos
   - Sistema de cache inteligente
   - Ver también: [Fix de Gemini AI](.claude/contexts/13_nutrition_ai_fix.md)

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

### 📝 Mejoras y Cambios Recientes

13. **[Fix de Gemini AI](.claude/contexts/13_nutrition_ai_fix.md)**
    - Bug crítico de GenerationConfig resuelto
    - Actualización a Gemini 2.5 Flash
    - Análisis proporcional de alimentos
    - Scripts de testing (test_gemini.dart)

14. **[Mejoras del Módulo de Nutrición](.claude/contexts/14_nutrition_improvements.md)**
    - Sistema de autocompletado de alimentos
    - Agregar múltiples alimentos rápidamente
    - Edición de alimentos individuales
    - Alimentos clickeables con edición
    - Métricas de mejora UX

15. **[Changelog de Versiones](.claude/contexts/15_changelog.md)**
    - Registro detallado de todas las fases completadas
    - Historial de features implementados
    - Roadmap de próximas versiones

16. **[Limitación de Imágenes en Gemini](.claude/contexts/16_gemini_image_limitation.md)**
    - Bug conocido en análisis de imágenes
    - Investigación completa del problema
    - Estado actual y plan de acción

17. **[Plan de Migración a firebase_ai](.claude/contexts/17_firebase_ai_migration_plan.md)**
    - Comparación detallada de SDKs
    - Plan de migración en 4 fases (2-3 horas)
    - Checklist completa y análisis de riesgos

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

### Fase Actual: **Fase 6.11 Completada ✅ - Investigación y Documentación de IA**

**Resumen:**
Investigación completa del bug de análisis de imágenes en Gemini. Se identificó la causa raíz (SDK deprecated), se documentó exhaustivamente el problema, y se creó un plan detallado de migración a `firebase_ai` para resolverlo en el futuro.

**Estado del análisis de IA:**
- ✅ Análisis de texto: Funciona perfectamente
- ⚠️ Análisis de imágenes: Bloqueado por bug del SDK (documentado)
- ✅ Plan de migración: Listo para ejecutar cuando se disponga de tiempo

**Para ver el estado completo y detallado de todas las fases:** Ver **[Changelog de Versiones](.claude/contexts/15_changelog.md)**

**Fases completadas brevemente:**

- ✅ **Fase 1:** Infraestructura Base (13 tablas Drift, Riverpod, Material 3, Clean Architecture)
- ✅ **Fase 2:** Módulo de Recordatorios (CRUD completo, notificaciones, recurrencias, swipe actions, búsqueda)
- ✅ **Fase 3:** Módulo de Fitness (Workouts, ejercicios, templates, grupos musculares, estadísticas, calendario)
- ✅ **Fase 4:** Módulo de Nutrición Básico (Comidas, análisis IA, objetivos, resumen diario)
- ✅ **Fase 5:** Módulo de Sueño y Estudio (Horarios, registro, cronómetro, estadísticas)
- ✅ **Fase 6:** Settings y Exportación (Temas, API keys, import/export, onboarding)
- ✅ **Fase 6.5:** Dashboard y Gráficas (4 summary cards, charts con fl_chart, calendario)
- ✅ **Fase 6.8:** Mejoras UX Fitness/Nutrition (Templates, autocompletado, optimizaciones)
- ✅ **Fase 6.9:** Calendario de Recordatorios y Localizaciones (Historial, fecha inicio, español)
- ✅ **Fase 6.10:** Mejoras Nutrición (Fix Gemini AI, autocompletado, edición granular, múltiples alimentos)
- ✅ **Fase 6.11:** Investigación y Documentación de IA (Bug de imágenes, plan de migración a firebase_ai)

**Total:** ~135 archivos, ~22,500+ líneas de código, Schema v6, 28+ commits

📊 **Ver detalles completos:** [Changelog de Versiones](.claude/contexts/15_changelog.md)

### Próximos Pasos

**Fase 7.0: Pulido Técnico** (Parcialmente completado)
- ✅ Mejoras UX de Recordatorios completadas (swipe actions, búsqueda, ordenamiento, recurrencia custom)
- Pendiente: Animaciones con flutter_animate en otras secciones
- Pendiente: Optimización de performance (DB, paginación, lazy loading)
- Pendiente: Manejo robusto de errores
- Pendiente: Optimización y limpieza de base de datos

**Fase 6.12: Migración a firebase_ai** (Planificado - Mejora UX)
- Setup de Firebase (30-45 min)
- Migrar AiService a firebase_ai (1-1.5 horas)
- Testing exhaustivo de análisis de imágenes (30-45 min)
- Cleanup y documentación (30 min)
- **Categoría:** Mejora funcional/UX (Fase 6, no Fase 7)
- Ver: [Plan de Migración](.claude/contexts/17_firebase_ai_migration_plan.md)

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

**Última actualización:** 2025-11-11
**Versión de documentación:** 6.11.0 (Fase 6.11 completada - Investigación del bug de imágenes y plan de migración a firebase_ai)
