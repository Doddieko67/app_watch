# 📱 Plan de Implementación

## Fase 1: Configuración Inicial (Semana 1)

### Objetivos
Establecer la base del proyecto con toda la infraestructura core.

### Tareas

#### Setup del Proyecto
- [ ] Crear proyecto Flutter con `flutter create app_watch`
- [ ] Configurar `pubspec.yaml` con todas las dependencias
- [ ] Ejecutar `flutter pub get`
- [ ] Configurar análisis de código (`analysis_options.yaml`)

#### Estructura de Carpetas
- [ ] Crear estructura completa según arquitectura
- [ ] Setup de carpetas `lib/core/` y `lib/features/`
- [ ] Crear carpetas `assets/`, `test/`

#### Base de Datos (Drift)
- [ ] Crear todas las tablas en `lib/core/database/tables/`
- [ ] Configurar `AppDatabase` con todas las tablas
- [ ] Ejecutar `build_runner` para generar código
- [ ] Crear DAOs básicos para cada tabla

#### Riverpod Setup
- [ ] Configurar `ProviderScope` en `main.dart`
- [ ] Crear `database_provider.dart`
- [ ] Crear providers básicos para cada feature

#### Tema y Navegación
- [ ] Implementar `AppTheme` con Material 3
- [ ] Crear selector de colores
- [ ] Implementar navegación adaptativa (Bottom Nav + Rail)
- [ ] Configurar rutas

#### Assets
- [ ] Preparar `nutrition_database.json` con 500 alimentos
- [ ] Agregar iconos y assets necesarios
- [ ] Configurar `pubspec.yaml` para assets

### Entregable
Proyecto base funcional con navegación entre secciones vacías y tema personalizable.

---

## Fase 2: Recordatorios (Semana 2) ✅ COMPLETADO

### Objetivos
Implementar el módulo de recordatorios completo con notificaciones.

### Tareas

#### Domain Layer
- [x] Crear `Reminder` entity
- [x] Crear `ReminderRepository` interface
- [x] Implementar use cases:
  - `CreateReminder`
  - `UpdateReminder`
  - `DeleteReminder`
  - `GetAllReminders`
  - `ScheduleNotification`

#### Data Layer
- [x] Implementar `ReminderRepositoryImpl`
- [x] Crear `ReminderLocalDataSource`
- [x] Configurar conversiones DTO ↔ Entity

#### Presentation Layer
- [x] Crear `RemindersProvider` con Riverpod
- [x] Implementar `RemindersHomeScreen`:
  - Lista de recordatorios
  - Filtros (todos, pendientes, completados)
  - Ordenar por prioridad/fecha
- [x] Implementar `ReminderDetailScreen`:
  - Crear/Editar recordatorio
  - Selector de recurrencia
  - Selector de prioridad
  - Tags personalizables
- [x] Crear widgets:
  - `ReminderCard`
  - `PrioritySelector`
  - `RecurrencePicker`

#### Notificaciones
- [x] Configurar `NotificationService`
- [x] Implementar scheduling de notificaciones diarias
- [x] Implementar notificaciones semanales
- [x] Implementar notificaciones personalizadas
- [x] Configurar canales de Android
- [x] Solicitar permisos en iOS/Android

#### Mejoras UX/UI (Fase 7.0 - Completadas)
- [x] **Swipe Actions**: Deslizar para completar/eliminar (flutter_slidable)
- [x] **Estados de Carga**: Loading indicators en acciones async
- [x] **Búsqueda en Tiempo Real**: Buscar en título, descripción y tags
- [x] **Ordenamiento Flexible**: Por fecha/prioridad/alfabético con menú
- [x] **Recurrencia Personalizada**: Slider para 1-30 días con UI intuitiva
- [x] **Feedback Mejorado**: Mostrar próxima notificación calculada
- [x] **Errores Humanizados**: Mensajes contextuales y comprensibles
- [x] **Jerarquía Visual**: Títulos bold, espaciado aumentado, touch targets
- [x] **Recordatorios Vencidos**: Borde rojo + background destacado
- [x] **Iconos de Prioridad**: Diferenciados semánticamente (flag_outlined, flag, priority_high)
- [x] **Tema Material 3**: Colores del theme en lugar de hardcoded

