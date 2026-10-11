import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/localization.dart';
import 'core/theme.dart';
import 'presentation/screens/admin_dashboard.dart';
import 'presentation/screens/ar_dashboard.dart';
import 'presentation/screens/hod_dashboard_redesigned.dart';
import 'presentation/screens/dean_dashboard.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/student_home_screen.dart';
import 'presentation/screens/student_academic_record_screen.dart';
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
    final appService = Provider.of<AppService>(context);

    return ValueListenableBuilder<String>(
      valueListenable: RuslLocalization.languageNotifier,
      builder: (context, lang, _) {
        return MaterialApp(
          key: ValueKey(lang),
          title: 'RUSL Smart Course Registration',
          debugShowCheckedModeBanner: false,
          theme: RuslTheme.lightTheme,
          darkTheme: RuslTheme.darkTheme,
          themeMode: appService.themeMode,
          home: !appService.isReady
              ? const _BrandedSplashScreen()
              : authService.isAuthenticated
              ? const MainShellScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}

class _BrandedSplashScreen extends StatelessWidget {
  const _BrandedSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuslColors.bgCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: RuslColors.primaryMaroon,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: RuslColors.primaryMaroon.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'RUSL',
                  style: TextStyle(
                    color: RuslColors.accentYellow,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rajarata University of Sri Lanka',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: RuslColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Faculty of Technology • Course Registration System',
              style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: RuslColors.primaryMaroon,
              ),
            ),
          ],
        ),
      ),
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
  int _hodPage = 0;
  int _adminPage = 0;
  int _arPage = 0;
  int _deanPage = 0;

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    final isStudent = appService.currentRole == UserRole.student;
    final isHod = appService.currentRole == UserRole.headOfDepartment;
    final isAdmin = appService.currentRole == UserRole.systemAdmin;
    final isAr = appService.currentRole == UserRole.assistantRegistrar;
    final isDean = appService.currentRole == UserRole.dean;

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
          5 => const StudentAcademicRecordScreen(),
          _ => const StudentProfileScreen(),
        };
        break;
      case UserRole.headOfDepartment:
        activeBody = HodDashboardRedesigned(
          selectedSection: _hodPage,
          onNavigate: (index) => setState(() => _hodPage = index),
        );
        break;
      case UserRole.assistantRegistrar:
        activeBody = ArDashboardScreen(
          selectedSection: _arPage,
          onNavigate: (index) => setState(() => _arPage = index),
        );
        break;
      case UserRole.dean:
        activeBody = DeanDashboardScreen(
          selectedSection: _deanPage,
          onNavigate: (index) => setState(() => _deanPage = index),
        );
        break;
      case UserRole.systemAdmin:
        activeBody = AdminDashboardScreen(
          selectedSection: _adminPage,
          onNavigate: (index) => setState(() => _adminPage = index),
        );
        break;
    }

    return PopScope(
      canPop: _canPopCurrentRole(appService.currentRole),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(appService.currentRole);
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBgColor,
        appBar: AppBar(
          leading: (isStudent || isHod || isAdmin || isAr || isDean)
              ? Builder(
                  builder: (drawerCtx) => IconButton(
                    tooltip: 'Open navigation menu',
                    icon: const Icon(Icons.menu_rounded, size: 26),
                    onPressed: () => Scaffold.of(drawerCtx).openDrawer(),
                  ),
                )
              : null,
          title: Text(
            isStudent
                ? _studentPageTitle
                : isHod
                ? _hodPageTitle
                : isAdmin
                ? _adminPageTitle
                : isAr
                ? _arPageTitle
                : isDean
                ? _deanPageTitle
                : '${appService.currentRole.displayName} Portal',
          ),
          actions: [
            IconButton(
              tooltip: appService.themeMode == ThemeMode.dark
                  ? 'Light Mode'
                  : 'Dark Mode',
              icon: Icon(
                appService.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                final newMode = appService.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                appService.switchThemeMode(newMode);
              },
            ),
            PopupMenuButton<String>(
              tooltip: 'Switch Language',
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    appService.currentLanguage.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onSelected: (code) => appService.switchLanguage(code),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'en', child: Text('English (EN)')),
                PopupMenuItem(value: 'si', child: Text('සිංහල (SI)')),
                PopupMenuItem(value: 'ta', child: Text('தமிழ் (TA)')),
              ],
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => NotificationModal.show(context),
              icon: Badge(
                isLabelVisible: appService.unreadNotificationCount > 0,
                label: Text(
                  appService.unreadNotificationCount > 9
                      ? '9+'
                      : '${appService.unreadNotificationCount}',
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: isStudent
            ? _StudentSidebar(
                selectedIndex: _studentPage,
                userName: user?.displayName ?? 'M. N. Mohamed Nafis',
                registrationNumber: user?.designationOrReg ?? 'ICT/2021/045',
                onSelected: (index) {
                  setState(() => _studentPage = index);
                  Navigator.pop(context);
                },
                onLogout: authService.logout,
              )
            : isHod
            ? _HodSidebar(
                selectedIndex: _hodPage,
                userName: user?.displayName ?? 'Dr. Lahiru Jayasuriya',
                designation:
                    user?.designationOrReg ?? 'Head of Department (HoD)',
                onSelected: (index) {
                  setState(() => _hodPage = index);
                  Navigator.pop(context);
                },
                onLogout: authService.logout,
              )
            : isAdmin
            ? AdminSidebar(
                selectedIndex: _adminPage,
                userName: user?.displayName ?? 'Mr. P. S. Palliyaguruge',
                onSelected: (index) {
                  setState(() => _adminPage = index);
                  Navigator.pop(context);
                },
                onLogout: authService.logout,
              )
            : isAr
            ? ArSidebar(
                selectedIndex: _arPage,
                userName: user?.displayName ?? 'Ms. K. H. Gaurika Kahawala',
                onSelected: (index) {
                  setState(() => _arPage = index);
                  Navigator.pop(context);
                },
                onLogout: authService.logout,
              )
            : isDean
            ? DeanSidebar(
                selectedIndex: _deanPage,
                userName: user?.displayName ?? 'Prof. T. C. Bamunuarachchige',
                onSelected: (index) {
                  setState(() => _deanPage = index);
                  Navigator.pop(context);
                },
                onLogout: authService.logout,
              )
            : null,
        body: SafeArea(child: activeBody),
      ),
    );
  }

  bool _canPopCurrentRole(UserRole role) {
    return switch (role) {
      UserRole.student => _studentPage == 0,
      UserRole.headOfDepartment => _hodPage == 0,
      UserRole.assistantRegistrar => _arPage == 0,
      UserRole.dean => _deanPage == 0,
      UserRole.systemAdmin => _adminPage == 0,
    };
  }

  void _handleBackPress(UserRole role) {
    setState(() {
      switch (role) {
        case UserRole.student:
          _studentPage = 0;
          break;
        case UserRole.headOfDepartment:
          _hodPage = 0;
          break;
        case UserRole.assistantRegistrar:
          _arPage = 0;
          break;
        case UserRole.dean:
          _deanPage = 0;
          break;
        case UserRole.systemAdmin:
          _adminPage = 0;
          break;
      }
    });
  }

  String get _studentPageTitle => const [
    'Student Home',
    'Subject Registration',
    'My Timetable',
    'Special Requests',
    'Registration Status',
    'Academic Record',
    'My Profile',
  ][_studentPage];

  String get _hodPageTitle => const [
    'Department Overview',
    'Endorsement Queue',
    'Course Offerings & Lecturers',
    'Timetable Scheduling',
    'Special Petitions & Waivers',
    'Batch Student Directory',
    'Department Reports & Analytics',
    'HoD Profile & Authority',
  ][_hodPage];

  String get _adminPageTitle => const [
    'System Overview',
    'Staff & Roles',
    'Student Directory',
    'Academic Structure',
    'Registration Periods',
    'System Settings',
    'Audit Logs',
    'Admin Profile',
  ][_adminPage];

  String get _arPageTitle => const [
    'Registry Overview',
    'Official Sealing Queue',
    'Faculty Student Registry',
    'Exam Compliance & Lists',
    'Registration Freeze Control',
    'Verification & Slips',
    'Academic Records',
    'AR Profile & Authority',
  ][_arPage];

  String get _deanPageTitle => const [
    'Faculty Overview',
    'Faculty Endorsement Queue',
    'Faculty Departments',
    'Faculty Student Registry',
    'Special Petitions & Appeals',
    'Faculty Academic Staff',
    'Faculty Reports & Analytics',
    'Dean Profile & Authority',
  ][_deanPage];
}

