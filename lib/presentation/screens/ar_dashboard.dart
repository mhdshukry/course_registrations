import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../core/pdf_generator.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';
import '../widgets/custom_widgets.dart';

class ArDashboardScreen extends StatefulWidget {
  final int selectedSection;
  final ValueChanged<int>? onNavigate;

  const ArDashboardScreen({
    super.key,
    this.selectedSection = 0,
    this.onNavigate,
  });

  @override
  State<ArDashboardScreen> createState() => _ArDashboardScreenState();
}

class _ArDashboardScreenState extends State<ArDashboardScreen> {
  late int _section;
  String _searchQueue = '';
  String _selectedDept = 'All Departments';
  String _selectedQueueStatus = 'All';
  int _selectedLevel =
      0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  int _registryLevel =
      0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  int _examLevel =
      0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  String _registrySearch = '';
  String _registryDept = 'All';
  _ArCandidate? _verifiedResult;

  final TextEditingController _verifyController = TextEditingController();

  Widget _buildArLevelPill(int level) {
    final color = switch (level) {
      1 => const Color(0xFF2563EB),
      2 => const Color(0xFF0D9488),
      3 => const Color(0xFF7C3AED),
      4 => const Color(0xFFD97706),
      _ => RuslColors.primaryMaroon,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        'LEVEL $level',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Academic Records Directory State
  String _academicSearch = '';
  String _academicDept = 'All Departments';
  String _academicStanding = 'all';
  _ArCandidate? _selectedAcademicCandidate;
  String _academicSemesterFilter = 'all';
  final TextEditingController _academicSearchController =
      TextEditingController();
  final Map<String, List<AcademicCourseRecord>> _candidateRecordsCache = {};

  // Faculty Candidates Seed Data
  late List<_ArCandidate> _candidates;
  late List<_LateExceptionRequest> _lateExceptions;
  late List<_RegistryAuditEvent> _auditLog;

  @override
  void initState() {
    super.initState();
    _section = widget.selectedSection;
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant ArDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSection != widget.selectedSection) {
      setState(() {
        _section = widget.selectedSection;
        if (widget.selectedSection == 6) {
          _selectedAcademicCandidate = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _verifyController.dispose();
    _academicSearchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _candidates = [
      _ArCandidate(
        id: 'c_01',
        name: 'M. N. Mohamed Nafis',
        regNumber: 'ICT/2021/045',
        examIndexNumber: 'FOT/EX/2026/045',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 3,
        semester: 6,
        credits: 12,
        gpa: 3.79,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-X992',
        enrolledCourses: [
          'ICT 3202 — Mobile Application Development (Compulsory, 2 Cr)',
          'ICT 3204 — Cloud Computing & Microservices (Compulsory, 2 Cr)',
          'ICT 3214 — Human Computer Interaction (Compulsory, 2 Cr)',
          'ICT 3216 — Information Assurance & Security (Compulsory, 2 Cr)',
          'ICT 3310 — Machine Learning & Artificial Intelligence (Compulsory, 3 Cr)',
          'CML 3202 — Research Methodology (Compulsory, 1 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'student.nafis@rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_02',
        name: 'K. A. Kavindu Madushanka',
        regNumber: 'ICT/2021/012',
        examIndexNumber: 'FOT/EX/2026/012',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 3,
        semester: 5,
        credits: 15,
        gpa: 3.65,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-K012',
        enrolledCourses: [
          'ICT 3201 — Software Project Management (Compulsory, 2 Cr)',
          'ICT 3203 — Scientific Computer Applications (Compulsory, 2 Cr)',
          'ICT 3206 — Skill Development Project III (Compulsory, 2 Cr)',
          'ICT 3208 — Design and Analysis of Algorithms (Compulsory, 2 Cr)',
          'ICT 3312 — Software Verification and Validation (Compulsory, 3 Cr)',
          'CML 3101 — Legal and Patent Aspects (Compulsory, 1 Cr)',
          'ICT 3315 — Internet of Things (Elective, 3 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'kavindu.madushanka@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_03',
        name: 'W. M. Sanduni Senaratne',
        regNumber: 'ICT/2021/088',
        examIndexNumber: 'FOT/EX/2026/088',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 3,
        semester: 5,
        credits: 14,
        gpa: 3.80,
        status: 'Officially Sealed',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-S088',
        enrolledCourses: [
          'ICT 3201 — Software Project Management (Compulsory, 2 Cr)',
          'ICT 3203 — Scientific Computer Applications (Compulsory, 2 Cr)',
          'ICT 3206 — Skill Development Project III (Compulsory, 2 Cr)',
          'ICT 3208 — Design and Analysis of Algorithms (Compulsory, 2 Cr)',
          'ICT 3312 — Software Verification and Validation (Compulsory, 3 Cr)',
          'CML 3101 — Legal and Patent Aspects (Compulsory, 1 Cr)',
          'ICT 3217 — Advanced Computer Networks (Elective, 2 Cr)',
        ],
        sealDate: '2026-10-06 09:30',
        arRemarks: 'All pre-requisites and course fee cleared.',
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'sanduni.senaratne@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_04',
        name: 'R. M. Thisara Bandara',
        regNumber: 'EET/2021/005',
        examIndexNumber: 'FOT/EX/2026/105',
        department: 'Electrical & Electronic Technology',
        degreeProgram: 'BET (Hons)',
        level: 3,
        semester: 5,
        credits: 16,
        gpa: 3.28,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Dr. W. K. P. Chathurangika',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-T005',
        enrolledCourses: [
          'ENT 3101 — Applied Thermodynamics (4 Cr)',
          'ENT 3102 — Material Science & Testing (4 Cr)',
          'ENT 3103 — Control Systems & Instrumentation (4 Cr)',
          'ENG 3101 — Technical Communication (2 Cr)',
          'MGT 3105 — Industrial Management (2 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'thisara.bandara@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_05',
        name: 'N. D. Nimesha Dissanayake',
        regNumber: 'EET/2021/034',
        examIndexNumber: 'FOT/EX/2026/134',
        department: 'Electrical & Electronic Technology',
        degreeProgram: 'BET (Hons)',
        level: 3,
        semester: 5,
        credits: 14,
        gpa: 3.10,
        status: 'Officially Sealed',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Dr. W. K. P. Chathurangika',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-N034',
        enrolledCourses: [
          'ENT 3101 — Applied Thermodynamics (4 Cr)',
          'ENT 3102 — Material Science & Testing (4 Cr)',
          'ENT 3103 — Control Systems & Instrumentation (4 Cr)',
          'ENG 3101 — Technical Communication (2 Cr)',
        ],
        sealDate: '2026-10-06 10:15',
        arRemarks: 'Verified against engineering council standard.',
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'nimesha.dissanayake@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_06',
        name: 'T. K. Chamod Ranasinghe',
        regNumber: 'BST/2021/019',
        examIndexNumber: 'FOT/EX/2026/219',
        department: 'Bio-Process Technology',
        degreeProgram: 'BBST (Hons)',
        level: 3,
        semester: 5,
        credits: 14,
        gpa: 2.95,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. W. M. M. D. Bandara',
        coordClearedBy: 'Dr. W. M. M. D. Bandara',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-C019',
        enrolledCourses: [
          'BST 3101 — Postharvest Technology (3 Cr)',
          'BST 3102 — Bioprocess Engineering (4 Cr)',
          'BST 3103 — Agricultural Waste Management (3 Cr)',
          'ENG 3101 — Technical Communication (2 Cr)',
          'BST 3105 — Precision Agriculture (2 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'chamod.ranasinghe@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_07',
        name: 'D. M. Rashmi Wickramasinghe',
        regNumber: 'BST/2021/041',
        examIndexNumber: 'FOT/EX/2026/241',
        department: 'Bio-Process Technology',
        degreeProgram: 'BBST (Hons)',
        level: 3,
        semester: 5,
        credits: 12,
        gpa: 3.55,
        status: 'Officially Sealed',
        hodEndorsedBy: 'Dr. W. M. M. D. Bandara',
        coordClearedBy: 'Dr. W. M. M. D. Bandara',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-R041',
        enrolledCourses: [
          'BST 3101 — Postharvest Technology (3 Cr)',
          'BST 3102 — Bioprocess Engineering (4 Cr)',
          'BST 3103 — Agricultural Waste Management (3 Cr)',
          'ENG 3101 — Technical Communication (2 Cr)',
        ],
        sealDate: '2026-10-06 11:00',
        arRemarks: 'All requirements satisfied.',
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'rashmi.wickramasinghe@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_08',
        name: 'A. G. Anuki Jayawardena',
        regNumber: 'ICT/2020/003',
        examIndexNumber: 'FOT/EX/2026/003R',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 4,
        semester: 5,
        credits: 6,
        gpa: 1.85,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-A003R',
        enrolledCourses: [
          'ICT 3201 — Software Project Management (Repeat, 2 Cr)',
          'ICT 3203 — Scientific Computer Applications (Repeat, 2 Cr)',
          'ICT 3206 — Skill Development Project III (Repeat, 2 Cr)',
        ],
        sealDate: null,
        arRemarks: 'Repeat examination registration fee paid (LKR 1,000).',
        isRepeatCandidate: true,
        feesCleared: true,
        email: 'anuki.jayawardena@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_09',
        name: 'H. M. Amasha Perera',
        regNumber: 'ICT/2024/004',
        examIndexNumber: 'FOT/EX/2026/L1004',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 1,
        semester: 2,
        credits: 16,
        gpa: 3.75,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-A004',
        enrolledCourses: [
          'ICT 1302 — Database Management Systems (Compulsory, 3 Cr)',
          'ICT 1207 — Web Technologies (Compulsory, 2 Cr)',
          'ICT 1209 — System Analysis and Design (Compulsory, 2 Cr)',
          'CMT 1204 — Discrete Mathematics (Compulsory, 2 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'amasha.perera@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_10',
        name: 'T. M. Ravindu Fernando',
        regNumber: 'ICT/2023/025',
        examIndexNumber: 'FOT/EX/2026/L2025',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 2,
        semester: 4,
        credits: 17,
        gpa: 3.60,
        status: 'HoD Approved',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-R025',
        enrolledCourses: [
          'ICT 2203 — Object Oriented Programming (Compulsory, 3 Cr)',
          'ICT 2204 — Data Structures and Algorithms (Compulsory, 3 Cr)',
          'ICT 2208 — Computer Networks (Compulsory, 2 Cr)',
          'ICT 2210 — Advanced Database Systems (Compulsory, 2 Cr)',
          'ICT 2214 — Web Application Development (Compulsory, 2 Cr)',
        ],
        sealDate: null,
        arRemarks: null,
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'ravindu.fernando@student.rjt.ac.lk',
      ),
      _ArCandidate(
        id: 'c_11',
        name: 'K. L. Dulshan Rajapaksha',
        regNumber: 'ICT/2021/002',
        examIndexNumber: 'FOT/EX/2026/L4002',
        department: 'Information & Communication Technology',
        degreeProgram: 'BICT (Hons)',
        level: 4,
        semester: 7,
        credits: 14,
        gpa: 3.88,
        status: 'Officially Sealed',
        hodEndorsedBy: 'Dr. Lahiru Jayasuriya',
        coordClearedBy: 'Mr. Wiraj Wickramaarachchi',
        examEligible: true,
        verificationToken: 'RUSL-REG-FOT-2026-D002',
        enrolledCourses: [
          'ICT 4601 — Capstone Research Project & Dissertation I (Compulsory, 3 Cr)',
          'ICT 4301 — Advanced Enterprise Architecture & Governance (Compulsory, 3 Cr)',
          'ICT 4302 — Deep Learning & Computer Vision (Compulsory, 3 Cr)',
          'ICT 4203 — Information Systems Auditing (Compulsory, 2 Cr)',
        ],
        sealDate: '2026-10-06 14:30',
        arRemarks:
            'All Level 1-3 credit requirements certified. Final year capstone clearance approved.',
        isRepeatCandidate: false,
        feesCleared: true,
        email: 'dulshan.rajapaksha@student.rjt.ac.lk',
      ),
    ];

    _lateExceptions = [
      _LateExceptionRequest(
        id: 'lex_01',
        studentName: 'P. G. Dineth Perera',
        regNumber: 'EET/2021/049',
        department: 'Electrical & Electronic Technology',
        reason:
            'Hospitalized during regular course registration window. Medical certificate submitted from DGH Anuradhapura.',
        penaltyFee: 2500,
        status: 'WAIVED',
        submittedAt: '2026-10-05',
      ),
      _LateExceptionRequest(
        id: 'lex_02',
        studentName: 'W. K. Hiruni Fonseka',
        regNumber: 'BST/2021/030',
        department: 'Bio-Process Technology',
        reason:
            'Late prerequisite clearance from previous semester board of examiners.',
        penaltyFee: 2500,
        status: 'PENDING',
        submittedAt: '2026-10-07',
      ),
    ];

    _auditLog = [
      _RegistryAuditEvent(
        id: 'aud_01',
        action: 'FACULTY_SEAL_AFFIXED',
        target: 'ICT/2021/088 — W. M. Sanduni Senaratne',
        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
        timestamp: '2026-10-06 09:30',
        status: 'COMPLETED',
      ),
      _RegistryAuditEvent(
        id: 'aud_02',
        action: 'FACULTY_SEAL_AFFIXED',
        target: 'EET/2021/034 — N. D. Nimesha Dissanayake',
        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
        timestamp: '2026-10-06 10:15',
        status: 'COMPLETED',
      ),
      _RegistryAuditEvent(
        id: 'aud_03',
        action: 'EXAM_ADMISSION_EXPORT',
        target: 'Semester 5 Master Register (CSV)',
        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
        timestamp: '2026-10-07 14:10',
        status: 'COMPLETED',
      ),
    ];
  }

  void _syncWithLiveStudent(AppService app) {
    final live = _candidates.firstWhere((c) => c.regNumber == 'ICT/2021/045');
    if (app.activeRegistrationStatus == RegistrationStatus.registered ||
        app.activeRegistrationStatus == RegistrationStatus.locked) {
      live.status = 'Officially Sealed';
      live.sealDate ??= '2026-10-08 11:45';
      live.arRemarks ??=
          'Officially sealed and confirmed by Assistant Registrar.';
    } else if (app.activeRegistrationStatus ==
        RegistrationStatus.facultyApproved) {
      live.status = 'Faculty Approved';
      live.sealDate = null;
    } else if (app.activeRegistrationStatus ==
        RegistrationStatus.departmentApproved) {
      live.status = 'HoD Approved';
      live.sealDate = null;
    } else if (app.activeRegistrationStatus ==
        RegistrationStatus.changesRequested) {
      live.status = 'Changes Requested';
      live.sealDate = null;
    } else if (app.activeRegistrationStatus == RegistrationStatus.rejected) {
      live.status = 'Rejected';
      live.sealDate = null;
    } else if (app.activeRegistrationStatus == RegistrationStatus.submitted) {
      live.status = 'Submitted';
      live.sealDate = null;
    } else if (app.activeRegistrationStatus == RegistrationStatus.draft) {
      live.status = 'Draft';
      live.sealDate = null;
    }

    live.credits = app.totalSelectedCredits;
    live.verificationToken = app.verificationToken;
    final selectedOfferings = app.courseOfferings
        .where((off) => app.selectedOfferingIds.contains(off.id))
        .toList();
    if (selectedOfferings.isNotEmpty) {
      live.enrolledCourses = selectedOfferings.map((off) {
        final course = app.courses.firstWhere(
          (c) => c.id == off.courseId,
          orElse: () => Course(
            id: off.courseId,
            code: off.courseId,
            title: 'Course',
            description: '',
            creditValue: 0,
            level: 3,
            semester: 1,
            departmentId: 'd1',
            courseType: CourseType.compulsory,
          ),
        );
        final typeStr = course.courseType == CourseType.compulsory
            ? 'Compulsory'
            : 'Elective';
        return '${course.code} — ${course.title} ($typeStr, ${course.creditValue} Cr)';
      }).toList();
    }
    if (app.currentCgpa > 0) {
      live.gpa = app.currentCgpa;
    }
  }

  void _navigate(int index) {
    setState(() {
      if (index == 6 && _section == 6) {
        _selectedAcademicCandidate = null;
      }
      _section = index;
    });
    widget.onNavigate?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppService>(context);
    _syncWithLiveStudent(app);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: RuslColors.bgCream,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Indicator Header (Responsive)
            _buildHeader(app, isMobile),
            SizedBox(height: isMobile ? 14 : 20),

            // Active Section View
            switch (_section) {
              0 => _buildOverview(app, isMobile),
              1 => _buildSealingQueue(app, isMobile),
              2 => _buildStudentRegistry(app, isMobile),
              3 => _buildExamCompliance(app, isMobile),
              4 => _buildFreezeControl(app, isMobile),
              5 => _buildVerificationService(app, isMobile),
              6 => _buildAcademicRecords(app, isMobile),
              7 => _buildArProfile(app, isMobile),
              _ => _buildOverview(app, isMobile),
            },
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER (Fully Responsive for Mobile & Desktop)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(AppService app, bool isMobile) {
    final isLocked = app.activeRegistrationStatus == RegistrationStatus.locked;

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${RuslLocalization.tr("role_ar")} Portal',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: isMobile ? 22 : 30,
            fontWeight: FontWeight.w900,
            color: RuslColors.darkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Faculty of Technology • Examination & Registry',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: isMobile ? 11 : 13,
            color: RuslColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final statusBadges = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLocked
                ? RuslColors.errorRed.withValues(alpha: 0.12)
                : RuslColors.successGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? RuslColors.errorRed.withValues(alpha: 0.3)
                  : RuslColors.successGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked ? Icons.lock_rounded : Icons.verified_user_rounded,
                size: 13,
                color: isLocked ? RuslColors.errorRed : RuslColors.successGreen,
              ),
              const SizedBox(width: 5),
              Text(
                isLocked ? 'FROZEN' : 'ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isLocked
                      ? RuslColors.errorRed
                      : RuslColors.successGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: RuslColors.darkText,
              ),
              SizedBox(width: 5),
              Text(
                '2025/2026 Sem 5',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          titleColumn,
          const SizedBox(height: 8),
          statusBadges,
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleColumn),
              const SizedBox(width: 12),
              statusBadges,
            ],
          ),
        ],
        const SizedBox(height: 12),

        // Quick Navigation Pills (Horizontal scrollable)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildNavPill(0, 'Overview', Icons.dashboard_rounded),
              _buildNavPill(
                1,
                'Queue (${_pendingQueueCount()})',
                Icons.verified_rounded,
              ),
              _buildNavPill(2, 'Registry', Icons.groups_rounded),
              _buildNavPill(3, 'Exam Lists', Icons.fact_check_rounded),
              _buildNavPill(4, 'Freeze Control', Icons.lock_clock_rounded),
              _buildNavPill(5, 'Verify Token', Icons.qr_code_scanner_rounded),
              _buildNavPill(6, 'Academic Records', Icons.history_edu_rounded),
              _buildNavPill(7, 'AR Profile', Icons.badge_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavPill(int index, String label, IconData icon) {
    final isSelected = _section == index;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _navigate(index),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? RuslColors.darkText : RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? RuslColors.darkText : RuslColors.borderGrey,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: RuslColors.darkText.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? RuslColors.accentYellow
                    : RuslColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? RuslColors.pureWhite
                      : RuslColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _pendingQueueCount() =>
      _candidates.where((c) => c.status == 'HoD Approved').length;

  // ---------------------------------------------------------------------------
  // SECTION 0: REGISTRY EXECUTIVE OVERVIEW
  // ---------------------------------------------------------------------------
  Widget _buildOverview(AppService app, bool isMobile) {
    final total = _candidates.length;
    final sealed = _candidates
        .where((c) => c.status == 'Officially Sealed')
        .length;
    final pending = _candidates.where((c) => c.status == 'HoD Approved').length;
    final eligibleRate = total > 0
        ? ((sealed / total) * 100).toStringAsFixed(1)
        : '100.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive KPI Cards (2x2 on mobile, 4 in row on desktop)
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 600
                ? (constraints.maxWidth - 10) / 2
                : (constraints.maxWidth - 36) / 4;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const StatMetricCard(
                    value: '420',
                    label: 'Total Registered',
                    icon: Icons.how_to_reg_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value: '$sealed',
                    label: 'Officially Sealed',
                    icon: Icons.verified_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value: '$pending',
                    label: 'Pending AR Seal',
                    icon: Icons.hourglass_bottom_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value: '$eligibleRate%',
                    label: 'Exam Readiness',
                    icon: Icons.fact_check_rounded,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: isMobile ? 14 : 20),

        // Quick Command Bar (Responsive)
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isMobile
                          ? 'Registrar Actions'
                          : 'Registrar Fast Actions & Governance',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigate(1),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: Text(
                      isMobile ? 'Queue' : 'Open Queue',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: pending > 0 ? () => _bulkSealConfirm(app) : null,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: Text('Batch Seal All ($pending)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.successGreen,
                      foregroundColor: RuslColors.pureWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _navigate(3),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RuslColors.darkText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _navigate(4),
                    icon: const Icon(Icons.lock_rounded, size: 16),
                    label: Text(
                      app.activeRegistrationStatus == RegistrationStatus.locked
                          ? 'Registry Frozen'
                          : 'Freeze Registry',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RuslColors.darkText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 20),

        // Faculty Academic Year Level Distribution (Levels 1 - 4)
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Faculty Academic Year Level Distribution',
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.w900,
                            color: RuslColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Four concurrent cohorts enrolled for the 2025/2026 academic calendar',
                          style: TextStyle(
                            fontSize: 11,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth < 640
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - 36) / 4;
                  final levelStats = [
                    (
                      1,
                      'Level 1',
                      'Intake 2024/2025',
                      '100-Series Foundational',
                      const Color(0xFF2563EB),
                    ),
                    (
                      2,
                      'Level 2',
                      'Intake 2023/2024',
                      '200-Series Core & Skills',
                      const Color(0xFF0D9488),
                    ),
                    (
                      3,
                      'Level 3',
                      'Intake 2022/2023',
                      '300-Series Specializations',
                      const Color(0xFF7C3AED),
                    ),
                    (
                      4,
                      'Level 4',
                      'Intake 2021/2022',
                      '400-Series Capstone & Intern',
                      const Color(0xFFD97706),
                    ),
                  ];
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: levelStats.map((st) {
                      final lvl = st.$1;
                      final count = _candidates
                          .where((c) => c.level == lvl)
                          .length;
                      final sealedCount = _candidates
                          .where(
                            (c) =>
                                c.level == lvl &&
                                c.status == 'Officially Sealed',
                          )
                          .length;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLevel = lvl;
                            _section = 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: st.$5.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: st.$5.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    st.$2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: st.$5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: st.$5.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$count Students',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: st.$5,
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
                                  fontWeight: FontWeight.w700,
                                  color: RuslColors.darkText,
                                ),
                              ),
                              Text(
                                st.$4,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: RuslColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: count > 0 ? sealedCount / count : 1.0,
                                  minHeight: 4,
                                  backgroundColor: RuslColors.borderGrey
                                      .withValues(alpha: 0.4),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    st.$5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$sealedCount / $count sealed in roster',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: RuslColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 20),

        // Department Sealing Progress & Pipeline
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department Sealing Progress',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Verification and official registrar seal status across academic units',
                style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 14),
              _buildDeptProgress(
                'Information & Communication Tech (BICT)',
                0.94,
                '132 / 140',
                RuslColors.primaryMaroon,
              ),
              const SizedBox(height: 12),
              _buildDeptProgress(
                'Engineering Technology (BET)',
                0.90,
                '144 / 160',
                RuslColors.accentYellow,
              ),
              const SizedBox(height: 12),
              _buildDeptProgress(
                'Bio Systems Technology (BBST)',
                0.93,
                '112 / 120',
                RuslColors.successGreen,
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 20),

        // Recent Sealing Ledger
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Sealing Ledger',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              ..._candidates
                  .where((c) => c.status == 'Officially Sealed')
                  .take(4)
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: RuslColors.cardSubtle,
                            child: Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: RuslColors.successGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${c.regNumber} • ${c.sealDate ?? "Today"}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeptProgress(
    String deptName,
    double progress,
    String label,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                deptName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: RuslColors.darkText,
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
            backgroundColor: RuslColors.borderGrey.withValues(alpha: 0.4),
            color: color,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: OFFICIAL SEALING QUEUE (Mobile Adaptive)
  // ---------------------------------------------------------------------------
  Widget _buildSealingQueue(AppService app, bool isMobile) {
    var filtered = _candidates.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(_searchQueue.toLowerCase()) ||
          c.regNumber.toLowerCase().contains(_searchQueue.toLowerCase());
      final matchesDept =
          _selectedDept == 'All Departments' || c.department == _selectedDept;
      final matchesStatus =
          _selectedQueueStatus == 'All' ||
          (_selectedQueueStatus == 'Pending Seal' &&
              c.status == 'HoD Approved') ||
          (_selectedQueueStatus == 'Officially Sealed' &&
              c.status == 'Officially Sealed');
      final matchesLevel = _selectedLevel == 0 || c.level == _selectedLevel;
      return matchesSearch && matchesDept && matchesStatus && matchesLevel;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Queue Toolbar
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Official Sealing Queue (Levels 1 - 4)',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _bulkSealConfirm(app),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: Text(
                      isMobile ? 'Seal All' : 'Bulk Seal All Pending',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: RuslColors.successGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search & Filters (Stacked on mobile, row on desktop)
              if (isMobile) ...[
                TextField(
                  onChanged: (val) => setState(() => _searchQueue = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: 'Search candidate name or reg number...',
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDept,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Departments',
                            child: Text(
                              'All Depts',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Information & Communication Technology',
                            child: Text(
                              'ICT Dept',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Engineering Technology',
                            child: Text(
                              'Engineering',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Bio Systems Technology',
                            child: Text(
                              'Bio Systems',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(
                          () => _selectedDept = v ?? 'All Departments',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedQueueStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
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
                            child: Text('All', style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'Pending Seal',
                            child: Text(
                              'Pending',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Officially Sealed',
                            child: Text(
                              'Sealed',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedQueueStatus = v ?? 'All'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQueue = val),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText:
                              'Search by candidate name or registration number...',
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDept,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Departments',
                            child: Text('All Departments'),
                          ),
                          DropdownMenuItem(
                            value: 'Information & Communication Technology',
                            child: Text('ICT Dept'),
                          ),
                          DropdownMenuItem(
                            value: 'Engineering Technology',
                            child: Text('Engineering Tech'),
                          ),
                          DropdownMenuItem(
                            value: 'Bio Systems Technology',
                            child: Text('Bio Systems Tech'),
                          ),
                        ],
                        onChanged: (v) => setState(
                          () => _selectedDept = v ?? 'All Departments',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedQueueStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'Pending Seal',
                            child: Text('Pending Seal'),
                          ),
                          DropdownMenuItem(
                            value: 'Officially Sealed',
                            child: Text('Officially Sealed'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedQueueStatus = v ?? 'All'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Cohort Academic Level Chips (Levels 1 - 4)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4].map((lvl) {
                  final selected = _selectedLevel == lvl;
                  final count = lvl == 0
                      ? _candidates.length
                      : _candidates.where((c) => c.level == lvl).length;
                  final label = lvl == 0
                      ? 'All Levels ($count)'
                      : 'Level $lvl ($count)';
                  final color = lvl == 0
                      ? RuslColors.darkText
                      : switch (lvl) {
                          1 => const Color(0xFF2563EB),
                          2 => const Color(0xFF0D9488),
                          3 => const Color(0xFF7C3AED),
                          4 => const Color(0xFFD97706),
                          _ => RuslColors.primaryMaroon,
                        };
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedLevel = lvl),
                    selectedColor: lvl == 0
                        ? RuslColors.accentYellow
                        : color.withValues(alpha: 0.2),
                    backgroundColor: RuslColors.cardSubtle,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected && lvl != 0 ? color : RuslColors.darkText,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Candidate Cards List
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: RuslColors.textMuted,
                ),
                SizedBox(height: 8),
                Text(
                  'No candidates found matching filter criteria',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ...filtered.map((c) => _buildCandidateQueueCard(c, app, isMobile)),
      ],
    );
  }

  Widget _buildCandidateQueueCard(
    _ArCandidate c,
    AppService app,
    bool isMobile,
  ) {
    final isSealed = c.status == 'Officially Sealed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSealed
              ? RuslColors.successGreen.withValues(alpha: 0.3)
              : RuslColors.borderGrey,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isMobile ? 18 : 22,
                backgroundColor: isSealed
                    ? RuslColors.successGreen
                    : RuslColors.accentYellow,
                child: Icon(
                  isSealed ? Icons.verified_rounded : Icons.person_rounded,
                  size: isMobile ? 18 : 22,
                  color: isSealed ? Colors.white : RuslColors.darkText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildArLevelPill(c.level),
                        if (c.isRepeatCandidate) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: RuslColors.warningOrange.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'REPEAT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: RuslColors.warningOrange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.regNumber} • ${c.degreeProgram}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSealed
                      ? RuslColors.successGreen.withValues(alpha: 0.12)
                      : RuslColors.accentYellow.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSealed ? 'SEALED' : 'PENDING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isSealed
                        ? RuslColors.successGreen
                        : RuslColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Compliance Pill Badges
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildAuditBadge(
                Icons.check_circle_rounded,
                '${c.credits} Cr',
                true,
              ),
              _buildAuditBadge(
                Icons.check_circle_rounded,
                'GPA ${c.gpa.toStringAsFixed(2)}',
                true,
              ),
              _buildAuditBadge(
                Icons.domain_verification_rounded,
                'HoD Signed',
                true,
              ),
              _buildAuditBadge(
                Icons.event_available_rounded,
                'Coord Cleared',
                true,
              ),
            ],
          ),
          const Divider(height: 18),

          // Action Toolbar (Responsive for Mobile)
          if (isMobile) ...[
            Text(
              'Token: ${c.verificationToken}',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Courier',
                color: RuslColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCandidateDetails(c, app, isMobile),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Modules',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: !isSealed
                      ? FilledButton.icon(
                          onPressed: () => _showSealDialog(c, app, isMobile),
                          icon: const Icon(Icons.verified_rounded, size: 14),
                          label: const Text(
                            'Affix Seal',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: RuslColors.successGreen,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _printCandidateSlip(c, app),
                          icon: const Icon(Icons.print_rounded, size: 14),
                          label: const Text(
                            'Print Slip',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RuslColors.accentYellow,
                            foregroundColor: RuslColors.darkText,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Token: ${c.verificationToken}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier',
                    color: RuslColors.textMuted,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showCandidateDetails(c, app, isMobile),
                      icon: const Icon(Icons.visibility_rounded, size: 15),
                      label: const Text('View Modules'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (!isSealed)
                      FilledButton.icon(
                        onPressed: () => _showSealDialog(c, app, isMobile),
                        icon: const Icon(Icons.verified_rounded, size: 15),
                        label: const Text('Affix Official Seal'),
                        style: FilledButton.styleFrom(
                          backgroundColor: RuslColors.successGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _printCandidateSlip(c, app),
                        icon: const Icon(Icons.print_rounded, size: 15),
                        label: const Text('Print Official Slip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RuslColors.accentYellow,
                          foregroundColor: RuslColors.darkText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditBadge(IconData icon, String text, bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: passed
            ? RuslColors.cardSubtle
            : RuslColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RuslColors.borderGrey.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: passed ? RuslColors.successGreen : RuslColors.errorRed,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: passed ? RuslColors.darkText : RuslColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2: FACULTY STUDENT REGISTRY (Mobile Adaptive)
  // ---------------------------------------------------------------------------
  Widget _buildStudentRegistry(AppService app, bool isMobile) {
    var filtered = _candidates.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(_registrySearch.toLowerCase()) ||
          c.regNumber.toLowerCase().contains(_registrySearch.toLowerCase()) ||
          c.verificationToken.toLowerCase().contains(
            _registrySearch.toLowerCase(),
          );
      final matchesDept =
          _registryDept == 'All' || c.department.contains(_registryDept);
      final matchesLevel = _registryLevel == 0 || c.level == _registryLevel;
      return matchesSearch && matchesDept && matchesLevel;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faculty Student Registry',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              if (isMobile) ...[
                TextField(
                  onChanged: (val) => setState(() => _registrySearch = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    hintText: 'Search reg number, name, token...',
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _registryDept,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
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
                        'All Departments',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Information & Communication',
                      child: Text('ICT Dept', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'Engineering',
                      child: Text(
                        'Engineering Tech',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Bio Systems',
                      child: Text(
                        'Bio Systems Tech',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _registryDept = v ?? 'All'),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        onChanged: (val) =>
                            setState(() => _registrySearch = val),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText:
                              'Search by registration number, student name, or token...',
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _registryDept,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Departments'),
                          ),
                          DropdownMenuItem(
                            value: 'Information & Communication',
                            child: Text('Information & Communication Tech'),
                          ),
                          DropdownMenuItem(
                            value: 'Engineering',
                            child: Text('Engineering Technology'),
                          ),
                          DropdownMenuItem(
                            value: 'Bio Systems',
                            child: Text('Bio Systems Technology'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _registryDept = v ?? 'All'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Academic Level Ribbon Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4].map((lvl) {
                  final selected = _registryLevel == lvl;
                  final count = lvl == 0
                      ? _candidates.length
                      : _candidates.where((c) => c.level == lvl).length;
                  final label = lvl == 0
                      ? 'All Levels ($count)'
                      : 'Level $lvl ($count)';
                  final color = lvl == 0
                      ? RuslColors.darkText
                      : switch (lvl) {
                          1 => const Color(0xFF2563EB),
                          2 => const Color(0xFF0D9488),
                          3 => const Color(0xFF7C3AED),
                          4 => const Color(0xFFD97706),
                          _ => RuslColors.primaryMaroon,
                        };
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _registryLevel = lvl),
                    selectedColor: lvl == 0
                        ? RuslColors.accentYellow
                        : color.withValues(alpha: 0.2),
                    backgroundColor: RuslColors.cardSubtle,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected && lvl != 0 ? color : RuslColors.darkText,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Registry Display: Mobile Cards or Desktop DataTable
        if (isMobile)
          _buildStudentRegistryMobileCards(filtered, app)
        else
          Container(
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(RuslColors.cardSubtle),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'REG NUMBER',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STUDENT NAME',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'LEVEL',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PROGRAMME',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CREDITS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CGPA',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  rows: filtered.map((c) {
                    final isSealed = c.status == 'Officially Sealed';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            c.regNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(_buildArLevelPill(c.level)),
                        DataCell(
                          Text(
                            c.degreeProgram,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${c.credits} Cr',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            c.gpa.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isSealed
                                  ? RuslColors.successGreen.withValues(
                                      alpha: 0.12,
                                    )
                                  : RuslColors.accentYellow.withValues(
                                      alpha: 0.2,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isSealed ? 'SEALED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isSealed
                                    ? RuslColors.successGreen
                                    : RuslColors.darkText,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_rounded,
                                  size: 16,
                                ),
                                tooltip: 'View Candidate Details',
                                onPressed: () =>
                                    _showCandidateDetails(c, app, isMobile),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.history_edu_rounded,
                                  size: 16,
                                  color: RuslColors.primaryMaroon,
                                ),
                                tooltip: 'View Academic Record',
                                onPressed: () {
                                  setState(() {
                                    _selectedAcademicCandidate = c;
                                    _academicSemesterFilter = 'all';
                                    _section = 6;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 16,
                                  color: RuslColors.successGreen,
                                ),
                                tooltip: 'Insert Exam Result',
                                onPressed: () => _showInsertResultDialog(c, app),
                              ),
                              IconButton(
                                icon: const Icon(Icons.print_rounded, size: 16),
                                tooltip: 'Print Official Slip',
                                onPressed: () => _printCandidateSlip(c, app),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentRegistryMobileCards(
    List<_ArCandidate> filtered,
    AppService app,
  ) {
    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: RuslColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RuslColors.borderGrey),
        ),
        alignment: Alignment.center,
        child: const Text(
          'No students matching search filter.',
          style: TextStyle(
            color: RuslColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Column(
      children: filtered.map((c) {
        final isSealed = c.status == 'Officially Sealed';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSealed
                        ? RuslColors.successGreen.withValues(alpha: 0.15)
                        : RuslColors.accentYellow.withValues(alpha: 0.3),
                    child: Text(
                      c.name.isNotEmpty
                          ? c.name
                              .split(' ')
                              .where((w) => w.isNotEmpty)
                              .map((w) => w[0])
                              .take(2)
                              .join()
                          : 'ST',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: isSealed
                            ? RuslColors.successGreen
                            : RuslColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${c.regNumber} • ${c.degreeProgram}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: RuslColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSealed
                          ? RuslColors.successGreen.withValues(alpha: 0.12)
                          : RuslColors.accentYellow.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSealed ? 'SEALED' : 'PENDING',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isSealed
                            ? RuslColors.successGreen
                            : RuslColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildArLevelPill(c.level),
                    Text(
                      'Credits: ${c.credits} Cr',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'CGPA: ${c.gpa.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: RuslColors.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showCandidateDetails(c, app, true),
                    icon: const Icon(Icons.visibility_rounded, size: 14),
                    label: const Text('Details', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      setState(() {
                        _selectedAcademicCandidate = c;
                        _academicSemesterFilter = 'all';
                        _section = 6;
                      });
                    },
                    icon: const Icon(Icons.history_edu_rounded, size: 14),
                    label: const Text(
                      'Academic Record',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showInsertResultDialog(c, app),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
                    label: const Text(
                      'Insert Result',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: RuslColors.primaryMaroon,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_rounded, size: 16),
                    tooltip: 'Print Slip',
                    onPressed: () => _printCandidateSlip(c, app),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 3: EXAM COMPLIANCE & ADMISSION LISTS (Mobile Adaptive)
  // ---------------------------------------------------------------------------
  Widget _buildExamCompliance(AppService app, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compliance Banner
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Examination Admission Register',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Faculty By-laws: Candidates who satisfied minimum 12 credits, departmental endorsement, and prerequisite clearances are eligible for admission tickets.',
                style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _exportCsvDialog(isMobile),
                    icon: const Icon(Icons.table_view_rounded, size: 16),
                    label: const Text('Export CSV for Exam Division'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.primaryMaroon,
                      foregroundColor: RuslColors.pureWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _printExamHallRegister(app),
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Print Hall Register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RuslColors.darkText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Academic Level Ribbon Chips for Examination Registry
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4].map((lvl) {
                  final selected = _examLevel == lvl;
                  final count = lvl == 0
                      ? _candidates.length
                      : _candidates.where((c) => c.level == lvl).length;
                  final label = lvl == 0
                      ? 'All Levels ($count)'
                      : 'Level $lvl ($count)';
                  final color = lvl == 0
                      ? RuslColors.darkText
                      : switch (lvl) {
                          1 => const Color(0xFF2563EB),
                          2 => const Color(0xFF0D9488),
                          3 => const Color(0xFF7C3AED),
                          4 => const Color(0xFFD97706),
                          _ => RuslColors.primaryMaroon,
                        };
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _examLevel = lvl),
                    selectedColor: lvl == 0
                        ? RuslColors.accentYellow
                        : color.withValues(alpha: 0.2),
                    backgroundColor: RuslColors.cardSubtle,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected && lvl != 0 ? color : RuslColors.darkText,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Compliance Breakdown Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 600
                ? (constraints.maxWidth - 10) / 2
                : (constraints.maxWidth - 36) / 4;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const StatMetricCard(
                    value: '420',
                    label: 'Eligible Candidates',
                    icon: Icons.how_to_reg_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const StatMetricCard(
                    value: '0',
                    label: 'Attendance Barred',
                    icon: Icons.block_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const StatMetricCard(
                    value: '2',
                    label: 'Repeat Candidates',
                    icon: Icons.replay_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const StatMetricCard(
                    value: '100%',
                    label: 'Compliance Rate',
                    icon: Icons.verified_rounded,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Candidates Master List
        Container(
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(RuslColors.cardSubtle),
                columns: const [
                  DataColumn(
                    label: Text(
                      'EXAM INDEX',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'REG NUMBER',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'CANDIDATE NAME',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LEVEL',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'PROGRAMME',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'MODULES',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ADMISSION',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                rows: _candidates
                    .where((c) => _examLevel == 0 || c.level == _examLevel)
                    .map((c) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              c.examIndexNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Courier',
                                fontSize: 11,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              c.regNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          DataCell(_buildArLevelPill(c.level)),
                          DataCell(
                            Text(
                              c.degreeProgram,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${c.enrolledCourses.length} mod (${c.credits} Cr)',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: RuslColors.successGreen.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CLEARED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: RuslColors.successGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 4: REGISTRATION FREEZE & DEADLINE GOVERNANCE (Mobile Adaptive)
  // ---------------------------------------------------------------------------
  Widget _buildFreezeControl(AppService app, bool isMobile) {
    final isLocked = app.activeRegistrationStatus == RegistrationStatus.locked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Freeze Banner Card
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isLocked
                  ? RuslColors.errorRed.withValues(alpha: 0.3)
                  : RuslColors.borderGrey,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 18 : 22,
                    backgroundColor: isLocked
                        ? RuslColors.errorRed.withValues(alpha: 0.15)
                        : RuslColors.accentYellow,
                    child: Icon(
                      isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: isMobile ? 18 : 22,
                      color: isLocked
                          ? RuslColors.errorRed
                          : RuslColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocked
                              ? 'Registrations: FROZEN & LOCKED'
                              : 'Registrations: OPEN / ACTIVE',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w900,
                            color: isLocked
                                ? RuslColors.errorRed
                                : RuslColors.darkText,
                          ),
                        ),
                        const Text(
                          'Academic Year 2025/2026 • Semester 5 Registry State',
                          style: TextStyle(
                            fontSize: 11,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: isMobile ? double.infinity : null,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLocked) {
                      app.unlockFacultyRegistration();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Faculty registration freeze lifted. Re-opened for administrative review.',
                          ),
                          backgroundColor: RuslColors.successGreen,
                        ),
                      );
                    } else {
                      app.lockFacultyRegistration();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Faculty registrations FROZEN. Course selections locked for all candidates.',
                          ),
                          backgroundColor: RuslColors.errorRed,
                        ),
                      );
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    size: 16,
                  ),
                  label: Text(
                    isLocked
                        ? 'Lift Registration Freeze'
                        : 'Freeze Faculty Registrations',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked
                        ? RuslColors.successGreen
                        : RuslColors.errorRed,
                    foregroundColor: RuslColors.pureWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              const Text(
                'Faculty Freeze Governance Policy:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'Freezing registration locks student elective course alterations, freezes credit limits, and finalizes the candidate master ledger for the Examination Division.',
                style: TextStyle(
                  fontSize: 11,
                  color: RuslColors.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Late Registration Exception Petitions
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Late Registration Exception Requests',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              ..._lateExceptions.map(
                (ex) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: RuslColors.warningOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${ex.studentName} (${ex.regNumber})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ex.status == 'PENDING'
                                  ? RuslColors.warningOrange.withValues(
                                      alpha: 0.15,
                                    )
                                  : RuslColors.successGreen.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ex.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: ex.status == 'PENDING'
                                    ? RuslColors.warningOrange
                                    : RuslColors.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(ex.reason, style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(
                        'Late Fine: LKR ${ex.penaltyFee}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: RuslColors.primaryMaroon,
                        ),
                      ),
                      if (ex.status == 'PENDING') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() => ex.status = 'WAIVED');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Waived late fee for ${ex.studentName}.',
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                ),
                                child: const Text(
                                  'Waive Fine',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  setState(() => ex.status = 'APPROVED');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Approved late registration with fine for ${ex.studentName}.',
                                      ),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                ),
                                child: const Text(
                                  'Approve (Fine Paid)',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 5: VERIFICATION & CERTIFICATE SERVICE (Mobile Adaptive)
  // ---------------------------------------------------------------------------
  Widget _buildVerificationService(AppService app, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cryptographic Verification Service',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter Registration Number or Verification Token to validate authenticity against the faculty seal ledger.',
                style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 12),
              if (isMobile) ...[
                TextField(
                  controller: _verifyController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                    ),
                    hintText: 'e.g. ICT/2021/045 or RUSL-REG-FOT-2026-X992',
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _performVerification,
                    icon: const Icon(Icons.search_rounded, size: 16),
                    label: const Text('Verify Record'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verifyController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                          hintText:
                              'Enter Reg No (e.g. ICT/2021/045) or Token (e.g. RUSL-REG-FOT-2026-X992)...',
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _performVerification,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Verify Record'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Verification Outcome
        if (_verifiedResult != null) ...[
          Container(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.successGreen, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: RuslColors.successGreen,
                      child: Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AUTHENTICATED & SEALED',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: RuslColors.successGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Serial: ${_verifiedResult!.verificationToken}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: RuslColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    _verifyInfoTile('Student Name', _verifiedResult!.name),
                    _verifyInfoTile(
                      'Registration No',
                      _verifiedResult!.regNumber,
                    ),
                    _verifyInfoTile(
                      'Programme',
                      _verifiedResult!.degreeProgram,
                    ),
                    _verifyInfoTile(
                      'Enrolled Credits',
                      '${_verifiedResult!.credits} Academic Credits',
                    ),
                    _verifyInfoTile(
                      'Approving Officer',
                      'Ms. K. H. Gaurika Kahawala (AR)',
                    ),
                    _verifyInfoTile(
                      'Sealing Date',
                      _verifiedResult!.sealDate ?? '2026-10-08',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Registered Course Modules Under Official Seal:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                const SizedBox(height: 6),
                ..._verifiedResult!.enrolledCourses.map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: RuslColors.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(m, style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: () => _printCandidateSlip(_verifiedResult!, app),
                    icon: const Icon(Icons.print_rounded, size: 14),
                    label: const Text('Print Verified Registration Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.accentYellow,
                      foregroundColor: RuslColors.darkText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_verifyController.text.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: RuslColors.errorRed.withValues(alpha: 0.5),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 36,
                  color: RuslColors.errorRed,
                ),
                SizedBox(height: 6),
                Text(
                  'No authentic registration found with that token or registration number.',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: RuslColors.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _performVerification() {
    final q = _verifyController.text.trim().toLowerCase();
    if (q.isEmpty) return;
    setState(() {
      _verifiedResult = _candidates.cast<_ArCandidate?>().firstWhere(
        (c) =>
            c!.regNumber.toLowerCase() == q ||
            c.verificationToken.toLowerCase() == q ||
            c.name.toLowerCase().contains(q),
        orElse: () => null,
      );
    });
  }

  Widget _verifyInfoTile(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 6: FACULTY ACADEMIC RECORDS & TRANSCRIPTS REGISTRY (Responsive)
  // ---------------------------------------------------------------------------
  Widget _buildAcademicRecords(AppService app, bool isMobile) {
    if (_selectedAcademicCandidate == null) {
      return _buildAcademicRecordsDirectory(app, isMobile);
    }
    return _buildStudentAcademicRecordDetail(
      app,
      _selectedAcademicCandidate!,
      isMobile,
    );
  }

  // View A: Faculty Academic Records Directory (Search & Select Students)
  Widget _buildAcademicRecordsDirectory(AppService app, bool isMobile) {
    final query = _academicSearch.trim().toLowerCase();
    final filtered = _candidates.where((c) {
      final matchesDept =
          _academicDept == 'All Departments' || c.department == _academicDept;
      final matchesQuery =
          query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.regNumber.toLowerCase().contains(query) ||
          c.degreeProgram.toLowerCase().contains(query);
      final matchesStanding = switch (_academicStanding) {
        'first_class' => c.gpa >= 3.70,
        'second_upper' => c.gpa >= 3.50 && c.gpa < 3.70,
        'second_lower' => c.gpa >= 3.00 && c.gpa < 3.50,
        'pass' => c.gpa >= 2.00 && c.gpa < 3.00,
        'batch_miss' => c.gpa < 2.00,
        _ => true,
      };
      return matchesDept && matchesQuery && matchesStanding;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Header Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF800000), Color(0xFF5A0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_edu_rounded,
                  color: RuslColors.accentYellow,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faculty Academic Records & Transcripts Registry',
                      style: TextStyle(
                        fontSize: isMobile ? 17 : 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Central Examination Division • Search and inspect undergraduate student transcripts, earned credits, CGPA standings, and course outcomes.',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Registry Metrics by Degree Honours Classification
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int cols = width < 520
                ? 1
                : width < 820
                ? 2
                : width < 1180
                ? 3
                : 5;
            final cardWidth = (width - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value: '${_candidates.where((c) => c.gpa >= 3.70).length}',
                    label: '1st Class (≥ 3.70)',
                    icon: Icons.workspace_premium_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value:
                        '${_candidates.where((c) => c.gpa >= 3.50 && c.gpa < 3.70).length}',
                    label: '2nd Class Upper (≥ 3.50)',
                    icon: Icons.military_tech_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value:
                        '${_candidates.where((c) => c.gpa >= 3.00 && c.gpa < 3.50).length}',
                    label: '2nd Class Lower (≥ 3.00)',
                    icon: Icons.school_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value:
                        '${_candidates.where((c) => c.gpa >= 2.00 && c.gpa < 3.00).length}',
                    label: 'Pass (≥ 2.00)',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatMetricCard(
                    value: '${_candidates.where((c) => c.gpa < 2.00).length}',
                    label: 'Batch Miss (< 2.00)',
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // Search & Filter Controls
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              TextField(
                controller: _academicSearchController,
                onChanged: (val) => setState(() => _academicSearch = val),
                decoration: InputDecoration(
                  hintText:
                      'Search by Student Name, Reg Number (e.g. ICT/2021/045), Degree...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _academicSearch.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _academicSearchController.clear();
                            setState(() => _academicSearch = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: RuslColors.lightGreyBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Department:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  ...[
                    'All Departments',
                    'Information & Communication Technology',
                    'Electrical & Electronic Technology',
                    'Bio-Process Technology',
                  ].map((dept) {
                    final isSel = _academicDept == dept;
                    final shortDept = dept == 'All Departments'
                        ? 'All'
                        : dept.contains('Information')
                        ? 'ICT'
                        : dept.contains('Electrical')
                        ? 'EET'
                        : 'BST';
                    return ChoiceChip(
                      selected: isSel,
                      onSelected: (_) => setState(() => _academicDept = dept),
                      selectedColor: RuslColors.darkText,
                      label: Text(
                        shortDept,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : RuslColors.darkText,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  const Text(
                    'Standing:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  ...[
                    ('all', 'All Standings'),
                    ('first_class', '1st Class (≥3.70)'),
                    ('second_upper', '2nd Upper (≥3.50)'),
                    ('second_lower', '2nd Lower (≥3.00)'),
                    ('pass', 'Pass (≥2.00)'),
                    ('batch_miss', 'Batch Miss (<2.00)'),
                  ].map((item) {
                    final isSel = _academicStanding == item.$1;
                    return ChoiceChip(
                      selected: isSel,
                      onSelected: (_) =>
                          setState(() => _academicStanding = item.$1),
                      selectedColor: RuslColors.primaryMaroon,
                      label: Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : RuslColors.darkText,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Students Table
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Student Academic Directory (${filtered.length} students found)',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (query.isNotEmpty ||
                      _academicDept != 'All Departments' ||
                      _academicStanding != 'all')
                    TextButton.icon(
                      onPressed: () {
                        _academicSearchController.clear();
                        setState(() {
                          _academicSearch = '';
                          _academicDept = 'All Departments';
                          _academicStanding = 'all';
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text(
                        'Reset Filters',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: RuslColors.textMuted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No students found matching your search criteria.',
                        style: TextStyle(
                          color: RuslColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isMobile)
                _buildAcademicDirectoryMobileCards(filtered, app)
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 22,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF9FAFB),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Reg Number',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Student Name',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Department & Degree',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Level / Sem',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'CGPA',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Academic Standing',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                    rows: filtered.map((c) {
                      final isNafis = c.regNumber == 'ICT/2021/045';
                      final gpaColor = c.gpa >= 3.70
                          ? RuslColors.successGreen
                          : c.gpa >= 3.20
                          ? const Color(0xFF1976D2)
                          : c.gpa >= 2.70
                          ? RuslColors.warningOrange
                          : RuslColors.errorRed;

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: RuslColors.primaryMaroon.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: RuslColors.primaryMaroon.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                c.regNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: RuslColors.primaryMaroon,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (isNafis) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: RuslColors.successGreen.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'LIVE ACTIVE',
                                      style: TextStyle(
                                        color: RuslColors.successGreen,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '${c.degreeProgram} • ${c.department.contains("Information")
                                  ? "ICT"
                                  : c.department.contains("Electrical")
                                  ? "EET"
                                  : "BST"}',
                            ),
                          ),
                          DataCell(Text('Level ${c.level} Sem ${c.semester}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: gpaColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                c.gpa.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: gpaColor,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Builder(
                              builder: (context) {
                                final standing = DegreeClassStanding.fromGpa(
                                  c.gpa,
                                );
                                final (textColor, bgColor) = switch (standing) {
                                  DegreeClassStanding.firstClass => (
                                    const Color(0xFF1B5E20),
                                    const Color(0xFFE8F5E9),
                                  ),
                                  DegreeClassStanding.secondUpper => (
                                    const Color(0xFF0D47A1),
                                    const Color(0xFFE3F2FD),
                                  ),
                                  DegreeClassStanding.secondLower => (
                                    const Color(0xFF006064),
                                    const Color(0xFFE0F7FA),
                                  ),
                                  DegreeClassStanding.pass => (
                                    const Color(0xFFE65100),
                                    const Color(0xFFFFF3E0),
                                  ),
                                  DegreeClassStanding.batchMiss => (
                                    RuslColors.errorRed,
                                    const Color(0xFFFFEBEE),
                                  ),
                                };
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: textColor.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        standing.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          color: textColor,
                                        ),
                                      ),
                                      if (c.isRepeatCandidate) ...[
                                        const SizedBox(width: 4),
                                        const Text(
                                          '• Repeat',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: RuslColors.warningOrange,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAcademicCandidate = c;
                                      _academicSemesterFilter = 'all';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.history_edu_rounded,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'View Record',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 18,
                                    color: RuslColors.primaryMaroon,
                                  ),
                                  tooltip: 'Insert Exam Result',
                                  onPressed: () =>
                                      _showInsertResultDialog(c, app),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicDirectoryMobileCards(
    List<_ArCandidate> filtered,
    AppService app,
  ) {
    return Column(
      children: filtered.map((c) {
        final isNafis = c.regNumber == 'ICT/2021/045';
        final gpaColor = c.gpa >= 3.70
            ? RuslColors.successGreen
            : c.gpa >= 3.20
            ? const Color(0xFF1976D2)
            : c.gpa >= 2.70
            ? RuslColors.warningOrange
            : RuslColors.errorRed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.primaryMaroon.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: RuslColors.primaryMaroon.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      c.regNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: RuslColors.primaryMaroon,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isNafis)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: RuslColors.successGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE ACTIVE',
                        style: TextStyle(
                          color: RuslColors.successGreen,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: gpaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'CGPA ${c.gpa.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: gpaColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${c.degreeProgram} • Level ${c.level} Sem ${c.semester}',
                style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
              Text(
                DegreeClassStanding.fromGpa(c.gpa).fullName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: gpaColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedAcademicCandidate = c;
                        _academicSemesterFilter = 'all';
                      });
                    },
                    icon: const Icon(Icons.history_edu_rounded, size: 14),
                    label: const Text(
                      'Inspect Record',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showInsertResultDialog(c, app),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
                    label: const Text(
                      'Insert Result',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // View B: Selected Student Detailed Academic Record & Transcript Management
  Widget _buildStudentAcademicRecordDetail(
    AppService app,
    _ArCandidate candidate,
    bool isMobile,
  ) {
    final isNafis = candidate.regNumber == 'ICT/2021/045';
    final allRecords = _getRecordsForCandidate(app, candidate);

    final completed = allRecords
        .where((r) => r.status == AcademicRecordStatus.completed)
        .fold(0, (acc, r) => acc + r.credits);
    final medical = allRecords
        .where((r) => r.status == AcademicRecordStatus.medical)
        .fold(0, (acc, r) => acc + r.credits);
    final dropped = allRecords
        .where((r) => r.status == AcademicRecordStatus.dropped)
        .fold(0, (acc, r) => acc + r.credits);

    final filteredRecords = switch (_academicSemesterFilter) {
      'l1s1' =>
        allRecords.where((r) => r.level == 1 && r.semester == 1).toList(),
      'l1s2' =>
        allRecords.where((r) => r.level == 1 && r.semester == 2).toList(),
      'l2s1' =>
        allRecords.where((r) => r.level == 2 && r.semester == 1).toList(),
      'l2s2' =>
        allRecords.where((r) => r.level == 2 && r.semester == 2).toList(),
      'l3s1' =>
        allRecords.where((r) => r.level == 3 && r.semester == 1).toList(),
      _ => allRecords,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation & Quick Switcher Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _selectedAcademicCandidate = null),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  isMobile ? 'Back' : 'Back to Student Directory',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMobile)
                    const Text(
                      'Quick Switch: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  DropdownButton<_ArCandidate>(
                    value: candidate,
                    isDense: true,
                    underline: const SizedBox(),
                    selectedItemBuilder: isMobile
                        ? (context) => _candidates
                              .map(
                                (item) => Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    item.regNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                              .toList()
                        : null,
                    items: _candidates
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              '${c.regNumber} — ${c.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (newCand) {
                      if (newCand != null) {
                        setState(() {
                          _selectedAcademicCandidate = newCand;
                          _academicSemesterFilter = 'all';
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Student Profile Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.darkText,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isMobile ? 18 : 22,
                    backgroundColor: RuslColors.accentYellow,
                    child: Text(
                      candidate.name.isNotEmpty
                          ? candidate.name
                              .split(' ')
                              .where((w) => w.isNotEmpty)
                              .map((w) => w[0])
                              .take(2)
                              .join()
                          : 'ST',
                      style: TextStyle(
                        color: RuslColors.darkText,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 11 : 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              candidate.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: isMobile ? 15 : 18,
                              ),
                            ),
                            if (isNafis)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: RuslColors.successGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LIVE REGISTRATION ENGINE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Reg: ${candidate.regNumber}  •  Index: ${candidate.examIndexNumber}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${candidate.department} • ${candidate.degreeProgram}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                'Current: Level ${candidate.level} Semester ${candidate.semester} • ${DegreeClassStanding.fromGpa(candidate.gpa).fullName} (${candidate.gpa.toStringAsFixed(2)})',
                style: const TextStyle(
                  color: RuslColors.accentYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Metric Cards
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              'Completed credits',
              '$completed / 120',
              RuslColors.successGreen,
              Icons.check_circle_rounded,
              isMobile,
            ),
            _buildStatCard(
              'Medical credits',
              '$medical',
              Colors.orange,
              Icons.medical_information_rounded,
              isMobile,
            ),
            _buildStatCard(
              'Dropped credits',
              '$dropped',
              RuslColors.errorRed,
              Icons.remove_circle_rounded,
              isMobile,
            ),
            _buildStatCard(
              'Cumulative GPA',
              candidate.gpa.toStringAsFixed(2),
              Colors.blue,
              Icons.analytics_rounded,
              isMobile,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Semester Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSemesterChip(
                key: 'all',
                label: 'All Semesters',
                count: '${allRecords.length} courses',
              ),
              const SizedBox(width: 8),
              _buildSemesterChip(
                key: 'l1s1',
                label: 'Level 1 Sem 1',
                count:
                    '${allRecords.where((r) => r.level == 1 && r.semester == 1).length} courses',
              ),
              const SizedBox(width: 8),
              _buildSemesterChip(
                key: 'l1s2',
                label: 'Level 1 Sem 2',
                count:
                    '${allRecords.where((r) => r.level == 1 && r.semester == 2).length} courses',
              ),
              const SizedBox(width: 8),
              _buildSemesterChip(
                key: 'l2s1',
                label: 'Level 2 Sem 1',
                count:
                    '${allRecords.where((r) => r.level == 2 && r.semester == 1).length} courses',
              ),
              const SizedBox(width: 8),
              _buildSemesterChip(
                key: 'l2s2',
                label: 'Level 2 Sem 2',
                count:
                    '${allRecords.where((r) => r.level == 2 && r.semester == 2).length} courses',
              ),
              const SizedBox(width: 8),
              _buildSemesterChip(
                key: 'l3s1',
                label: 'Level 3 Sem 1',
                count:
                    '${allRecords.where((r) => r.level == 3 && r.semester == 1).length} courses',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Repeat Review Banner & Dropped Subjects Regulations
        Builder(
          builder: (context) {
            final repeatEligible = allRecords
                .where((r) => r.canRegisterAgain)
                .toList();
            final droppedRecords = allRecords
                .where((r) => r.isDropped)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (repeatEligible.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RuslColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: RuslColors.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.replay_rounded,
                              color: RuslColors.warningOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Repeat Eligible Subjects (Medical / Failed Results)',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Under faculty regulations, students with approved Medical concessions or Failed results can re-register.',
                          style: TextStyle(
                            fontSize: 12,
                            color: RuslColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...repeatEligible.map(
                          (record) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: RuslColors.cardSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                RuslColors.warningOrange
                                                    .withValues(alpha: .15),
                                            child: const Icon(
                                              Icons.replay_rounded,
                                              color: RuslColors.warningOrange,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${record.courseCode} - ${record.courseTitle}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${record.repeatEligibilityLabel} | Academic Year: ${record.academicYear}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: RuslColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: RuslColors.warningOrange
                                              .withValues(alpha: .15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          (isNafis &&
                                                  app.requestedRepeatRecordIds
                                                      .contains(record.id))
                                              ? 'STUDENT REQUESTED'
                                              : 'ELIGIBLE TO RE-REGISTER',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: RuslColors.warningOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: RuslColors.warningOrange
                                          .withValues(alpha: .12),
                                      child: const Icon(
                                        Icons.replay_rounded,
                                        color: RuslColors.warningOrange,
                                      ),
                                    ),
                                    title: Text(
                                      '${record.courseCode} - ${record.courseTitle}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${record.repeatEligibilityLabel} | Academic Year: ${record.academicYear}',
                                    ),
                                    trailing: Chip(
                                      backgroundColor: RuslColors.warningOrange
                                          .withValues(alpha: .12),
                                      label: Text(
                                        (isNafis &&
                                                app.requestedRepeatRecordIds
                                                    .contains(record.id))
                                            ? 'STUDENT REQUESTED'
                                            : 'ELIGIBLE TO RE-REGISTER',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: RuslColors.warningOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (droppedRecords.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RuslColors.errorRed.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: RuslColors.errorRed.withValues(alpha: .2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.block_rounded,
                              color: RuslColors.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dropped Subjects (Cannot Re-register)',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w900,
                                  color: RuslColors.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Under faculty academic regulations, once a student drops a subject, they CANNOT register for it again.',
                          style: TextStyle(
                            fontSize: 12,
                            color: RuslColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...droppedRecords.map(
                          (record) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: RuslColors.errorRed
                                                .withValues(alpha: .15),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: RuslColors.errorRed,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${record.courseCode} - ${record.courseTitle}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Dropped in ${record.academicYear} (${record.semesterLabel}) • Permanently blocked',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: RuslColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'CANNOT RE-REGISTER',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: RuslColors.errorRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: RuslColors.errorRed
                                          .withValues(alpha: .12),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: RuslColors.errorRed,
                                      ),
                                    ),
                                    title: Text(
                                      '${record.courseCode} - ${record.courseTitle}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Dropped in ${record.academicYear} (${record.semesterLabel}) • Re-registration permanently blocked',
                                    ),
                                    trailing: const Chip(
                                      backgroundColor: Color(0xFFFFEBEE),
                                      label: Text(
                                        'CANNOT RE-REGISTER',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: RuslColors.errorRed,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),

        // Subject Outcomes Register Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Official Subject Outcome Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Showing ${filteredRecords.length} courses • Changes recorded with audit trails.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: RuslColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              _showInsertResultDialog(candidate, app),
                          icon: const Icon(Icons.add_circle_rounded, size: 16),
                          label: const Text(
                            'Insert Result',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: RuslColors.primaryMaroon,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _exportCandidateTranscript(candidate),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                          label: const Text(
                            'Export Transcript',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Official Subject Outcome Register',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Showing ${filteredRecords.length} courses • Changes are recorded with full audit trails.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: RuslColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              _showInsertResultDialog(candidate, app),
                          icon: const Icon(Icons.add_circle_rounded, size: 16),
                          label: const Text(
                            'Insert New Result',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: RuslColors.primaryMaroon,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _exportCandidateTranscript(candidate),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                          label: const Text(
                            'Export Transcript',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              ...filteredRecords.map(
                (record) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: RuslColors.borderGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _academicRecordDetails(record),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showEditResultDialog(
                                    candidate,
                                    record,
                                    app,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Edit Grade',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 170,
                                  child: _academicStatusDropdown(
                                    app,
                                    candidate,
                                    record,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _academicRecordDetails(record)),
                            const SizedBox(width: 14),
                            OutlinedButton.icon(
                              onPressed: () => _showEditResultDialog(
                                candidate,
                                record,
                                app,
                              ),
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Edit Grade',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 180,
                              child: _academicStatusDropdown(
                                app,
                                candidate,
                                record,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            foregroundColor: color,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: RuslColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterChip({
    required String key,
    required String label,
    required String count,
  }) {
    final isSel = _academicSemesterFilter == key;
    return ChoiceChip(
      selected: isSel,
      onSelected: (_) => setState(() => _academicSemesterFilter = key),
      selectedColor: RuslColors.primaryMaroon,
      backgroundColor: Colors.white,
      label: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isSel ? Colors.white : RuslColors.darkText,
        ),
      ),
    );
  }

  List<AcademicCourseRecord> _getRecordsForCandidate(
    AppService app,
    _ArCandidate candidate,
  ) {
    if (candidate.regNumber == 'ICT/2021/045') {
      return app.academicRecords;
    }
    return _candidateRecordsCache.putIfAbsent(
      candidate.id,
      () => _generateCandidateRecords(candidate),
    );
  }

  List<AcademicCourseRecord> _generateCandidateRecords(_ArCandidate candidate) {
    if (candidate.department.contains('Electrical') ||
        candidate.regNumber.startsWith('EET')) {
      return [
        AcademicCourseRecord(
          id: 'eet_101_${candidate.id}',
          courseCode: 'ENT 1101',
          courseTitle: 'Engineering Mathematics I',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 3,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'eet_102_${candidate.id}',
          courseCode: 'ENT 1102',
          courseTitle: 'Fundamentals of Electrical Engineering',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 3,
          grade: 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'eet_103_${candidate.id}',
          courseCode: 'ENT 1103',
          courseTitle: 'Engineering Mechanics',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: 'B',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'eet_104_${candidate.id}',
          courseCode: 'ENG 1101',
          courseTitle: 'Technical English I',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'eet_105_${candidate.id}',
          courseCode: 'ENT 1201',
          courseTitle: 'Analog Electronics',
          academicYear: '2022/2023',
          level: 1,
          semester: 2,
          credits: 3,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 10, 20),
        ),
        AcademicCourseRecord(
          id: 'eet_106_${candidate.id}',
          courseCode: 'ENT 1202',
          courseTitle: 'Circuit Analysis',
          academicYear: '2022/2023',
          level: 1,
          semester: 2,
          credits: 3,
          grade: 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 10, 20),
        ),
        AcademicCourseRecord(
          id: 'eet_201_${candidate.id}',
          courseCode: 'ENT 2101',
          courseTitle: 'Digital Systems & Microprocessors',
          academicYear: '2023/2024',
          level: 2,
          semester: 1,
          credits: 3,
          grade: 'B',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 4, 20),
        ),
        AcademicCourseRecord(
          id: 'eet_202_${candidate.id}',
          courseCode: 'ENT 2102',
          courseTitle: 'Signals and Systems',
          academicYear: '2023/2024',
          level: 2,
          semester: 1,
          credits: 3,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 4, 20),
        ),
        AcademicCourseRecord(
          id: 'eet_203_${candidate.id}',
          courseCode: 'ENT 2201',
          courseTitle: 'Power Systems & Electrical Machines',
          academicYear: '2023/2024',
          level: 2,
          semester: 2,
          credits: 3,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 10, 18),
        ),
      ];
    } else if (candidate.department.contains('Bio') ||
        candidate.regNumber.startsWith('BST')) {
      return [
        AcademicCourseRecord(
          id: 'bst_101_${candidate.id}',
          courseCode: 'BST 1101',
          courseTitle: 'Introduction to Bio-Process Technology',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 3,
          grade: 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'bst_102_${candidate.id}',
          courseCode: 'BST 1102',
          courseTitle: 'Microbiology for Technology',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 3,
          grade: 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'bst_103_${candidate.id}',
          courseCode: 'BST 1103',
          courseTitle: 'General Chemistry for Technology',
          academicYear: '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'bst_104_${candidate.id}',
          courseCode: 'BST 1201',
          courseTitle: 'Biochemistry & Molecular Biology',
          academicYear: '2022/2023',
          level: 1,
          semester: 2,
          credits: 3,
          grade: 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 10, 20),
        ),
        AcademicCourseRecord(
          id: 'bst_201_${candidate.id}',
          courseCode: 'BST 2101',
          courseTitle: 'Fermentation Technology',
          academicYear: '2023/2024',
          level: 2,
          semester: 1,
          credits: 3,
          grade: 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 4, 20),
        ),
        AcademicCourseRecord(
          id: 'bst_202_${candidate.id}',
          courseCode: 'BST 2201',
          courseTitle: 'Enzyme Technology',
          academicYear: '2023/2024',
          level: 2,
          semester: 2,
          credits: 3,
          grade: 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 10, 18),
        ),
      ];
    } else {
      final isAnuki = candidate.regNumber == 'ICT/2020/003';
      return [
        AcademicCourseRecord(
          id: 'ict_101_${candidate.id}',
          courseCode: 'ICT 1101',
          courseTitle: 'Introduction to Information Technology',
          academicYear: isAnuki ? '2021/2022' : '2022/2023',
          level: 1,
          semester: 1,
          credits: 1,
          grade: isAnuki ? 'C+' : 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'ict_102_${candidate.id}',
          courseCode: 'ICT 1201',
          courseTitle: 'Programming Fundamentals',
          academicYear: isAnuki ? '2021/2022' : '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: isAnuki ? 'C' : 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'ict_103_${candidate.id}',
          courseCode: 'ICT 1202',
          courseTitle: 'Computer Systems and Organization',
          academicYear: isAnuki ? '2021/2022' : '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: isAnuki ? 'B-' : 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'ict_104_${candidate.id}',
          courseCode: 'CMT 1201',
          courseTitle: 'Communication Skills I',
          academicYear: isAnuki ? '2021/2022' : '2022/2023',
          level: 1,
          semester: 1,
          credits: 2,
          grade: isAnuki ? 'C+' : 'B+',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 4, 15),
        ),
        AcademicCourseRecord(
          id: 'ict_105_${candidate.id}',
          courseCode: 'ICT 1302',
          courseTitle: 'Database Management Systems',
          academicYear: isAnuki ? '2021/2022' : '2022/2023',
          level: 1,
          semester: 2,
          credits: 3,
          grade: isAnuki ? 'C' : 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2023, 10, 20),
        ),
        AcademicCourseRecord(
          id: 'ict_201_${candidate.id}',
          courseCode: 'ICT 2203',
          courseTitle: 'Object Oriented Programming',
          academicYear: isAnuki ? '2022/2023' : '2023/2024',
          level: 2,
          semester: 1,
          credits: 3,
          grade: isAnuki ? 'D+' : 'A',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 4, 20),
        ),
        AcademicCourseRecord(
          id: 'ict_202_${candidate.id}',
          courseCode: 'ICT 2204',
          courseTitle: 'Data Structures and Algorithms',
          academicYear: isAnuki ? '2022/2023' : '2023/2024',
          level: 2,
          semester: 2,
          credits: 3,
          grade: isAnuki ? 'C+' : 'A-',
          status: AcademicRecordStatus.completed,
          updatedAt: DateTime(2024, 10, 18),
        ),
        if (isAnuki)
          AcademicCourseRecord(
            id: 'ict_301_${candidate.id}',
            courseCode: 'ICT 3201',
            courseTitle: 'Software Project Management',
            academicYear: '2024/2025',
            level: 3,
            semester: 1,
            credits: 2,
            grade: null,
            status: AcademicRecordStatus.medical,
            updatedAt: DateTime(2025, 4, 25),
          ),
      ];
    }
  }

  Widget _buildGradePill(String grade) {
    final g = grade.toUpperCase().trim();
    final point = UniversityGradingSystem.gradeToPoint(g);
    final color = switch (g) {
      'A+' || 'A' || 'A-' => RuslColors.successGreen,
      'B+' || 'B' || 'B-' => const Color(0xFF2563EB),
      'C+' || 'C' => const Color(0xFF0D9488),
      'C-' || 'D+' || 'D' || 'D-' => RuslColors.warningOrange,
      'E' || 'F' => RuslColors.errorRed,
      'MC' => const Color(0xFF7C3AED),
      _ => RuslColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$g (${point.toStringAsFixed(1)} GP)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _academicRecordDetails(AcademicCourseRecord record) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${record.courseCode} - ${record.courseTitle}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (record.isDropped)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: RuslColors.errorRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Cannot Re-register',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: RuslColors.errorRed,
                ),
              ),
            )
          else if (record.canRegisterAgain)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: RuslColors.warningOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Eligible to Re-register',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: RuslColors.warningOrange,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${record.academicYear} • ${record.semesterLabel} • ${record.credits} credits',
            style: const TextStyle(
              fontSize: 11,
              color: RuslColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (record.grade != null) _buildGradePill(record.grade!),
          Text(
            '• ${record.repeatEligibilityLabel}',
            style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
          ),
        ],
      ),
    ],
  );

  Widget _academicStatusDropdown(
    AppService app,
    _ArCandidate candidate,
    AcademicCourseRecord record,
  ) => DropdownButtonFormField<AcademicRecordStatus>(
    initialValue: record.status,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'Official status',
      isDense: true,
    ),
    items: AcademicRecordStatus.values
        .map(
          (status) =>
              DropdownMenuItem(value: status, child: Text(status.label)),
        )
        .toList(),
    onChanged: (status) {
      if (status != null && status != record.status) {
        _confirmAcademicRecordChange(app, candidate, record, status);
      }
    },
  );

  Future<void> _confirmAcademicRecordChange(
    AppService app,
    _ArCandidate candidate,
    AcademicCourseRecord record,
    AcademicRecordStatus status,
  ) async {
    final regulationNote = status == AcademicRecordStatus.dropped
        ? '\n\n⚠️ REGULATION WARNING: If a subject is marked as Dropped, faculty regulations prohibit the student from ever registering for it again.'
        : '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm official record change'),
        content: Text(
          'Change ${record.courseCode} for ${candidate.name} (${candidate.regNumber}) from ${record.status.label} to ${status.label}? This action will be recorded in the official registry audit log.$regulationNote',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm change'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    bool updated = false;
    if (candidate.regNumber == 'ICT/2021/045') {
      updated = app.updateAcademicRecordStatus(record.id, status);
    } else {
      record.status = status;
      record.updatedAt = DateTime.now();
      updated = true;
      _auditLog.insert(
        0,
        _RegistryAuditEvent(
          id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
          action: 'ACADEMIC_RECORD_STATUS_UPDATED',
          target:
              '${candidate.regNumber} — ${record.courseCode} -> ${status.label}',
          officer: 'Ms. K. H. Gaurika Kahawala (AR)',
          timestamp: DateTime.now().toString().substring(0, 16),
          status: 'COMPLETED',
        ),
      );
      setState(() {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated
              ? '${record.courseCode} for ${candidate.name} updated to ${status.label}.'
              : 'Academic record could not be updated.',
        ),
        backgroundColor: updated
            ? RuslColors.successGreen
            : RuslColors.errorRed,
      ),
    );
  }

  double _calculateCandidateGpa(List<AcademicCourseRecord> records) {
    final completed = records.where(
      (r) => r.status == AcademicRecordStatus.completed && r.grade != null,
    );
    if (completed.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final r in completed) {
      final point = UniversityGradingSystem.gradeToPoint(r.grade!);
      totalPoints += point * r.credits;
      totalCredits += r.credits;
    }
    return totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  }

  void _showInsertResultDialog(_ArCandidate candidate, AppService app) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 560.0;

    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    String selectedYear = '2024/2025';
    int selectedLevel = candidate.level;
    int selectedSemester = candidate.semester;
    int selectedCredits = 3;
    String selectedGrade = 'A';
    AcademicRecordStatus selectedStatus = AcademicRecordStatus.completed;

    // Filter courses relevant to candidate department
    final relevantCourses = app.courses.where((c) {
      if (candidate.department.contains('Information')) {
        return c.departmentId.contains('ICT') || c.departmentId.contains('Information');
      } else if (candidate.department.contains('Engineering')) {
        return c.departmentId.contains('ENT') || c.departmentId.contains('Engineering') || c.departmentId.contains('Electrical');
      } else {
        return c.departmentId.contains('BST') || c.departmentId.contains('Bio');
      }
    }).toList();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final isFail = UniversityGradingSystem.isFail(selectedGrade);
          final isRepeat = UniversityGradingSystem.isRepeat(selectedGrade);
          final isPass = UniversityGradingSystem.isPass(selectedGrade);
          final isMedical = selectedGrade == 'MC';
          final isPending = selectedGrade == 'Pending';
          final gradePoint = (isPending || isMedical)
              ? 0.0
              : UniversityGradingSystem.gradeToPoint(selectedGrade);
          final gradePointsTotal = selectedCredits * gradePoint;

          // Projected CGPA calculation
          final currentRecords = _getRecordsForCandidate(app, candidate);
          double totalPoints = 0;
          int totalCredits = 0;
          for (final r in currentRecords) {
            if (r.status == AcademicRecordStatus.completed && r.grade != null) {
              totalPoints +=
                  UniversityGradingSystem.gradeToPoint(r.grade!) * r.credits;
              totalCredits += r.credits;
            }
          }
          if (selectedStatus == AcademicRecordStatus.completed &&
              !isPending &&
              !isMedical) {
            totalPoints += gradePointsTotal;
            totalCredits += selectedCredits;
          }
          final projectedCgpa = totalCredits > 0
              ? (totalPoints / totalCredits)
              : candidate.gpa;

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            actionsOverflowDirection: VerticalDirection.down,
            actionsOverflowButtonSpacing: 8,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: RuslColors.primaryMaroon.withValues(alpha: 0.12),
                  foregroundColor: RuslColors.primaryMaroon,
                  child: const Icon(Icons.post_add_rounded, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insert Examination Result',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        '${candidate.name} (${candidate.regNumber})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: RuslColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: dialogWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (relevantCourses.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Quick Select from Faculty Syllabus',
                          labelStyle: const TextStyle(fontSize: 12),
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text(
                              '-- Or enter custom subject code & title below --',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...relevantCourses.map(
                            (c) => DropdownMenuItem(
                              value: c.code,
                              child: Text(
                                '${c.code} - ${c.title} (${c.creditValue} Cr)',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null && val.isNotEmpty) {
                            final matched = relevantCourses.firstWhere((c) => c.code == val);
                            setDialogState(() {
                              codeCtrl.text = matched.code;
                              titleCtrl.text = matched.title;
                              selectedCredits = matched.creditValue;
                              selectedLevel = matched.level;
                              selectedSemester = matched.semester;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: codeCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Course Code *',
                              hintText: 'e.g. ICT 2201',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: titleCtrl,
                            decoration: InputDecoration(
                              labelText: 'Course Title *',
                              hintText: 'e.g. Database Systems',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Academic Year',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: '2021/2022', child: Text('2021/2022', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: '2022/2023', child: Text('2022/2023', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: '2023/2024', child: Text('2023/2024', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: '2024/2025', child: Text('2024/2025', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: '2025/2026', child: Text('2025/2026', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) => setDialogState(() => selectedYear = v ?? selectedYear),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedLevel,
                            decoration: InputDecoration(
                              labelText: 'Level',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [1, 2, 3, 4]
                                .map((lvl) => DropdownMenuItem(value: lvl, child: Text('Level $lvl', style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setDialogState(() => selectedLevel = v ?? selectedLevel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedSemester,
                            decoration: InputDecoration(
                              labelText: 'Semester',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [1, 2]
                                .map((sem) => DropdownMenuItem(value: sem, child: Text('Sem $sem', style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setDialogState(() => selectedSemester = v ?? selectedSemester),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedCredits,
                            decoration: InputDecoration(
                              labelText: 'Credits',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [1, 2, 3, 4, 6]
                                .map((cr) => DropdownMenuItem(value: cr, child: Text('$cr Cr', style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setDialogState(() => selectedCredits = v ?? selectedCredits),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedGrade,
                            decoration: InputDecoration(
                              labelText: 'Official RUSL Grade *',
                              filled: true,
                              fillColor: RuslColors.cardSubtle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'A+', child: Text('A+ (4.00 GP - High Distinction)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'A', child: Text('A  (4.00 GP - Distinction)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'A-', child: Text('A- (3.70 GP - Excellent)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'B+', child: Text('B+ (3.30 GP - Very Good)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'B', child: Text('B  (3.00 GP - Good)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'B-', child: Text('B- (2.70 GP - Satisfactory)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'C+', child: Text('C+ (2.30 GP - Fair)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'C', child: Text('C  (2.00 GP - Pass)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'C-', child: Text('C- (1.70 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'D+', child: Text('D+ (1.30 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'D', child: Text('D  (1.00 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'E', child: Text('E  (0.00 GP - Fail / Repeat Required)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'F', child: Text('F  (0.00 GP - Fail / Repeat Required)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'MC', child: Text('MC (Medical / Incomplete)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Pending', child: Text('Pending (Result Withheld)', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() {
                                  selectedGrade = v;
                                  if (v == 'MC') {
                                    selectedStatus = AcademicRecordStatus.medical;
                                  } else {
                                    selectedStatus = AcademicRecordStatus.completed;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<AcademicRecordStatus>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Record Status',
                        filled: true,
                        fillColor: RuslColors.cardSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: AcademicRecordStatus.values
                          .map((st) => DropdownMenuItem(value: st, child: Text(st.label, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedStatus = v ?? selectedStatus),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPass
                            ? RuslColors.successGreen.withValues(alpha: 0.08)
                            : isRepeat
                            ? RuslColors.warningOrange.withValues(alpha: 0.08)
                            : isFail
                            ? RuslColors.errorRed.withValues(alpha: 0.08)
                            : RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPass
                              ? RuslColors.successGreen.withValues(alpha: 0.3)
                              : isRepeat
                              ? RuslColors.warningOrange.withValues(alpha: 0.3)
                              : isFail
                              ? RuslColors.errorRed.withValues(alpha: 0.3)
                              : RuslColors.borderGrey,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Grade Point: ${gradePoint.toStringAsFixed(2)} × $selectedCredits Cr = ${gradePointsTotal.toStringAsFixed(2)} GP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPass
                                      ? RuslColors.successGreen
                                      : isRepeat
                                      ? RuslColors.warningOrange
                                      : isFail
                                      ? RuslColors.errorRed
                                      : RuslColors.textMuted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isPass ? 'PASS' : isRepeat ? 'REPEAT ELIGIBLE' : isFail ? 'FAIL' : selectedGrade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Current CGPA: ${candidate.gpa.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: RuslColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.arrow_right_alt_rounded, size: 16, color: RuslColors.textMuted),
                              Text(
                                'Projected CGPA: ${projectedCgpa.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: projectedCgpa >= candidate.gpa
                                      ? RuslColors.successGreen
                                      : RuslColors.errorRed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${DegreeClassStanding.fromGpa(projectedCgpa).label})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: RuslColors.textMuted,
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  final code = codeCtrl.text.trim();
                  final title = titleCtrl.text.trim();
                  if (code.isEmpty || title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter both course code and title.'),
                        backgroundColor: RuslColors.errorRed,
                      ),
                    );
                    return;
                  }

                  final gradeToSave = (selectedGrade == 'Pending' || selectedGrade == 'MC')
                      ? null
                      : selectedGrade;
                  final statusToSave = selectedGrade == 'MC'
                      ? AcademicRecordStatus.medical
                      : selectedStatus;

                  if (candidate.regNumber == 'ICT/2021/045') {
                    app.insertAcademicCourseRecord(
                      courseCode: code,
                      courseTitle: title,
                      academicYear: selectedYear,
                      level: selectedLevel,
                      semester: selectedSemester,
                      credits: selectedCredits,
                      grade: gradeToSave,
                      status: statusToSave,
                      studentRegNumber: candidate.regNumber,
                    );
                    candidate.gpa = app.currentCgpa;
                    candidate.credits = app.academicRecords
                        .where((r) => r.status == AcademicRecordStatus.completed)
                        .fold(0, (sum, r) => sum + r.credits);
                  } else {
                    final list = _getRecordsForCandidate(app, candidate);
                    final existingIdx = list.indexWhere(
                      (r) =>
                          r.courseCode.replaceAll(' ', '').toUpperCase() ==
                          code.replaceAll(' ', '').toUpperCase(),
                    );
                    if (existingIdx != -1) {
                      list[existingIdx] = AcademicCourseRecord(
                        id: list[existingIdx].id,
                        courseCode: code,
                        courseTitle: title,
                        academicYear: selectedYear,
                        level: selectedLevel,
                        semester: selectedSemester,
                        credits: selectedCredits,
                        grade: gradeToSave,
                        status: statusToSave,
                        updatedAt: DateTime.now(),
                      );
                    } else {
                      list.add(
                        AcademicCourseRecord(
                          id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                          courseCode: code,
                          courseTitle: title,
                          academicYear: selectedYear,
                          level: selectedLevel,
                          semester: selectedSemester,
                          credits: selectedCredits,
                          grade: gradeToSave,
                          status: statusToSave,
                          updatedAt: DateTime.now(),
                        ),
                      );
                    }
                    candidate.gpa = _calculateCandidateGpa(list);
                    candidate.credits = list
                        .where((r) => r.status == AcademicRecordStatus.completed)
                        .fold(0, (sum, r) => sum + r.credits);

                    _auditLog.insert(
                      0,
                      _RegistryAuditEvent(
                        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
                        action: 'EXAM_RESULT_PUBLISHED',
                        target:
                            '${candidate.regNumber} — $code: $selectedGrade ($selectedCredits Cr)',
                        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
                        timestamp: DateTime.now().toString().substring(0, 16),
                        status: 'COMPLETED',
                      ),
                    );
                  }

                  setState(() {});
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Result recorded successfully for $code ($selectedGrade) — ${candidate.name}.',
                      ),
                      backgroundColor: RuslColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: const Text('Record & Publish Result'),
                style: FilledButton.styleFrom(backgroundColor: RuslColors.primaryMaroon),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditResultDialog(
    _ArCandidate candidate,
    AcademicCourseRecord record,
    AppService app,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 480.0;

    String selectedGrade = record.grade ?? 'Pending';
    AcademicRecordStatus selectedStatus = record.status;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final isFail = UniversityGradingSystem.isFail(selectedGrade);
          final isRepeat = UniversityGradingSystem.isRepeat(selectedGrade);
          final isPass = UniversityGradingSystem.isPass(selectedGrade);
          final isMedical = selectedGrade == 'MC';
          final isPending = selectedGrade == 'Pending';
          final gradePoint = (isPending || isMedical)
              ? 0.0
              : UniversityGradingSystem.gradeToPoint(selectedGrade);

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            actionsOverflowDirection: VerticalDirection.down,
            actionsOverflowButtonSpacing: 8,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: RuslColors.primaryMaroon.withValues(alpha: 0.12),
                  foregroundColor: RuslColors.primaryMaroon,
                  child: const Icon(Icons.edit_note_rounded, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Subject Grade & Outcome',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        '${record.courseCode} • ${candidate.name} (${candidate.regNumber})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: RuslColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: dialogWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: RuslColors.borderGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.courseTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${record.academicYear} • Level ${record.level} Sem ${record.semester} • ${record.credits} Credits',
                            style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Grade: ${record.grade ?? "No Grade"} (${record.status.label})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGrade,
                      decoration: InputDecoration(
                        labelText: 'New Official Grade *',
                        filled: true,
                        fillColor: RuslColors.cardSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A+', child: Text('A+ (4.00 GP - High Distinction)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'A', child: Text('A  (4.00 GP - Distinction)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'A-', child: Text('A- (3.70 GP - Excellent)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'B+', child: Text('B+ (3.30 GP - Very Good)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'B', child: Text('B  (3.00 GP - Good)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'B-', child: Text('B- (2.70 GP - Satisfactory)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'C+', child: Text('C+ (2.30 GP - Fair)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'C', child: Text('C  (2.00 GP - Pass)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'C-', child: Text('C- (1.70 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'D+', child: Text('D+ (1.30 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'D', child: Text('D  (1.00 GP - Repeat Eligible)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'E', child: Text('E  (0.00 GP - Fail / Repeat Required)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'F', child: Text('F  (0.00 GP - Fail / Repeat Required)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'MC', child: Text('MC (Medical / Incomplete)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending (Result Withheld)', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedGrade = v;
                            if (v == 'MC') {
                              selectedStatus = AcademicRecordStatus.medical;
                            } else {
                              selectedStatus = AcademicRecordStatus.completed;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AcademicRecordStatus>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Record Status',
                        filled: true,
                        fillColor: RuslColors.cardSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: AcademicRecordStatus.values
                          .map((st) => DropdownMenuItem(value: st, child: Text(st.label, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedStatus = v ?? selectedStatus),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPass
                            ? RuslColors.successGreen.withValues(alpha: 0.08)
                            : isRepeat
                            ? RuslColors.warningOrange.withValues(alpha: 0.08)
                            : isFail
                            ? RuslColors.errorRed.withValues(alpha: 0.08)
                            : RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPass ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 16,
                            color: isPass ? RuslColors.successGreen : RuslColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Grade Points: ${gradePoint.toStringAsFixed(2)} • Classification will recalculate upon confirmation.',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  final newGradeVal = selectedGrade == 'Pending' ? null : selectedGrade;

                  if (candidate.regNumber == 'ICT/2021/045') {
                    app.updateAcademicRecordGrade(
                      recordId: record.id,
                      newGrade: newGradeVal ?? '',
                      newStatus: selectedStatus,
                    );
                    candidate.gpa = app.currentCgpa;
                    candidate.credits = app.academicRecords
                        .where((r) => r.status == AcademicRecordStatus.completed)
                        .fold(0, (sum, r) => sum + r.credits);
                  } else {
                    record.grade = newGradeVal;
                    record.status = selectedStatus;
                    record.updatedAt = DateTime.now();
                    final list = _getRecordsForCandidate(app, candidate);
                    candidate.gpa = _calculateCandidateGpa(list);
                    candidate.credits = list
                        .where((r) => r.status == AcademicRecordStatus.completed)
                        .fold(0, (sum, r) => sum + r.credits);

                    _auditLog.insert(
                      0,
                      _RegistryAuditEvent(
                        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
                        action: 'EXAM_GRADE_MODIFIED',
                        target:
                            '${candidate.regNumber} — ${record.courseCode} -> $selectedGrade (${selectedStatus.label})',
                        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
                        timestamp: DateTime.now().toString().substring(0, 16),
                        status: 'COMPLETED',
                      ),
                    );
                  }

                  setState(() {});
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Grade for ${record.courseCode} updated to $selectedGrade (${candidate.name}).',
                      ),
                      backgroundColor: RuslColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Grade Change'),
                style: FilledButton.styleFrom(backgroundColor: RuslColors.primaryMaroon),
              ),
            ],
          );
        },
      ),
    );
  }

  void _exportCandidateTranscript(_ArCandidate candidate) {
    final app = Provider.of<AppService>(context, listen: false);
    final records = _getRecordsForCandidate(app, candidate);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 580.0;

    final standing = DegreeClassStanding.fromGpa(candidate.gpa);

    _auditLog.insert(
      0,
      _RegistryAuditEvent(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        action: 'OFFICIAL_TRANSCRIPT_EXPORTED',
        target:
            '${candidate.regNumber} — ${candidate.name} (CGPA: ${candidate.gpa.toStringAsFixed(2)})',
        officer: 'Ms. K. H. Gaurika Kahawala (AR)',
        timestamp: DateTime.now().toString().substring(0, 16),
        status: 'COMPLETED',
      ),
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: RuslColors.accentYellow,
              foregroundColor: RuslColors.darkText,
              child: Icon(Icons.picture_as_pdf_rounded, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Official Academic Transcript',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    'Rajarata University of Sri Lanka • Examination Division',
                    style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              candidate.name,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: RuslColors.primaryMaroon,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OFFICIAL COPY',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reg No: ${candidate.regNumber} • Index: ${candidate.examIndexNumber}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${candidate.degreeProgram} • ${candidate.department}',
                        style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cumulative GPA', style: TextStyle(fontSize: 10, color: RuslColors.textMuted)),
                              Text(
                                candidate.gpa.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: RuslColors.primaryMaroon),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Earned Credits', style: TextStyle(fontSize: 10, color: RuslColors.textMuted)),
                              Text(
                                '${candidate.credits} Cr',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Standing / Honours', style: TextStyle(fontSize: 10, color: RuslColors.textMuted)),
                              Text(
                                standing.label,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: RuslColors.successGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Academic Module Results Summary:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final r = records[idx];
                      final gradeColor = UniversityGradingSystem.isPass(r.grade)
                          ? RuslColors.successGreen
                          : UniversityGradingSystem.isRepeat(r.grade)
                          ? RuslColors.warningOrange
                          : RuslColors.errorRed;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                r.courseCode,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                r.courseTitle,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${r.credits} Cr',
                              style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 32,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: (r.grade != null ? gradeColor : RuslColors.textMuted).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.grade ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: r.grade != null ? gradeColor : RuslColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              final buf = StringBuffer();
              buf.writeln('RAJARATA UNIVERSITY OF SRI LANKA - ACADEMIC TRANSCRIPT');
              buf.writeln('Candidate: ${candidate.name} (${candidate.regNumber})');
              buf.writeln('Degree: ${candidate.degreeProgram}');
              buf.writeln('CGPA: ${candidate.gpa.toStringAsFixed(2)} | Credits: ${candidate.credits} | Class: ${standing.fullName}');
              buf.writeln('--------------------------------------------------');
              for (final r in records) {
                buf.writeln('${r.courseCode} - ${r.courseTitle} | ${r.credits} Cr | Grade: ${r.grade ?? "Pending"} (${r.status.label})');
              }
              Clipboard.setData(ClipboardData(text: buf.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Academic transcript text copied to clipboard!'),
                  backgroundColor: RuslColors.primaryMaroon,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Transcript'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Official academic transcript for ${candidate.name} generated & sent to print queue.',
                  ),
                  backgroundColor: RuslColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Print Transcript'),
            style: FilledButton.styleFrom(backgroundColor: RuslColors.primaryMaroon),
          ),
        ],
      ),
    );
  }

  Widget _buildArProfile(AppService app, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isMobile ? 28 : 36,
                backgroundColor: RuslColors.accentYellow,
                child: Text(
                  'DR',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: RuslColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ms. K. H. Gaurika Kahawala',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Assistant Registrar • Faculty of Technology',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: RuslColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Dean\'s Office, Faculty of Technology, RUSL, Mihintale',
                      style: TextStyle(
                        fontSize: 11,
                        color: RuslColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: const [
                        _OfficerBadge('EMP-0010'),
                        _OfficerBadge('RUSL-SEAL-FOT-8831'),
                        _OfficerBadge('Scope: FOT (ICT, ET, BST)'),
                        _OfficerBadge('Signing Key: ACTIVE'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Registry Audit Trail
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assistant Registrar Statutory Audit Ledger',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w900,
                  color: RuslColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cryptographic ledger of all registration seals, locks, and exports affixed by the Assistant Registrar.',
                style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 12),
              ..._auditLog.map(
                (aud) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 16,
                        color: RuslColors.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${aud.action}: ${aud.target}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${aud.officer} • ${aud.timestamp}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RuslColors.cardSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          aud.status,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE DIALOGS (Responsive)
  // ---------------------------------------------------------------------------
  void _showSealDialog(_ArCandidate c, AppService app, bool isMobile) {
    final commentsCtrl = TextEditingController(
      text: 'Verified against university exam criteria. Officially sealed.',
    );
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 520.0;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: RuslColors.accentYellow,
              child: Icon(
                Icons.verified_rounded,
                size: 16,
                color: RuslColors.darkText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Affix Official Registrar Seal',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  Text(
                    '${c.name} (${c.regNumber})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: RuslColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compliance Checklist
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Examination Clearance Checklist:',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildCheckRow(
                        'Minimum Credit Threshold (>= 12 Credits)',
                        c.credits >= 12,
                      ),
                      _buildCheckRow(
                        'Department HoD Endorsement Cleared (${c.hodEndorsedBy})',
                        true,
                      ),
                      _buildCheckRow(
                        'Timetable and examination eligibility validated',
                        true,
                      ),
                      _buildCheckRow(
                        'Tuition & Examination Fee Cleared',
                        c.feesCleared,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Official Registrar Seal Remarks:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: commentsCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText:
                        'Enter remarks to print on official registration record...',
                    filled: true,
                    fillColor: RuslColors.lightGreyBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                c.status = 'Changes Requested';
              });
              if (c.regNumber == 'ICT/2021/045') {
                app.arReturnWithRegistryQuery(commentsCtrl.text);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Registry query raised for ${c.name}. Application returned.',
                  ),
                ),
              );
            },
            child: const Text('Raise Query'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                c.status = 'Officially Sealed';
                c.sealDate = '2026-10-08 12:00';
                c.arRemarks = commentsCtrl.text;
                _auditLog.insert(
                  0,
                  _RegistryAuditEvent(
                    id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
                    action: 'FACULTY_SEAL_AFFIXED',
                    target: '${c.regNumber} — ${c.name}',
                    officer: 'Ms. K. H. Gaurika Kahawala (AR)',
                    timestamp: 'Today',
                    status: 'COMPLETED',
                  ),
                );
              });
              if (c.regNumber == 'ICT/2021/045') {
                app.approveAndSealByAr(commentsCtrl.text);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Registration officially sealed for ${c.name}!',
                  ),
                  backgroundColor: RuslColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.verified_rounded, size: 14),
            label: const Text('Affix Seal'),
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _showCandidateDetails(_ArCandidate c, AppService app, bool isMobile) {
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 480.0;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: RuslColors.cardSubtle,
              child: Icon(
                Icons.school_rounded,
                size: 16,
                color: RuslColors.darkText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${c.regNumber} • ${c.degreeProgram}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: RuslColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exam Index: ${c.examIndexNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'CGPA: ${c.gpa.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Registered Course Modules:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                const SizedBox(height: 4),
                ...c.enrolledCourses.map(
                  (m) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: RuslColors.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(m, style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Exam Ticket Eligible:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Switch(
                      value: c.examEligible,
                      onChanged: (val) {
                        setState(() => c.examEligible = val);
                        Navigator.pop(ctx);
                        _showCandidateDetails(c, app, isMobile);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedAcademicCandidate = c;
                _academicSemesterFilter = 'all';
                _section = 6;
              });
            },
            icon: const Icon(Icons.history_edu_rounded, size: 16),
            label: const Text('Academic Record'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showInsertResultDialog(c, app);
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
            label: const Text('Insert Result'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _printCandidateSlip(c, app);
            },
            icon: const Icon(Icons.print_rounded, size: 14),
            label: const Text('Print Slip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RuslColors.accentYellow,
              foregroundColor: RuslColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  void _bulkSealConfirm(AppService app) {
    final pendingList = _candidates
        .where((c) => c.status == 'Faculty Approved')
        .toList();
    if (pendingList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pending candidates to seal at this time.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Bulk Seal Candidates',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text(
          'Affix official seal to all ${pendingList.length} compliant candidates awaiting verification?',
          style: const TextStyle(fontSize: 13),
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
                for (var c in pendingList) {
                  c.status = 'Officially Sealed';
                  c.sealDate = '2026-10-08 12:00';
                  c.arRemarks =
                      'Bulk sealed by Assistant Registrar for examination compliance.';
                }
              });
              app.arBulkSealEligibleRegistrations();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully affixed official seal to ${pendingList.length} candidates!',
                  ),
                  backgroundColor: RuslColors.successGreen,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: RuslColors.successGreen,
            ),
            child: Text('Confirm (${pendingList.length})'),
          ),
        ],
      ),
    );
  }

  void _printCandidateSlip(_ArCandidate c, AppService app) {
    final student = StudentProfile(
      id: c.id,
      userId: 'u_${c.id}',
      registrationNumber: c.regNumber,
      fullName: c.name,
      facultyName: 'Faculty of Technology',
      departmentName: c.department,
      programmeName: c.degreeProgram,
      curriculumVersion: '2024 Version 2.1',
      currentLevel: c.level,
      currentSemester: c.semester,
      minAllowedCredits: 12,
      maxAllowedCredits: 24,
      completedCourseIds: const [],
      failedCourseIds: const [],
    );

    final courses = _registeredCoursesForCandidate(c, app.courses);
    final printedCredits = courses.fold<int>(
      0,
      (total, course) => total + course.creditValue,
    );
    final isOfficial = c.status == 'Officially Sealed';

    PdfSlipGenerator.downloadOrPrintPdf(
      student: student,
      registeredCourses: courses,
      totalCredits: printedCredits,
      academicYear: '2025/2026',
      semesterNumber: c.semester,
      verificationCode: c.verificationToken,
      status: c.status.toUpperCase(),
      documentTitle: isOfficial
          ? 'OFFICIAL COURSE REGISTRATION RECORD'
          : 'COURSE REGISTRATION REVIEW COPY',
    );
  }

  List<Course> _registeredCoursesForCandidate(
    _ArCandidate candidate,
    List<Course> catalogue,
  ) {
    return candidate.enrolledCourses.map((line) {
      final codeMatch = RegExp(r'^[A-Z]{2,4}\s+\d{4}').firstMatch(line);
      final creditMatch = RegExp(
        r'(\d+)\s*Cr',
        caseSensitive: false,
      ).firstMatch(line);
      final code = codeMatch?.group(0) ?? 'N/A';
      final catalogueMatch = catalogue.where((course) => course.code == code);
      if (catalogueMatch.isNotEmpty) return catalogueMatch.first;

      var title = line.substring(codeMatch?.end ?? 0).trim();
      title = title.replaceFirst(RegExp(r'^[^A-Za-z0-9]+'), '');
      final detailsStart = title.lastIndexOf('(');
      if (detailsStart > 0) title = title.substring(0, detailsStart).trim();
      final credits = int.tryParse(creditMatch?.group(1) ?? '') ?? 0;
      final elective = line.toLowerCase().contains('elective');
      return Course(
        id: 'print_${candidate.id}_$code',
        code: code,
        title: title,
        description: '',
        creditValue: credits,
        level: candidate.level,
        semester: candidate.semester,
        departmentId: candidate.department,
        courseType: elective ? CourseType.elective : CourseType.compulsory,
      );
    }).toList();
  }

  void _exportCsvDialog(bool isMobile) {
    final csvContent = StringBuffer();
    csvContent.writeln(
      'Exam Index Number,Registration Number,Candidate Name,Programme,Credits,Status,Verification Token',
    );
    for (var c in _candidates) {
      csvContent.writeln(
        '${c.examIndexNumber},${c.regNumber},"${c.name}","${c.degreeProgram}",${c.credits},${c.status},${c.verificationToken}',
      );
    }

    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : 520.0;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Export CSV for Exam Division',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generated RFC-4180 CSV register:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                height: 160,
                decoration: BoxDecoration(
                  color: RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvContent.toString(),
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent.toString()));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV copied to clipboard successfully!'),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: const Text('Copy CSV'),
          ),
        ],
      ),
    );
  }

  void _printExamHallRegister(AppService app) {
    _printCandidateSlip(_candidates.first, app);
  }

  Widget _buildCheckRow(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: passed ? RuslColors.successGreen : RuslColors.errorRed,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: passed ? RuslColors.darkText : RuslColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficerBadge extends StatelessWidget {
  final String text;
  const _OfficerBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: RuslColors.cardSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AR SIDEBAR DRAWER
// -----------------------------------------------------------------------------
class ArSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const ArSidebar({
    super.key,
    required this.selectedIndex,
    required this.userName,
    required this.onSelected,
    required this.onLogout,
  });

  static const items = [
    (Icons.dashboard_rounded, 'Registry Overview'),
    (Icons.verified_rounded, 'Official Sealing Queue'),
    (Icons.groups_rounded, 'Faculty Student Registry'),
    (Icons.fact_check_rounded, 'Exam Compliance & Lists'),
    (Icons.lock_clock_rounded, 'Registration Freeze Control'),
    (Icons.qr_code_scanner_rounded, 'Verification & Slips'),
    (Icons.history_edu_rounded, 'Academic Records'),
    (Icons.badge_rounded, 'AR Profile & Authority'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: RuslColors.accentYellow,
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RUSL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Faculty Registrar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile Card in Sidebar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RuslColors.darkText,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: RuslColors.accentYellow,
                    child: Text(
                      'AR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: RuslColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Assistant Registrar (FOT)',
                          style: TextStyle(
                            color: RuslColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Items
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final (icon, title) = entry.value;
              final isSelected = selectedIndex == index;
              return Material(
                color: isSelected
                    ? RuslColors.accentYellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    icon,
                    color: isSelected
                        ? RuslColors.darkText
                        : RuslColors.textMuted,
                    size: 18,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      color: RuslColors.darkText,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => onSelected(index),
                ),
              );
            }),

            const Divider(height: 24),
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.logout_rounded,
                color: RuslColors.errorRed,
                size: 18,
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: RuslColors.errorRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INTERNAL MODELS
// -----------------------------------------------------------------------------
class _ArCandidate {
  final String id;
  final String name;
  final String regNumber;
  final String examIndexNumber;
  final String department;
  final String degreeProgram;
  final int level;
  final int semester;
  int credits;
  double gpa;
  String status;
  final String hodEndorsedBy;
  final String coordClearedBy;
  bool examEligible;
  String verificationToken;
  List<String> enrolledCourses;
  String? sealDate;
  String? arRemarks;
  final bool isRepeatCandidate;
  final bool feesCleared;
  final String email;

  _ArCandidate({
    required this.id,
    required this.name,
    required this.regNumber,
    required this.examIndexNumber,
    required this.department,
    required this.degreeProgram,
    required this.level,
    required this.semester,
    required this.credits,
    required this.gpa,
    required this.status,
    required this.hodEndorsedBy,
    required this.coordClearedBy,
    required this.examEligible,
    required this.verificationToken,
    required this.enrolledCourses,
    this.sealDate,
    this.arRemarks,
    required this.isRepeatCandidate,
    required this.feesCleared,
    required this.email,
  });
}

class _LateExceptionRequest {
  final String id;
  final String studentName;
  final String regNumber;
  final String department;
  final String reason;
  final int penaltyFee;
  String status;
  final String submittedAt;

  _LateExceptionRequest({
    required this.id,
    required this.studentName,
    required this.regNumber,
    required this.department,
    required this.reason,
    required this.penaltyFee,
    required this.status,
    required this.submittedAt,
  });
}

class _RegistryAuditEvent {
  final String id;
  final String action;
  final String target;
  final String officer;
  final String timestamp;
  final String status;

  _RegistryAuditEvent({
    required this.id,
    required this.action,
    required this.target,
    required this.officer,
    required this.timestamp,
    required this.status,
  });
}
