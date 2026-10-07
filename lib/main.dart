import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/localization.dart';
import 'core/theme.dart';
import 'presentation/screens/admin_dashboard.dart';
import 'presentation/screens/adviser_dashboard.dart';
import 'presentation/screens/ar_dashboard.dart';
import 'presentation/screens/coordinator_dashboard.dart';
import 'presentation/screens/hod_dashboard.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/student_home_screen.dart';
import 'presentation/screens/student_profile_screen.dart';
import 'presentation/screens/subject_registration_pro_screen.dart';
import 'presentation/screens/registration_status_pro_screen.dart';
import 'presentation/screens/student_timetable_screen.dart';
import 'presentation/screens/special_requests_screen.dart';
import 'presentation/widgets/notification_modal.dart';
import 'services/app_service.dart';
import 'services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppService()),
      ],
      child: const RuslCourseRegistrationApp(),
    ),
  );
}

class RuslCourseRegistrationApp extends StatelessWidget {
  const RuslCourseRegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return ValueListenableBuilder<String>(
      valueListenable: RuslLocalization.languageNotifier,
      builder: (context, lang, _) {
        return MaterialApp(
          key: ValueKey(lang),
          title: 'RUSL Smart Course Registration',
          debugShowCheckedModeBanner: false,
          theme: RuslTheme.lightTheme,
          home: authService.isAuthenticated
              ? const MainShellScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _studentPage = 0;

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    Widget activeBody;
    switch (appService.currentRole) {
      case UserRole.student:
        activeBody = switch (_studentPage) {
          0 => const StudentHomeScreen(),
          1 => const SubjectRegistrationProScreen(),
          2 => const StudentTimetableScreen(),
          3 => const SpecialRequestsScreen(),
          4 => RegistrationStatusProScreen(
            onEditRegistration: () => setState(() => _studentPage = 1),
          ),
          _ => const StudentProfileScreen(),
        };
        break;
      case UserRole.academicAdviser:
      case UserRole.lecturer:
        activeBody = const AdviserDashboardScreen();
        break;
      case UserRole.headOfDepartment:
        activeBody = const HodDashboardScreen();
        break;
      case UserRole.facultyCoordinator:
        activeBody = const CoordinatorDashboardScreen();
        break;
      case UserRole.assistantRegistrar:
        activeBody = const ArDashboardScreen();
        break;
      case UserRole.centralAdmin:
      case UserRole.systemAdmin:
        activeBody = const AdminDashboardScreen();
        break;
    }

    final isStudent = appService.currentRole == UserRole.student;
    return Scaffold(
      backgroundColor: RuslColors.bgCream,
      appBar: AppBar(
        title: Text(
          isStudent
              ? _studentPageTitle
              : '${appService.currentRole.displayName} Portal',
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => NotificationModal.show(context),
            icon: Badge(
              isLabelVisible: appService.unreadNotificationCount > 0,
              label: Text('${appService.unreadNotificationCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isStudent
          ? _StudentSidebar(
              selectedIndex: _studentPage,
              userName: user?.displayName ?? '',
              registrationNumber: user?.designationOrReg ?? '',
              onSelected: (index) {
                setState(() => _studentPage = index);
                Navigator.pop(context);
              },
              onLogout: authService.logout,
            )
          : null,
      body: SafeArea(child: activeBody),
    );
  }

  String get _studentPageTitle => const [
    'Student Home',
    'Subject Registration',
    'My Timetable',
    'Special Requests',
    'Registration Status',
    'My Profile',
  ][_studentPage];
}

class _StudentSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final String registrationNumber;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _StudentSidebar({
    required this.selectedIndex,
    required this.userName,
    required this.registrationNumber,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_rounded, Icons.home_outlined, 'Home', 'News and overview'),
      (
        Icons.app_registration_rounded,
        Icons.app_registration_outlined,
        'Subject Registration',
        'Select and submit',
      ),
      (
        Icons.calendar_month_rounded,
        Icons.calendar_month_outlined,
        'My Timetable',
        'Weekly class schedule',
      ),
      (
        Icons.description_rounded,
        Icons.description_outlined,
        'Special Requests',
        'Academic exceptions',
      ),
      (
        Icons.fact_check_rounded,
        Icons.fact_check_outlined,
        'Registration Status',
        'Track your approval',
      ),
      (
        Icons.person_rounded,
        Icons.person_outline_rounded,
        'My Profile',
        'Academic information',
      ),
    ];
    return Drawer(
      width: 320,
      backgroundColor: RuslColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: RuslColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RUSL Student Portal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Academic Services',
                          style: TextStyle(
                            fontSize: 11,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: RuslColors.darkText,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 23,
                      backgroundColor: RuslColors.accentYellow,
                      child: Icon(
                        Icons.person_rounded,
                        color: RuslColors.darkText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            registrationNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: RuslColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 13, 24, 8),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: RuslColors.textMuted,
                ),
              ),
            ),
            ...destinations.indexed.map((entry) {
              final index = entry.$1;
              final item = entry.$2;
              final selected = selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                child: Material(
                  color: selected
                      ? RuslColors.accentYellow.withValues(alpha: .28)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: selected
                                  ? RuslColors.accentYellow
                                  : RuslColors.cardSubtle,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(selected ? item.$1 : item.$2, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$3,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  item.$4,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 19),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Year',
                            style: TextStyle(
                              fontSize: 10,
                              color: RuslColors.textMuted,
                            ),
                          ),
                          Text(
                            '2025/2026 • Semester 1',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Sign out'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
