import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

// ============================================================================
// DEAN DASHBOARD DATA MODELS
// ============================================================================

class _DeanStudentItem {
  final String id;
  final String registrationNumber;
  final String name;
  final String departmentId;
  final String departmentCode;
  final String departmentName;
  final String degreeProgramme;
  final int level;
  final int semester;
  final double gpa;
  final int credits;
  RegistrationStatus status;
  final String hodEndorsementDate;
  final List<String> enrolledCourses;
  final String? remarks;

  _DeanStudentItem({
    required this.id,
    required this.registrationNumber,
    required this.name,
    required this.departmentId,
    required this.departmentCode,
    required this.departmentName,
    required this.degreeProgramme,
    required this.level,
    required this.semester,
    required this.gpa,
    required this.credits,
    required this.status,
    required this.hodEndorsementDate,
    required this.enrolledCourses,
    this.remarks,
  });

  String get initials => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0])
      .take(2)
      .join();
}

class _DeanStaffMember {
  final String name;
  final String designation;
  final String departmentCode;
  final String departmentName;
  final String email;
  final String office;
  final String qualifications;
  final bool isFacultyBoardMember;

  const _DeanStaffMember({
    required this.name,
    required this.designation,
    required this.departmentCode,
    required this.departmentName,
    required this.email,
    required this.office,
    required this.qualifications,
    this.isFacultyBoardMember = true,
  });
}

// ============================================================================
// MAIN DEAN DASHBOARD SCREEN
// ============================================================================

class DeanDashboardScreen extends StatefulWidget {
  final int selectedSection;
  final ValueChanged<int>? onNavigate;

  const DeanDashboardScreen({
    super.key,
    required this.selectedSection,
    this.onNavigate,
  });

  @override
  State<DeanDashboardScreen> createState() => _DeanDashboardScreenState();
}

class _DeanDashboardScreenState extends State<DeanDashboardScreen> {
  late int _activeSection;

  // Filter States
  String _queueDeptFilter = 'All';
  int _queueLevelFilter = 0; // 0 = All, 1..4
  String _queueStatusFilter = 'All'; // All, Pending, Endorsed, Under Revision

  String _studentSearchQuery = '';
  String _studentDeptFilter = 'All';
  int _studentLevelFilter = 0;
  String _studentStandingFilter = 'All';

  String _petitionStatusFilter = 'All'; // All, Pending, Approved, Rejected
  String _staffDeptFilter = 'All';

