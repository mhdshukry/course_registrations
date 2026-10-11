import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';
import '../../services/auth_service.dart';
import '../widgets/academic_record_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int selectedSection;
  final ValueChanged<int>? onNavigate;

  const AdminDashboardScreen({
    super.key,
    this.selectedSection = 0,
    this.onNavigate,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late int _section;

  // Search and filter states
  String userSearch = '';
  String roleFilter = 'All roles';
  String auditSearch = '';
  String auditCategoryFilter = 'All';

  // System settings state
  bool maintenanceMode = false;
  bool emailNotifications = true;
  bool enforceMfa = true;
  bool automaticBackups = true;
  bool enforcePrerequisites = true;
  bool strictCreditLimits = true;
  bool smsNotifications = false;
  bool autoSessionTimeout = true;

  // Academic Structure sub-tab: 0 = Faculties & Curricula, 1 = Timetable Management
  int _academicStructureTab = 0;
  String _timetableDayFilter = 'All';

  // Staff and Privileged Officers seed data
  late List<_AdminUser> users;

  // Academic Units seed data
  late List<_AcademicUnit> academicUnits;

  // Faculty -> Department -> Students hierarchy state
  String _selectedFacultyId = 'f1'; // Faculty of Technology by default
  String _selectedDepartmentId = 'd1'; // Department of ICT by default
  int _selectedAcademicLevel =
      0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  int _timetableLevelFilter =
      0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  String _studentSearch = '';
  String _studentLevelFilter = 'All levels';
  String _studentStandingFilter = 'All';
  String _studentStatusFilter = 'All';
  final List<_AdminStudent> _customStudents = [];

  @override
  void initState() {
    super.initState();
    _section = widget.selectedSection;
    _initializeSeedData();
  }

  @override
  void didUpdateWidget(covariant AdminDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSection != widget.selectedSection) {
      setState(() => _section = widget.selectedSection);
    }
  }

  void _navigate(int index) {
    setState(() => _section = index);
    widget.onNavigate?.call(index);
  }

  void _navigateToStudentDirectoryWithLevel(int level) {
    setState(() {
      _section = 2;
      _selectedAcademicLevel = level;
      _studentLevelFilter = level == 0 ? 'All levels' : 'Level $level';
    });
    widget.onNavigate?.call(2);
  }

  Color _getLevelColor(int level) => switch (level) {
    1 => const Color(0xFF1976D2), // Royal Blue
    2 => const Color(0xFF00897B), // Emerald Teal
    3 => const Color(0xFF7B1FA2), // Royal Purple
    4 => const Color(0xFFE65100), // Amber / Deep Orange
    _ => RuslColors.primaryMaroon,
  };

  String _getLevelTitle(int level) => switch (level) {
    1 => 'Level 1',
    2 => 'Level 2',
    3 => 'Level 3',
    4 => 'Level 4',
    _ => 'Level $level',
  };

  String _getLevelSubtitle(int level) => switch (level) {
    1 => 'First Year (Freshers)',
    2 => 'Second Year (Sophomores)',
    3 => 'Third Year (Juniors)',
    4 => 'Fourth Year (Final Year / Seniors)',
    _ => 'Undergraduate Cohort',
  };

  String _getLevelIntake(int level) => switch (level) {
    1 => 'Intake 2024/2025',
    2 => 'Intake 2023/2024',
    3 => 'Intake 2022/2023',
    4 => 'Intake 2021/2022',
    _ => 'Undergraduate Intake',
  };

  String _getLevelDescription(int level) => switch (level) {
    1 =>
      'Freshers Induction, Core Computing, Mathematics & Foundations (12 - 20 Credits / Sem)',
    2 =>
      'Intermediate Systems, OOP, DBMS & Data Structures (14 - 22 Credits / Sem)',
    3 =>
      'Specialization Streams, Web APIs, Mobile & Cloud Systems (12 - 22 Credits / Sem)',
    4 =>
      'Capstone Research Project, Dissertation & 6-Month Internship (12 - 24 Credits / Sem)',
    _ => 'University Undergraduate Degree Programme',
  };

  Widget _buildLevelPill(int level) {
    final color = _getLevelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Level $level',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  void _initializeSeedData() {
    users = [
      _AdminUser(
        name: 'Mr. P. S. Palliyaguruge',
        username: 'sysadmin',
        role: 'System Admin',
        department: 'Center for IT Services (CITS)',
        email: 'palliyaguruge@cits.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Ms. K. H. Gaurika Kahawala',
        username: 'ar_fot',
        role: 'Assistant Registrar',
        department: 'Faculty of Technology Administration',
        email: 'ar.fot@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Prof. T. C. Bamunuarachchige',
        username: 'dean_fot',
        role: 'Dean',
        department: 'Faculty of Technology Office',
        email: 'dean@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Dr. Lahiru Jayasuriya',
        username: 'hod_ict',
        role: 'Head of Department',
        department: 'Information & Communication Technology',
        email: 'lahiru.j@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Dr. W. M. M. D. Bandara',
        username: 'hod_bpt',
        role: 'Head of Department',
        department: 'Bio-Process Technology',
        email: 'bandara.bpt@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Dr. H. A. Naveen Dharmagunawardhane',
        username: 'hod_mtt',
        role: 'Head of Department',
        department: 'Materials & Mechanical Technology',
        email: 'naveen.d@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Mr. Wiraj Wickramaarachchi',
        username: 'wiraj_w',
        role: 'Senior Lecturer',
        department: 'Information & Communication Technology',
        email: 'wiraj.w@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Dr. W. K. P. Chathurangika',
        username: 'chathurangika_w',
        role: 'Lecturer',
        department: 'Information & Communication Technology',
        email: 'chathurangika@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Mrs. Nishadi Prasanthika',
        username: 'nishadi_p',
        role: 'Lecturer',
        department: 'Information & Communication Technology',
        email: 'nishadi.p@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Eng. T. Kugaranan',
        username: 'kugaranan_t',
        role: 'Lecturer',
        department: 'Engineering Technology',
        email: 'kugaranan.t@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Mr. Sahan Ekanayake',
        username: 'sahan_e',
        role: 'Lecturer',
        department: 'Information & Communication Technology',
        email: 'sahan.e@tech.rjt.ac.lk',
        active: true,
      ),
      _AdminUser(
        name: 'Mr. M. U. I. Marasinghe',
        username: 'marasinghe_m',
        role: 'Lecturer',
        department: 'Information & Communication Technology',
        email: 'marasinghe.m@tech.rjt.ac.lk',
        active: true,
      ),
    ];

    academicUnits = [
      _AcademicUnit(
        code: 'FOT',
        name: 'Faculty of Technology',
        departments: [
          'Information & Communication Technology',
          'Engineering Technology',
          'Bio Systems Technology',
          'Materials & Mechanical Technology',
        ],
        programmes: ['BICT (Hons)', 'BET (Hons)', 'BBST (Hons)'],
        courses: [
          'ICT 3102 — Software Engineering (3 Cr)',
          'ICT 3205 — UI/UX Design & Development (3 Cr)',
          'ICT 3210 — Advanced Web Technologies (3 Cr)',
          'ICT 3103 — Mobile Application Development (3 Cr)',
          'ET 3101 — Control Systems (3 Cr)',
          'BST 3102 — Bio-Process Engineering (3 Cr)',
        ],
      ),
      _AcademicUnit(
        code: 'FAS',
        name: 'Faculty of Applied Sciences',
        departments: [
          'Department of Computing',
          'Department of Physical Sciences',
          'Department of Biological Sciences',
        ],
        programmes: [
          'B.Sc. in Applied Sciences',
          'B.Sc. (Hons) in Computer Science',
          'B.Sc. in Physics & Electronics',
        ],
        courses: [
          'CSC 1101 — Programming Fundamentals (3 Cr)',
          'CSC 2202 — Data Structures & Algorithms (3 Cr)',
          'MAT 1101 — Calculus & Analytical Geometry (3 Cr)',
        ],
      ),
      _AcademicUnit(
        code: 'FMS',
        name: 'Faculty of Management Studies',
        departments: [
          'Department of Accountancy & Finance',
          'Department of Business Management',
          'Department of Marketing Management',
          'Department of Tourism & Hospitality',
        ],
        programmes: [
          'B.Sc. in Business Management',
          'B.Sc. in Accountancy',
          'B.Sc. in Marketing',
        ],
        courses: [
          'MGT 1101 — Management Principles (3 Cr)',
          'ACC 1102 — Financial Accounting (3 Cr)',
          'MKT 2101 — Principles of Marketing (3 Cr)',
        ],
      ),
      _AcademicUnit(
        code: 'FOA',
        name: 'Faculty of Agriculture',
        departments: [
          'Department of Agricultural Systems',
          'Department of Plant Sciences',
          'Department of Animal & Food Sciences',
        ],
        programmes: [
          'B.Sc. (Hons) in Agriculture',
          'B.Sc. in Food Production & Technology',
        ],
        courses: [
          'AGR 1101 — Crop Production Science (3 Cr)',
          'AGR 2103 — Soil Fertility & Management (3 Cr)',
          'AFS 3105 — Food Processing Technology (3 Cr)',
        ],
      ),
      _AcademicUnit(
        code: 'FMAS',
        name: 'Faculty of Medicine and Allied Sciences',
        departments: [
          'Department of Medicine',
          'Department of Surgery',
          'Department of Paediatrics',
          'Department of Nursing & Allied Sciences',
        ],
        programmes: [
          'MBBS Degree',
          'B.Sc. in Nursing',
          'B.Sc. in Medical Laboratory Sciences',
        ],
        courses: [
          'MED 1101 — Human Anatomy & Physiology (4 Cr)',
          'MED 2104 — Pathology & Microbiology (4 Cr)',
          'NUR 1201 — Fundamentals of Nursing (3 Cr)',
        ],
      ),
      _AcademicUnit(
        code: 'FSSH',
        name: 'Faculty of Social Sciences and Humanities',
        departments: [
          'Department of Humanities',
          'Department of Social Sciences',
          'Department of Economics',
          'Department of Archaeology & Heritage',
        ],
        programmes: [
          'BA (General)',
          'BA (Special) in Economics',
          'BA (Special) in Archaeology',
        ],
        courses: [
          'ECN 1101 — Microeconomics (3 Cr)',
          'HUM 1102 — Sri Lankan History & Heritage (3 Cr)',
          'SOC 2101 — Sociological Thought (3 Cr)',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    return Container(
      color: context.scaffoldBgColor,
      child: switch (_section) {
        0 => _overview(app),
        1 => _usersPage(),
        2 => _studentsDirectoryPage(app),
        3 => _academicStructure(app),
        4 => _registrationPeriods(app),
        5 => _settingsPage(),
        6 => _auditPage(app),
        _ => _profilePage(),
      },
    );
  }

  // Common modern page wrapper with refined typography and padding
  Widget _page(
    String title,
    String subtitle,
    List<Widget> children, {
    Widget? trailing,
  }) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 28,
        vertical: compact ? 16 : 24,
      ),
      children: [
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeading(title, subtitle, compact),
              if (trailing != null) ...[
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: trailing),
              ],
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _pageHeading(title, subtitle, compact)),
              if (trailing != null) ...[const SizedBox(width: 16), trailing],
            ],
          ),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }

  Widget _pageHeading(String title, String subtitle, bool compact) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: compact ? 22 : 26,
          fontWeight: FontWeight.w900,
          color: context.textPrimaryColor,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(
          color: context.textSecondaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  // ============================================================================
  // SECTION 0: SYSTEM OVERVIEW
  // ============================================================================
  Widget _overview(AppService app) {
    return _page(
      'System Administration Overview',
      'Rajarata University of Sri Lanka • Central Academic Governance & System Health',
      [
        // Executive Hero Welcome Banner
        _buildExecutiveHeroBanner(app),
        const SizedBox(height: 20),

        // 4 KPI Metrics Grid
        LayoutBuilder(
          builder: (context, c) {
            final isSmall = c.maxWidth < 600;
            final isMedium = c.maxWidth < 1000;
            final cardWidth = isSmall
                ? c.maxWidth
                : isMedium
                ? (c.maxWidth - 14) / 2
                : (c.maxWidth - 42) / 4;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _metric(
                  cardWidth,
                  '4,850',
                  'Active Undergraduates',
                  Icons.groups_rounded,
                  RuslColors.primaryMaroon,
                  '+120 Registered this week',
                  true,
                ),
                _metric(
                  cardWidth,
                  '${users.length}',
                  'Privileged Staff Officers',
                  Icons.manage_accounts_rounded,
                  const Color(0xFF1E88E5), // Sapphire
                  'Deans, ARs, HoDs & Faculty Staff',
                  false,
                ),
                _metric(
                  cardWidth,
                  '${app.faculties.length}',
                  'Accredited Faculties',
                  Icons.account_balance_rounded,
                  const Color(0xFF00897B), // Emerald Teal
                  '24 Academic Departments Active',
                  false,
                ),
                _metric(
                  cardWidth,
                  '99.98%',
                  'Platform SLA & Uptime',
                  Icons.monitor_heart_rounded,
                  RuslColors.successGreen,
                  'All core cluster services healthy',
                  true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),

        // Quick Admin Shortcuts Navigation Bar
        _panel(
          title: 'Quick Administrative Operations',
          subtitle: 'Jump directly to primary registry governance modules',
          child: LayoutBuilder(
            builder: (context, c) {
              final isSmall = c.maxWidth < 600;
              final itemWidth = isSmall ? c.maxWidth : (c.maxWidth - 28) / 3;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _shortcutCard(
                    itemWidth,
                    'Staff & Permissions',
                    'Configure university officers and lecturer roles',
                    Icons.badge_rounded,
                    RuslColors.primaryMaroon,
                    () => _navigate(1),
                  ),
                  _shortcutCard(
                    itemWidth,
                    'Student Directory',
                    'Browse by faculty, department and degree standing',
                    Icons.school_rounded,
                    const Color(0xFF1E88E5),
                    () => _navigate(2),
                  ),
                  _shortcutCard(
                    itemWidth,
                    'Academic Structure',
                    'Manage faculties, course catalogue and timetables',
                    Icons.apartment_rounded,
                    const Color(0xFF00897B),
                    () => _navigate(3),
                  ),
                  _shortcutCard(
                    itemWidth,
                    'Registration Windows',
                    'Open or close enrollment windows and extend deadlines',
                    Icons.event_available_rounded,
                    RuslColors.warningOrange,
                    () => _navigate(4),
                  ),
                  _shortcutCard(
                    itemWidth,
                    'System Settings',
                    'Security policies, MFA, backups, and maintenance',
                    Icons.tune_rounded,
                    const Color(0xFF5E35B1),
                    () => _navigate(5),
                  ),
                  _shortcutCard(
                    itemWidth,
                    'Audit & Compliance',
                    'Trace tamper-proof security and registration logs',
                    Icons.policy_rounded,
                    const Color(0xFF37474F),
                    () => _navigate(6),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Live Service Health Matrix
        _panel(
          title: 'Cluster Health & Infrastructure Status',
          subtitle: 'Continuous health monitoring and heartbeat telemetry',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HealthTile(
                'User Identity & SSO',
                'Operational (14ms)',
                Icons.lock_outline_rounded,
                RuslColors.successGreen,
              ),
              _HealthTile(
                'Registration API',
                'Operational (22ms)',
                Icons.sync_rounded,
                RuslColors.successGreen,
              ),
              _HealthTile(
                'Primary DB Cluster',
                'Healthy • 100% Synced',
                Icons.storage_rounded,
                RuslColors.successGreen,
              ),
              _HealthTile(
                'Timetable Engine',
                'Operational (8ms)',
                Icons.calendar_today_rounded,
                RuslColors.successGreen,
              ),
              _HealthTile(
                'Notification Dispatcher',
                'Queue Active (0 Backlog)',
                Icons.notifications_active_outlined,
                RuslColors.successGreen,
              ),
              _HealthTile(
                'Audit Streaming',
                'Compliant (Zero Drift)',
                Icons.security_rounded,
                RuslColors.successGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Faculty Registration Progress Overview
        _panel(
          title: 'Faculty Enrollment & Registration Status',
          subtitle:
              'Current 2025/2026 Semester 1 enrollment status across all faculties',
          child: LayoutBuilder(
            builder: (context, c) {
              final isSmall = c.maxWidth < 650;
              final cardWidth = isSmall ? c.maxWidth : (c.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: app.faculties.map((f) {
                  final code = RuslFaculties.facultyCodes[f.name] ?? f.code;
                  final progress = switch (code) {
                    'FOT' => 0.94,
                    'FAS' => 0.88,
                    'FMS' => 0.91,
                    'FOA' => 0.82,
                    'FMAS' => 0.98,
                    _ => 0.85,
                  };
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardSubtleColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: RuslColors.accentYellow.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: RuslColors.darkText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${f.departmentCount} Departments • Levels 1-4 Enrolling',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _Badge(
                              app.isRegistrationOpen
                                  ? 'WINDOW OPEN'
                                  : 'WINDOW CLOSED',
                              app.isRegistrationOpen
                                  ? RuslColors.successGreen
                                  : RuslColors.errorRed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registration Progress',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondaryColor,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}% completed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: context.isDarkMode
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 0.90
                                  ? RuslColors.successGreen
                                  : progress >= 0.80
                                  ? RuslColors.primaryMaroon
                                  : RuslColors.warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // University Academic Year Level Distribution (Levels 1 - 4)
        _panel(
          title: 'University Academic Year Level Distribution (Levels 1 - 4)',
          subtitle:
              'Active 2025/2026 undergraduate cohorts, curriculum stages, credit bounds, and enrollment rates',
          child: LayoutBuilder(
            builder: (context, c) {
              final isSmall = c.maxWidth < 650;
              final cardWidth = isSmall ? c.maxWidth : (c.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _buildLevelOverviewCard(
                    width: cardWidth,
                    level: 1,
                    title: 'Level 1 • First Year (Freshers)',
                    intake: 'Intake 2024/2025',
                    studentCount: 1350,
                    progress: 0.92,
                    color: const Color(0xFF1976D2),
                    stageInfo:
                        'Freshers Induction, Core Computing & Basic Mathematics',
                    creditBound: '12 - 20 Credits / Semester',
                    onInspect: () => _navigateToStudentDirectoryWithLevel(1),
                  ),
                  _buildLevelOverviewCard(
                    width: cardWidth,
                    level: 2,
                    title: 'Level 2 • Second Year (Sophomores)',
                    intake: 'Intake 2023/2024',
                    studentCount: 1240,
                    progress: 0.89,
                    color: const Color(0xFF00897B),
                    stageInfo:
                        'Intermediate Systems, OOP, Databases & Algorithms',
                    creditBound: '14 - 22 Credits / Semester',
                    onInspect: () => _navigateToStudentDirectoryWithLevel(2),
                  ),
                  _buildLevelOverviewCard(
                    width: cardWidth,
                    level: 3,
                    title: 'Level 3 • Third Year (Juniors)',
                    intake: 'Intake 2022/2023',
                    studentCount: 1180,
                    progress: 0.94,
                    color: const Color(0xFF7B1FA2),
                    stageInfo:
                        'Specialization Streams, Web APIs, Mobile & Cloud Systems',
                    creditBound: '12 - 22 Credits / Semester',
                    onInspect: () => _navigateToStudentDirectoryWithLevel(3),
                  ),
                  _buildLevelOverviewCard(
                    width: cardWidth,
                    level: 4,
                    title: 'Level 4 • Fourth Year (Final Year / Seniors)',
                    intake: 'Intake 2021/2022',
                    studentCount: 1080,
                    progress: 0.97,
                    color: const Color(0xFFE65100),
                    stageInfo:
                        'Capstone Research Projects, Dissertation & 6-Month Internship',
                    creditBound: '12 - 24 Credits / Semester',
                    onInspect: () => _navigateToStudentDirectoryWithLevel(4),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelOverviewCard({
    required double width,
    required int level,
    required String title,
    required String intake,
    required int studentCount,
    required double progress,
    required Color color,
    required String stageInfo,
    required String creditBound,
    required VoidCallback onInspect,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardSubtleColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'L$level',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$intake • $creditBound',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$studentCount Enrolled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stageInfo,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: context.textSecondaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enrollment Completion',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% sealed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onInspect,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: color,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(
                'Inspect Level $level Roster',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveHeroBanner(AppService app) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [const Color(0xFF2A1012), const Color(0xFF1B1B20)]
              : [RuslColors.primaryMaroon, const Color(0xFF5A0D0E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: RuslColors.primaryMaroon.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'RUSL CENTRAL ADMIN CONSOLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: app.isRegistrationOpen
                                    ? RuslColors.successGreen.withValues(
                                        alpha: 0.8,
                                      )
                                    : RuslColors.warningOrange.withValues(
                                        alpha: 0.8,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    app.isRegistrationOpen
                                        ? 'ENROLLMENT LIVE'
                                        : 'ENROLLMENT CLOSED',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Rajarata University of Sri Lanka',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Academic Year 2025/2026 • Semester 1 • Center for Information & Communication Technology',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 14),
              if (c.maxWidth < 560)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: RuslColors.accentYellow,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Deadline: ${app.registrationEndLabel}, 23:59',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () => _navigate(4),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                      label: const Text('Manage Registration Window'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _navigate(2),
                      style: FilledButton.styleFrom(
                        backgroundColor: RuslColors.accentYellow,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.person_search_rounded, size: 16),
                      label: const Text('Open Student Directory'),
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: RuslColors.accentYellow,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Deadline: ${app.registrationEndLabel}, 23:59',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _navigate(4),
                          icon: const Icon(
                            Icons.edit_calendar_rounded,
                            size: 16,
                          ),
                          label: const Text('Manage Window'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _navigate(2),
                          style: FilledButton.styleFrom(
                            backgroundColor: RuslColors.accentYellow,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(
                            Icons.person_search_rounded,
                            size: 16,
                          ),
                          label: const Text('Open Student Directory'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _shortcutCard(
    double width,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardSubtleColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.textSecondaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SECTION 1: STAFF & ROLE MANAGEMENT
  // ============================================================================
  Widget _usersPage() {
    final visible = users.where((u) {
      final q = userSearch.toLowerCase();
      final matchesRole = (roleFilter == 'All roles' || u.role == roleFilter);
      final matchesQuery =
          q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          u.department.toLowerCase().contains(q);
      return matchesRole && matchesQuery;
    }).toList();

    return _page(
      'Staff & Role Governance',
      'Manage university academic staff, department heads, and registrars. Students are segregated in the Student Directory.',
      [
        // Staff Statistics Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardSubtleColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Wrap(
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _statPill(
                'Total Staff',
                '${users.length}',
                Icons.badge_rounded,
                context.textPrimaryColor,
              ),
              _statPill(
                'SysAdmins',
                '${users.where((u) => u.role == "System Admin").length}',
                Icons.shield_rounded,
                RuslColors.primaryMaroon,
              ),
              _statPill(
                'Deans & ARs',
                '${users.where((u) => u.role == "Dean" || u.role == "Assistant Registrar").length}',
                Icons.account_balance_rounded,
                const Color(0xFF5E35B1),
              ),
              _statPill(
                'HoDs',
                '${users.where((u) => u.role == "Head of Department").length}',
                Icons.apartment_rounded,
                const Color(0xFF1E88E5),
              ),
              _statPill(
                'Lecturers',
                '${users.where((u) => u.role.contains("Lecturer")).length}',
                Icons.school_rounded,
                const Color(0xFF00897B),
              ),
              _statPill(
                'Active Accounts',
                '${users.where((u) => u.active).length}',
                Icons.check_circle_rounded,
                RuslColors.successGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Action Toolbar
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: (v) => setState(() => userSearch = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: 'Search staff name, EPF, or dept...',
                  filled: true,
                  fillColor: context.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: roleFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => roleFilter = v ?? 'All roles'),
              ),
            ),
            FilledButton.icon(
              onPressed: _showAddUser,
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                'Add Staff Member',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Staff List
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              'No staff members match the specified filters.',
              style: TextStyle(color: context.textSecondaryColor),
            ),
          )
        else
          ...visible.map((u) => _buildStaffCard(u)),
      ],
    );
  }

  Widget _buildStaffCard(_AdminUser u) {
    final roleColor = switch (u.role) {
      'System Admin' => RuslColors.primaryMaroon,
      'Assistant Registrar' => const Color(0xFFE65100),
      'Dean' => const Color(0xFF6A1B9A),
      'Head of Department' => const Color(0xFF1565C0),
      _ => const Color(0xFF00695C),
    };

    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: roleColor.withValues(alpha: 0.14),
                      child: Text(
                        _initials(u.name),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: roleColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: context.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${u.username} • ${u.department}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: u.active,
                      activeThumbColor: RuslColors.successGreen,
                      onChanged: (v) {
                        setState(() => u.active = v);
                        _message('${u.name} ${v ? 'activated' : 'suspended'}.');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.role,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: roleColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (u.active
                                    ? RuslColors.successGreen
                                    : RuslColors.errorRed)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.active ? 'ACTIVE' : 'SUSPENDED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: u.active
                              ? RuslColors.successGreen
                              : RuslColors.errorRed,
                        ),
                      ),
                    ),
                    Text(
                      u.email,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit staff member',
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      onPressed: () => _showEditUser(u),
                    ),
                    IconButton(
                      tooltip: 'Generate temp password',
                      icon: const Icon(Icons.lock_reset_rounded, size: 19),
                      onPressed: () => _showResetPassword(u.name, u.username),
                    ),
                    if (u.role != 'System Admin')
                      IconButton(
                        tooltip: 'Remove account',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: RuslColors.errorRed,
                        ),
                        onPressed: () {
                          setState(() => users.remove(u));
                          _message('Removed staff account: ${u.name}');
                        },
                      ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: roleColor.withValues(alpha: 0.14),
                  child: Text(
                    _initials(u.name),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: roleColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            u.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: context.textPrimaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              u.role,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: roleColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (u.active
                                          ? RuslColors.successGreen
                                          : RuslColors.errorRed)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              u.active ? 'ACTIVE' : 'SUSPENDED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: u.active
                                    ? RuslColors.successGreen
                                    : RuslColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${u.username} • ${u.department} • ${u.email}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit staff member',
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  onPressed: () => _showEditUser(u),
                ),
                IconButton(
                  tooltip: 'Generate temp password',
                  icon: const Icon(Icons.lock_reset_rounded, size: 19),
                  onPressed: () => _showResetPassword(u.name, u.username),
                ),
                if (u.role != 'System Admin')
                  IconButton(
                    tooltip: 'Remove account',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: RuslColors.errorRed,
                    ),
                    onPressed: () {
                      setState(() => users.remove(u));
                      _message('Removed staff account: ${u.name}');
                    },
                  ),
                Switch(
                  value: u.active,
                  activeThumbColor: RuslColors.successGreen,
                  onChanged: (v) {
                    setState(() => u.active = v);
                    _message('${u.name} ${v ? 'activated' : 'suspended'}.');
                  },
                ),
              ],
            ),
    );
  }

  static const _roles = [
    'All roles',
    'System Admin',
    'Assistant Registrar',
    'Dean',
    'Head of Department',
    'Senior Lecturer',
    'Lecturer',
  ];

  Future<void> _showAddUser() async {
    final name = TextEditingController();
    final username = TextEditingController();
    final dept = TextEditingController(
      text: 'Information & Communication Technology',
    );
    final email = TextEditingController();
    var role = 'Lecturer';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Create Staff Account',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Staff member full name',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      labelText: 'Username / EPF number',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dept,
                    decoration: InputDecoration(
                      labelText: 'Department / Unit',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'University email address',
                      hintText: 'e.g. staff@rjt.ac.lk',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: role,
                    items: _roles
                        .skip(1)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => update(() => role = v ?? role),
                    decoration: InputDecoration(
                      labelText: 'Assigned Role & Privileges',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || username.text.trim().isEmpty) {
                  return;
                }
                setState(
                  () => users.insert(
                    0,
                    _AdminUser(
                      name: name.text.trim(),
                      username: username.text.trim(),
                      role: role,
                      department: dept.text.trim().isNotEmpty
                          ? dept.text.trim()
                          : 'Central Administration',
                      email: email.text.trim().isNotEmpty
                          ? email.text.trim()
                          : '${username.text.trim()}@rjt.ac.lk',
                      active: true,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
                _message(
                  'Staff account created successfully for ${name.text.trim()}.',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditUser(_AdminUser u) async {
    final nameCtrl = TextEditingController(text: u.name);
    final userCtrl = TextEditingController(text: u.username);
    final deptCtrl = TextEditingController(text: u.department);
    final emailCtrl = TextEditingController(text: u.email);
    var role = u.role;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Staff Member: ${u.name}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username / EPF',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deptCtrl,
                    decoration: InputDecoration(
                      labelText: 'Department / Unit',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: role,
                    items: _roles
                        .skip(1)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => update(() => role = v ?? role),
                    decoration: InputDecoration(
                      labelText: 'Assigned Role',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    userCtrl.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  u.name = nameCtrl.text.trim();
                  u.username = userCtrl.text.trim();
                  u.department = deptCtrl.text.trim();
                  u.email = emailCtrl.text.trim();
                  u.role = role;
                });
                Navigator.pop(dialogContext);
                _message('Updated staff account: ${u.name}');
              },
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPassword(String name, String username) {
    const tempPass = 'RuslPass#2026';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password • $name',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A secure temporary password has been provisioned for $username:',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.cardSubtleColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: SelectableText(
                      tempPass,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy password to clipboard',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: tempPass));
                      _message('Temporary password copied to clipboard.');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The user will be required to renew their credentials upon first sign-in.',
              style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.primaryMaroon,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 2: DEDICATED STUDENT DIRECTORY (FACULTY -> DEPT -> STUDENTS)
  // ============================================================================
  Widget _studentsDirectoryPage(AppService app) {
    final faculties = app.faculties;
    final selectedFaculty = faculties.firstWhere(
      (f) => f.id == _selectedFacultyId,
      orElse: () => faculties.first,
    );

    final departments = _getDepartmentsForFaculty(app, selectedFaculty.id);
    if (!departments.any((d) => d.id == _selectedDepartmentId)) {
      if (departments.isNotEmpty) {
        _selectedDepartmentId = departments.first.id;
      }
    }

    final selectedDepartment = departments.firstWhere(
      (d) => d.id == _selectedDepartmentId,
      orElse: () => departments.isNotEmpty
          ? departments.first
          : Department(
              id: 'd1',
              facultyId: selectedFaculty.id,
              code: 'GEN',
              name: 'General Department',
            ),
    );

    // Filter department students
    final allDepartmentStudents = _getStudentsForDepartment(
      selectedFaculty.id,
      selectedDepartment.id,
      selectedDepartment.code,
      selectedDepartment.name,
    );

    // Degree Honours Classification counts for active level/department cohort
    final levelScopedStudents = _selectedAcademicLevel == 0
        ? allDepartmentStudents
        : allDepartmentStudents
              .where((s) => s.level == _selectedAcademicLevel)
              .toList();

    final totalCount = levelScopedStudents.length;
    final firstClassCount = levelScopedStudents
        .where(
          (s) =>
              DegreeClassStanding.fromGpa(s.gpa) ==
              DegreeClassStanding.firstClass,
        )
        .length;
    final secondUpperCount = levelScopedStudents
        .where(
          (s) =>
              DegreeClassStanding.fromGpa(s.gpa) ==
              DegreeClassStanding.secondUpper,
        )
        .length;
    final secondLowerCount = levelScopedStudents
        .where(
          (s) =>
              DegreeClassStanding.fromGpa(s.gpa) ==
              DegreeClassStanding.secondLower,
        )
        .length;
    final passCount = levelScopedStudents
        .where(
          (s) => DegreeClassStanding.fromGpa(s.gpa) == DegreeClassStanding.pass,
        )
        .length;
    final batchMissCount = levelScopedStudents
        .where(
          (s) =>
              DegreeClassStanding.fromGpa(s.gpa) ==
              DegreeClassStanding.batchMiss,
        )
        .length;

    final departmentStudents = allDepartmentStudents.where((s) {
      if (_selectedAcademicLevel != 0 && s.level != _selectedAcademicLevel) {
        return false;
      }
      if (_studentLevelFilter != 'All levels') {
        final lvl = int.tryParse(
          _studentLevelFilter.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        if (lvl != null && s.level != lvl) {
          return false;
        }
      }
      if (_studentStandingFilter != 'All') {
        final standing = DegreeClassStanding.fromGpa(s.gpa);
        if (_studentStandingFilter == '1st Class' &&
            standing != DegreeClassStanding.firstClass) {
          return false;
        }
        if (_studentStandingFilter == '2nd Upper' &&
            standing != DegreeClassStanding.secondUpper) {
          return false;
        }
        if (_studentStandingFilter == '2nd Lower' &&
            standing != DegreeClassStanding.secondLower) {
          return false;
        }
        if (_studentStandingFilter == 'Pass' &&
            standing != DegreeClassStanding.pass) {
          return false;
        }
        if (_studentStandingFilter == 'Batch Miss' &&
            standing != DegreeClassStanding.batchMiss) {
          return false;
        }
      }
      if (_studentStatusFilter != 'All') {
        if (s.status != _studentStatusFilter) {
          return false;
        }
      }
      if (_studentSearch.isNotEmpty) {
        final q = _studentSearch.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.registrationNumber.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final hasActiveFilters =
        _studentSearch.isNotEmpty ||
        _selectedAcademicLevel != 0 ||
        _studentLevelFilter != 'All levels' ||
        _studentStandingFilter != 'All' ||
        _studentStatusFilter != 'All';

    return _page(
      'Undergraduate Student Directory',
      'Select a Faculty and Department to view student records, CGPA standings, and perform administrative overrides.',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: () =>
                _showAddStudentDialog(selectedFaculty, selectedDepartment),
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.primaryMaroon,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Enroll Student'),
          ),
          OutlinedButton.icon(
            onPressed: () => _message(
              'Exported ${selectedDepartment.code} student roster (CSV).',
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export Roster'),
          ),
        ],
      ),
      [
        // Integrated Faculty & Department Selector Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faculty Row Header
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    size: 18,
                    color: RuslColors.primaryMaroon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'FACULTY SELECTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${faculties.length} Academic Faculties',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Faculty Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: faculties.map((f) {
                  final isSelected = f.id == _selectedFacultyId;
                  return ChoiceChip(
                    label: Text('${f.code} • ${f.name}'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedFacultyId = f.id;
                          final depts = _getDepartmentsForFaculty(app, f.id);
                          _selectedDepartmentId = depts.isNotEmpty
                              ? depts.first.id
                              : '';
                        });
                      }
                    },
                    selectedColor: RuslColors.primaryMaroon,
                    backgroundColor: context.cardSubtleColor,
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : context.textPrimaryColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: 14),

              // Department Sub-section Header
              Row(
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    size: 18,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEPARTMENT ROSTER (${selectedFaculty.code})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Active: ${selectedDepartment.code}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: RuslColors.primaryMaroon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Department Pills with student count
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: departments.map((d) {
                  final isSelected = d.id == _selectedDepartmentId;
                  final deptStudentCount = _getStudentsForDepartment(
                    selectedFaculty.id,
                    d.id,
                    d.code,
                    d.name,
                  ).length;
                  return InkWell(
                    onTap: () => setState(() => _selectedDepartmentId = d.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width < 700
                          ? double.infinity
                          : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RuslColors.primaryMaroon
                            : context.cardSubtleColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? RuslColors.primaryMaroon
                              : context.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 16,
                            color: isSelected
                                ? RuslColors.accentYellow
                                : context.textSecondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${d.code} — ${d.name}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : context.textPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? RuslColors.accentYellow
                                  : context.borderColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isSelected
                                  ? 'ACTIVE • $deptStudentCount'
                                  : '$deptStudentCount',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.black
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: 14),

              // Academic Level Division Header
              Row(
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    size: 18,
                    color: RuslColors.primaryMaroon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ACADEMIC LEVEL DIVISION (LEVELS 1 - 4)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _selectedAcademicLevel == 0
                          ? 'All Undergraduates'
                          : '${_getLevelTitle(_selectedAcademicLevel)} Cohort Active',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _selectedAcademicLevel == 0
                            ? RuslColors.primaryMaroon
                            : _getLevelColor(_selectedAcademicLevel),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Academic Level Cohort Switcher Cards
              LayoutBuilder(
                builder: (context, c) {
                  final cardWidth = c.maxWidth > 920
                      ? (c.maxWidth - 40) / 5
                      : c.maxWidth > 580
                      ? (c.maxWidth - 20) / 3
                      : c.maxWidth;

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildLevelCohortCard(
                        width: cardWidth,
                        levelNumber: 0,
                        title: 'All Levels',
                        subtitle: 'Entire Roster',
                        intakeYear: 'Intakes 2021-2024',
                        studentCount: allDepartmentStudents.length,
                        accentColor: RuslColors.primaryMaroon,
                        isSelected: _selectedAcademicLevel == 0,
                        onTap: () {
                          setState(() {
                            _selectedAcademicLevel = 0;
                            _studentLevelFilter = 'All levels';
                          });
                        },
                      ),
                      _buildLevelCohortCard(
                        width: cardWidth,
                        levelNumber: 1,
                        title: 'Level 1',
                        subtitle: 'First Year • Freshers',
                        intakeYear: 'Intake 2024/2025',
                        studentCount: allDepartmentStudents
                            .where((s) => s.level == 1)
                            .length,
                        accentColor: const Color(0xFF1976D2),
                        isSelected: _selectedAcademicLevel == 1,
                        onTap: () {
                          setState(() {
                            _selectedAcademicLevel = 1;
                            _studentLevelFilter = 'Level 1';
                          });
                        },
                      ),
                      _buildLevelCohortCard(
                        width: cardWidth,
                        levelNumber: 2,
                        title: 'Level 2',
                        subtitle: 'Second Year • Sophomores',
                        intakeYear: 'Intake 2023/2024',
                        studentCount: allDepartmentStudents
                            .where((s) => s.level == 2)
                            .length,
                        accentColor: const Color(0xFF00897B),
                        isSelected: _selectedAcademicLevel == 2,
                        onTap: () {
                          setState(() {
                            _selectedAcademicLevel = 2;
                            _studentLevelFilter = 'Level 2';
                          });
                        },
                      ),
                      _buildLevelCohortCard(
                        width: cardWidth,
                        levelNumber: 3,
                        title: 'Level 3',
                        subtitle: 'Third Year • Juniors',
                        intakeYear: 'Intake 2022/2023',
                        studentCount: allDepartmentStudents
                            .where((s) => s.level == 3)
                            .length,
                        accentColor: const Color(0xFF7B1FA2),
                        isSelected: _selectedAcademicLevel == 3,
                        onTap: () {
                          setState(() {
                            _selectedAcademicLevel = 3;
                            _studentLevelFilter = 'Level 3';
                          });
                        },
                      ),
                      _buildLevelCohortCard(
                        width: cardWidth,
                        levelNumber: 4,
                        title: 'Level 4',
                        subtitle: 'Final Year • Seniors',
                        intakeYear: 'Intake 2021/2022',
                        studentCount: allDepartmentStudents
                            .where((s) => s.level == 4)
                            .length,
                        accentColor: const Color(0xFFE65100),
                        isSelected: _selectedAcademicLevel == 4,
                        onTap: () {
                          setState(() {
                            _selectedAcademicLevel = 4;
                            _studentLevelFilter = 'Level 4';
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (_selectedAcademicLevel != 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getLevelColor(
                _selectedAcademicLevel,
              ).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getLevelColor(
                  _selectedAcademicLevel,
                ).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: _getLevelColor(_selectedAcademicLevel),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Cohort Division: ${_getLevelTitle(_selectedAcademicLevel)} (${_getLevelSubtitle(_selectedAcademicLevel)}) • ${_getLevelIntake(_selectedAcademicLevel)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: _getLevelColor(_selectedAcademicLevel),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLevelDescription(_selectedAcademicLevel),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedAcademicLevel = 0;
                    _studentLevelFilter = 'All levels';
                  }),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'View All Levels',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Degree Honours Classification KPI Metric Cards
        Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 18,
              color: RuslColors.accentYellow,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'DEGREE HONOURS CLASSIFICATION SUMMARY (${selectedDepartment.code} • ${_selectedAcademicLevel == 0 ? "All Levels" : "Level $_selectedAcademicLevel Cohort"})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 1050
                ? (constraints.maxWidth - (5 * 12)) / 6
                : constraints.maxWidth > 650
                ? (constraints.maxWidth - (2 * 12)) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: 'Total Students',
                  count: totalCount,
                  subtitle: _selectedAcademicLevel == 0
                      ? 'Department Roster'
                      : 'Level $_selectedAcademicLevel Cohort',
                  icon: Icons.people_alt_rounded,
                  accentColor: _selectedAcademicLevel == 0
                      ? RuslColors.primaryMaroon
                      : _getLevelColor(_selectedAcademicLevel),
                  isSelected: _studentStandingFilter == 'All',
                  onTap: () => setState(() => _studentStandingFilter = 'All'),
                ),
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: '1st Class',
                  count: firstClassCount,
                  subtitle: 'CGPA ≥ 3.70',
                  icon: Icons.military_tech_rounded,
                  accentColor: RuslColors.successGreen,
                  isSelected: _studentStandingFilter == '1st Class',
                  onTap: () => setState(() {
                    _studentStandingFilter =
                        _studentStandingFilter == '1st Class'
                        ? 'All'
                        : '1st Class';
                  }),
                ),
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: '2nd Class Upper',
                  count: secondUpperCount,
                  subtitle: '3.50 ≤ CGPA < 3.70',
                  icon: Icons.workspace_premium_rounded,
                  accentColor: const Color(0xFF00897B),
                  isSelected: _studentStandingFilter == '2nd Upper',
                  onTap: () => setState(() {
                    _studentStandingFilter =
                        _studentStandingFilter == '2nd Upper'
                        ? 'All'
                        : '2nd Upper';
                  }),
                ),
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: '2nd Class Lower',
                  count: secondLowerCount,
                  subtitle: '3.00 ≤ CGPA < 3.50',
                  icon: Icons.school_rounded,
                  accentColor: const Color(0xFF1E88E5),
                  isSelected: _studentStandingFilter == '2nd Lower',
                  onTap: () => setState(() {
                    _studentStandingFilter =
                        _studentStandingFilter == '2nd Lower'
                        ? 'All'
                        : '2nd Lower';
                  }),
                ),
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: 'Pass',
                  count: passCount,
                  subtitle: '2.00 ≤ CGPA < 3.00',
                  icon: Icons.verified_rounded,
                  accentColor: const Color(0xFFE65100),
                  isSelected: _studentStandingFilter == 'Pass',
                  onTap: () => setState(() {
                    _studentStandingFilter = _studentStandingFilter == 'Pass'
                        ? 'All'
                        : 'Pass';
                  }),
                ),
                _buildDegreeKpiCard(
                  width: cardWidth,
                  title: 'Batch Miss',
                  count: batchMissCount,
                  subtitle: 'CGPA < 2.00 (Warning)',
                  icon: Icons.warning_amber_rounded,
                  accentColor: RuslColors.errorRed,
                  isSelected: _studentStandingFilter == 'Batch Miss',
                  onTap: () => setState(() {
                    _studentStandingFilter =
                        _studentStandingFilter == 'Batch Miss'
                        ? 'All'
                        : 'Batch Miss';
                  }),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // Students Register Roster Container
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Register Header with Action Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedDepartment.name} Roster',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedFaculty.name} • ${selectedDepartment.code} Department Register',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: RuslColors.primaryMaroon.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          size: 16,
                          color: RuslColors.primaryMaroon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${departmentStudents.length} Students Listed',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: RuslColors.primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search and Filter Toolbar
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      onChanged: (v) => setState(() => _studentSearch = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        hintText: 'Search student name, reg, email...',
                        suffixIcon: _studentSearch.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _studentSearch = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: context.cardSubtleColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_studentLevelFilter),
                      isExpanded: true,
                      initialValue: _studentLevelFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.cardSubtleColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All levels',
                          child: Text(
                            'All Levels',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Level 1',
                          child: Text(
                            'Level 1',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Level 2',
                          child: Text(
                            'Level 2',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Level 3',
                          child: Text(
                            'Level 3',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Level 4',
                          child: Text(
                            'Level 4',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _studentLevelFilter = v ?? 'All levels';
                        _selectedAcademicLevel = switch (_studentLevelFilter) {
                          'Level 1' => 1,
                          'Level 2' => 2,
                          'Level 3' => 3,
                          'Level 4' => 4,
                          _ => 0,
                        };
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 175,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _studentStandingFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.cardSubtleColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text(
                            'All Standings',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '1st Class',
                          child: Text(
                            '1st Class (≥3.70)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '2nd Upper',
                          child: Text(
                            '2nd Upper (≥3.50)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '2nd Lower',
                          child: Text(
                            '2nd Lower (≥3.00)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Pass',
                          child: Text(
                            'Pass (≥2.00)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Batch Miss',
                          child: Text(
                            'Batch Miss (<2.0)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _studentStandingFilter = v ?? 'All'),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _studentStatusFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.cardSubtleColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text(
                            'All Statuses',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Registered',
                          child: Text(
                            'Registered',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Submitted',
                          child: Text(
                            'Submitted',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'HoD Approved',
                          child: Text(
                            'HoD Approved',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Changes Requested',
                          child: Text(
                            'Changes Req.',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _studentStatusFilter = v ?? 'All'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardSubtleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Showing ${departmentStudents.length} of $totalCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _studentSearch = '';
                        _selectedAcademicLevel = 0;
                        _studentLevelFilter = 'All levels';
                        _studentStandingFilter = 'All';
                        _studentStatusFilter = 'All';
                      }),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reset Filters'),
                      style: TextButton.styleFrom(
                        foregroundColor: RuslColors.primaryMaroon,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Student List / Table Presentation
              if (departmentStudents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.cardSubtleColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_search_rounded,
                        size: 48,
                        color: context.textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No students match the criteria',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try clearing search terms or active filters for ${selectedDepartment.name}.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      if (hasActiveFilters) ...[
                        const SizedBox(height: 14),
                        FilledButton.tonal(
                          onPressed: () => setState(() {
                            _studentSearch = '';
                            _selectedAcademicLevel = 0;
                            _studentLevelFilter = 'All levels';
                            _studentStandingFilter = 'All';
                            _studentStatusFilter = 'All';
                          }),
                          child: const Text('Clear All Filters'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 760;
                    if (isDesktop) {
                      return _buildStudentTable(departmentStudents, app);
                    } else {
                      return Column(
                        children: departmentStudents
                            .map((s) => _buildStudentCard(s, app))
                            .toList(),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDegreeKpiCard({
    required double width,
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FILTERED',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.textPrimaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? accentColor : context.textPrimaryColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCohortCard({
    required double width,
    required int levelNumber,
    required String title,
    required String subtitle,
    required String intakeYear,
    required int studentCount,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.14)
              : context.cardSubtleColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : accentColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.25)
                        : context.borderColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$studentCount Students',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? accentColor
                          : context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? accentColor : context.textPrimaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              intakeYear,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTable(List<_AdminStudent> students, AppService app) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardSubtleColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(bottom: BorderSide(color: context.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'STUDENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PROGRAMME & LEVEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CGPA & STANDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: Text(
                    'ACTIONS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: context.borderColor),
            itemBuilder: (context, index) {
              final s = students[index];
              return _buildStudentTableRow(s, app);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTableRow(_AdminStudent s, AppService app) {
    final standing = DegreeClassStanding.fromGpa(s.gpa);
    final (standingBg, standingFg) = _getDegreeStandingColors(standing);
    final (statusBg, statusFg) = _getStatusColors(s.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Column 1: Student
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: RuslColors.accentYellow.withValues(
                    alpha: 0.4,
                  ),
                  child: Text(
                    s.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${s.registrationNumber} • ${s.email}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Column 2: Programme & Level
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.degreeProgramme,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: context.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _buildLevelPill(s.level),
                    const SizedBox(width: 6),
                    Text(
                      'Sem ${s.semester}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Column 3: CGPA & Standing
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  s.gpa.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: standingBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    standing.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: standingFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Column 4: Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusFg,
                  ),
                ),
              ),
            ),
          ),
          // Column 5: Actions
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: () => _showStudentDetailsDialog(s, app),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Manage & Override',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit details',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showEditStudentDialog(s),
                ),
                Switch(
                  value: s.active,
                  activeThumbColor: RuslColors.successGreen,
                  onChanged: (val) {
                    setState(() => s.active = val);
                    _message(
                      '${s.name} account ${val ? 'activated' : 'suspended'}.',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(_AdminStudent s, AppService app) {
    final standing = DegreeClassStanding.fromGpa(s.gpa);
    final (standingBg, standingFg) = _getDegreeStandingColors(standing);
    final (statusBg, statusFg) = _getStatusColors(s.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardSubtleColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: RuslColors.accentYellow.withValues(
                  alpha: 0.35,
                ),
                child: Text(
                  s.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${s.registrationNumber} • ${s.email}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.active,
                activeThumbColor: RuslColors.successGreen,
                onChanged: (val) {
                  setState(() => s.active = val);
                  _message(
                    '${s.name} account ${val ? 'activated' : 'suspended'}.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLevelPill(s.level),
              Text(
                'Sem ${s.semester}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                '•  ${s.degreeProgramme}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Text(
                'CGPA ${s.gpa.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: context.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: standingBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  standing.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: standingFg,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit details',
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showEditStudentDialog(s),
              ),
              FilledButton.tonal(
                onPressed: () => _showStudentDetailsDialog(s, app),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Manage & Override',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _getDegreeStandingColors(DegreeClassStanding standing) {
    return switch (standing) {
      DegreeClassStanding.firstClass => (
        RuslColors.successGreen.withValues(alpha: 0.15),
        RuslColors.successGreen,
      ),
      DegreeClassStanding.secondUpper => (
        const Color(0xFF00897B).withValues(alpha: 0.15),
        const Color(0xFF00897B),
      ),
      DegreeClassStanding.secondLower => (
        const Color(0xFF1E88E5).withValues(alpha: 0.15),
        const Color(0xFF1E88E5),
      ),
      DegreeClassStanding.pass => (
        const Color(0xFFFF8F00).withValues(alpha: 0.18),
        const Color(0xFFE65100),
      ),
      DegreeClassStanding.batchMiss => (
        RuslColors.errorRed.withValues(alpha: 0.14),
        RuslColors.errorRed,
      ),
    };
  }

  (Color, Color) _getStatusColors(String status) {
    return switch (status) {
      'Registered' => (
        RuslColors.successGreen.withValues(alpha: 0.15),
        RuslColors.successGreen,
      ),
      'Submitted' => (
        const Color(0xFF1E88E5).withValues(alpha: 0.15),
        const Color(0xFF1E88E5),
      ),
      'HoD Approved' => (
        const Color(0xFF00897B).withValues(alpha: 0.15),
        const Color(0xFF00897B),
      ),
      'Changes Requested' => (
        const Color(0xFFFF8F00).withValues(alpha: 0.18),
        const Color(0xFFE65100),
      ),
      'Rejected' => (
        RuslColors.errorRed.withValues(alpha: 0.15),
        RuslColors.errorRed,
      ),
      _ => (Colors.grey.withValues(alpha: 0.15), Colors.grey.shade700),
    };
  }

  // ============================================================================
  // SECTION 3: ACADEMIC STRUCTURE & TIMETABLE EXPLORER
  // ============================================================================
  Widget _academicStructure(AppService app) {
    return _page(
      'Academic Structure & Course Catalogue',
      'Manage university faculties, departments, degree curricula, and course timetable offerings.',
      [
        // Segmented Sub-Tab Bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _academicStructureTab = 0),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _academicStructureTab == 0
                          ? RuslColors.primaryMaroon
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Faculties, Departments & Curricula (${academicUnits.length})',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _academicStructureTab == 0
                            ? Colors.white
                            : context.textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _academicStructureTab = 1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _academicStructureTab == 1
                          ? RuslColors.primaryMaroon
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'University Timetable Offerings',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _academicStructureTab == 1
                            ? Colors.white
                            : context.textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (_academicStructureTab == 0) ...[
          // Action button row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Accredited Academic Units (${academicUnits.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: context.textPrimaryColor,
                ),
              ),
              FilledButton.icon(
                onPressed: _showAddAcademicUnit,
                style: FilledButton.styleFrom(
                  backgroundColor: RuslColors.primaryMaroon,
                ),
                icon: const Icon(Icons.add_business_rounded, size: 16),
                label: const Text('Add Academic Faculty'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Academic Units List
          ...academicUnits.map((f) => _buildAcademicUnitCard(f)),
        ] else ...[
          // Timetable Management Tab
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'University Lecture & Practical Slots',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: context.textPrimaryColor,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showCreateTimetableSlot(app),
                style: FilledButton.styleFrom(
                  backgroundColor: RuslColors.primaryMaroon,
                ),
                icon: const Icon(Icons.add_alarm_rounded, size: 16),
                label: const Text('Add Timetable Slot'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Timetable Academic Level & Day Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'COHORT LEVEL:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: context.textSecondaryColor,
                ),
              ),
              ...[
                (0, 'All Levels'),
                (1, 'Level 1'),
                (2, 'Level 2'),
                (3, 'Level 3'),
                (4, 'Level 4'),
              ].map((lvl) {
                final isSelected = _timetableLevelFilter == lvl.$1;
                final color = lvl.$1 == 0
                    ? RuslColors.primaryMaroon
                    : _getLevelColor(lvl.$1);
                return ChoiceChip(
                  label: Text(lvl.$2),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _timetableLevelFilter = lvl.$1);
                  },
                  selectedColor: color,
                  backgroundColor: context.surfaceColor,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : context.textPrimaryColor,
                    fontSize: 12,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'WEEKDAY:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: context.textSecondaryColor,
                ),
              ),
              ...[
                'All',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
              ].map((day) {
                final isSelected = _timetableDayFilter == day;
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _timetableDayFilter = day);
                  },
                  selectedColor: RuslColors.primaryMaroon,
                  backgroundColor: context.surfaceColor,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : context.textPrimaryColor,
                    fontSize: 12,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Timetable Slots List
          _buildTimetableList(app),
        ],
      ],
    );
  }

  Widget _buildAcademicUnitCard(_AcademicUnit f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: context.surfaceColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: context.borderColor),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: RuslColors.accentYellow.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                f.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          title: Text(
            f.name,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          subtitle: Text(
            '${f.departments.length} Departments • ${f.programmes.length} Programmes • ${f.courses.length} Courses',
            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 10),
            _managerTile(
              Icons.apartment_rounded,
              'Departments',
              f,
              f.departments,
            ),
            _managerTile(
              Icons.workspace_premium_outlined,
              'Degree Programmes',
              f,
              f.programmes,
            ),
            _managerTile(
              Icons.menu_book_outlined,
              'Course Offerings Catalogue',
              f,
              f.courses,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableList(AppService app) {
    final allSlots = <(CourseOffering, TimetableSlot, Course)>[];
    for (final offering in app.courseOfferings) {
      final course = app.courses.firstWhere(
        (c) => c.id == offering.courseId,
        orElse: () => Course(
          id: offering.courseId,
          code: 'GEN',
          title: 'General Course',
          description: 'General Course Description',
          creditValue: 3,
          level: 1,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.compulsory,
          prerequisiteCourseIds: [],
          corequisiteCourseIds: [],
        ),
      );
      for (final slot in offering.slots) {
        final matchesDay =
            _timetableDayFilter == 'All' ||
            slot.dayOfWeek == _timetableDayFilter;
        final matchesLevel =
            _timetableLevelFilter == 0 || course.level == _timetableLevelFilter;
        if (matchesDay && matchesLevel) {
          allSlots.add((offering, slot, course));
        }
      }
    }

    if (allSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(36),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(
          'No timetable slots configured for the selected level and day filters.',
          style: TextStyle(color: context.textSecondaryColor),
        ),
      );
    }

    return Column(
      children: allSlots.map((entry) {
        final (offering, slot, course) = entry;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      slot.dayOfWeek.substring(0, 3).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLevelPill(course.level),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${course.code} — ${course.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: context.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.startTime} – ${slot.endTime} • Venue: ${slot.venue} • Group: ${slot.groupType}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete Slot',
                onPressed: () {
                  app.deleteTimetableSlot(offering.id, slot.id);
                  _message('Removed timetable slot for ${course.code}.');
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: RuslColors.errorRed,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // SECTION 4: REGISTRATION PERIODS & DEADLINES
  // ============================================================================
  Widget _registrationPeriods(AppService app) {
    return _page(
      'Registration Windows & Calendar Control',
      'Manage university course enrollment windows, deadlines, and policy rules.',
      [
        // Master Registration Window Control Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: app.isRegistrationOpen
                  ? RuslColors.successGreen
                  : RuslColors.warningOrange,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (app.isRegistrationOpen
                                  ? RuslColors.successGreen
                                  : RuslColors.warningOrange)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      app.isRegistrationOpen
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      color: app.isRegistrationOpen
                          ? RuslColors.successGreen
                          : RuslColors.warningOrange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Academic Year 2025/2026 • Semester 1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            _Badge(
                              app.isRegistrationOpen
                                  ? 'WINDOW ACTIVE'
                                  : 'WINDOW CLOSED',
                              app.isRegistrationOpen
                                  ? RuslColors.successGreen
                                  : RuslColors.errorRed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Window Span: ${app.registrationStartLabel}, 08:00 AM — ${app.registrationEndLabel}, 23:59 PM',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: app.isRegistrationOpen,
                    activeThumbColor: RuslColors.successGreen,
                    onChanged: (v) {
                      app.adminToggleRegistrationWindow(v);
                      _message(
                        v
                            ? 'Enrollment window opened university-wide.'
                            : 'Enrollment window closed university-wide.',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: context.borderColor, height: 1),
              const SizedBox(height: 16),

              // Quick Extension Actions
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      app.adminExtendDeadline(7);
                      _message(
                        'Deadline extended by 7 days to ${app.registrationEndLabel}.',
                      );
                    },
                    icon: const Icon(Icons.more_time_rounded, size: 16),
                    label: const Text('Extend Deadline (+7 Days)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      app.adminExtendDeadline(14);
                      _message(
                        'Deadline extended by 14 days to ${app.registrationEndLabel}.',
                      );
                    },
                    icon: const Icon(Icons.more_time_rounded, size: 16),
                    label: const Text('Extend Deadline (+14 Days)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _message(
                      'Late registration penalty policies confirmed.',
                    ),
                    icon: const Icon(Icons.attach_money_rounded, size: 16),
                    label: const Text('Late Fee Configuration'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Undergraduate Academic Level Staggered Registration Windows (Levels 1 to 4)
        _panel(
          title:
              'Undergraduate Level Staggered Registration Schedules (Levels 1 - 4)',
          subtitle:
              'Specific enrollment windows, batch priorities, and deadline extensions divided by Academic Year levels',
          child: Column(
            children: [
              _buildLevelWindowScheduleRow(
                level: 4,
                title:
                    'Level 4 • Fourth Year (Final Year / Seniors • Intake 2021/2022)',
                windowSpan: 'Priority Window: Mar 10, 2026 — Apr 05, 2026',
                notes:
                    'Early verification for Capstone Research Projects & Industrial Internships (12-24 credits)',
                badge: 'PRIORITY OPEN',
                badgeColor: const Color(0xFFE65100),
                completionPercent: 0.97,
                app: app,
              ),
              const Divider(height: 1),
              _buildLevelWindowScheduleRow(
                level: 3,
                title: 'Level 3 • Third Year (Juniors • Intake 2022/2023)',
                windowSpan:
                    'Specialization Window: Mar 15, 2026 — Apr 05, 2026',
                notes:
                    'Elective specializations, Software Engineering & Cloud Infrastructure tracks (12-22 credits)',
                badge: 'ACTIVE OPEN',
                badgeColor: const Color(0xFF7B1FA2),
                completionPercent: 0.94,
                app: app,
              ),
              const Divider(height: 1),
              _buildLevelWindowScheduleRow(
                level: 2,
                title: 'Level 2 • Second Year (Sophomores • Intake 2023/2024)',
                windowSpan: 'Intermediate Window: Mar 20, 2026 — Apr 05, 2026',
                notes:
                    'Intermediate core modules, OOP & Database Systems (14-22 credits)',
                badge: 'ACTIVE OPEN',
                badgeColor: const Color(0xFF00897B),
                completionPercent: 0.89,
                app: app,
              ),
              const Divider(height: 1),
              _buildLevelWindowScheduleRow(
                level: 1,
                title: 'Level 1 • First Year (Freshers • Intake 2024/2025)',
                windowSpan:
                    'Foundation Window: Mar 22, 2026 — Apr 08, 2026 (Extended)',
                notes:
                    'Freshers orientation & foundational core modules registration (12-20 credits)',
                badge: 'WINDOW EXTENDED',
                badgeColor: const Color(0xFF1976D2),
                completionPercent: 0.92,
                app: app,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // University Registration Regulatory Policies Card
        _panel(
          title: 'Faculty Regulations & Enrollment Constraints',
          subtitle:
              'Enforced university-wide rules for undergraduate registration',
          child: Column(
            children: [
              _policyRow(
                Icons.rule_folder_outlined,
                'Minimum Credit Bound per Semester',
                '12 Credits (Mandatory Minimum for Full-time Students)',
                'ENFORCED',
                RuslColors.successGreen,
              ),
              const Divider(height: 1),
              _policyRow(
                Icons.speed_rounded,
                'Maximum Credit Ceiling per Semester',
                '22 Credits Normal Maximum (24 Credits with HoD Approved Waiver)',
                'ENFORCED',
                RuslColors.successGreen,
              ),
              const Divider(height: 1),
              _policyRow(
                Icons.block_flipped,
                'Dropped Courses Prohibition',
                'Students who dropped a course are permanently prohibited from re-registering',
                'ACTIVE LOCK',
                RuslColors.errorRed,
              ),
              const Divider(height: 1),
              _policyRow(
                Icons.upgrade_rounded,
                'Repeat Upgrading Cap (C-, D+, D, D-)',
                'Repeat examination grades are eligible to upgrade up to maximum grade C (2.0 GP)',
                'C MAX CAPPED',
                const Color(0xFF1E88E5),
              ),
              const Divider(height: 1),
              _policyRow(
                Icons.medical_services_outlined,
                'Medical Concession Repeat Provision',
                'Students with approved Medical certificates may re-register as First Attempt candidates',
                'PERMITTED',
                const Color(0xFF00897B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _policyRow(
    IconData icon,
    String title,
    String description,
    String badge,
    Color badgeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: RuslColors.primaryMaroon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          _Badge(badge, badgeColor),
        ],
      ),
    );
  }

  Widget _buildLevelWindowScheduleRow({
    required int level,
    required String title,
    required String windowSpan,
    required String notes,
    required String badge,
    required Color badgeColor,
    required double completionPercent,
    required AppService app,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLevelPill(level),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: context.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _Badge(badge, badgeColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            windowSpan,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            notes,
            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionPercent,
                    minHeight: 6,
                    backgroundColor: context.isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(completionPercent * 100).toInt()}% sealed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                app.adminExtendDeadline(7);
                _message('Extended Level $level enrollment window by 7 days.');
              },
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              child: const Text(
                '+7 Days Extension',
                style: TextStyle(fontSize: 10.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 5: SYSTEM SETTINGS
  // ============================================================================
  Widget _settingsPage() {
    return _page(
      'System Settings & Security Policies',
      'Configure platform security, authentication policies, automated backups, and maintenance controls.',
      [
        // Group 1: Security & Identity
        _panel(
          title: 'Security & Access Controls',
          subtitle:
              'Authentication requirements for university staff and administrators',
          child: Column(
            children: [
              _settingRow(
                'Enforce Multi-Factor Authentication (MFA)',
                'Require time-based one-time passwords for all privileged officer accounts',
                Icons.security_rounded,
                enforceMfa,
                (v) => setState(() => enforceMfa = v),
              ),
              const Divider(height: 1),
              _settingRow(
                'Automatic Session Timeout',
                'Terminate idle administrative sessions after 30 minutes of inactivity',
                Icons.timer_outlined,
                autoSessionTimeout,
                (v) => setState(() => autoSessionTimeout = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Group 2: Course Registration Validation Engine
        _panel(
          title: 'Course Registration Engine Governance',
          subtitle: 'Automated constraints checked during student submission',
          child: Column(
            children: [
              _settingRow(
                'Enforce Course Prerequisites',
                'Prevent registration in advanced courses if prerequisites are unfulfilled',
                Icons.checklist_rounded,
                enforcePrerequisites,
                (v) => setState(() => enforcePrerequisites = v),
              ),
              const Divider(height: 1),
              _settingRow(
                'Strict Credit Bounds (12 - 24 Credits)',
                'Block submissions below 12 credits or above 22 credits without formal petition',
                Icons.balance_rounded,
                strictCreditLimits,
                (v) => setState(() => strictCreditLimits = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Group 3: Notifications & Infrastructure
        _panel(
          title: 'Notifications & System Operations',
          subtitle: 'Alerts dispatch, disaster recovery, and maintenance state',
          child: Column(
            children: [
              _settingRow(
                'Email Notification Dispatches',
                'Send automatic email receipts for endorsements, rejections, and deadlines',
                Icons.alternate_email_rounded,
                emailNotifications,
                (v) => setState(() => emailNotifications = v),
              ),
              const Divider(height: 1),
              _settingRow(
                'SMS Alert Gateway',
                'Dispatch urgent SMS notices for registration sealing and freeze warnings',
                Icons.sms_outlined,
                smsNotifications,
                (v) => setState(() => smsNotifications = v),
              ),
              const Divider(height: 1),
              _settingRow(
                'Automated Daily Encrypted Backups',
                'Create encrypted daily snapshots of student records and audit trails',
                Icons.cloud_done_outlined,
                automaticBackups,
                (v) => setState(() => automaticBackups = v),
              ),
              const Divider(height: 1),
              _settingRow(
                'System Maintenance Mode',
                'Temporarily suspend student portal access while keeping admin access open',
                Icons.build_circle_outlined,
                maintenanceMode,
                (v) => setState(() => maintenanceMode = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Save Button
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => _message(
              'System administration configuration saved successfully.',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.primaryMaroon,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text(
              'Save Configuration',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingRow(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: RuslColors.primaryMaroon, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: context.textPrimaryColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
          ),
          value: value,
          activeThumbColor: RuslColors.successGreen,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================================
  // SECTION 6: AUDIT & COMPLIANCE LOGS
  // ============================================================================
  Widget _auditPage(AppService app) {
    final logs = app.auditLogs.where((log) {
      final q = auditSearch.toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          log.userName.toLowerCase().contains(q) ||
          log.action.toLowerCase().contains(q) ||
          log.details.toLowerCase().contains(q);
      final matchesCat = switch (auditCategoryFilter) {
        'Registration' =>
          log.action.contains('REGISTRATION') || log.action.contains('COURSE'),
        'Overrides' =>
          log.action.contains('OVERRIDE') || log.action.contains('STATUS'),
        'Security' =>
          log.action.contains('AUTH') || log.action.contains('PASSWORD'),
        _ => true,
      };
      return matchesQuery && matchesCat;
    }).toList();

    return _page(
      'System Audit & Security Logs',
      'Traceable, tamper-evident record of all authentication, registration, and administrative override events.',
      [
        // Filter and Search Toolbar
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 340,
              child: TextField(
                onChanged: (v) => setState(() => auditSearch = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: 'Search user, action, or event details...',
                  filled: true,
                  fillColor: context.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children: ['All', 'Registration', 'Overrides', 'Security'].map((
                cat,
              ) {
                final isSelected = auditCategoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => auditCategoryFilter = cat);
                  },
                  selectedColor: RuslColors.primaryMaroon,
                  backgroundColor: context.surfaceColor,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : context.textPrimaryColor,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  _message('Exported audit log as encrypted CSV archive.'),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export Audit Log'),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Audit Log Cards
        if (logs.isEmpty)
          Container(
            padding: const EdgeInsets.all(36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              'No audit logs match the current search filter.',
              style: TextStyle(color: context.textSecondaryColor),
            ),
          )
        else
          ...logs.map((log) => _buildAuditCard(log)),
      ],
    );
  }

  Widget _buildAuditCard(AuditLog log) {
    final (icon, iconColor) = switch (log.action) {
      String a when a.contains('STATUS') || a.contains('OVERRIDE') => (
        Icons.shield_outlined,
        RuslColors.warningOrange,
      ),
      String a when a.contains('SUBMITTED') || a.contains('APPROVED') => (
        Icons.check_circle_outline_rounded,
        RuslColors.successGreen,
      ),
      String a when a.contains('AUTH') || a.contains('LOGIN') => (
        Icons.lock_clock_outlined,
        const Color(0xFF1E88E5),
      ),
      _ => (Icons.history_rounded, RuslColors.primaryMaroon),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      log.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.cardSubtleColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.userRole,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                    _Badge(log.action, iconColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.details,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 7: ADMINISTRATOR PROFILE
  // ============================================================================
  Widget _profilePage() {
    return _page(
      'System Administrator Profile',
      'Officer credentials, active security session, and superuser administrative rights.',
      [
        // Profile Header Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: RuslColors.primaryMaroon,
                    child: const Text(
                      'SP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.accentYellow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Mr. P. S. Palliyaguruge',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            _Badge('SUPER ADMIN', RuslColors.primaryMaroon),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Director, Center for Information & Communication Technology (CITS)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rajarata University of Sri Lanka • Mihintale Campus',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: context.borderColor, height: 1),
              const SizedBox(height: 18),

              // Officer Metadata Grid
              Wrap(
                spacing: 24,
                runSpacing: 14,
                children: [
                  _profileItem(
                    'Username / Account',
                    'sysadmin',
                    Icons.account_circle_outlined,
                  ),
                  _profileItem(
                    'Staff EPF / ID',
                    'EPF/2012/CITS/001',
                    Icons.badge_outlined,
                  ),
                  _profileItem(
                    'Official Email',
                    'palliyaguruge@cits.rjt.ac.lk',
                    Icons.email_outlined,
                  ),
                  _profileItem(
                    'Active Session',
                    'Trusted University Optical Backbone',
                    Icons.lan_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Session Security Card
        _panel(
          title: 'Session & Cryptographic Credentials',
          subtitle:
              'Active session encryption and zero-trust authentication telemetry',
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: RuslColors.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Factor Authentication: Hardware Key / FIDO2 Enforced',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Session token: RUSL-SEC-ROOT-99824 • Verified via Campus Radius SSO',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _message('Password modification requested.'),
                    icon: const Icon(Icons.password_rounded, size: 16),
                    label: const Text('Change Password'),
                  ),
                  FilledButton.icon(
                    onPressed: context.read<AuthService>().logout,
                    style: FilledButton.styleFrom(
                      backgroundColor: RuslColors.errorRed,
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Sign Out of Admin Console'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: RuslColors.primaryMaroon),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // DIALOGS & ACTION MODALS
  // ============================================================================
  void _showAddStudentDialog(Faculty faculty, Department department) {
    final nameCtrl = TextEditingController();
    final regCtrl = TextEditingController(text: '${department.code}/2023/');
    final emailCtrl = TextEditingController();
    var level = 1;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Enroll Student in ${department.code}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty: ${faculty.name}\nDepartment: ${department.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Student Full Name',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regCtrl,
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'University Email Address',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: level,
                    decoration: InputDecoration(
                      labelText: 'Academic Level',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Level 1 (First Year)'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Level 2 (Second Year)'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Level 3 (Third Year)'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('Level 4 (Fourth Year)'),
                      ),
                    ],
                    onChanged: (val) => update(() => level = val ?? 1),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    regCtrl.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  _customStudents.insert(
                    0,
                    _AdminStudent(
                      registrationNumber: regCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                      facultyId: faculty.id,
                      departmentId: department.id,
                      degreeProgramme: 'B.Sc. in ${department.name}',
                      level: level,
                      semester: 1,
                      gpa: 3.50,
                      email: emailCtrl.text.trim().isNotEmpty
                          ? emailCtrl.text.trim()
                          : 'student@rjt.ac.lk',
                      status: 'Registered',
                    ),
                  );
                });
                Navigator.pop(ctx);
                _message(
                  'Student ${nameCtrl.text.trim()} enrolled in ${department.code}.',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Enroll Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetailsDialog(_AdminStudent student, AppService app) {
    var overrideStatus = student.status;
    final newCourseCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, updateDialog) {
          final standing = DegreeClassStanding.fromGpa(student.gpa);
          return AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: RuslColors.accentYellow,
                  child: const Icon(Icons.school_rounded, color: Colors.black),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${student.registrationNumber} • ${student.degreeProgramme}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Academic Metadata Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cardSubtleColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Academic Level: Level ${student.level} • Sem ${student.semester}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'CGPA: ${student.gpa.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _Badge(
                                    standing.label,
                                    RuslColors.primaryMaroon,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Email: ${student.email}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                'Active: ${student.active ? "Yes" : "Suspended"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: student.active
                                      ? RuslColors.successGreen
                                      : RuslColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Administrative Status Override
                    Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: RuslColors.warningOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ADMINISTRATIVE STATUS OVERRIDE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.cardSubtleColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: overrideStatus,
                              decoration: const InputDecoration(
                                labelText: 'Registration Status',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Registered',
                                  child: Text(
                                    'Registered (Officially Sealed)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Submitted',
                                  child: Text(
                                    'Submitted (Pending HoD)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'HoD Approved',
                                  child: Text(
                                    'HoD Approved (Endorsed)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Faculty Approved',
                                  child: Text(
                                    'Faculty Approved',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Changes Requested',
                                  child: Text(
                                    'Changes Requested',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Rejected',
                                  child: Text(
                                    'Rejected',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Draft',
                                  child: Text(
                                    'Draft',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (v) => updateDialog(
                                () => overrideStatus = v ?? overrideStatus,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () {
                              setState(() => student.status = overrideStatus);
                              if (student.registrationNumber.contains('045')) {
                                final regStatus = switch (overrideStatus) {
                                  'Registered' => RegistrationStatus.registered,
                                  'Submitted' => RegistrationStatus.submitted,
                                  'HoD Approved' =>
                                    RegistrationStatus.departmentApproved,
                                  'Faculty Approved' =>
                                    RegistrationStatus.facultyApproved,
                                  'Changes Requested' =>
                                    RegistrationStatus.changesRequested,
                                  'Rejected' => RegistrationStatus.rejected,
                                  _ => RegistrationStatus.draft,
                                };
                                app.adminSetRegistrationStatus(
                                  regStatus,
                                  'Status changed by System Administrator',
                                );
                              }
                              updateDialog(() {});
                              _message(
                                'Updated status for ${student.name} to $overrideStatus.',
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: RuslColors.primaryMaroon,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Enrolled Course Modules
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enrolled Modules (${student.enrolledCourses.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showResetPassword(
                            student.name,
                            student.registrationNumber,
                          ),
                          icon: const Icon(Icons.password_rounded, size: 16),
                          label: const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardSubtleColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        children: [
                          ...student.enrolledCourses.map(
                            (c) => ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.check_circle_rounded,
                                color: RuslColors.successGreen,
                                size: 18,
                              ),
                              title: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Drop module',
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: RuslColors.errorRed,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(
                                    () => student.enrolledCourses.remove(c),
                                  );
                                  updateDialog(() {});
                                  _message('Dropped module: $c');
                                },
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newCourseCtrl,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'e.g. ICT 3215 — Mobile Computing (3 Cr)',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: () {
                                    final val = newCourseCtrl.text.trim();
                                    if (val.isEmpty) return;
                                    setState(
                                      () => student.enrolledCourses.add(val),
                                    );
                                    newCourseCtrl.clear();
                                    updateDialog(() {});
                                    _message('Force enrolled module: $val');
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: RuslColors.primaryMaroon,
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text(
                                    'Enroll',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (student.registrationNumber ==
                  app.activeStudent.registrationNumber)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showAcademicRecordManager(context, app);
                  },
                  icon: const Icon(Icons.history_edu_rounded, size: 18),
                  label: const Text('Academic Record'),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEditStudentDialog(student);
                },
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Edit Info'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditStudentDialog(_AdminStudent student) {
    final nameCtrl = TextEditingController(text: student.name);
    final regCtrl = TextEditingController(text: student.registrationNumber);
    final degreeCtrl = TextEditingController(text: student.degreeProgramme);
    final gpaCtrl = TextEditingController(text: student.gpa.toStringAsFixed(2));
    final emailCtrl = TextEditingController(text: student.email);
    var level = student.level;
    var semester = student.semester;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Student • ${student.registrationNumber}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: regCtrl,
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: degreeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Degree Programme',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'University Email',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: level,
                          decoration: InputDecoration(
                            labelText: 'Level',
                            filled: true,
                            fillColor: context.cardSubtleColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Level 1')),
                            DropdownMenuItem(value: 2, child: Text('Level 2')),
                            DropdownMenuItem(value: 3, child: Text('Level 3')),
                            DropdownMenuItem(value: 4, child: Text('Level 4')),
                          ],
                          onChanged: (v) => update(() => level = v ?? level),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: semester,
                          decoration: InputDecoration(
                            labelText: 'Semester',
                            filled: true,
                            fillColor: context.cardSubtleColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Sem 1')),
                            DropdownMenuItem(value: 2, child: Text('Sem 2')),
                          ],
                          onChanged: (v) =>
                              update(() => semester = v ?? semester),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: gpaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CGPA',
                            filled: true,
                            fillColor: context.cardSubtleColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    regCtrl.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  student.name = nameCtrl.text.trim();
                  student.registrationNumber = regCtrl.text.trim();
                  student.degreeProgramme = degreeCtrl.text.trim();
                  student.email = emailCtrl.text.trim();
                  student.level = level;
                  student.semester = semester;
                  student.gpa =
                      double.tryParse(gpaCtrl.text.trim()) ?? student.gpa;
                });
                Navigator.pop(ctx);
                _message('Student record updated for ${student.name}.');
              },
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateTimetableSlot(AppService app) async {
    var offeringId = app.courseOfferings.first.id;
    var day = 'Monday';
    final start = TextEditingController(text: '08:30');
    final end = TextEditingController(text: '10:30');
    final venue = TextEditingController(text: 'LT 01 • Main Complex');
    String? error;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Create Timetable Slot',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: offeringId,
                    decoration: InputDecoration(
                      labelText: 'Course Offering',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: app.courseOfferings.map((offering) {
                      final course = app.courses.firstWhere(
                        (c) => c.id == offering.courseId,
                      );
                      return DropdownMenuItem(
                        value: offering.id,
                        child: Text(
                          '${course.code} — ${course.title}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => offeringId = value!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: day,
                    decoration: InputDecoration(
                      labelText: 'Day of Week',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        const [
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                            ]
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(
                                  val,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => day = value!,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: start,
                          decoration: InputDecoration(
                            labelText: 'Start (HH:mm)',
                            filled: true,
                            fillColor: context.cardSubtleColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: end,
                          decoration: InputDecoration(
                            labelText: 'End (HH:mm)',
                            filled: true,
                            fillColor: context.cardSubtleColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: venue,
                    decoration: InputDecoration(
                      labelText: 'Venue / Lecture Hall',
                      filled: true,
                      fillColor: context.cardSubtleColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: RuslColors.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final result = app.createTimetableSlot(
                  offeringId: offeringId,
                  dayOfWeek: day,
                  startTime: start.text.trim(),
                  endTime: end.text.trim(),
                  venue: venue.text.trim(),
                  groupType: 'Lecture',
                );
                if (result == null) {
                  Navigator.pop(ctx);
                  _message('Timetable slot created successfully.');
                } else {
                  update(() => error = result);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Create Slot'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddAcademicUnit() async {
    final code = TextEditingController();
    final name = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Academic Faculty',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.textPrimaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Faculty Code (e.g. FOT, FAS)',
                filled: true,
                fillColor: context.cardSubtleColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'Faculty Full Name',
                filled: true,
                fillColor: context.cardSubtleColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (code.text.trim().isEmpty || name.text.trim().isEmpty) return;
              setState(() {
                academicUnits.add(
                  _AcademicUnit(
                    code: code.text.trim().toUpperCase(),
                    name: name.text.trim(),
                    departments: [],
                    programmes: [],
                    courses: [],
                  ),
                );
              });
              Navigator.pop(dialogContext);
              _message('${name.text.trim()} added to university directory.');
            },
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.primaryMaroon,
            ),
            child: const Text('Add Faculty'),
          ),
        ],
      ),
    );
  }

  Widget _managerTile(
    IconData icon,
    String title,
    _AcademicUnit unit,
    List<String> items,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: RuslColors.primaryMaroon, size: 18),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: context.textPrimaryColor,
      ),
    ),
    subtitle: Text(
      '${items.length} records configured',
      style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
    ),
    trailing: TextButton(
      onPressed: () => _showItemsManager(unit, title, items),
      child: const Text('Manage'),
    ),
  );

  Future<void> _showItemsManager(
    _AcademicUnit unit,
    String title,
    List<String> items,
  ) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '$title • ${unit.code}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
            ),
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'New record entry',
                          filled: true,
                          fillColor: context.cardSubtleColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Add record',
                      style: IconButton.styleFrom(
                        backgroundColor: RuslColors.primaryMaroon,
                      ),
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isEmpty) return;
                        setState(() => items.add(value));
                        updateDialog(() {});
                        controller.clear();
                      },
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No records configured yet.'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              items[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove record',
                              onPressed: () {
                                setState(() => items.removeAt(index));
                                updateDialog(() {});
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: RuslColors.errorRed,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: RuslColors.primaryMaroon,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPERS & CARDS
  // ============================================================================
  Widget _statPill(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _metric(
    double width,
    String value,
    String label,
    IconData icon,
    Color color,
    String subtext,
    bool positive,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (positive
                              ? RuslColors.successGreen
                              : const Color(0xFF1E88E5))
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  positive ? 'ONLINE' : 'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: positive
                        ? RuslColors.successGreen
                        : const Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: context.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  List<Department> _getDepartmentsForFaculty(AppService app, String facultyId) {
    final list = app.departments
        .where((d) => d.facultyId == facultyId)
        .toList();
    if (list.isNotEmpty) return list;
    switch (facultyId) {
      case 'f2':
        return const [
          Department(
            id: 'd4',
            facultyId: 'f2',
            code: 'CS',
            name: 'Department of Computing',
          ),
          Department(
            id: 'd_fas1',
            facultyId: 'f2',
            code: 'DPS',
            name: 'Department of Physical Sciences',
          ),
          Department(
            id: 'd_fas2',
            facultyId: 'f2',
            code: 'DBS',
            name: 'Department of Biological Sciences',
          ),
        ];
      case 'f3':
        return const [
          Department(
            id: 'd_fms1',
            facultyId: 'f3',
            code: 'ACT',
            name: 'Department of Accountancy & Finance',
          ),
          Department(
            id: 'd_fms2',
            facultyId: 'f3',
            code: 'MGT',
            name: 'Department of Business Management',
          ),
          Department(
            id: 'd_fms3',
            facultyId: 'f3',
            code: 'MKT',
            name: 'Department of Marketing Management',
          ),
        ];
      case 'f4':
        return const [
          Department(
            id: 'd_foa1',
            facultyId: 'f4',
            code: 'AGS',
            name: 'Department of Agricultural Systems',
          ),
          Department(
            id: 'd_foa2',
            facultyId: 'f4',
            code: 'PLS',
            name: 'Department of Plant Sciences',
          ),
          Department(
            id: 'd_foa3',
            facultyId: 'f4',
            code: 'AFS',
            name: 'Department of Animal & Food Sciences',
          ),
        ];
      case 'f5':
        return const [
          Department(
            id: 'd_med1',
            facultyId: 'f5',
            code: 'MED',
            name: 'Department of Medicine',
          ),
          Department(
            id: 'd_med2',
            facultyId: 'f5',
            code: 'SURG',
            name: 'Department of Surgery',
          ),
          Department(
            id: 'd_med3',
            facultyId: 'f5',
            code: 'PAED',
            name: 'Department of Paediatrics',
          ),
        ];
      case 'f6':
        return const [
          Department(
            id: 'd_ssh1',
            facultyId: 'f6',
            code: 'HUM',
            name: 'Department of Humanities',
          ),
          Department(
            id: 'd_ssh2',
            facultyId: 'f6',
            code: 'SOC',
            name: 'Department of Social Sciences',
          ),
          Department(
            id: 'd_ssh3',
            facultyId: 'f6',
            code: 'ECON',
            name: 'Department of Economics',
          ),
        ];
      default:
        return const [
          Department(
            id: 'd1',
            facultyId: 'f1',
            code: 'ICT',
            name: 'Information & Communication Technology',
          ),
        ];
    }
  }

  List<_AdminStudent> _getStudentsForDepartment(
    String facultyId,
    String departmentId,
    String departmentCode,
    String departmentName,
  ) {
    final list = <_AdminStudent>[];

    if (departmentId == 'd1' || departmentCode == 'ICT') {
      list.addAll([
        // ================= LEVEL 1 (First Year • Freshers • Intake 2024/2025) =================
        _AdminStudent(
          registrationNumber: 'ICT/2024/001',
          name: 'Dinuka Perera',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 3.82,
          email: 'dinuka.p@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2024/015',
          name: 'Tharindu Dananjaya',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 3.65,
          email: 'tharindu.d@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2024/032',
          name: 'Sewwandi Rajapaksha',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 3.38,
          email: 'sewwandi.r@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2024/055',
          name: 'Chathura Senanayake',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 2.85,
          email: 'chathura.s@student.rjt.ac.lk',
          status: 'Submitted',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2024/078',
          name: 'Malithi Fonseka',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 3.74,
          email: 'malithi.f@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2024/110',
          name: 'Ravindu Wickramasinghe',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 1,
          semester: 1,
          gpa: 1.90, // Batch Miss candidate (< 2.00)
          email: 'ravindu.w@student.rjt.ac.lk',
          status: 'Changes Requested',
          enrolledCourses: [
            'ICT 1101 Fundamentals of Computing (3 Cr)',
            'ICT 1102 Structured Programming (3 Cr)',
            'CMT 1101 Mathematics for Computing (3 Cr)',
            'ENG 1101 English for Technology (2 Cr)',
          ],
        ),

        // ================= LEVEL 2 (Second Year • Sophomores • Intake 2023/2024) =================
        _AdminStudent(
          registrationNumber: 'ICT/2023/008',
          name: 'Chamindu Bandara',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 3.58,
          email: 'chamindu.b@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2023/024',
          name: 'Kaveesha De Silva',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 3.75,
          email: 'kaveesha.d@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2023/047',
          name: 'Pubudu Rathnayake',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 3.25,
          email: 'pubudu.r@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2023/062',
          name: 'Oshadi Jayasundara',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 3.60,
          email: 'oshadi.j@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2023/089',
          name: 'Isuru Jayawardena',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 2.70,
          email: 'isuru.j@student.rjt.ac.lk',
          status: 'Submitted',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2023/105',
          name: 'Anjana Weerakkody',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 2,
          semester: 1,
          gpa: 3.48,
          email: 'anjana.w@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 2101 Object Oriented Programming (3 Cr)',
            'ICT 2102 Database Management Systems (3 Cr)',
            'ICT 2103 Data Structures & Algorithms (3 Cr)',
            'CMT 2101 Discrete Mathematics (3 Cr)',
          ],
        ),

        // ================= LEVEL 3 (Third Year • Juniors • Intake 2022/2023 & 2021) =================
        _AdminStudent(
          registrationNumber: 'ICT/2021/045',
          name: 'M. N. Mohamed Nafis',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 2,
          gpa: 3.79,
          email: 'nafis.ahamed@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/001',
          name: 'Amaya Perera',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 3.65,
          email: 'amaya.perera@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/002',
          name: 'Kasun Silva',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 3.42,
          email: 'kasun.silva@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/003',
          name: 'Tharushi Fernando',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 3.88,
          email: 'tharushi.fernando@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/004',
          name: 'Dilan Bandara',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 3.20,
          email: 'dilan.bandara@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/005',
          name: 'Nethmi Herath',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 3.55,
          email: 'nethmi.herath@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2022/088',
          name: 'Anuki Jayasinghe',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 3,
          semester: 1,
          gpa: 1.85, // Batch Miss candidate (< 2.00)
          email: 'anuki.j@student.rjt.ac.lk',
          status: 'Changes Requested',
          enrolledCourses: [
            'ICT 3101 Software Engineering (3 Cr)',
            'ICT 3102 Web Services & API Design (3 Cr)',
            'ICT 3103 Mobile Application Development (3 Cr)',
            'ICT 3104 Cloud Infrastructure (3 Cr)',
          ],
        ),

        // ================= LEVEL 4 (Fourth Year • Final Year • Intake 2021/2022) =================
        _AdminStudent(
          registrationNumber: 'ICT/2021/014',
          name: 'Sanduni Pathirana',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 3.82,
          email: 'sanduni.p@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2020/022',
          name: 'Malith Fernando',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 3.75,
          email: 'malith.f@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2021/028',
          name: 'Hasitha Gunawardena',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 3.52,
          email: 'hasitha.g@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2021/050',
          name: 'Bhagya Senaratne',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 3.35,
          email: 'bhagya.s@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2021/072',
          name: 'Janith Alwis',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 2.90,
          email: 'janith.a@student.rjt.ac.lk',
          status: 'Submitted',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'ICT/2021/099',
          name: 'Nadun Samarasinghe',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in ICT',
          level: 4,
          semester: 1,
          gpa: 3.68,
          email: 'nadun.s@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'ICT 4101 Final Year Research Project (6 Cr)',
            'ICT 4102 Advanced Enterprise Architecture (3 Cr)',
            'ICT 4103 Machine Learning & Data Science (3 Cr)',
            'ICT 4201 Industrial Training & Internship (6 Cr)',
          ],
        ),
      ]);
    } else if (departmentId == 'd2' || departmentCode == 'BPT') {
      list.addAll([
        // Level 1 BPT
        _AdminStudent(
          registrationNumber: 'BPT/2024/001',
          name: 'K.M. Jayawardena',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 1,
          semester: 1,
          gpa: 3.70,
          email: 'jayawardena.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 1101 Introduction to Bioprocess (3 Cr)',
            'BPT 1102 General Microbiology (3 Cr)',
            'CMT 1102 Applied Chemistry (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'BPT/2024/002',
          name: 'S.H. Wickramasinghe',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 1,
          semester: 1,
          gpa: 3.52,
          email: 'wickrama.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 1101 Introduction to Bioprocess (3 Cr)',
            'BPT 1102 General Microbiology (3 Cr)',
            'CMT 1102 Applied Chemistry (3 Cr)',
          ],
        ),
        // Level 2 BPT
        _AdminStudent(
          registrationNumber: 'BPT/2023/001',
          name: 'R.D. Tennakoon',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 2,
          semester: 1,
          gpa: 3.45,
          email: 'tennakoon.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 2101 Biochemical Engineering (3 Cr)',
            'BPT 2102 Microbial Genetics (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'BPT/2023/002',
          name: 'P.L. Herath',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 2,
          semester: 1,
          gpa: 3.62,
          email: 'herath.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 2101 Biochemical Engineering (3 Cr)',
            'BPT 2102 Microbial Genetics (3 Cr)',
          ],
        ),
        // Level 3 BPT
        _AdminStudent(
          registrationNumber: 'BPT/2022/001',
          name: 'N.C. Dissanayake',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 3,
          semester: 1,
          gpa: 3.68,
          email: 'dissanayake.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 3101 Industrial Fermentation (3 Cr)',
            'BPT 3102 Bioseparation Processes (3 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'BPT/2022/002',
          name: 'M.A. Fernando',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 3,
          semester: 1,
          gpa: 3.30,
          email: 'fernando.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 3101 Industrial Fermentation (3 Cr)',
            'BPT 3102 Bioseparation Processes (3 Cr)',
          ],
        ),
        // Level 4 BPT
        _AdminStudent(
          registrationNumber: 'BPT/2021/001',
          name: 'T.K. Perera',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 4,
          semester: 1,
          gpa: 3.85,
          email: 'perera.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 4101 Capstone Research Thesis (6 Cr)',
            'BPT 4201 Industrial Biotechnology Training (6 Cr)',
          ],
        ),
        _AdminStudent(
          registrationNumber: 'BPT/2021/002',
          name: 'G.S. Alahakoon',
          facultyId: facultyId,
          departmentId: departmentId,
          degreeProgramme: 'B.Sc. (Hons) in Bio-Process Technology',
          level: 4,
          semester: 1,
          gpa: 3.56,
          email: 'alahakoon.bpt@student.rjt.ac.lk',
          status: 'Registered',
          enrolledCourses: [
            'BPT 4101 Capstone Research Thesis (6 Cr)',
            'BPT 4201 Industrial Biotechnology Training (6 Cr)',
          ],
        ),
      ]);
    } else {
      // Procedurally generate a rich 16-student cohort cleanly spanning Levels 1, 2, 3, and 4
      const firstNames = [
        'Nuwan',
        'Sanduni',
        'Kavishka',
        'Dilki',
        'Isuru',
        'Hansani',
        'Charith',
        'Anoma',
        'Lakshan',
        'Praveen',
        'Sachith',
        'Thilini',
        'Janaka',
        'Nadeesha',
        'Mahesh',
        'Gayan',
      ];
      const lastNames = [
        'Bandara',
        'Wijesinghe',
        'Herath',
        'Jayathilaka',
        'Rathnamalala',
        'Gunasekara',
        'Perera',
        'Silva',
        'Fernando',
        'Kumara',
        'Senanayake',
        'Wickramasooriya',
        'Dassanayake',
        'Alahakoon',
        'Samarajeewa',
        'Lokuge',
      ];
      final gpas = [
        3.85,
        3.68,
        3.42,
        2.85,
        3.75,
        3.58,
        3.32,
        2.92,
        3.88,
        3.65,
        3.20,
        1.88,
        3.92,
        3.55,
        3.40,
        3.10,
      ];

      for (int i = 0; i < 16; i++) {
        final level =
            (i % 4) + 1; // Exactly 4 students each for Level 1, 2, 3, and 4
        final intakeYear = switch (level) {
          1 => '2024',
          2 => '2023',
          3 => '2022',
          _ => '2021',
        };
        final regIndex = ((i ~/ 4) + 1).toString().padLeft(3, '0');
        final fullName = '${firstNames[i]} ${lastNames[i]}';
        final emailPrefix =
            '${firstNames[i].toLowerCase()}.${lastNames[i].toLowerCase()}';
        final status = i == 11
            ? 'Changes Requested'
            : (i % 5 == 0 ? 'Submitted' : 'Registered');

        list.add(
          _AdminStudent(
            registrationNumber: '$departmentCode/$intakeYear/$regIndex',
            name: fullName,
            facultyId: facultyId,
            departmentId: departmentId,
            degreeProgramme: 'B.Sc. in $departmentName',
            level: level,
            semester: 1,
            gpa: gpas[i],
            email: '$emailPrefix@student.rjt.ac.lk',
            status: status,
            enrolledCourses: [
              '$departmentCode ${level}101 Core Module 1 (3 Cr)',
              '$departmentCode ${level}102 Core Module 2 (3 Cr)',
              '$departmentCode ${level}103 Elective Module (3 Cr)',
            ],
          ),
        );
      }
    }

    list.addAll(_customStudents.where((s) => s.departmentId == departmentId));
    return list;
  }

  String _initials(String name) => name
      .split(' ')
      .where((v) => v.isNotEmpty)
      .map((v) => v[0])
      .take(2)
      .join();

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}

// ============================================================================
// ADMIN SIDEBAR NAVIGATION DRAWER
// ============================================================================
class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.userName,
    required this.onSelected,
    required this.onLogout,
  });

  static const items = [
    (Icons.dashboard_rounded, 'System Overview'),
    (Icons.manage_accounts_rounded, 'Staff & Roles'),
    (Icons.groups_rounded, 'Student Directory'),
    (Icons.account_balance_rounded, 'Academic Structure'),
    (Icons.date_range_rounded, 'Registration Periods'),
    (Icons.tune_rounded, 'System Settings'),
    (Icons.policy_rounded, 'Audit Logs'),
    (Icons.admin_panel_settings_rounded, 'Admin Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RuslColors.primaryMaroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      color: RuslColors.accentYellow,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RUSL PORTAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: RuslColors.primaryMaroon,
                        ),
                      ),
                      Text(
                        'Central Administration',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Officer Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [RuslColors.primaryMaroon, const Color(0xFF5A0D0E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: RuslColors.accentYellow,
                    child: const Text(
                      'SA',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
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
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'System Administrator • CITS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                'GOVERNANCE MODULES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: context.textSecondaryColor,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  selected: selectedIndex == i,
                  selectedTileColor: RuslColors.primaryMaroon.withValues(
                    alpha: 0.12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    items[i].$1,
                    color: selectedIndex == i
                        ? RuslColors.primaryMaroon
                        : context.textSecondaryColor,
                    size: 20,
                  ),
                  title: Text(
                    items[i].$2,
                    style: TextStyle(
                      fontWeight: selectedIndex == i
                          ? FontWeight.w900
                          : FontWeight.w700,
                      fontSize: 13,
                      color: selectedIndex == i
                          ? RuslColors.primaryMaroon
                          : context.textPrimaryColor,
                    ),
                  ),
                  trailing: selectedIndex == i
                      ? const Icon(
                          Icons.chevron_right_rounded,
                          color: RuslColors.primaryMaroon,
                          size: 18,
                        )
                      : null,
                  onTap: () => onSelected(i),
                ),
              ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: RuslColors.errorRed,
                side: const BorderSide(color: RuslColors.errorRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Supporting Domain Data Classes
class _AcademicUnit {
  final String code;
  final String name;
  final List<String> departments;
  final List<String> programmes;
  final List<String> courses;

  _AcademicUnit({
    required this.code,
    required this.name,
    required this.departments,
    required this.programmes,
    required this.courses,
  });
}

class _AdminUser {
  String name;
  String username;
  String role;
  String department;
  String email;
  bool active;

  _AdminUser({
    required this.name,
    required this.username,
    required this.role,
    required this.department,
    required this.email,
    this.active = true,
  });
}

class _AdminStudent {
  String registrationNumber;
  String name;
  String facultyId;
  String departmentId;
  String degreeProgramme;
  int level;
  int semester;
  double gpa;
  bool active = true;
  String status;
  String email;
  List<String> enrolledCourses;

  _AdminStudent({
    required this.registrationNumber,
    required this.name,
    required this.facultyId,
    required this.departmentId,
    required this.degreeProgramme,
    required this.level,
    required this.semester,
    required this.gpa,
    this.status = 'Registered',
    required this.email,
    List<String>? enrolledCourses,
  }) : enrolledCourses =
           enrolledCourses ??
           [
             'Core Module 1 (3 Credits, Compulsory)',
             'Core Module 2 (3 Credits, Compulsory)',
             'Elective Module 1 (3 Credits, Option)',
             'Elective Module 2 (3 Credits, Option)',
           ];

  String get initials => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0])
      .take(2)
      .join();
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _HealthTile extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color statusColor;

  const _HealthTile(this.title, this.status, this.icon, this.statusColor);

  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.cardSubtleColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.borderColor),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