class _RuslSidebarDestination {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String title;
  final String subtitle;

  const _RuslSidebarDestination(
    this.selectedIcon,
    this.unselectedIcon,
    this.title,
    this.subtitle,
  );
}

class _RuslSidebar extends StatelessWidget {
  final int selectedIndex;
  final String portalTitle;
  final String portalSubtitle;
  final IconData portalIcon;
  final String userName;
  final String userSubtitle;
  final IconData userAvatarIcon;
  final List<_RuslSidebarDestination> destinations;
  final Widget? extraCard;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _RuslSidebar({
    required this.selectedIndex,
    required this.portalTitle,
    required this.portalSubtitle,
    required this.portalIcon,
    required this.userName,
    required this.userSubtitle,
    required this.userAvatarIcon,
    required this.destinations,
    this.extraCard,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();

    return Drawer(
      width: 320,
      backgroundColor: context.surfaceColor,
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
                    child: Icon(portalIcon, color: RuslColors.darkText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portalTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          portalSubtitle,
                          style: const TextStyle(
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
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: RuslColors.accentYellow,
                      child: Icon(userAvatarIcon, color: RuslColors.darkText),
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
                            userSubtitle,
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
                            child: Icon(
                              selected
                                  ? item.selectedIcon
                                  : item.unselectedIcon,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
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
            if (extraCard != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: extraCard!,
              ),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: context.cardSubtleColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 19),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Academic Year',
                            style: TextStyle(
                              fontSize: 10,
                              color: RuslColors.textMuted,
                            ),
                          ),
                          Text(
                            app.currentAcademicYearLabel,
                            style: const TextStyle(
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
      _RuslSidebarDestination(
        Icons.home_rounded,
        Icons.home_outlined,
        'Home',
        'News and overview',
      ),
      _RuslSidebarDestination(
        Icons.app_registration_rounded,
        Icons.app_registration_outlined,
        'Subject Registration',
        'Select and submit',
      ),
      _RuslSidebarDestination(
        Icons.calendar_month_rounded,
        Icons.calendar_month_outlined,
        'My Timetable',
        'Weekly class schedule',
      ),
      _RuslSidebarDestination(
        Icons.description_rounded,
        Icons.description_outlined,
        'Special Requests',
        'Academic exceptions',
      ),
      _RuslSidebarDestination(
        Icons.fact_check_rounded,
        Icons.fact_check_outlined,
        'Registration Status',
        'Track your approval',
      ),
      _RuslSidebarDestination(
        Icons.history_edu_rounded,
        Icons.history_edu_outlined,
        'Academic Record',
        'Subjects and credits',
      ),
      _RuslSidebarDestination(
        Icons.person_rounded,
        Icons.person_outline_rounded,
        'My Profile',
        'Academic information',
      ),
    ];

    return _RuslSidebar(
      selectedIndex: selectedIndex,
      portalTitle: 'RUSL Student Portal',
      portalSubtitle: 'Academic Services',
      portalIcon: Icons.school_rounded,
      userName: userName,
      userSubtitle: registrationNumber,
      userAvatarIcon: Icons.person_rounded,
      destinations: destinations,
      onSelected: onSelected,
      onLogout: onLogout,
    );
  }
}

class _HodSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final String designation;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _HodSidebar({
    required this.selectedIndex,
    required this.userName,
    required this.designation,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const destinations = [
      _RuslSidebarDestination(
        Icons.dashboard_rounded,
        Icons.dashboard_outlined,
        'Overview',
        'Batch registration progress & summary',
      ),
      _RuslSidebarDestination(
        Icons.verified_user_rounded,
        Icons.verified_user_outlined,
        'Endorsement Queue',
        'Student submissions awaiting endorsement',
      ),
      _RuslSidebarDestination(
        Icons.menu_book_rounded,
        Icons.menu_book_outlined,
        'Course Offerings & Lecturers',
        'Semester courses & enrollment distribution',
      ),
      _RuslSidebarDestination(
        Icons.calendar_month_rounded,
        Icons.calendar_month_outlined,
        'Timetable Scheduling',
        'Assign lecture slots & clash-free schedules',
      ),
      _RuslSidebarDestination(
        Icons.assignment_turned_in_rounded,
        Icons.assignment_turned_in_outlined,
        'Special Petitions',
        'Credit overload & prerequisite waivers',
      ),
      _RuslSidebarDestination(
        Icons.groups_rounded,
        Icons.groups_outlined,
        'Batch Student Directory',
        'ICT Level 3 cohort student roster',
      ),
      _RuslSidebarDestination(
        Icons.assessment_rounded,
        Icons.assessment_outlined,
        'Department Analytics',
        'Curriculum progression & Senate reports',
      ),
      _RuslSidebarDestination(
        Icons.badge_rounded,
        Icons.badge_outlined,
        'HoD Profile & Authority',
        'Head credentials & university seal',
      ),
    ];

    return _RuslSidebar(
      selectedIndex: selectedIndex,
      portalTitle: 'RUSL HoD Portal',
      portalSubtitle: 'Dept. of ICT • Faculty of Technology',
      portalIcon: Icons.account_balance_rounded,
      userName: userName,
      userSubtitle: designation,
      userAvatarIcon: Icons.school_rounded,
      destinations: destinations,
      extraCard: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.cardSubtleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.corporate_fare_rounded, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JURISDICTION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: RuslColors.textMuted,
                    ),
                  ),
                  Text(
                    'Dept. of ICT • 148 Students (L3)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onSelected: onSelected,
      onLogout: onLogout,
    );
  }
}
