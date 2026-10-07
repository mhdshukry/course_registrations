import '../../domain/models.dart';
import '../mock_data.dart';

abstract class NotificationRepository {
  List<AppNotification> getNotifications();
  void addNotification(AppNotification notification);
  void markAsRead(String id);
  void markAllAsRead();

  List<AuditLog> getAuditLogs();
  void addAuditLog(AuditLog log);
}

class MockNotificationRepository implements NotificationRepository {
  List<AppNotification>? _notifications;
  List<AuditLog>? _auditLogs;

  @override
  List<AppNotification> getNotifications() {
    _notifications ??= MockData.getInitialNotifications();
    return _notifications!;
  }

  @override
  void addNotification(AppNotification notification) {
    _notifications ??= MockData.getInitialNotifications();
    _notifications!.insert(0, notification);
  }

  @override
  void markAsRead(String id) {
    _notifications ??= MockData.getInitialNotifications();
    final notif = _notifications!.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Not found'),
    );
    notif.isRead = true;
  }

  @override
  void markAllAsRead() {
    _notifications ??= MockData.getInitialNotifications();
    for (var n in _notifications!) {
      n.isRead = true;
    }
  }

  @override
  List<AuditLog> getAuditLogs() {
    _auditLogs ??= MockData.getAuditLogs();
    return _auditLogs!;
  }

  @override
  void addAuditLog(AuditLog log) {
    _auditLogs ??= MockData.getAuditLogs();
    _auditLogs!.insert(0, log);
  }
}
