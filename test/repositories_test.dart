import 'package:flutter_test/flutter_test.dart';
import 'package:course_registration/data/repositories/academic_repository.dart';
import 'package:course_registration/data/repositories/notification_repository.dart';
import 'package:course_registration/data/repositories/registration_repository.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/domain/models.dart';

void main() {
  group('AcademicRepository & Mock Implementation', () {
    late AcademicRepository repository;

    setUp(() {
      repository = MockAcademicRepository();
    });

    test('getFaculties returns faculties with valid codes and departments count', () {
      final faculties = repository.getFaculties();
      expect(faculties.isNotEmpty, isTrue);
      expect(faculties.any((f) => f.code == 'FOT'), isTrue);
      expect(faculties.any((f) => f.name.contains('Technology')), isTrue);
    });

    test('getDepartments returns departments linked to existing faculties', () {
      final departments = repository.getDepartments();
      final faculties = repository.getFaculties();
      final facultyIds = faculties.map((f) => f.id).toSet();

      expect(departments.isNotEmpty, isTrue);
      expect(departments.every((d) => facultyIds.contains(d.facultyId)), isTrue);
      expect(departments.any((d) => d.name.contains('Information & Communication')), isTrue);
    });

    test('getCourses returns courses with valid credit values and types', () {
      final courses = repository.getCourses();
      expect(courses.isNotEmpty, isTrue);
      expect(courses.every((c) => c.creditValue > 0), isTrue);
      expect(courses.any((c) => c.courseType == CourseType.compulsory), isTrue);
      expect(courses.any((c) => c.courseType == CourseType.elective), isTrue);
    });

    test('getCourseOfferings returns offerings with slots and capacities', () {
      final offerings = repository.getCourseOfferings();
      expect(offerings.isNotEmpty, isTrue);
      expect(offerings.every((o) => o.maxCapacity > 0), isTrue);
      expect(offerings.any((o) => o.slots.isNotEmpty), isTrue);
    });

    test('getDegreeProgrammes returns seeded FOT degree programmes', () {
      final programmes = repository.getDegreeProgrammes();
      expect(programmes.isNotEmpty, isTrue);
      expect(programmes.any((p) => p.code == 'BICT'), isTrue);
      expect(programmes.any((p) => p.code == 'BET'), isTrue);
    });

    test('getCurriculums returns seeded 2024 Version 2.1 curriculum', () {
      final curriculums = repository.getCurriculums();
      expect(curriculums.isNotEmpty, isTrue);
      expect(curriculums.any((c) => c.version.contains('2024 Version 2.1')), isTrue);
    });
  });

  group('NotificationRepository & Mock Implementation', () {
    late NotificationRepository repository;

    setUp(() {
      repository = MockNotificationRepository();
    });

    test('getNotifications returns initial notifications', () {
      final notifications = repository.getNotifications();
      expect(notifications.isNotEmpty, isTrue);
    });

    test('addNotification prepends notification at index 0', () {
      final initialCount = repository.getNotifications().length;
      final newNotif = AppNotification(
        id: 'test_notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Notification',
        message: 'Test message body',
        timestamp: DateTime.now(),
        type: NotificationType.system,
      );

      repository.addNotification(newNotif);
      final updated = repository.getNotifications();

      expect(updated.length, equals(initialCount + 1));
      expect(updated.first.id, equals(newNotif.id));
      expect(updated.first.title, equals('Test Notification'));
    });

    test('markAsRead marks specified notification as read', () {
      final notif = AppNotification(
        id: 'unread_target',
        title: 'Unread Alert',
        message: 'Alert body',
        timestamp: DateTime.now(),
        isRead: false,
        type: NotificationType.approval,
      );
      repository.addNotification(notif);

      expect(repository.getNotifications().firstWhere((n) => n.id == 'unread_target').isRead, isFalse);

      repository.markAsRead('unread_target');
      expect(repository.getNotifications().firstWhere((n) => n.id == 'unread_target').isRead, isTrue);
    });

    test('markAllAsRead sets isRead to true across all notifications', () {
      repository.markAllAsRead();
      expect(repository.getNotifications().every((n) => n.isRead), isTrue);
    });

    test('addAuditLog prepends audit log at index 0', () {
      final initialCount = repository.getAuditLogs().length;
      final newLog = AuditLog(
        id: 'test_log_${DateTime.now().millisecondsSinceEpoch}',
        userName: 'Auditor',
        userRole: 'Security Officer',
        action: 'TEST_AUDIT',
        details: 'Audit trail verification',
        timestamp: DateTime.now(),
      );

      repository.addAuditLog(newLog);
      final updated = repository.getAuditLogs();

      expect(updated.length, equals(initialCount + 1));
      expect(updated.first.id, equals(newLog.id));
      expect(updated.first.action, equals('TEST_AUDIT'));
    });
  });

  group('RegistrationRepository & Mock Implementation', () {
    late RegistrationRepository repository;

    setUp(() {
      repository = MockRegistrationRepository();
    });

    test('getActiveStudent returns complete student profile', () {
      final student = repository.getActiveStudent();
      expect(student.registrationNumber, equals('ICT/2021/045'));
      expect(student.fullName, equals('M. N. Mohamed Nafis'));
      expect(student.currentLevel, equals(3));
      expect(student.currentSemester, equals(1));
    });

    test('getWaitingListEntries returns student waiting list', () {
      final student = repository.getActiveStudent();
      final entries = repository.getWaitingListEntries(student.id);
      expect(entries, isNotNull);
    });

    test('getSpecialRequests returns special petitions for student', () {
      final student = repository.getActiveStudent();
      final requests = repository.getSpecialRequests(student.id, student.fullName);
      expect(requests, isNotNull);
      expect(requests.every((r) => r.studentId == student.id), isTrue);
    });
  });
}
