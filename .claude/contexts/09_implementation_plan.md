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

## Fase 2: Recordatorios (Semana 2)

### Objetivos
Implementar el módulo de recordatorios completo con notificaciones.

### Tareas

#### Domain Layer
- [ ] Crear `Reminder` entity
- [ ] Crear `ReminderRepository` interface
- [ ] Implementar use cases:
  - `CreateReminder`
  - `UpdateReminder`
  - `DeleteReminder`
  - `GetAllReminders`
  - `ScheduleNotification`

#### Data Layer
- [ ] Implementar `ReminderRepositoryImpl`
- [ ] Crear `ReminderLocalDataSource`
- [ ] Configurar conversiones DTO ↔ Entity

#### Presentation Layer
- [ ] Crear `RemindersProvider` con Riverpod
- [ ] Implementar `RemindersHomeScreen`:
  - Lista de recordatorios
  - Filtros (todos, pendientes, completados)
  - Ordenar por prioridad/fecha
- [ ] Implementar `ReminderDetailScreen`:
  - Crear/Editar recordatorio
  - Selector de recurrencia
  - Selector de prioridad
  - Tags personalizables
- [ ] Crear widgets:
  - `ReminderCard`
  - `PrioritySelector`
  - `RecurrencePicker`

#### Notificaciones
- [ ] Configurar `NotificationService`
- [ ] Implementar scheduling de notificaciones diarias
- [ ] Implementar notificaciones semanales
- [ ] Implementar notificaciones personalizadas
- [ ] Configurar canales de Android
- [ ] Solicitar permisos en iOS/Android

#### Testing
- [ ] Unit tests para use cases
- [ ] Widget tests para `ReminderCard`
- [ ] Integration test: crear y marcar como completado

### Entregable
Módulo de recordatorios funcional con notificaciones locales.

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

## Fase 7: Pulido y Optimización (Semana 7)

### Objetivos
Optimizar rendimiento, agregar animaciones y preparar para release.

### Tareas

#### Animaciones
- [ ] Agregar hero animations entre pantallas
- [ ] Fade in + slide en listas con flutter_animate
- [ ] Animaciones de éxito/error en formularios
- [ ] Smooth transitions en gráficas

#### Performance
- [ ] Optimizar consultas a DB (índices)
- [ ] Implementar paginación en listas largas
- [ ] Lazy loading de gráficas
- [ ] Reducir rebuilds innecesarios

#### Manejo de Errores
- [ ] Try-catch en todos los services
- [ ] Snackbars informativos para el usuario
- [ ] Logging para debugging
- [ ] Validación de formularios robusta

#### Testing
- [ ] Completar unit tests para todos los use cases
- [ ] Widget tests para componentes críticos
- [ ] Integration tests para flujos principales:
  - Crear recordatorio → recibir notificación
  - Loggear comida con IA
  - Registrar workout completo
- [ ] Probar en múltiples tamaños de pantalla
- [ ] Probar con datos grandes (10,000+ registros)

#### Optimización de DB
- [ ] Verificar índices están aplicados
- [ ] Probar queries con EXPLAIN
- [ ] Implementar limpieza de cache antigua
- [ ] Limpiar soft deletes viejos

#### Documentación
- [ ] Comentar código complejo
- [ ] README.md del proyecto
- [ ] Documentar arquitectura
- [ ] Guía de contribución

#### Preparación para Release
- [ ] Configurar app icons (Android/iOS)
- [ ] Configurar splash screen
- [ ] Versionar app (1.0.0)
- [ ] Configurar signing (Android)
- [ ] Build de release y probar
- [ ] Screenshots para stores

### Entregable
App lista para publicar en Play Store / App Store.

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