#### Testing
- [ ] Unit tests para use cases
- [ ] Widget tests para `ReminderCard`
- [ ] Integration test: crear y marcar como completado

### Entregable
Módulo de recordatorios funcional con notificaciones locales y UX optimizada.

---

## Fase 3: Fitness Tracker (Semana 3)

### Objetivos
Implementar tracking de entrenamientos con calendario y gráficas.

### Tareas

#### Domain Layer
- [ ] Crear entities: `Workout`, `Exercise`, `WorkoutSplit`
- [ ] Crear `FitnessRepository` interface
- [ ] Implementar use cases:
  - `CreateWorkout`
  - `LogExercise`
  - `GetWorkoutHistory`
  - `GetProgressData`

#### Data Layer
- [ ] Implementar `FitnessRepositoryImpl`
- [ ] Crear `FitnessLocalDataSource`
- [ ] Manejar relaciones Workout → Exercises

#### Presentation Layer
- [ ] Crear `FitnessProvider`
- [ ] Implementar `FitnessHomeScreen`:
  - Calendario de entrenamientos (table_calendar)
  - Resumen semanal
  - Acceso rápido a último workout
- [ ] Implementar `WorkoutDetailScreen`:
  - Log de ejercicios
  - Timer de descanso
  - Notas
- [ ] Implementar `WorkoutHistoryScreen`:
  - Historial completo
  - Gráficas de progreso (fl_chart)
  - Stats: total weight lifted, PR por ejercicio
- [ ] Crear widgets:
  - `WorkoutCalendar`
  - `ExerciseLogCard`
  - `ProgressChart` (line chart)
  - `SplitSelector` (Push/Pull/Legs)

#### Gráficas
- [ ] Implementar line chart para progreso de peso/reps
- [ ] Implementar bar chart para volumen semanal
- [ ] Agregar animaciones con flutter_animate

### Entregable
Fitness tracker completo con calendario y visualización de progreso.

---

## Fase 4: Nutrición (Semana 4)

### Objetivos
Implementar tracking de comidas con integración de IA.

### Tareas

#### Domain Layer
- [ ] Crear entities: `Meal`, `FoodItem`, `NutritionGoals`
- [ ] Crear `NutritionRepository` interface
- [ ] Implementar use cases:
  - `LogMeal`
  - `AnalyzeFoodWithAI`
  - `GetCachedFood`
  - `SearchLocalFoodDb`
  - `GetDailyNutrition`

#### Data Layer
- [ ] Implementar `NutritionRepositoryImpl`
- [ ] Crear `NutritionLocalDataSource`
- [ ] Crear `NutritionAiDataSource` con Gemini

#### AI Service
- [ ] Implementar `AiService` con flujo de fallback
- [ ] Configurar cliente Gemini
- [ ] Implementar sistema de cache
- [ ] Cargar `nutrition_database.json`
- [ ] Implementar búsqueda fuzzy
- [ ] Implementar modo manual

#### Presentation Layer
- [ ] Crear `NutritionProvider`
- [ ] Implementar `NutritionHomeScreen`:
  - Resumen diario (macros, calorías)
  - Circular progress indicators
  - Lista de comidas del día
- [ ] Implementar `LogMealScreen`:
  - Input de texto para alimento
  - Análisis con IA (automático)
  - Mostrar resultado con confianza
  - Opción de editar manualmente
  - Guardar
- [ ] Implementar `NutritionStatsScreen`:
  - Gráficas semanales
  - Promedio de macros
  - Días en meta
- [ ] Crear widgets:
  - `MealCard`
  - `MacrosChart` (bar chart + pie chart)
  - `FoodSearchWidget`
  - `AiAnalysisWidget`

#### Testing IA
- [ ] Probar análisis con diferentes inputs
- [ ] Validar fallback a DB local
- [ ] Probar modo manual
- [ ] Verificar cache funciona correctamente

