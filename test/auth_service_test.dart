import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService - Authentication & Password Credentials', () {
    test('authenticates successfully with universal demo password RuslPass#2026', () async {
      final auth = AuthService();
      final success = await auth.login('student_nafis', 'RuslPass#2026');

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.role, equals(UserRole.student));
      expect(auth.currentUser?.displayName, equals('M. N. Mohamed Nafis'));
      expect(auth.errorMessage, isNull);
    });

    test('authenticates each role with its dedicated role credential', () async {
      final auth = AuthService();

      // Student dedicated password
      expect(await auth.login('student_nafis', 'Std@Rusl#2026'), isTrue);
      expect(auth.currentUser?.role, equals(UserRole.student));

      // HoD dedicated password
      expect(await auth.login('hod_perera', 'Hod@Rusl#2026'), isTrue);
      expect(auth.currentUser?.role, equals(UserRole.headOfDepartment));

      // AR dedicated password
      expect(await auth.login('ar_dilhani', 'Ar@Rusl#2026'), isTrue);
      expect(auth.currentUser?.role, equals(UserRole.assistantRegistrar));

      // Dean dedicated password
      expect(await auth.login('dean_fot', 'Dean@Rusl#2026'), isTrue);
      expect(auth.currentUser?.role, equals(UserRole.dean));

      // Admin dedicated password
      expect(await auth.login('sys_admin', 'Admin@Rusl#2026'), isTrue);
      expect(auth.currentUser?.role, equals(UserRole.systemAdmin));
    });

    test('authenticates case-insensitively using username, email, or reg number', () async {
      final auth = AuthService();

      // Username uppercase
      expect(await auth.login('STUDENT_NAFIS', 'RuslPass#2026'), isTrue);

      // Email lowercase
      expect(await auth.login('student.nafis@rjt.ac.lk', 'RuslPass#2026'), isTrue);

      // Registration number
      expect(await auth.login('ICT/2021/045', 'RuslPass#2026'), isTrue);
    });

    test('fails login with invalid password and sets appropriate error message', () async {
      final auth = AuthService();
      final success = await auth.login('student_nafis', 'WrongPassword123');

      expect(success, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
      expect(auth.errorMessage, contains('Incorrect username or password'));
    });

    test('fails login with non-existent account and sets error message', () async {
      final auth = AuthService();
      final success = await auth.login('unknown_user', 'RuslPass#2026');

      expect(success, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, contains('Incorrect username or password'));
    });
  });

  group('AuthService - Quick Role Login & Session State', () {
    test('quickLogin sets currentUser and role instantaneously', () {
      final auth = AuthService();

      auth.quickLogin(UserRole.headOfDepartment);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.role, equals(UserRole.headOfDepartment));
      expect(auth.currentUser?.displayName, equals('Dr. Lahiru Jayasuriya'));
      expect(auth.sessionStartTime, isNotNull);
      expect(auth.lastActivityTime, isNotNull);
    });

    test('quickLogin covers all five university roles cleanly', () {
      final auth = AuthService();

      for (final role in UserRole.values) {
        auth.quickLogin(role);
        expect(auth.currentUser?.role, equals(role));
        expect(auth.currentUser?.id, isNotEmpty);
      }
    });

    test('logout clears user profile, session timestamps, and errors', () {
      final auth = AuthService();
      auth.quickLogin(UserRole.student);
      expect(auth.isAuthenticated, isTrue);

      auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
      expect(auth.sessionStartTime, isNull);
      expect(auth.lastActivityTime, isNull);
      expect(auth.errorMessage, isNull);
    });

    test('recordActivity updates lastActivityTime when authenticated', () async {
      final auth = AuthService();
      auth.quickLogin(UserRole.student);

      final initial = auth.lastActivityTime;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      auth.recordActivity();

      expect(auth.lastActivityTime?.isAfter(initial!), isTrue);
    });
  });

  group('AuthService - Remember Me Persistence', () {
    test('persists remembered username when rememberMe is true', () async {
      final auth = AuthService();
      await auth.login('student_nafis', 'RuslPass#2026', rememberMe: true);

      final remembered = await AuthService.getRememberedUsername();
      final isRemembered = await AuthService.getRememberMe();

      expect(remembered, equals('student_nafis'));
      expect(isRemembered, isTrue);
    });

    test('clears remembered username when rememberMe is false', () async {
      final auth = AuthService();
      await auth.login('student_nafis', 'RuslPass#2026', rememberMe: false);

      final remembered = await AuthService.getRememberedUsername();
      final isRemembered = await AuthService.getRememberMe();

      expect(remembered, isNull);
      expect(isRemembered, isFalse);
    });
  });
}
