# 🔄 Estrategia de Sincronización Futura

## Preparación para Sincronización en la Nube

Aunque la app es 100% local inicialmente, está diseñada para agregar sincronización en la nube fácilmente.

---

## Campos en Todas las Tablas

```dart
// Campos estándar en todas las tablas principales
DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete
IntColumn get syncStatus => integer().withDefault(const Constant(0))();
```

### Estados de Sincronización

```dart
enum SyncStatus {
  synced(0),           // Sincronizado con el servidor
  pendingUpload(1),    // Cambios locales pendientes de subir
  pendingDownload(2),  // Cambios remotos pendientes de bajar
  conflict(3);         // Conflicto que requiere resolución

  final int value;
  const SyncStatus(this.value);
}
```

---

## Soft Deletes

En lugar de eliminar registros, marcarlos como eliminados:

```dart
class RemindersDao extends DatabaseAccessor<AppDatabase> {
  // Eliminar (soft delete)
  Future<void> delete(int id) async {
    await (update(reminders)
          ..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value(SyncStatus.pendingUpload.value),
        ));
  }

  // Obtener solo registros no eliminados
  Future<List<Reminder>> getAllActive() {
    return (select(reminders)
          ..where((r) => r.deletedAt.isNull()))
        .get();
  }

  // Limpiar registros eliminados hace más de 30 días (opcional)
  Future<void> cleanOldDeleted() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    await (delete(reminders)
          ..where((r) => r.deletedAt.isSmallerThanValue(cutoffDate)))
        .go();
  }
}
```

---

## Arquitectura de Sincronización

### Local-First

```
┌─────────────────────────────────────────┐
│           User Interaction              │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│      1. Guardar en SQLite (Local)       │
│      syncStatus = pendingUpload         │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│   2. Background Sync Service            │
│   (Solo si hay internet)                │
└────────────────┬────────────────────────┘
                 ↓
        ┌────────┴────────┐
        │                 │
        ↓                 ↓
┌──────────────┐   ┌──────────────┐
│ Upload local │   │ Download     │
│ changes      │   │ remote       │
└──────┬───────┘   └──────┬───────┘
       │                  │
       └────────┬─────────┘
                ↓
    ┌──────────────────────┐
    │ Conflict Resolution  │
    │ (Last-write-wins o   │
    │  manual)             │
    └──────────────────────┘
```

### Flujo de Sincronización

```dart
class SyncService {
  final ApiClient _apiClient;
  final AppDatabase _db;

  /// Sincronizar todos los cambios pendientes
  Future<SyncResult> syncAll() async {
    if (!await _hasInternet()) {
      return SyncResult.offline();
    }

    try {
      // 1. Subir cambios locales
      await _uploadPendingChanges();

      // 2. Descargar cambios remotos
      await _downloadRemoteChanges();

      // 3. Resolver conflictos
      await _resolveConflicts();

      return SyncResult.success();
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  Future<void> _uploadPendingChanges() async {
    // Reminders
    final pendingReminders = await _db.remindersDao
        .getPendingUpload(); // syncStatus == 1

    for (final reminder in pendingReminders) {
      try {
        if (reminder.deletedAt != null) {
          await _apiClient.deleteReminder(reminder.id);
        } else {
          await _apiClient.upsertReminder(reminder);
        }

        // Marcar como sincronizado
        await _db.remindersDao.updateSyncStatus(
          reminder.id,
          SyncStatus.synced,
        );
      } catch (e) {
        debugPrint('Error uploading reminder ${reminder.id}: $e');
        // Marcar como conflict si hay error
        await _db.remindersDao.updateSyncStatus(
          reminder.id,
          SyncStatus.conflict,
        );
      }
    }

    // Repetir para workouts, meals, etc.
  }

  Future<void> _downloadRemoteChanges() async {
    // Obtener timestamp de última sincronización
    final lastSync = await _db.settingsDao.get('last_sync_timestamp');
    final timestamp = lastSync != null
        ? DateTime.parse(lastSync)
        : DateTime.fromMillisecondsSinceEpoch(0);

    // Descargar cambios desde timestamp
    final remoteChanges = await _apiClient.getChangesSince(timestamp);

    // Aplicar cambios remotos
    for (final change in remoteChanges.reminders) {
      final local = await _db.remindersDao.findById(change.id);

      if (local == null) {
        // No existe localmente, insertar
        await _db.remindersDao.insert(change);
      } else if (local.updatedAt.isBefore(change.updatedAt)) {
        // Versión remota más reciente
        await _db.remindersDao.update(change);
      } else if (local.updatedAt.isAfter(change.updatedAt)) {
        // Conflicto: versión local más reciente
        await _db.remindersDao.updateSyncStatus(
          change.id,
          SyncStatus.conflict,
        );
      }
    }

    // Actualizar timestamp
    await _db.settingsDao.set(
      'last_sync_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _resolveConflicts() async {
    final conflicts = await _db.remindersDao.getConflicts();

    for (final conflict in conflicts) {
      // Estrategia: Last-write-wins
      // (En el futuro, permitir resolución manual)

      final remote = await _apiClient.getReminder(conflict.id);

      if (conflict.updatedAt.isAfter(remote.updatedAt)) {
        // Local gana, subir
        await _apiClient.upsertReminder(conflict);
      } else {
        // Remoto gana, aplicar
        await _db.remindersDao.update(remote);
      }

      // Marcar como resuelto
      await _db.remindersDao.updateSyncStatus(
        conflict.id,
        SyncStatus.synced,
      );
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
```