### Entregable
Módulo de nutrición con IA funcional y fallback offline completo.

---

## Fase 5: Sueño y Estudio (Semana 5)

### Objetivos
Implementar tracking de sueño y sesiones de estudio.

### Tareas

#### Domain Layer
- [ ] Crear entities: `SleepRecord`, `StudySession`, `SleepSchedule`
- [ ] Crear `SleepStudyRepository` interface
- [ ] Implementar use cases:
  - `ConfigureSleepSchedule`
  - `LogSleepRecord`
  - `LogStudySession`
  - `CalculateOptimalStudyTime`
  - `ScheduleSleepNotifications`

#### Data Layer
- [ ] Implementar `SleepStudyRepositoryImpl`
- [ ] Crear `SleepStudyLocalDataSource`

#### Presentation Layer
- [ ] Crear `SleepProvider` y `StudyProvider`
- [ ] Implementar `SleepStudyHomeScreen`:
  - Vista combinada de sueño y estudio
  - Configurar horarios
  - Ver última noche
  - Registrar sesión de estudio actual
- [ ] Implementar `SleepConfigScreen`:
  - Configurar hora de dormir
  - Configurar hora de despertar
  - Minutos de notificación pre-sueño
  - Toggle de hora óptima de estudio
- [ ] Implementar `SleepHistoryScreen`:
  - Historial de sueño
  - Gráfica de horas dormidas vs planificadas
  - Calidad promedio
- [ ] Crear widgets:
  - `SleepChart`
  - `StudyTimer` (con cronómetro)
  - `ScheduleConfigurator`

#### Notificaciones de Sueño
- [ ] Programar notificación de pre-sueño
- [ ] Programar notificación de despertar
- [ ] Calcular y notificar hora óptima de estudio

### Entregable
Módulo de sueño y estudio funcional con recomendaciones inteligentes.

---

## Fase 6: Ajustes y Extras (Semana 6)

### Objetivos
Completar configuración, exportación y onboarding.

### Tareas

#### Settings Screen
- [ ] Implementar `SettingsScreen`:
  - Tema (light/dark/system)
  - Color primario (selector)
  - Configurar API key de Gemini
  - Frecuencia de backup
  - Permisos
  - Acerca de
- [ ] Crear `ThemeProvider` persistente
- [ ] Crear `SettingsProvider`

#### Exportación/Importación
- [ ] Implementar `ExportService`
- [ ] Exportar a JSON
- [ ] Importar desde JSON
- [ ] Compartir backup con Share API
- [ ] Validar formato al importar
- [ ] Implementar auto-backup configurable

#### Onboarding
- [ ] Crear `OnboardingScreen` (3-4 pantallas):
  - Bienvenida
  - Explicar features principales
  - Solicitar permisos (notificaciones)
  - Configurar API key de Gemini (opcional)
  - Configurar horarios de sueño iniciales
- [ ] Guardar flag de onboarding completado

#### Seguridad
- [ ] Almacenar API key en `flutter_secure_storage`
- [ ] Validar inputs del usuario
- [ ] Manejar errores de red gracefully
- [ ] No exponer API keys en logs

#### Permisos
- [ ] Solicitar permiso de notificaciones
- [ ] Solicitar permiso de exact alarms (Android 12+)
- [ ] Manejar denegaciones

### Entregable
App completa con todas las configuraciones y onboarding.

---

## Fase 6.8: Mejoras Funcionales Pre-Pulido

### Objetivos
Implementar mejoras funcionales identificadas antes del pulido final: edición de ejercicios, listas de items guardados, estadísticas detalladas y optimizaciones de UX.

### Tareas

#### FITNESS - Edición de Ejercicios
- [ ] Permitir editar ejercicios en workout ANTES de guardar:
  - Modificar sets, reps, peso de ejercicios ya agregados
  - Botón de edición en cada ejercicio de la lista
  - Reordenar ejercicios (opcional)
- [ ] Permitir editar workouts ya guardados:
  - Editar ejercicios existentes en workout guardado
  - Agregar/eliminar ejercicios de workout existente
  - Actualizar estadísticas al modificar

