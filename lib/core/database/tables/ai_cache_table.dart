import 'package:drift/drift.dart';

@TableIndex(name: 'ai_cache_hash_idx', columns: {#queryHash})
class AiCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get queryType =>
      text()(); // "food_analysis", "workout_recommendation"
  TextColumn get queryInput => text()(); // Input del usuario
  TextColumn get queryHash =>
      text().unique()(); // Hash del input para búsqueda rápida

  TextColumn get aiResponse => text()(); // Respuesta completa de Gemini (JSON)

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();
  IntColumn get useCount => integer().withDefault(const Constant(1))();
}