  // Mock student roster for Faculty of Technology
  late List<_DeanStudentItem> _facultyStudents;
  bool _initializedData = false;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.selectedSection;
  }

  @override
  void didUpdateWidget(covariant DeanDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSection != widget.selectedSection) {
      _activeSection = widget.selectedSection;
    }
  }

  void _navigateTo(int section) {
    setState(() => _activeSection = section);
    widget.onNavigate?.call(section);
  }

  void _initFacultyData(AppService app) {
    if (_initializedData) return;
    _initializedData = true;

    // Build realistic FOT student cohort
    _facultyStudents = [
      _DeanStudentItem(
        id: 'st_001',
        registrationNumber: app.activeStudent.registrationNumber,
        name: app.activeStudent.fullName,
        departmentId: 'd1',
        departmentCode: 'ICT',
        departmentName: 'Information & Communication Technology',
        degreeProgramme: 'BICT (Honours)',
        level: app.activeStudent.currentLevel,
        semester: app.activeStudent.currentSemester,
        gpa: 3.65,
        credits: app.totalSelectedCredits > 0 ? app.totalSelectedCredits : 18,
        status: app.activeRegistrationStatus,
        hodEndorsementDate: '2026-10-08 14:30',
        enrolledCourses: app.selectedOfferingsList.isNotEmpty
            ? app.selectedOfferingsList.map((o) {
                final c = app.courses.cast<Course?>().firstWhere(
                      (item) => item?.id == o.courseId,
                      orElse: () => null,
                    );
                return '${c?.code ?? "ICT"} • ${c?.title ?? "Course"} (${c?.creditValue ?? 3} Credits)';
              }).toList()
            : [
                'ICT 3201 Software Project Management (2 Cr)',
                'ICT 3202 Distributed Systems (3 Cr)',
                'ICT 3203 Scientific Computing (2 Cr)',
                'ICT 3204 Cloud Computing (3 Cr)',
                'ICT 3205 Mobile App Development (3 Cr)',
              ],
        remarks: 'All compulsory and elective credit requirements satisfied.',
      ),
      _DeanStudentItem(
        id: 'st_002',
        registrationNumber: 'ICT/2021/012',
        name: 'K. A. D. Sanduni Perera',
        departmentId: 'd1',
        departmentCode: 'ICT',
        degreeProgramme: 'BICT (Honours)',
        departmentName: 'Information & Communication Technology',
        level: 3,
        semester: 2,
        gpa: 3.82,
        credits: 17,
        status: RegistrationStatus.departmentApproved,
        hodEndorsementDate: '2026-10-09 10:15',
        enrolledCourses: [
          'ICT 3201 Software Project Management (2 Cr)',
          'ICT 3202 Distributed Systems (3 Cr)',
          'ICT 3204 Cloud Computing (3 Cr)',
          'ICT 3206 Artificial Intelligence (3 Cr)',
        ],
        remarks: 'First class standing. HoD endorsed with merit.',
      ),
      _DeanStudentItem(
        id: 'st_003',
        registrationNumber: 'BPT/2021/008',
        name: 'T. M. Nuwan Jayawardena',
        departmentId: 'd2',
        departmentCode: 'BPT',
        departmentName: 'Bio-Process Technology',
        degreeProgramme: 'BBST (Honours)',
        level: 3,
        semester: 2,
        gpa: 3.45,
        credits: 18,
        status: RegistrationStatus.departmentApproved,
        hodEndorsementDate: '2026-10-09 11:45',
        enrolledCourses: [
          'BPT 3201 Bioreactor Design & Scale-up (3 Cr)',
          'BPT 3202 Fermentation Technology (3 Cr)',
          'BPT 3203 Downstream Processing (3 Cr)',
          'BPT 3204 Biosafety & Regulatory Affairs (2 Cr)',
        ],
      ),
      _DeanStudentItem(
        id: 'st_004',
        registrationNumber: 'EET/2022/021',
        name: 'R. S. Dilshan Bandara',
        departmentId: 'd3',
        departmentCode: 'EET',
        departmentName: 'Electrical & Electronic Technology',
        degreeProgramme: 'BET (Honours) - Electrical',
        level: 2,
        semester: 2,
        gpa: 3.28,
        credits: 16,
        status: RegistrationStatus.departmentApproved,
        hodEndorsementDate: '2026-10-09 16:00',
        enrolledCourses: [
          'EET 2201 Microcontroller Architecture (3 Cr)',
          'EET 2202 Power Electronics I (3 Cr)',
          'EET 2203 Signals and Systems (3 Cr)',
          'EET 2204 Instrumentation Laboratory (2 Cr)',
        ],
      ),
      _DeanStudentItem(
        id: 'st_005',
        registrationNumber: 'FDT/2023/033',
        name: 'H. M. Tharushi Nisansala',
        departmentId: 'd4',
        departmentCode: 'FDT',
        departmentName: 'Food Technology',
        degreeProgramme: 'BBST (Honours) - Food Tech',
        level: 1,
        semester: 2,
        gpa: 3.55,
        credits: 15,
        status: RegistrationStatus.facultyApproved,
        hodEndorsementDate: '2026-10-07 09:20',
        enrolledCourses: [
          'FDT 1201 Food Chemistry Fundamentals (3 Cr)',
          'FDT 1202 Post-harvest Biology (3 Cr)',
          'FDT 1203 Food Microbiology I (3 Cr)',
        ],
      ),
      _DeanStudentItem(
        id: 'st_006',
        registrationNumber: 'MTT/2021/005',
        name: 'W. G. Kasun Chamara',
        departmentId: 'd5',
        departmentCode: 'MTT',
        departmentName: 'Materials Technology',
        degreeProgramme: 'BET (Honours) - Materials',
        level: 4,
        semester: 2,
        gpa: 3.12,
        credits: 12,
        status: RegistrationStatus.registered,
        hodEndorsementDate: '2026-10-05 13:10',
        enrolledCourses: [
          'MTT 4201 Advanced Composite Materials (3 Cr)',
          'MTT 4202 Industrial Internship (6 Cr)',
          'MTT 4203 Final Research Seminar (3 Cr)',
        ],
      ),
      _DeanStudentItem(
        id: 'st_007',
        registrationNumber: 'ICT/2022/089',
        name: 'A. B. Fathima Rizna',
        departmentId: 'd1',
        departmentCode: 'ICT',
        departmentName: 'Information & Communication Technology',
        degreeProgramme: 'BICT (Honours)',
        level: 2,
        semester: 2,
        gpa: 3.71,
        credits: 16,
        status: RegistrationStatus.departmentApproved,
        hodEndorsementDate: '2026-10-09 17:30',
        enrolledCourses: [
          'ICT 2201 Database Management Systems (3 Cr)',
          'ICT 2202 Data Structures & Algorithms (3 Cr)',
          'ICT 2203 Web Application Engineering (3 Cr)',
        ],
      ),
      _DeanStudentItem(
        id: 'st_008',
        registrationNumber: 'BPT/2023/042',
        name: 'P. G. Sahan Methsara',
        departmentId: 'd2',
        departmentCode: 'BPT',
        departmentName: 'Bio-Process Technology',
        degreeProgramme: 'BBST (Honours)',
        level: 1,
        semester: 2,
        gpa: 2.85,
        credits: 14,
        status: RegistrationStatus.changesRequested,
        hodEndorsementDate: '2026-10-08 11:00',
        enrolledCourses: [
          'BPT 1201 Cell Biology & Genetics (3 Cr)',
          'BPT 1202 Applied Biochemistry (3 Cr)',
        ],
        remarks: 'Returned for prerequisite verification on Organic Chemistry.',
      ),
    ];
  }

  static const List<_DeanStaffMember> _facultyStaff = [
    _DeanStaffMember(
      name: 'Prof. T. C. Bamunuarachchige',
      designation: 'Dean & Professor of Technology',
      departmentCode: 'DEAN',
      departmentName: 'Office of the Dean',
      email: 'dean@tec.rjt.ac.lk',
      office: 'Dean\'s Secretariat, FOT Complex',
      qualifications: 'B.Sc. (Hons), Ph.D., C.Chem, F.I.Chem.C',
    ),
    _DeanStaffMember(
      name: 'Dr. Lahiru Jayasuriya',
      designation: 'Head of Department & Senior Lecturer',
      departmentCode: 'ICT',
      departmentName: 'Information & Communication Technology',
      email: 'lahiru@tec.rjt.ac.lk',
      office: 'Room 204, ICT Wing',
      qualifications: 'B.Sc. Eng (Hons), M.Sc., Ph.D.',
    ),
    _DeanStaffMember(
      name: 'Dr. Chaminda Ranasinghe',
      designation: 'Head of Department & Senior Lecturer',
      departmentCode: 'BPT',
      departmentName: 'Bio-Process Technology',
      email: 'chaminda.r@tec.rjt.ac.lk',
      office: 'Room 302, Bio Wing',
      qualifications: 'B.Sc. (Hons), Ph.D. (Monash)',
    ),
    _DeanStaffMember(
      name: 'Dr. W. K. P. Chathurangika',
      designation: 'Head of Department & Senior Lecturer',
      departmentCode: 'EET',
      departmentName: 'Electrical & Electronic Technology',
      email: 'chathurangika@tec.rjt.ac.lk',
      office: 'Room 105, Tech Complex',
      qualifications: 'B.Sc. Eng, M.Phil, Ph.D.',
    ),
    _DeanStaffMember(
      name: 'Dr. Anoma Wijesekara',
      designation: 'Head of Department & Senior Lecturer',
      departmentCode: 'FDT',
      departmentName: 'Food Technology',
      email: 'anoma.w@tec.rjt.ac.lk',
      office: 'Room 210, Food Processing Lab',
      qualifications: 'B.Sc. (Hons), M.Sc., Ph.D. (UQ)',
    ),
    _DeanStaffMember(
      name: 'Dr. S. K. Narangoda',
      designation: 'Head of Department & Senior Lecturer',
      departmentCode: 'MTT',
      departmentName: 'Materials Technology',
      email: 'sk.narangoda@tec.rjt.ac.lk',
      office: 'Room 118, Engineering Wing',
      qualifications: 'B.Sc. (Hons), Ph.D. (Cambridge)',
    ),
    _DeanStaffMember(
      name: 'Mr. Wiraj Wickramaarachchi',
      designation: 'Senior Lecturer in Computing',
      departmentCode: 'ICT',
      departmentName: 'Information & Communication Technology',
      email: 'wiraj@tec.rjt.ac.lk',
      office: 'Room 206, ICT Wing',
      qualifications: 'BICT (Hons), M.Sc. (Moratuwa)',
      isFacultyBoardMember: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final faculty = app.faculties.firstWhere(
      (item) => item.code == 'FOT',
      orElse: () => app.faculties.first,
    );
    final departments = app.departments
        .where((item) => item.facultyId == faculty.id)
        .toList();

    _initFacultyData(app);

    // Keep active student in sync
    final activeIndex = _facultyStudents.indexWhere(
      (s) => s.registrationNumber == app.activeStudent.registrationNumber,
    );
    if (activeIndex != -1) {
      _facultyStudents[activeIndex].status = app.activeRegistrationStatus;
    }

    return switch (_activeSection) {
      0 => _overview(app, faculty.name, departments.length),
      1 => _endorsementQueue(app),
      2 => _departments(departments),
      3 => _studentRegistry(),
      4 => _specialPetitions(app),
      5 => _academicStaff(),
      6 => _facultyReports(app, departments.length),
      _ => _deanProfile(),
    };
  }

  // ==========================================================================
  // SECTION 0: FACULTY OVERVIEW (EXECUTIVE DASHBOARD)
  // ==========================================================================

  Widget _overview(AppService app, String facultyName, int departmentCount) {
    final pendingDeanCount = _facultyStudents
        .where((s) => s.status == RegistrationStatus.departmentApproved)
        .length;
    final endorsedCount = _facultyStudents
        .where((s) =>
            s.status == RegistrationStatus.facultyApproved ||
            s.status == RegistrationStatus.registered ||
            s.status == RegistrationStatus.locked)
        .length;
    final totalStudents = _facultyStudents.length;
    final endorsementRate = totalStudents > 0
        ? ((endorsedCount / totalStudents) * 100).toInt()
        : 85;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Executive Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF581C87), Color(0xFF7E22CE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF581C87).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OFFICE OF THE DEAN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Faculty of Technology (FOT)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: app.isRegistrationOpen
                          ? const Color(0xFF10B981)
                          : RuslColors.errorRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      app.isRegistrationOpen
                          ? 'SESSION ACTIVE'
                          : 'SESSION CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Academic Year ${app.currentAcademicYearLabel} • Faculty Governance & Senate Endorsements',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Live KPI Metrics
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric(
              'Departments',
              '$departmentCount Depts',
              Icons.account_tree_rounded,
              const Color(0xFF2563EB),
            ),
            _metric(
              'Pending Faculty Endorsement',
              '$pendingDeanCount Submissions',
              Icons.pending_actions_rounded,
              RuslColors.warningOrange,
            ),
            _metric(
              'Faculty Endorsement Rate',
              '$endorsementRate%',
              Icons.verified_rounded,
              const Color(0xFF10B981),
            ),
            _metric(
              'Total Undergraduates',
              '520+ Students',
              Icons.groups_rounded,
              const Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Fast Action Shortcuts
        _panel(
          'Dean Executive Actions & Navigation',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionButton(
                icon: Icons.verified_user_rounded,
                label: 'Endorsement Queue ($pendingDeanCount)',
                color: RuslColors.primaryMaroon,
                onTap: () => _navigateTo(1),
              ),
              _actionButton(
                icon: Icons.account_tree_rounded,
                label: 'View 5 Departments',
                color: const Color(0xFF2563EB),
                onTap: () => _navigateTo(2),
              ),
              _actionButton(
                icon: Icons.groups_rounded,
                label: 'Faculty Student Registry',
                color: const Color(0xFF0D9488),
                onTap: () => _navigateTo(3),
              ),
              _actionButton(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Special Petitions (${app.specialRequests.length})',
                color: const Color(0xFFD97706),
                onTap: () => _navigateTo(4),
              ),
              _actionButton(
                icon: Icons.assessment_rounded,
                label: 'Senate Reports',
                color: const Color(0xFF7C3AED),
                onTap: () => _navigateTo(6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Undergrad cohort levels 1 - 4
        _panel(
          'Faculty Undergraduate Cohort Distribution (Levels 1 - 4)',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Faculty student enrollment across all four active undergraduate batches:',
                style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth < 520
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2;

                  final levelStats = [
                    (
                      1,
                      'Level 1 (Freshers)',
                      'Intake 2024/2025',
                      '140 Students',
                      0.98,
                      const Color(0xFF2563EB),
                    ),
                    (
                      2,
                      'Level 2 (Sophomores)',
                      'Intake 2023/2024',
                      '135 Students',
                      0.95,
                      const Color(0xFF0D9488),
                    ),
                    (
                      3,
                      'Level 3 (Juniors)',
                      'Intake 2022/2023',
                      '125 Students',
                      0.92,
                      const Color(0xFF7C3AED),
                    ),
                    (
                      4,
                      'Level 4 (Seniors/Honours)',
                      'Intake 2021/2022',
                      '120 Students',
                      1.00,
                      const Color(0xFFD97706),
                    ),
                  ];

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: levelStats.map((st) {
                      return Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: st.$6.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: st.$6.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    st.$2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: st.$6,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: st.$6.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    st.$4,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: st.$6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              st.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: RuslColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: st.$5,
                                minHeight: 5,
                                backgroundColor: RuslColors.borderGrey
                                    .withValues(alpha: 0.4),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  st.$6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(st.$5 * 100).toInt()}% endorsed & verified',
                              style: const TextStyle(
                                fontSize: 10,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Department Governance Matrix
        _panel(
          'Faculty Department Endorsement Matrix',
          Column(
            children: [
              _deptProgressRow(
                code: 'ICT',
                name: 'Information & Communication Technology',
                head: 'Dr. Lahiru Jayasuriya',
                students: '148 Students',
                progress: 0.94,
              ),
              const Divider(height: 16),
              _deptProgressRow(
                code: 'BPT',
                name: 'Bio-Process Technology',
                head: 'Dr. Chaminda Ranasinghe',
                students: '112 Students',
                progress: 0.90,
              ),
              const Divider(height: 16),
              _deptProgressRow(
                code: 'EET',
                name: 'Electrical & Electronic Technology',
                head: 'Dr. W. K. P. Chathurangika',
                students: '105 Students',
                progress: 0.88,
              ),
              const Divider(height: 16),
              _deptProgressRow(
                code: 'FDT',
                name: 'Food Technology',
                head: 'Dr. Anoma Wijesekara',
                students: '85 Students',
                progress: 0.96,
              ),
              const Divider(height: 16),
              _deptProgressRow(
                code: 'MTT',
                name: 'Materials Technology',
                head: 'Dr. S. K. Narangoda',
                students: '78 Students',
                progress: 0.85,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 1: FACULTY ENDORSEMENT QUEUE (CORE WORKING FUNCTION)
  // ==========================================================================

  Widget _endorsementQueue(AppService app) {
    // Filter queue items
    final filteredQueue = _facultyStudents.where((s) {
      if (_queueDeptFilter != 'All' && s.departmentCode != _queueDeptFilter) {
        return false;
      }
      if (_queueLevelFilter != 0 && s.level != _queueLevelFilter) {
        return false;
      }
      if (_queueStatusFilter == 'Pending' &&
          s.status != RegistrationStatus.departmentApproved) {
        return false;
      }
      if (_queueStatusFilter == 'Endorsed' &&
          s.status != RegistrationStatus.facultyApproved &&
          s.status != RegistrationStatus.registered &&
          s.status != RegistrationStatus.locked) {
        return false;
      }
      if (_queueStatusFilter == 'Under Revision' &&
          s.status != RegistrationStatus.changesRequested) {
        return false;
      }
      return true;
    }).toList();

    final pendingCount = _facultyStudents
        .where((s) => s.status == RegistrationStatus.departmentApproved)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faculty Endorsement Queue',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Faculty Academic Board endorsement for HoD-approved student submissions',
                    style: const TextStyle(
                      fontSize: 12,
                      color: RuslColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (pendingCount > 0)
              FilledButton.icon(
                onPressed: () => _showBulkEndorseDialog(app),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Bulk Endorse All'),
                style: FilledButton.styleFrom(
                  backgroundColor: RuslColors.primaryMaroon,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Filter Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'ICT', 'BPT', 'EET', 'FDT', 'MTT']
                      .map((dept) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: _queueDeptFilter == dept,
                              label: Text(dept == 'All' ? 'All Departments' : dept),
                              onSelected: (val) =>
                                  setState(() => _queueDeptFilter = dept),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              // Level & Status Filters
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...[0, 1, 2, 3, 4].map((lvl) {
                    final label = lvl == 0 ? 'All Levels' : 'Level $lvl';
                    return ChoiceChip(
                      selected: _queueLevelFilter == lvl,
                      label: Text(label),
                      onSelected: (val) =>
                          setState(() => _queueLevelFilter = lvl),
                    );
                  }),
                  const SizedBox(width: 8),
                  ...['All', 'Pending', 'Endorsed', 'Under Revision'].map((st) {
                    return ChoiceChip(
                      selected: _queueStatusFilter == st,
                      label: Text(st),
                      onSelected: (val) =>
                          setState(() => _queueStatusFilter = st),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Queue Items
        if (filteredQueue.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  size: 48,
                  color: Colors.green.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Submissions Match Filters',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All student registrations in this criteria are up to date.',
                  style: TextStyle(color: RuslColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...filteredQueue.map((student) => _queueCard(student, app)),
      ],
    );
  }

  Widget _queueCard(_DeanStudentItem item, AppService app) {
    final isPendingDean = item.status == RegistrationStatus.departmentApproved;
    final isEndorsed = item.status == RegistrationStatus.facultyApproved ||
        item.status == RegistrationStatus.registered ||
        item.status == RegistrationStatus.locked;
    final isRevision = item.status == RegistrationStatus.changesRequested;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPendingDean
              ? RuslColors.warningOrange.withValues(alpha: 0.6)
              : RuslColors.borderGrey,
          width: isPendingDean ? 1.5 : 1,
        ),
        boxShadow: isPendingDean
            ? [
                BoxShadow(
                  color: RuslColors.warningOrange.withValues(alpha: 0.08),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                child: Text(
                  item.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: RuslColors.primaryMaroon,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          item.registrationNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: RuslColors.primaryMaroon,
                          ),
                        ),
                        Text(
                          '• ${item.degreeProgramme}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _statusBadge(item.status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RuslColors.cardSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _pillInfo(
                  Icons.school_rounded,
                  'Level ${item.level} Sem ${item.semester}',
                ),
                _pillInfo(
                  Icons.credit_card_rounded,
                  '${item.credits} Total Credits',
                ),
                _pillInfo(
                  Icons.stars_rounded,
                  'CGPA ${item.gpa.toStringAsFixed(2)}',
                ),
                _pillInfo(
                  Icons.event_available_rounded,
                  'HoD: ${item.hodEndorsementDate}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _showCourseListDialog(item),
                icon: const Icon(Icons.list_alt_rounded, size: 16),
                label: Text('${item.enrolledCourses.length} Courses'),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (isPendingDean) ...[
                    OutlinedButton.icon(
                      onPressed: () => _showReturnQueryDialog(item, app),
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text('Return Query'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _endorseStudent(item, app),
                      icon: const Icon(Icons.verified_rounded, size: 16),
                      label: const Text('Endorse (Faculty)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: RuslColors.primaryMaroon,
                      ),
                    ),
                  ] else if (isEndorsed) ...[
                    const Chip(
                      avatar: Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 16),
                      label: Text('Endorsed by Dean'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ] else if (isRevision) ...[
                    const Chip(
                      avatar: Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 16),
                      label: Text('Under Revision'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _endorseStudent(_DeanStudentItem item, AppService app) {
    setState(() {
      item.status = RegistrationStatus.facultyApproved;
    });

    if (item.registrationNumber == app.activeStudent.registrationNumber) {
      app.approveByDean(
        'Faculty Academic Board approved curriculum and credit limits. Endorsed.',
      );
    } else {
      app.addNotification(
        title: 'Faculty Endorsement Granted',
        message:
            'Dean endorsed registration for ${item.name} (${item.registrationNumber}). Forwarded to Assistant Registrar.',
        type: NotificationType.approval,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Endorsed registration for ${item.registrationNumber}.'),
        backgroundColor: RuslColors.primaryMaroon,
      ),
    );
  }

  void _showReturnQueryDialog(_DeanStudentItem item, AppService app) {
    final queryController = TextEditingController(
      text: 'Faculty Academic Board requested revisions to elective selections.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Return Query • ${item.registrationNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify remarks or required changes for the Department HoD and student:',
              style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: queryController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Dean\'s query / instructions...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final query = queryController.text.trim();
              Navigator.pop(ctx);

              setState(() {
                item.status = RegistrationStatus.changesRequested;
              });

              if (item.registrationNumber ==
                  app.activeStudent.registrationNumber) {
                app.requestChangesByDean(query);
              } else {
                app.addNotification(
                  title: 'Dean Revision Requested',
                  message:
                      'Dean returned ${item.registrationNumber} for revision: $query',
                  type: NotificationType.changesRequested,
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Query sent for ${item.registrationNumber}. Status set to Changes Requested.',
                  ),
                  backgroundColor: RuslColors.warningOrange,
                ),
              );
            },
            child: const Text('Submit Query'),
          ),
        ],
      ),
    );
  }

  void _showBulkEndorseDialog(AppService app) {
    final pending = _facultyStudents
        .where((s) => s.status == RegistrationStatus.departmentApproved)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Faculty Endorsement'),
        content: Text(
          'Are you sure you want to grant Faculty Academic Board endorsement for all ${pending.length} HoD-approved student submissions across the Faculty of Technology?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                for (var s in pending) {
                  s.status = RegistrationStatus.facultyApproved;
                }
              });

              app.approveByDean(
                'Faculty Academic Board verified and bulk-endorsed ${pending.length} submissions.',
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully bulk-endorsed ${pending.length} registrations.',
                  ),
                  backgroundColor: RuslColors.primaryMaroon,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.primaryMaroon,
            ),
            child: Text('Endorse All (${pending.length})'),
          ),
        ],
      ),
    );
  }

  void _showCourseListDialog(_DeanStudentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: RuslColors.primaryMaroon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Courses • ${item.registrationNumber}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student: ${item.name}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Department: ${item.departmentName}',
                style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
              ),
              const Divider(height: 20),
              ...item.enrolledCourses.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 2: FACULTY DEPARTMENTS (INTERACTIVE DETAIL PAGES)
  // ==========================================================================

  Widget _departments(List<Department> departments) {
    final deptDetails = {
      'ICT': (
        programme: 'Bachelor of Information & Communication Technology (Honours)',
        head: 'Dr. Lahiru Jayasuriya',
        staffCount: 14,
        studentCount: 148,
        curriculum: 'Curriculum 2024 V2.1',
        courses: [
          'ICT 3201 Software Project Management (2 Cr)',
          'ICT 3202 Distributed Systems (3 Cr)',
          'ICT 3203 Scientific Computing (2 Cr)',
          'ICT 3204 Cloud Computing (3 Cr)',
          'ICT 3205 Mobile Application Development (3 Cr)',
          'ICT 3206 Artificial Intelligence (3 Cr)',
        ],
      ),
      'BPT': (
        programme: 'Bachelor of Bio-Systems Technology (Honours)',
        head: 'Dr. Chaminda Ranasinghe',
        staffCount: 12,
        studentCount: 112,
        curriculum: 'Curriculum 2023 V1.4',
        courses: [
          'BPT 3201 Bioreactor Design & Scale-up (3 Cr)',
          'BPT 3202 Fermentation Technology (3 Cr)',
          'BPT 3203 Downstream Processing (3 Cr)',
          'BPT 3204 Biosafety & Regulatory Affairs (2 Cr)',
        ],
      ),
      'EET': (
        programme: 'Bachelor of Engineering Technology (Honours) - Electrical',
        head: 'Dr. W. K. P. Chathurangika',
        staffCount: 11,
        studentCount: 105,
        curriculum: 'Curriculum 2023 V2.0',
        courses: [
          'EET 2201 Microcontroller Architecture (3 Cr)',
          'EET 2202 Power Electronics I (3 Cr)',
          'EET 2203 Signals and Systems (3 Cr)',
          'EET 2204 Instrumentation Laboratory (2 Cr)',
        ],
      ),
      'FDT': (
        programme: 'Bachelor of Bio-Systems Technology (Honours) - Food Tech',
        head: 'Dr. Anoma Wijesekara',
        staffCount: 9,
        studentCount: 85,
        curriculum: 'Curriculum 2024 V1.1',
        courses: [
          'FDT 1201 Food Chemistry Fundamentals (3 Cr)',
          'FDT 1202 Post-harvest Biology (3 Cr)',
          'FDT 1203 Food Microbiology I (3 Cr)',
        ],
      ),
      'MTT': (
        programme: 'Bachelor of Engineering Technology (Honours) - Materials',
        head: 'Dr. S. K. Narangoda',
        staffCount: 8,
        studentCount: 78,
        curriculum: 'Curriculum 2022 V1.8',
        courses: [
          'MTT 4201 Advanced Composite Materials (3 Cr)',
          'MTT 4202 Industrial Internship (6 Cr)',
          'MTT 4203 Final Research Seminar (3 Cr)',
        ],
      ),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Faculty Departments',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Academic departments under the Faculty of Technology (FOT)',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 16),
        ...departments.map((dept) {
          final detail = deptDetails[dept.code];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: Colors.white,
            child: InkWell(
              onTap: () => _showDepartmentDetailModal(dept, detail),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          RuslColors.primaryMaroon.withValues(alpha: 0.1),
                      child: Text(
                        dept.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: RuslColors.primaryMaroon,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          if (detail != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              detail.programme,
                              style: const TextStyle(
                                fontSize: 12,
                                color: RuslColors.primaryMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'HoD: ${detail.head}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '• ${detail.studentCount} Students',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: RuslColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showDepartmentDetailModal(Department dept, dynamic detail) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.account_tree_rounded,
                color: RuslColors.primaryMaroon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dept. of ${dept.name}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail != null) ...[
                  _detailRow('Degree Programme', detail.programme),
                  _detailRow('Head of Department', detail.head),
                  _detailRow('Academic Staff', '${detail.staffCount} Lecturers'),
                  _detailRow('Current Enrollment', '${detail.studentCount} Undergraduates'),
                  _detailRow('Curriculum Framework', detail.curriculum),
                  const Divider(height: 24),
                  const Text(
                    'Active Semester Modules:',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ...(detail.courses as List<String>).map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 3: FACULTY STUDENT REGISTRY (FULL ROSTER & DOSSIER)
  // ==========================================================================

  Widget _studentRegistry() {
    final filteredStudents = _facultyStudents.where((s) {
      if (_studentDeptFilter != 'All' && s.departmentCode != _studentDeptFilter) {
        return false;
      }
      if (_studentLevelFilter != 0 && s.level != _studentLevelFilter) {
        return false;
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
      if (_studentSearchQuery.isNotEmpty) {
        final q = _studentSearchQuery.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.registrationNumber.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Faculty Student Registry',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Undergraduate student directory across all 5 Faculty departments and 4 levels',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _studentSearchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'Search by student name or registration number...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: RuslColors.borderGrey),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...['All', 'ICT', 'BPT', 'EET', 'FDT', 'MTT'].map((dept) =>
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _studentDeptFilter == dept,
                      label: Text(dept),
                      onSelected: (val) =>
                          setState(() => _studentDeptFilter = dept),
                    ),
                  )),
              const SizedBox(width: 8),
              ...[0, 1, 2, 3, 4].map((lvl) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: _studentLevelFilter == lvl,
                      label: Text(lvl == 0 ? 'All Levels' : 'Level $lvl'),
                      onSelected: (val) =>
                          setState(() => _studentLevelFilter = lvl),
                    ),
                  )),
              const SizedBox(width: 8),
              ...['All', '1st Class', '2nd Upper', '2nd Lower', 'Pass', 'Batch Miss']
                  .map((st) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _studentStandingFilter == st,
                          label: Text(st),
                          onSelected: (val) =>
                              setState(() => _studentStandingFilter = st),
                        ),
                      )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Students List
        Text(
          'Displaying ${filteredStudents.length} Students',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 10),
        ...filteredStudents.map((s) => _studentRegistryCard(s)),
      ],
    );
  }

  Widget _studentRegistryCard(_DeanStudentItem student) {
    final standing = DegreeClassStanding.fromGpa(student.gpa);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: RuslColors.primaryMaroon.withValues(alpha: 0.1),
          child: Text(
            student.initials,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: RuslColors.primaryMaroon,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${student.registrationNumber} • ${student.departmentCode} • Level ${student.level}',
              style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'GPA ${student.gpa.toStringAsFixed(2)} (${standing.label})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
                _statusBadge(student.status),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'View Academic Dossier',
          onPressed: () => _showStudentDossier(student),
        ),
      ),
    );
  }

  void _showStudentDossier(_DeanStudentItem student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Academic Dossier • ${student.registrationNumber}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Full Name', student.name),
                _detailRow('Registration No', student.registrationNumber),
                _detailRow('Department', student.departmentName),
                _detailRow('Degree Programme', student.degreeProgramme),
                _detailRow('Academic Level', 'Level ${student.level} Semester ${student.semester}'),
                _detailRow('Cumulative GPA', '${student.gpa.toStringAsFixed(2)} / 4.00'),
                _detailRow('Workflow Status', student.status.label),
                const Divider(height: 20),
                const Text(
                  'Enrolled Modules:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...student.enrolledCourses.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $c', style: const TextStyle(fontSize: 12)),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 4: SPECIAL PETITIONS & OVERLOAD WAIVERS
  // ==========================================================================

  Widget _specialPetitions(AppService app) {
    final petitions = app.specialRequests.where((p) {
      if (_petitionStatusFilter != 'All' &&
          p.status.label != _petitionStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Special Petitions & Dean Waivers',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Credit overload requests, prerequisite waivers, and Senate special appeals',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: _petitionStatusFilter == status,
                  label: Text(status),
                  onSelected: (val) =>
                      setState(() => _petitionStatusFilter = status),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        if (petitions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: const Column(
              children: [
                Icon(Icons.inbox_rounded, size: 40, color: RuslColors.textMuted),
                SizedBox(height: 8),
                Text(
                  'No Petitions Found',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          )
        else
          ...petitions.map((req) => _petitionCard(req, app)),
      ],
    );
  }

  Widget _petitionCard(SpecialRequest req, AppService app) {
    final isPending = req.status == SpecialRequestStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    req.requestType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                _specialRequestStatusBadge(req.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted by: ${req.studentName} (${req.studentId})',
              style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RuslColors.cardSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                req.explanation,
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${req.submittedAt.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
                ),
                if (isPending)
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          app.updateSpecialRequestStatus(
                            req.id,
                            SpecialRequestStatus.rejected,
                            reviewerName: 'Prof. T. C. Bamunuarachchige',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Petition rejected by Dean.')),
                          );
                        },
                        child: const Text('Reject'),
                      ),
                      FilledButton(
                        onPressed: () {
                          app.updateSpecialRequestStatus(
                            req.id,
                            SpecialRequestStatus.approved,
                            reviewerName: 'Prof. T. C. Bamunuarachchige',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dean waiver approved.'),
                              backgroundColor: RuslColors.primaryMaroon,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: RuslColors.primaryMaroon,
                        ),
                        child: const Text('Grant Approval'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION 5: ACADEMIC STAFF & FACULTY BOARD DIRECTORY
  // ==========================================================================

  Widget _academicStaff() {
    final staffList = _facultyStaff.where((st) {
      if (_staffDeptFilter != 'All' && st.departmentCode != _staffDeptFilter) {
        return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Faculty Board & Academic Staff',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Professors, Department Heads, and Academic Staff of Faculty of Technology',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Department filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'DEAN', 'ICT', 'BPT', 'EET', 'FDT', 'MTT']
                .map((dept) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _staffDeptFilter == dept,
                        label: Text(dept),
                        onSelected: (val) =>
                            setState(() => _staffDeptFilter = dept),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        ...staffList.map((member) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          RuslColors.primaryMaroon.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person_rounded,
                        color: RuslColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.designation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: RuslColors.primaryMaroon,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.qualifications,
                            style: const TextStyle(
                              fontSize: 11,
                              color: RuslColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '📧 ${member.email}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                '🏢 ${member.office}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              if (member.isFacultyBoardMember)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FACULTY BOARD MEMBER',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: RuslColors.primaryMaroon,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ==========================================================================
  // SECTION 6: FACULTY REPORTS & SENATE ANALYTICS
  // ==========================================================================

  Widget _facultyReports(AppService app, int departments) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Faculty Reports & Senate Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Academic Board reporting, Senate credit compliance, and cohort tracking',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 16),

        _panel(
          'Senate Registration Compliance Summary',
          Column(
            children: [
              _detailRow('Departments Reporting', '$departments Academic Departments'),
              _detailRow('Active Registration Period', app.registrationEndLabel),
              _detailRow('Registration Window State', app.isRegistrationOpen ? 'OPEN (Active)' : 'CLOSED'),
              _detailRow('Target Degree Credits', '120 Total Credits (Honours Degree)'),
              _detailRow('Academic Calendar Status', 'Semester 2 Examination Preparation'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Repeat & Medical Candidate Attendance Exemption
        _panel(
          'Attendance-Exempt Repeat & Medical Candidates',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF0F766E), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'University Regulation: Students registering for Repeat or Medical concession subjects are exempt from lecture attendance. They sit end-semester exams only and do not occupy lecture timetable slots.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF134E4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Medical Concession Candidates', '14 Students (Exam Only)'),
              _detailRow('Repeat Examination Candidates', '28 Students (Exam Only)'),
              _detailRow('Lecture Timetable Impact', 'Zero Clashes (Exempted from Timetable)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cohort academic health by level
        _panel(
          'Undergraduate Cohort Academic Health Progression',
          Column(
            children: [
              _levelProgressionBar(
                level: 1,
                title: 'Level 1 (Intake 2024/2025 — Freshers)',
                averageCredits: '28 / 30 Target Cr',
                gpaAvg: '3.38 Avg GPA',
                progress: 0.93,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 12),
              _levelProgressionBar(
                level: 2,
                title: 'Level 2 (Intake 2023/2024 — Sophomores)',
                averageCredits: '58 / 60 Target Cr',
                gpaAvg: '3.42 Avg GPA',
                progress: 0.96,
                color: const Color(0xFF0D9488),
              ),
              const SizedBox(height: 12),
              _levelProgressionBar(
                level: 3,
                title: 'Level 3 (Intake 2022/2023 — Juniors)',
                averageCredits: '88 / 90 Target Cr',
                gpaAvg: '3.49 Avg GPA',
                progress: 0.97,
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 12),
              _levelProgressionBar(
                level: 4,
                title: 'Level 4 (Intake 2021/2022 — Seniors & Honours)',
                averageCredits: '118 / 120 Target Cr',
                gpaAvg: '3.55 Avg GPA',
                progress: 0.98,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 7: DEAN PROFILE & EXECUTIVE AUTHORITY
  // ==========================================================================

  Widget _deanProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Dean Profile & Executive Authority',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Faculty of Technology • Rajarata University of Sri Lanka',
          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const SizedBox(height: 16),

        _panel(
          'Executive Credentials',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: RuslColors.primaryMaroon,
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prof. T. C. Bamunuarachchige',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Dean, Faculty of Technology',
                          style: TextStyle(
                            color: RuslColors.primaryMaroon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'dean@tec.rjt.ac.lk • Office: Dean\'s Secretariat',
                          style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _detailRow('University Jurisdiction', 'Faculty of Technology (All 5 Departments)'),
              _detailRow('Statutory Delegation', 'Senate Academic Board Approvals & Endorsements'),
              _detailRow('Digital Signature Seal', 'Active (RUSL-FOT-DEAN-AUTH-2026)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _panel(
          'University By-laws & Governance Mandate',
          const Text(
            'The Dean of the Faculty serves as the Chief Academic and Executive Officer of the Faculty under Section 44 of the Universities Act No. 16 of 1978. All student course registrations, academic petitions, and credit overloads endorsed at the Department level by Heads of Departments are subject to Faculty Academic Board verification and Dean\'s final endorsement prior to official sealing by the Assistant Registrar.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================

  Widget _metric(String label, String value, IconData icon, Color color) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: RuslColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deptProgressRow({
    required String code,
    required String name,
    required String head,
    required String students,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$code • $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                students,
                style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor:
                        RuslColors.borderGrey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      RuslColors.primaryMaroon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'HoD: $head',
            style: const TextStyle(fontSize: 10, color: RuslColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _pillInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: RuslColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _statusBadge(RegistrationStatus status) {
    final (color, label) = switch (status) {
      RegistrationStatus.departmentApproved => (
          RuslColors.warningOrange,
          'Pending Dean',
        ),
      RegistrationStatus.facultyApproved => (
          Colors.blue,
          'Dean Endorsed',
        ),
      RegistrationStatus.registered || RegistrationStatus.locked => (
          Colors.green,
          'Sealed & Registered',
        ),
      RegistrationStatus.changesRequested => (
          Colors.red,
          'Revisions Requested',
        ),
      _ => (RuslColors.textMuted, status.label),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _specialRequestStatusBadge(SpecialRequestStatus status) {
    final (color, label) = switch (status) {
      SpecialRequestStatus.approved => (Colors.green, 'Approved'),
      SpecialRequestStatus.rejected => (Colors.red, 'Rejected'),
      SpecialRequestStatus.pending => (Colors.orange, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _levelProgressionBar({
    required int level,
    required String title,
    required String averageCredits,
    required String gpaAvg,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  gpaAvg,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: RuslColors.borderGrey.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  averageCredits,
                  style: const TextStyle(
                    fontSize: 11,
                    color: RuslColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}% completed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DEAN SIDEBAR NAVIGATION DRAWER
// ============================================================================

class DeanSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const DeanSidebar({
    super.key,
    required this.selectedIndex,
    required this.userName,
    required this.onSelected,
    required this.onLogout,
  });

  static const items = [
    (Icons.dashboard_rounded, 'Faculty Overview'),
    (Icons.verified_user_rounded, 'Endorsement Queue'),
    (Icons.account_tree_rounded, 'Departments'),
    (Icons.groups_rounded, 'Student Registry'),
    (Icons.assignment_turned_in_rounded, 'Special Petitions'),
    (Icons.badge_rounded, 'Academic Staff'),
    (Icons.analytics_rounded, 'Faculty Reports'),
    (Icons.account_balance_rounded, 'Dean Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: const CircleAvatar(
                backgroundColor: RuslColors.primaryMaroon,
                child: Icon(Icons.account_balance_rounded, color: Colors.white),
              ),
              title: Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Dean • Faculty of Technology'),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  selected: selectedIndex == index,
                  selectedTileColor: RuslColors.accentYellow.withValues(
                    alpha: .35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(items[index].$1),
                  title: Text(items[index].$2),
                  onTap: () => onSelected(index),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