#### FITNESS - Sistema de Ejercicios Guardados
- [ ] Crear tabla/almacenamiento de ejercicios únicos usados
- [ ] Implementar autocompletar al escribir nombre de ejercicio:
  - Sugerir ejercicios previamente usados
  - Mostrar últimos valores (sets, reps, peso)
- [ ] Botón para ver lista completa de ejercicios guardados:
  - Pantalla con todos los ejercicios históricos
  - Búsqueda y filtrado
  - Seleccionar ejercicio pre-rellena últimos valores

#### FITNESS - Estadísticas Detalladas
- [ ] Crear pantalla de estadísticas avanzadas:
  - Ejercicios más frecuentes (top 10-15)
  - Records personales (PRs) por ejercicio
  - Última vez que se hizo cada ejercicio
  - Progresión de peso/volumen por ejercicio

#### NUTRITION - Optimización de Carga
- [ ] Eliminar pantalla de carga al cambiar de día:
  - Optimizar query de resumen diario
  - Usar caché o estado previo mientras carga
  - Transición suave sin loading indicator

#### NUTRITION - Sistema de Alimentos Guardados
- [ ] Crear tabla/almacenamiento de alimentos únicos usados
- [ ] Implementar autocompletar al escribir nombre de alimento:
  - Sugerir alimentos previamente loggeados
  - Mostrar últimas cantidades/porciones
- [ ] Botón para ver lista completa de alimentos guardados:
  - Pantalla con todos los alimentos históricos
  - Búsqueda y filtrado
  - Seleccionar alimento pre-rellena últimos valores

#### NAVIGATION BAR - Simplificación
- [ ] Modificar MainNavigationScreen:
  - Eliminar labels de texto en NavigationBar
  - Aumentar tamaño de iconos
  - Solo iconos visibles en bottom navigation

### Entregable
App con todas las mejoras funcionales implementadas, lista para entrar a Fase 7 (Pulido).

---

## Fase 6.11: Investigación y Documentación de IA ✅ COMPLETADO (2025-11-11)

### Objetivos
Investigar y documentar bug de análisis de imágenes, crear plan de migración a firebase_ai.

### Tareas Completadas

#### Investigación del Bug ✅
- [x] Probar análisis de imágenes con test_gemini.dart
- [x] Identificar error: "Unhandled format for Content: {role: model}"
- [x] Verificar que análisis de texto funciona perfectamente
- [x] Investigar issues en GitHub del SDK (deprecated repo)
- [x] Buscar SDKs alternativos (firebase_ai encontrado)
- [x] Comparar google_generative_ai vs firebase_ai

#### Documentación Creada ✅
- [x] `.claude/contexts/16_gemini_image_limitation.md`
  - Documentación completa del bug
  - Investigación detallada
  - Causa raíz identificada
  - Plan de acción futuro
- [x] `.claude/contexts/17_firebase_ai_migration_plan.md`
  - Comparación de SDKs
  - Plan de 4 fases (2-3 horas)
  - Checklist completa de migración
  - Decisión: cuándo migrar

#### Sincronización de Documentos ✅
- [x] Actualizar `04_ai_strategy.md` con limitación actual
- [x] Actualizar `01_tech_stack.md` con versiones correctas
- [x] Agregar referencias cruzadas entre documentos

### Entregable
Documentación completa del bug y plan claro de migración a firebase_ai para resolver el análisis de imágenes.

**Commits:** 3 commits (2025-11-11)
- fix(nutrition): resolve Gemini multimodal Content format error
- docs(nutrition): document Gemini image analysis SDK limitation
- docs: update AI strategy and create firebase_ai migration plan

---

## Fase 6.12: Migración a firebase_ai (Futuro - Planificado)

### Objetivos
Migrar de `google_generative_ai` a `firebase_ai` para habilitar análisis de imágenes de alimentos.

### Pre-requisitos
- Reservar 2-3 horas de trabajo ininterrumpido
- Cuenta de Google/Firebase lista

### Tareas

