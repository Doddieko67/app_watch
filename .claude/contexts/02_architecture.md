# 📂 Arquitectura del Proyecto

## Estructura de Carpetas

```
lib/
├── main.dart
├── app.dart                          # MaterialApp config
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # Valores constantes
│   │   ├── routes.dart               # Nombres de rutas
│   │   └── nutrition_db.dart         # DB local de alimentos comunes
│   │
│   ├── database/
│   │   ├── app_database.dart         # Configuración Drift
│   │   ├── app_database.g.dart       # Generado por Drift
│   │   └── tables/                   # Tablas Drift
│   │       ├── reminders_table.dart
│   │       ├── fitness_table.dart
│   │       ├── nutrition_table.dart
│   │       ├── sleep_table.dart
│   │       └── sync_metadata_table.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # Material 3 theme
│   │   ├── color_schemes.dart        # Esquemas de color
│   │   └── text_styles.dart          # Tipografía
│   │
│   ├── providers/
│   │   ├── database_provider.dart    # Provider de DB
│   │   ├── theme_provider.dart       # Provider de tema
│   │   └── ai_service_provider.dart  # Provider de Gemini
│   │
│   ├── services/
│   │   ├── notification_service.dart # Gestión de notificaciones
│   │   ├── ai_service.dart           # Cliente Gemini + fallback
│   │   ├── export_service.dart       # Exportar/Importar datos
│   │   └── cache_service.dart        # Cache de respuestas IA
│   │
│   ├── models/
│   │   └── common/                   # Modelos compartidos
│   │       ├── result.dart           # Result<T> para manejo de errores
│   │       └── sync_status.dart      # Estados de sincronización
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── validators.dart
│       └── extensions.dart
│
├── features/
│   ├── daily_reminders/
│   │   ├── data/
│   │   │   ├── models/               # Data Transfer Objects
│   │   │   │   └── reminder_dto.dart
│   │   │   ├── repositories/
│   │   │   │   └── reminder_repository_impl.dart
│   │   │   └── datasources/
│   │   │       └── reminder_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── reminder.dart
│   │   │   ├── repositories/
│   │   │   │   └── reminder_repository.dart
│   │   │   └── usecases/             # Lógica de negocio
│   │   │       ├── create_reminder.dart
│   │   │       ├── update_reminder.dart
│   │   │       ├── delete_reminder.dart
│   │   │       └── schedule_notification.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── reminders_provider.dart
│   │       ├── screens/
│   │       │   ├── reminders_home_screen.dart
│   │       │   └── reminder_detail_screen.dart
│   │       └── widgets/
│   │           ├── reminder_card.dart
│   │           ├── priority_selector.dart
│   │           └── recurrence_picker.dart
│   │
│   ├── fitness/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── workout_dto.dart
│   │   │   │   └── exercise_dto.dart
│   │   │   ├── repositories/
│   │   │   │   └── fitness_repository_impl.dart
│   │   │   └── datasources/
│   │   │       └── fitness_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── workout.dart
│   │   │   │   ├── exercise.dart
│   │   │   │   └── workout_split.dart  # Push/Pull/Legs
│   │   │   ├── repositories/
│   │   │   │   └── fitness_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_workout.dart
│   │   │       ├── log_exercise.dart
│   │   │       └── get_ai_recommendations.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── fitness_provider.dart
│   │       │   └── workout_calendar_provider.dart
│   │       ├── screens/
│   │       │   ├── fitness_home_screen.dart
│   │       │   ├── workout_detail_screen.dart
│   │       │   └── workout_history_screen.dart
│   │       └── widgets/
│   │           ├── workout_calendar.dart
│   │           ├── exercise_log_card.dart
│   │           └── progress_chart.dart
│   │
│   ├── nutrition/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── meal_dto.dart
│   │   │   │   └── food_item_dto.dart
│   │   │   ├── repositories/
│   │   │   │   └── nutrition_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── nutrition_local_datasource.dart
│   │   │       └── nutrition_ai_datasource.dart  # Gemini + cache
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── meal.dart
│   │   │   │   ├── food_item.dart
│   │   │   │   └── nutrition_goals.dart
│   │   │   ├── repositories/
│   │   │   │   └── nutrition_repository.dart
│   │   │   └── usecases/
│   │   │       ├── log_meal.dart
│   │   │       ├── analyze_food_with_ai.dart
│   │   │       ├── get_cached_food.dart
│   │   │       └── search_local_food_db.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── nutrition_provider.dart
│   │       │   └── daily_nutrition_provider.dart
│   │       ├── screens/
│   │       │   ├── nutrition_home_screen.dart
│   │       │   ├── log_meal_screen.dart
│   │       │   └── nutrition_stats_screen.dart
│   │       └── widgets/
│   │           ├── meal_card.dart
│   │           ├── macros_chart.dart
│   │           ├── food_search_widget.dart
│   │           └── ai_analysis_widget.dart
│   │
│   ├── sleep_study/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── sleep_record_dto.dart
│   │   │   │   └── study_session_dto.dart
│   │   │   ├── repositories/
│   │   │   │   └── sleep_study_repository_impl.dart
│   │   │   └── datasources/
│   │   │       └── sleep_study_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── sleep_record.dart
│   │   │   │   ├── study_session.dart
│   │   │   │   └── sleep_schedule.dart
│   │   │   ├── repositories/
│   │   │   │   └── sleep_study_repository.dart
│   │   │   └── usecases/
│   │   │       ├── configure_sleep_schedule.dart
│   │   │       ├── log_sleep_record.dart
│   │   │       ├── calculate_optimal_study_time.dart
│   │   │       └── schedule_sleep_notifications.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── sleep_provider.dart
│   │       │   └── study_provider.dart
│   │       ├── screens/
│   │       │   ├── sleep_study_home_screen.dart
│   │       │   ├── sleep_config_screen.dart
│   │       │   └── sleep_history_screen.dart
│   │       └── widgets/
│   │           ├── sleep_chart.dart
│   │           ├── study_timer.dart
│   │           └── schedule_configurator.dart
│   │
│   ├── settings/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           ├── theme_picker.dart
│   │           ├── export_import_widget.dart
│   │           └── api_key_config.dart
│   │
│   └── home/
│       └── presentation/
│           ├── screens/
│           │   └── main_navigation_screen.dart
│           └── widgets/
│               └── navigation_rail_widget.dart

test/
├── unit/
│   ├── core/
│   └── features/
│       ├── daily_reminders/
│       ├── fitness/
│       ├── nutrition/
│       └── sleep_study/
├── widget/
└── integration/

assets/
├── images/
├── icons/
└── nutrition_database.json  # DB precargada de alimentos
```

---

## Principios Arquitectónicos

### Clean Architecture

1. **Domain Layer (Capa de Dominio)**
   - Entidades: Modelos de negocio puros
   - Repositorios: Interfaces abstractas
   - Use Cases: Lógica de negocio específica

2. **Data Layer (Capa de Datos)**
   - Models: DTOs para transferencia de datos
   - Repositories Impl: Implementación de interfaces
   - Data Sources: Acceso a BD, APIs, etc.

3. **Presentation Layer (Capa de Presentación)**
   - Providers: Estado con Riverpod
   - Screens: Pantallas completas
   - Widgets: Componentes reutilizables

### Feature-First

Cada feature es autocontenida con sus propias capas data/domain/presentation, facilitando:
- Mantenimiento independiente
- Testing aislado
- Desarrollo en paralelo
- Reutilización de código

---

## Flujo de Datos

```
User Interaction (Widget)
    ↓
Provider (Riverpod)
    ↓
Use Case (Domain Logic)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Drift/API)
    ↓
Database/Network
```