---

## UUID para Identificación Global

Cuando se implemente sincronización, agregar campo UUID:

```dart
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()(); // UUID v4

  // ... resto de campos
}

// Generar UUID al crear
final reminder = RemindersCompanion(
  uuid: Value(const Uuid().v4()),
  title: const Value('Mi recordatorio'),
  // ...
);
```

---

## Backend API (Referencia)

### Endpoints Necesarios

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/auth/me

GET    /api/v1/sync/changes?since=timestamp
POST   /api/v1/sync/upload

GET    /api/v1/reminders
POST   /api/v1/reminders
PUT    /api/v1/reminders/:id
DELETE /api/v1/reminders/:id

GET    /api/v1/workouts
POST   /api/v1/workouts
// ... (similar para meals, sleep, etc.)
```

### Estructura de Respuesta de Cambios

```json
{
  "timestamp": "2025-11-06T10:30:00.000Z",
  "changes": {
    "reminders": [
      {
        "id": 123,
        "uuid": "a1b2c3...",
        "operation": "update", // "create", "update", "delete"
        "data": { /* reminder completo */ },
        "updatedAt": "2025-11-06T10:25:00.000Z"
      }
    ],
    "workouts": [ /* ... */ ],
    "meals": [ /* ... */ ]
  }
}
```

---

## Resolución de Conflictos

### Estrategias

1. **Last-Write-Wins (LWW):** La versión con `updatedAt` más reciente gana
   - Pros: Simple, automático
   - Cons: Puede perder datos

2. **Manual:** Mostrar UI para que usuario elija
   - Pros: Usuario tiene control total
   - Cons: Requiere intervención

3. **Operacional (CRDT):** Transformar operaciones para merge automático
   - Pros: Sin pérdida de datos
   - Cons: Complejo de implementar

**Recomendación inicial:** LWW con opción de ver historial

---

## Background Sync

```dart
// Usar WorkManager para Android
class SyncWorker extends Worker {
  @override
  Future<void> perform() async {
    final syncService = getIt<SyncService>();
    await syncService.syncAll();
  }
}

// Programar sync periódico
void scheduleSyncWorker() {
  Workmanager().registerPeriodicTask(
    'sync-task',
    'syncAllData',
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );
}
```

---

## Migración de Esquema

Al agregar sincronización, ejecutar migración:

```dart
class Migration2 extends Migration {
  @override
  Future<void> migrate(Migrator m, int from, int to) async {
    if (from == 1 && to == 2) {
      // Agregar campo UUID
      await m.addColumn(reminders, reminders.uuid);

      // Generar UUIDs para registros existentes
      final existing = await (select(reminders)).get();
      for (final reminder in existing) {
        await (update(reminders)
              ..where((r) => r.id.equals(reminder.id)))
            .write(RemindersCompanion(
              uuid: Value(const Uuid().v4()),
            ));
      }
    }
  }
}
```

---

## Consideraciones

### Seguridad
- Autenticación con JWT
- HTTPS obligatorio
- Encriptar datos sensibles en tránsito y reposo

### Performance
- Sincronizar en background
- Paginar descarga de cambios grandes
- Comprimir payloads

### UX
- Indicador de sync status en UI
- Notificar cuando hay conflictos
- Permitir modo "solo local" (sin sync)

### Costos
- Considerar Firebase (gratuito para apps pequeñas)
- O backend propio con PostgreSQL
- Estimar: ~10MB/usuario/mes de datos