#### Fase 1: Setup de Firebase (30-45 min)
- [ ] Instalar FlutterFire CLI
- [ ] Ejecutar `flutterfire configure`
- [ ] Agregar dependencias (firebase_core, firebase_ai)
- [ ] Habilitar Gemini API en Firebase Console
- [ ] Actualizar main.dart con inicialización Firebase
- [ ] Compilar y verificar sin errores

#### Fase 2: Migrar AiService (1-1.5 horas)
- [ ] Crear branch `feature/migrate-firebase-ai`
- [ ] Actualizar imports (firebase_ai en lugar de google_generative_ai)
- [ ] Modificar `configureGemini()` (sin API key parameter)
- [ ] Cambiar `DataPart` → `InlineDataPart`
- [ ] Actualizar 3 métodos de análisis de imágenes
- [ ] Remover/actualizar UI de API Key en Settings
- [ ] Verificar compilación sin errores

#### Fase 3: Testing Exhaustivo (30-45 min)
- [ ] Actualizar test_gemini.dart
- [ ] Probar análisis de texto (debe funcionar)
- [ ] Probar análisis de imágenes (debe funcionar ✅)
- [ ] Verificar cache sigue funcionando
- [ ] Probar fallback a DB local
- [ ] Build APK y probar en dispositivo
- [ ] Tests manuales de todos los modos (Plato/Porción/Etiqueta)
- [ ] Verificar no hay regresiones

#### Fase 4: Cleanup y Documentación (30 min)
- [ ] Remover dependencia `google_generative_ai`
- [ ] Actualizar documentación (5 archivos .md)
- [ ] Crear commit detallado
- [ ] Merge a main
- [ ] Deploy nuevo APK

### Entregable
Análisis de imágenes funcionando completamente. Mejora UX con análisis visual de alimentos.

**Referencias:**
- [17. Plan Completo de Migración](./17_firebase_ai_migration_plan.md)
- [16. Documentación del Bug](./16_gemini_image_limitation.md)

**Tiempo estimado:** 2-3 horas
**Prioridad:** Media (mejora UX, no bloqueante para v1.0)
**Categoría:** Mejora funcional y UX (Fase 6)

---

## Fase 7.0: Pulido Técnico (Primera mitad Semana 7)

### Objetivos
Optimizar rendimiento, agregar animaciones, mejorar manejo de errores y optimizar base de datos.

### Tareas Completadas

#### Mejoras UX Recordatorios ✅
- [x] Swipe actions con flutter_slidable implementado
- [x] Loading states en acciones async
- [x] Búsqueda en tiempo real funcional
- [x] Ordenamiento flexible (fecha/prioridad/alfabético)
- [x] Recurrencia custom completa (1-30 días)
- [x] Feedback mejorado con próxima notificación
- [x] Mensajes de error humanizados
- [x] Jerarquía visual optimizada
- [x] Recordatorios vencidos destacados
- [x] Integración completa con Material 3 Theme

### Tareas Pendientes

#### Animaciones
- [ ] Agregar hero animations entre pantallas
- [ ] Fade in + slide en listas con flutter_animate
- [ ] Animaciones de éxito/error en formularios
- [ ] Smooth transitions en gráficas
- [ ] Animaciones en cambios de estado (loading, empty, error)

#### Performance
- [ ] Optimizar consultas a DB (índices)
- [ ] Implementar paginación en listas largas
- [ ] Lazy loading de gráficas
- [ ] Reducir rebuilds innecesarios con `const` constructors
- [ ] Usar `RepaintBoundary` en widgets complejos
- [ ] Optimizar imágenes y assets

#### Manejo de Errores
- [ ] Try-catch en todos los services
- [ ] Snackbars informativos para el usuario
- [ ] Logging para debugging (usando logger package)
- [ ] Validación de formularios robusta
- [ ] Error boundaries para widgets críticos
- [ ] Mensajes de error user-friendly

#### Optimización de DB
- [ ] Verificar índices están aplicados correctamente
- [ ] Probar queries con EXPLAIN para análisis
- [ ] Implementar limpieza de cache antigua (>30 días)
- [ ] Limpiar soft deletes viejos (>90 días)
- [ ] Optimizar queries N+1 si existen
- [ ] Implementar batch operations donde sea posible

