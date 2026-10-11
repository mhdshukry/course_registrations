import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/core/localization.dart';
import 'package:course_registration/main.dart';
import 'package:course_registration/presentation/screens/login_screen.dart';
import 'package:course_registration/presentation/screens/hod_dashboard_redesigned.dart';
import 'package:course_registration/presentation/screens/ar_dashboard.dart';
import 'package:course_registration/presentation/screens/registration_status_pro_screen.dart';
import 'package:course_registration/presentation/screens/student_academic_record_screen.dart';
import 'package:course_registration/presentation/screens/admin_dashboard.dart';
import 'package:course_registration/presentation/screens/dean_dashboard.dart';
import 'package:course_registration/presentation/widgets/notification_modal.dart';
import 'package:course_registration/services/app_service.dart';
import 'package:course_registration/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RuslLocalization.currentLanguage = 'en';
  });

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
    expect(find.textContaining('Welcome, M. N. Mohamed Nafis'), findsOneWidget);
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
    expect(find.textContaining('3.79'), findsOneWidget);
  });

  testWidgets(
    'Head of Department sees departmental endorsements and management',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final appService = AppService();
      authService.quickLogin(UserRole.headOfDepartment);
      appService.switchRole(UserRole.headOfDepartment);

      await tester.pumpWidget(
        createTestWidget(authService: authService, appService: appService),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Department'), findsWidgets);
    },
  );

  testWidgets('System Administrator has responsive working management pages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService();
    final appService = AppService();
    authService.quickLogin(UserRole.systemAdmin);
    appService.switchRole(UserRole.systemAdmin);

    await tester.pumpWidget(
      createTestWidget(authService: authService, appService: appService),
    );
    await tester.pumpAndSettle();

    expect(find.text('System Overview'), findsOneWidget);
    expect(find.text('System Administration Overview'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staff & Roles'));
    await tester.pumpAndSettle();

    expect(find.text('Staff & Role Governance'), findsOneWidget);
    expect(find.text('Add Staff Member'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registration Periods'));
    await tester.pumpAndSettle();

    expect(find.text('Registration Periods'), findsWidgets);
    expect(find.textContaining('Registration Windows'), findsWidgets);
  });

  testWidgets('Dean sees only faculty-scoped governance and departments', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService();
    final appService = AppService();
    authService.quickLogin(UserRole.dean);
    appService.switchRole(UserRole.dean);

    await tester.pumpWidget(
      createTestWidget(authService: authService, appService: appService),
    );
    await tester.pumpAndSettle();

    expect(find.text('Faculty Overview'), findsOneWidget);
    expect(find.text('Faculty of Technology'), findsWidgets);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Departments'));
    await tester.pumpAndSettle();

    expect(find.text('Faculty Departments'), findsWidgets);
    expect(find.text('Information & Communication Technology'), findsOneWidget);
    expect(find.text('Biological Sciences'), findsNothing);
  });

  testWidgets(
    'Assistant Registrar has full multi-page portal with drawer and sealing queue',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final appService = AppService();
      authService.quickLogin(UserRole.assistantRegistrar);
      appService.switchRole(UserRole.assistantRegistrar);

      await tester.pumpWidget(
        createTestWidget(authService: authService, appService: appService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registry Overview'), findsOneWidget);
      expect(find.text('Registrar Fast Actions & Governance'), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Official Sealing Queue'));
      await tester.pumpAndSettle();

      expect(find.text('Official Sealing Queue'), findsWidgets);
    },
  );

  testWidgets(
    'Assistant Registrar portal adapts cleanly to mobile without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final appService = AppService();
      authService.quickLogin(UserRole.assistantRegistrar);
      appService.switchRole(UserRole.assistantRegistrar);

      await tester.pumpWidget(
        createTestWidget(authService: authService, appService: appService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registry Overview'), findsOneWidget);
      expect(find.text('Registrar Actions'), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Official Sealing Queue'));
      await tester.pumpAndSettle();

      expect(find.text('Official Sealing Queue'), findsWidgets);
      expect(find.text('Seal All'), findsOneWidget);
    },
  );

  testWidgets('Assistant Registrar has a separate Academic Records page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService()..quickLogin(UserRole.assistantRegistrar);
    final appService = AppService()..switchRole(UserRole.assistantRegistrar);

    await tester.pumpWidget(
      createTestWidget(authService: authService, appService: appService),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Academic Records'));
    await tester.pumpAndSettle();

    expect(
      find.text('Faculty Academic Records & Transcripts Registry'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Student and HoD portals render at narrow mobile width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final studentAuth = AuthService()..quickLogin(UserRole.student);
    final studentApp = AppService()..switchRole(UserRole.student);
    await tester.pumpWidget(
      createTestWidget(authService: studentAuth, appService: studentApp),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final hodAuth = AuthService()..quickLogin(UserRole.headOfDepartment);
    final hodApp = AppService()..switchRole(UserRole.headOfDepartment);
    await tester.pumpWidget(
      createTestWidget(authService: hodAuth, appService: hodApp),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Every HoD section is aligned at mobile width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.headOfDepartment);
    for (var section = 0; section < 8; section++) {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: HodDashboardRedesigned(selectedSection: section),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'HoD section $section');
    }
  });

  testWidgets('HoD can endorse a submitted registration without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.headOfDepartment);
    app.activeRegistrationStatus = RegistrationStatus.submitted;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppService>.value(
        value: app,
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: HodDashboardRedesigned(selectedSection: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Endorse'));
    await tester.tap(find.text('Endorse'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Registration Review'), findsNothing);
    expect(app.activeRegistrationStatus, RegistrationStatus.departmentApproved);
  });

  testWidgets(
    'HoD has dedicated timetable assigning page with clash prevention',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.headOfDepartment);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const Scaffold(
              body: HodDashboardRedesigned(selectedSection: 3),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Timetable Scheduling & Assignment'), findsOneWidget);
      expect(find.text('Assign Lecture Slot'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Open Assign Lecture Slot dialog
      await tester.tap(find.text('Assign Lecture Slot'));
      await tester.pumpAndSettle();

      expect(find.text('Assign Timetable Slot'), findsOneWidget);
      expect(find.text('Course Module (All Levels 1 - 4)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('student sees sealed-slip download only after AR sealing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.student);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppService>.value(
        value: app,
        child: const MaterialApp(
          home: Scaffold(body: RegistrationStatusProScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Download sealed registration slip'), findsNothing);

    app.activeRegistrationStatus = RegistrationStatus.registered;
    app.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('Download sealed registration slip'), findsOneWidget);
    expect(
      find.textContaining('submit the printed copy manually'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets(
    'AR Academic Records section opens directory by default and allows viewing any student transcript',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.assistantRegistrar);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(body: ArDashboardScreen(selectedSection: 6)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directory view is rendered
      expect(
        find.text('Faculty Academic Records & Transcripts Registry'),
        findsOneWidget,
      );
      expect(find.textContaining('Student Academic Directory'), findsOneWidget);

      // Verify Degree Honours Classification Metric Cards
      expect(find.text('1st Class (≥ 3.70)'), findsOneWidget);
      expect(find.text('2nd Class Upper (≥ 3.50)'), findsOneWidget);
      expect(find.text('2nd Class Lower (≥ 3.00)'), findsOneWidget);
      expect(find.text('Pass (≥ 2.00)'), findsOneWidget);
      expect(find.text('Batch Miss (< 2.00)'), findsOneWidget);

      // Verify "View Record" buttons exist for faculty students
      final viewRecordButtons = find.text('View Record');
      expect(viewRecordButtons, findsWidgets);

      // Scroll and tap the first student's "View Record"
      await tester.scrollUntilVisible(viewRecordButtons.first, 300);
      await tester.tap(viewRecordButtons.first);
      await tester.pumpAndSettle();

      // Verify detailed student transcript view is now opened
      expect(find.text('Back to Student Directory'), findsOneWidget);
      expect(find.text('Official Subject Outcome Register'), findsOneWidget);
      expect(find.text('Quick Switch: '), findsOneWidget);

      // Tap "Back to Student Directory"
      await tester.tap(find.text('Back to Student Directory'));
      await tester.pumpAndSettle();

      // Verify returned to the Directory
      expect(
        find.text('Faculty Academic Records & Transcripts Registry'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AR student record detail fits a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.assistantRegistrar);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppService>.value(
        value: app,
        child: const MaterialApp(
          home: Scaffold(body: ArDashboardScreen(selectedSection: 6)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('View Record').first, 300);
    await tester.tap(find.text('View Record').first);
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Completed credits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('student Academic Record page fits a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.student);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppService>.value(
        value: app,
        child: const MaterialApp(
          home: Scaffold(body: StudentAcademicRecordScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Official Academic Record'), findsOneWidget);
    expect(find.text('Completed credits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Admin Dashboard renders Overview, Hero Banner, and Quick Action Shortcuts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.systemAdmin);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(body: AdminDashboardScreen(selectedSection: 0)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System Administration Overview'), findsOneWidget);
      expect(find.text('RUSL CENTRAL ADMIN CONSOLE'), findsOneWidget);
      expect(find.text('Active Undergraduates'), findsOneWidget);
      expect(find.text('Privileged Staff Officers'), findsOneWidget);
      expect(find.text('Platform SLA & Uptime'), findsOneWidget);
      expect(find.text('Staff & Permissions'), findsOneWidget);
      expect(find.text('Student Directory'), findsWidgets);
      expect(find.text('Registration Windows'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Admin Dashboard renders Staff & Roles section with staff cards and role tags',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.systemAdmin);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(body: AdminDashboardScreen(selectedSection: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Staff & Role Governance'), findsOneWidget);
      expect(find.text('Total Staff: '), findsOneWidget);
      expect(find.text('SysAdmins: '), findsOneWidget);
      expect(find.text('Add Staff Member'), findsOneWidget);
      expect(find.text('Mr. P. S. Palliyaguruge'), findsOneWidget);
      expect(find.text('Dr. Lahiru Jayasuriya'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Admin Dashboard renders Student Directory with Faculty, Department, and Degree Standing badges',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.systemAdmin);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(body: AdminDashboardScreen(selectedSection: 2)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Undergraduate Student Directory'), findsOneWidget);
      expect(find.text('FACULTY SELECTION'), findsOneWidget);
      expect(find.textContaining('DEPARTMENT ROSTER'), findsOneWidget);
      expect(find.text('Enroll Student'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('M. N. Mohamed Nafis'), 300);
      expect(find.text('M. N. Mohamed Nafis'), findsOneWidget);
      expect(find.text('1st Class'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Admin Dashboard renders Registration Periods with regulatory constraints',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final app = AppService()..switchRole(UserRole.systemAdmin);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(body: AdminDashboardScreen(selectedSection: 4)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Registration Windows & Calendar Control'),
        findsOneWidget,
      );
      expect(find.text('Extend Deadline (+7 Days)'), findsOneWidget);
      expect(find.text('Dropped Courses Prohibition'), findsOneWidget);
      expect(find.text('Repeat Upgrading Cap (C-, D+, D, D-)'), findsOneWidget);
      expect(find.text('Medical Concession Repeat Provision'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every Admin section renders without mobile overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.systemAdmin);
    final auth = AuthService()..quickLogin(UserRole.systemAdmin);
    for (var section = 0; section < 8; section++) {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppService>.value(value: app),
            ChangeNotifierProvider<AuthService>.value(value: auth),
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: AdminDashboardScreen(selectedSection: section),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin section $section');
    }
  });

  testWidgets('every Dean section renders without mobile overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppService()..switchRole(UserRole.dean);
    for (var section = 0; section < 5; section++) {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppService>.value(
          value: app,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: DeanDashboardScreen(
                selectedSection: section,
                onNavigate: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Dean section $section');
    }
  });
}
