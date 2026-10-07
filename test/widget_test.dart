import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/core/localization.dart';
import 'package:course_registration/main.dart';
import 'package:course_registration/presentation/screens/login_screen.dart';
import 'package:course_registration/presentation/widgets/notification_modal.dart';
import 'package:course_registration/services/app_service.dart';
import 'package:course_registration/services/auth_service.dart';

void main() {
  setUp(() => RuslLocalization.currentLanguage = 'en');

  Widget createTestWidget({AuthService? authService, AppService? appService}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService ?? AuthService()),
        ChangeNotifierProvider(create: (_) => appService ?? AppService()),
      ],
      child: const RuslCourseRegistrationApp(),
    );
  }

  testWidgets('Renders LoginScreen on unauthenticated app startup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(RuslLocalization.tr('sign_in_title')), findsOneWidget);
    expect(find.text(RuslLocalization.tr('sign_in_btn')), findsOneWidget);
  });

  testWidgets('Allows trilingual language switching on LoginScreen', (
    WidgetTester tester,
  ) async {
    final appService = AppService();
    await tester.pumpWidget(createTestWidget(appService: appService));
    await tester.pumpAndSettle();

    // Switch to Sinhala
    final sinhalaChip = find.text('සිංහල');
    expect(sinhalaChip, findsOneWidget);
    await tester.tap(sinhalaChip);
    await tester.pumpAndSettle();

    expect(appService.currentLanguage, equals('si'));

    // Switch to Tamil
    final tamilChip = find.text('தமிழ்');
    expect(tamilChip, findsOneWidget);
    await tester.tap(tamilChip);
    await tester.pumpAndSettle();

    expect(appService.currentLanguage, equals('ta'));
  });

  testWidgets('Authenticates student and displays production student home', (
    WidgetTester tester,
  ) async {
    final authService = AuthService();
    final appService = AppService();

    await tester.pumpWidget(
      createTestWidget(authService: authService, appService: appService),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'student_nafis');
    await tester.enterText(fields.at(1), 'RuslPass#2026');

    // Tap sign in
    final signInBtn = find.text(RuslLocalization.tr('sign_in_btn'));
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    expect(authService.isAuthenticated, isTrue);
    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('Student Home'), findsOneWidget);
    expect(find.textContaining('Welcome, Nafis'), findsOneWidget);
  });

  testWidgets(
    'Notification bell shows unread count and opens NotificationModal',
    (WidgetTester tester) async {
      final authService = AuthService();
      final appService = AppService();

      // Auto login
      authService.quickLogin(UserRole.student);

      await tester.pumpWidget(
        createTestWidget(authService: authService, appService: appService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Student Home'), findsOneWidget);

      // Tap notification bell
      final bellFinder = find.byIcon(Icons.notifications_outlined);
      expect(bellFinder, findsOneWidget);
      await tester.tap(bellFinder);
      await tester.pumpAndSettle();

      // Verify NotificationModal is presented
      expect(find.byType(NotificationModal), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    },
  );

  testWidgets('Student drawer opens registration and profile pages', (
    WidgetTester tester,
  ) async {
    final authService = AuthService();
    authService.quickLogin(UserRole.student);
    await tester.pumpWidget(createTestWidget(authService: authService));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subject Registration'));
    await tester.pumpAndSettle();
    expect(find.text('Semester Subject Registration'), findsOneWidget);
    expect(find.textContaining('Compulsory'), findsWidgets);
    expect(find.textContaining('Optional'), findsWidgets);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Drawer), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Current CGPA'), findsOneWidget);
    expect(find.text('3.42'), findsOneWidget);
  });
}