### Entregable
App con animaciones fluidas, rendimiento optimizado y manejo robusto de errores.

---

## Fase 7.5: Preparación para Release (Segunda mitad Semana 7)

### Objetivos
Testing completo, documentación final y preparación para publicación en stores.

### Tareas

#### Testing Completo
- [ ] Completar unit tests para todos los use cases (objetivo: 80%+ coverage)
- [ ] Widget tests para componentes críticos:
  - ReminderCard, WorkoutCard, MealCard
  - Summary cards del home
  - Formularios principales
- [ ] Integration tests para flujos principales:
  - Crear recordatorio → recibir notificación
  - Loggear comida con IA → verificar guardado
  - Registrar workout completo → verificar estadísticas
  - Exportar/Importar datos
- [ ] Probar en múltiples tamaños de pantalla (small, medium, large)
- [ ] Probar con datos grandes (10,000+ registros)
- [ ] Probar modo offline completo
- [ ] Ejecutar `flutter test --coverage`

#### Documentación
- [ ] Comentar código complejo con ejemplos
- [ ] README.md del proyecto completo con:
  - Descripción de la app
  - Screenshots
  - Instalación y setup
  - Estructura del proyecto
  - Comandos útiles
- [ ] Documentar arquitectura en ARCHITECTURE.md
- [ ] Guía de contribución (CONTRIBUTING.md)
- [ ] Changelog actualizado (CHANGELOG.md)
- [ ] Actualizar todos los contextos en `.claude/contexts/`

#### Preparación para Release
- [ ] Configurar app icons (Android/iOS) - 1024x1024 base
- [ ] Configurar splash screen adaptativo
- [ ] Actualizar versión a 1.0.0 en pubspec.yaml
- [ ] Configurar signing para Android (keystore)
- [ ] Configurar bundle ID y signing para iOS
- [ ] Build de release y probar exhaustivamente:
  - `flutter build apk --release`
  - `flutter build appbundle --release`
  - `flutter build ios --release`
- [ ] Tomar screenshots para stores (5-8 por plataforma)
- [ ] Preparar descripción para stores
- [ ] Crear privacy policy
- [ ] Preparar términos de servicio

### Entregable
App completamente probada, documentada y lista para publicar en Play Store / App Store.

---


## Checklist Final Antes de Release

### Funcionalidad
- [ ] Todas las features funcionan sin bugs críticos
- [ ] Notificaciones se disparan correctamente
- [ ] IA funciona con fallback offline
- [ ] Exportación/Importación funciona
- [ ] App no crashea con datos vacíos
- [ ] App no crashea sin internet

### Performance
- [ ] App inicia en <2 segundos
- [ ] 60 FPS en animaciones
- [ ] DB responde rápido con 10,000+ registros
- [ ] Memoria bajo control (<200MB)

### UX
- [ ] Onboarding claro y conciso
- [ ] Todas las pantallas son intuitivas
- [ ] Mensajes de error son comprensibles
- [ ] Estados de carga son visibles
- [ ] Empty states son informativos

### Seguridad
- [ ] API keys no están en código
- [ ] No hay logs con datos sensibles
- [ ] Permisos justificados

### Testing
- [ ] 80%+ code coverage en unit tests
- [ ] Widget tests para componentes clave
- [ ] Integration tests pasan

### Documentación
- [ ] README completo
- [ ] Contextos actualizados
- [ ] Comentarios en código complejo

---

## Post-Release (Roadmap Futuro)

### v1.1.0
- [ ] Sincronización en la nube
- [ ] Multi-idioma (inglés)
- [ ] Widgets para home screen

### v1.2.0
- [ ] Compartir workouts con amigos
- [ ] Recetas con macros calculados
- [ ] Integración con Google Fit / Apple Health

### v1.3.0
- [ ] Web app (Flutter Web)
- [ ] Desktop app (Windows/Mac/Linux)
- [ ] Estadísticas avanzadas con ML
