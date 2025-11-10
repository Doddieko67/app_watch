import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/ai_cache_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/exercises_table.dart';
import 'tables/food_items_table.dart';
import 'tables/meals_table.dart';
import 'tables/nutrition_goals_table.dart';
import 'tables/reminders_table.dart';
import 'tables/saved_exercises_table.dart';
import 'tables/saved_workouts_table.dart';
import 'tables/sleep_records_table.dart';
import 'tables/sleep_schedules_table.dart';
import 'tables/study_sessions_table.dart';
import 'tables/workouts_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Reminders,
  Workouts,
  Exercises,
  SavedExercises,
  SavedWorkouts,
  Meals,
  FoodItems,
  NutritionGoals,
  SleepRecords,
  StudySessions,
  SleepSchedules,
  AppSettings,
  AiCache,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migración de v1 a v2: agregar tabla SavedExercises
          if (from == 1 && to == 2) {
            await m.createTable(savedExercises);
          }
          // Migración de v2 a v3: agregar SavedWorkouts y cambiar split a muscleGroups
          if (from == 2 && to == 3) {
            await m.createTable(savedWorkouts);
            // Migrar columna split a muscleGroups en workouts
            await m.addColumn(workouts, workouts.muscleGroups);
            // Copiar datos de split a muscleGroups (convertir a JSON array)
            await customStatement('''
              UPDATE workouts
              SET muscle_groups = '["' || split || '"]'
              WHERE muscle_groups IS NULL OR muscle_groups = ''
            ''');
            // Nota: No eliminamos la columna 'split' por compatibilidad
          }
        },
      );

  // DAOs básicos para cada tabla

  // Reminders
  Future<List<Reminder>> getAllReminders() => select(reminders).get();
  Future<Reminder?> getReminderById(int id) =>
      (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();
  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);
  Future<bool> updateReminder(Reminder reminder) =>
      update(reminders).replace(reminder);
  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  // Workouts
  Future<List<Workout>> getAllWorkouts() => select(workouts).get();
  Future<Workout?> getWorkoutById(int id) =>
      (select(workouts)..where((w) => w.id.equals(id))).getSingleOrNull();
  Future<int> insertWorkout(WorkoutsCompanion workout) =>
      into(workouts).insert(workout);
  Future<bool> updateWorkout(Workout workout) =>
      update(workouts).replace(workout);
  Future<int> deleteWorkout(int id) =>
      (delete(workouts)..where((w) => w.id.equals(id))).go();

  // Exercises
  Future<List<Exercise>> getExercisesByWorkoutId(int workoutId) =>
      (select(exercises)..where((e) => e.workoutId.equals(workoutId))).get();
  Future<int> insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise);
  Future<bool> updateExercise(Exercise exercise) =>
      update(exercises).replace(exercise);
  Future<int> deleteExercise(int id) =>
      (delete(exercises)..where((e) => e.id.equals(id))).go();

  // SavedExercises
  Future<List<SavedExerciseData>> getAllSavedExercises() =>
      (select(savedExercises)
            ..where((e) => e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.desc(e.lastUsed)]))
          .get();
  Future<SavedExerciseData?> getSavedExerciseByName(String name) =>
      (select(savedExercises)..where((e) => e.name.equals(name)))
          .getSingleOrNull();
  Future<int> insertSavedExercise(SavedExercisesCompanion exercise) =>
      into(savedExercises).insert(exercise);
  Future<bool> updateSavedExercise(SavedExerciseData exercise) =>
      update(savedExercises).replace(exercise);
  Future<int> deleteSavedExercise(int id) =>
      (delete(savedExercises)..where((e) => e.id.equals(id))).go();

  // SavedWorkouts
  Future<List<SavedWorkoutData>> getAllSavedWorkouts() =>
      (select(savedWorkouts)
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm.desc(w.lastUsed)]))
          .get();
  Future<SavedWorkoutData?> getSavedWorkoutByName(String name) =>
      (select(savedWorkouts)..where((w) => w.name.equals(name)))
          .getSingleOrNull();
  Future<int> insertSavedWorkout(SavedWorkoutsCompanion workout) =>
      into(savedWorkouts).insert(workout);
  Future<bool> updateSavedWorkout(SavedWorkoutData workout) =>
      update(savedWorkouts).replace(workout);
  Future<int> deleteSavedWorkout(int id) =>
      (delete(savedWorkouts)..where((w) => w.id.equals(id))).go();

  // Meals
  Future<List<Meal>> getAllMeals() => select(meals).get();
  Future<Meal?> getMealById(int id) =>
      (select(meals)..where((m) => m.id.equals(id))).getSingleOrNull();
  Future<int> insertMeal(MealsCompanion meal) => into(meals).insert(meal);
  Future<bool> updateMeal(Meal meal) => update(meals).replace(meal);
  Future<int> deleteMeal(int id) =>
      (delete(meals)..where((m) => m.id.equals(id))).go();

  // FoodItems
  Future<List<FoodItem>> getFoodItemsByMealId(int mealId) =>
      (select(foodItems)..where((f) => f.mealId.equals(mealId))).get();
  Future<int> insertFoodItem(FoodItemsCompanion foodItem) =>
      into(foodItems).insert(foodItem);
  Future<bool> updateFoodItem(FoodItem foodItem) =>
      update(foodItems).replace(foodItem);
  Future<int> deleteFoodItem(int id) =>
      (delete(foodItems)..where((f) => f.id.equals(id))).go();

  // NutritionGoals
  Future<List<NutritionGoal>> getAllNutritionGoals() =>
      select(nutritionGoals).get();
  Future<NutritionGoal?> getActiveNutritionGoal() => (select(nutritionGoals)
        ..where((g) => g.isActive.equals(true)))
      .getSingleOrNull();
  Future<int> insertNutritionGoal(NutritionGoalsCompanion goal) =>
      into(nutritionGoals).insert(goal);
  Future<bool> updateNutritionGoal(NutritionGoal goal) =>
      update(nutritionGoals).replace(goal);

  // SleepRecords
  Future<List<SleepRecord>> getAllSleepRecords() => select(sleepRecords).get();
  Future<SleepRecord?> getSleepRecordById(int id) =>
      (select(sleepRecords)..where((s) => s.id.equals(id))).getSingleOrNull();
  Future<int> insertSleepRecord(SleepRecordsCompanion record) =>
      into(sleepRecords).insert(record);
  Future<bool> updateSleepRecord(SleepRecord record) =>
      update(sleepRecords).replace(record);
  Future<int> deleteSleepRecord(int id) =>
      (delete(sleepRecords)..where((s) => s.id.equals(id))).go();

  // StudySessions
  Future<List<StudySession>> getAllStudySessions() =>
      select(studySessions).get();
  Future<StudySession?> getStudySessionById(int id) =>
      (select(studySessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  Future<int> insertStudySession(StudySessionsCompanion session) =>
      into(studySessions).insert(session);
  Future<bool> updateStudySession(StudySession session) =>
      update(studySessions).replace(session);
  Future<int> deleteStudySession(int id) =>
      (delete(studySessions)..where((s) => s.id.equals(id))).go();

  // SleepSchedules
  Future<List<SleepSchedule>> getAllSleepSchedules() =>
      select(sleepSchedules).get();
  Future<SleepSchedule?> getActiveSleepSchedule() => (select(sleepSchedules)
        ..where((s) => s.isActive.equals(true)))
      .getSingleOrNull();
  Future<int> insertSleepSchedule(SleepSchedulesCompanion schedule) =>
      into(sleepSchedules).insert(schedule);
  Future<bool> updateSleepSchedule(SleepSchedule schedule) =>
      update(sleepSchedules).replace(schedule);

  // AppSettings
  Future<AppSetting?> getSettings() => (select(appSettings)..limit(1)).getSingleOrNull();
  Future<int> insertSettings(AppSettingsCompanion settings) =>
      into(appSettings).insert(settings);
  Future<bool> updateSettings(AppSetting settings) =>
      update(appSettings).replace(settings);
  Stream<AppSetting?> watchSettings() =>
      (select(appSettings)..limit(1)).watchSingleOrNull();

  // AiCache
  Future<AiCacheData?> getCachedResponse(String queryHash) =>
      (select(aiCache)..where((c) => c.queryHash.equals(queryHash)))
          .getSingleOrNull();
  Future<int> insertCacheEntry(AiCacheCompanion entry) =>
      into(aiCache).insert(entry);
  Future<bool> updateCacheEntry(AiCacheData entry) =>
      update(aiCache).replace(entry);
  Future<int> deleteCacheEntry(int id) =>
      (delete(aiCache)..where((c) => c.id.equals(id))).go();

  // AiCache - Additional methods for nutrition
  Future<AiCacheData?> findByHash(String hash) =>
      (select(aiCache)..where((c) => c.queryHash.equals(hash)))
          .getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_watch.db'));
    return NativeDatabase(file);
  });
}
