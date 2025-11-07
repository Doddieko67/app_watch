import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/notification_service.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  final service = NotificationService();
  // Inicializar el servicio al crearlo
  service.initialize();
  return service;
}
