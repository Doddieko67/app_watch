import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Theme settings
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))(); // 'light', 'dark', 'system'
  TextColumn get primaryColorHex =>
      text().withDefault(const Constant('#6750A4'))();

  // Backup settings
  TextColumn get backupFrequency =>
      text().withDefault(const Constant('never'))(); // 'never', 'daily', 'weekly'
  DateTimeColumn get lastBackupDate => dateTime().nullable()();

  // Notifications
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();

  // AI settings
  BoolColumn get hasApiKey => boolean().withDefault(const Constant(false))();

  // Onboarding
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
