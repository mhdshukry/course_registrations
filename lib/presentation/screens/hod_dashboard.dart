import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';
import '../../services/auth_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class HodDashboardScreen extends StatefulWidget {
  final int selectedSection;
  final ValueChanged<int>? onNavigate;

  const HodDashboardScreen({
    super.key,
    this.selectedSection = 0,
    this.onNavigate,
  });

  @override
  State<HodDashboardScreen> createState() => _HodDashboardScreenState();
}

class _HodDashboardScreenState extends State<HodDashboardScreen> {
  late int _currentSection;
  late final List<_HodStudentRecord> _records;
  int _selectedAcademicLevel = 0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4

  @override
  void initState() {
    super.initState();
    _currentSection = widget.selectedSection;
    _records = _makeHodStudentRecords();
  }

  @override
  void didUpdateWidget(covariant HodDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSection != oldWidget.selectedSection) {
      _currentSection = widget.selectedSection;
    }
  }

  void _switchSection(int index) {
    setState(() => _currentSection = index);
    widget.onNavigate?.call(index);
  }

  void _navigateToStudentDirectoryWithLevel(int level) {
    setState(() {
      _selectedAcademicLevel = level;
      _currentSection = 5;
    });
    widget.onNavigate?.call(5);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();

    // Synchronize record 0 (M. N. Mohamed Nafis) with active AppService state
    _records[0].status = switch (app.activeRegistrationStatus) {
      RegistrationStatus.submitted => 'Pending HoD Endorsement',
      RegistrationStatus.departmentApproved ||
      RegistrationStatus.facultyApproved ||
      RegistrationStatus.registered ||
      RegistrationStatus.locked => 'Department Endorsed',
      RegistrationStatus.changesRequested => 'Changes Requested',
      RegistrationStatus.rejected => 'Rejected',
      RegistrationStatus.draft => 'Draft',
    };
    _records[0].credits = app.totalSelectedCredits;
    _records[0].subjects = app.selectedOfferingIds.length;

    final activeView = switch (_currentSection) {
      0 => _HodOverview(
        records: _records,
        app: app,
        onNavigate: _switchSection,
        onNavigateWithLevel: _navigateToStudentDirectoryWithLevel,
        onReview: (r) => _showEndorsementDialog(r, app),
      ),
      1 => _HodEndorsementQueue(
        records: _records,
        app: app,
        onReview: (r) => _showEndorsementDialog(r, app),
      ),
      2 => _HodCourseOfferings(app: app),
      3 => _HodTimetableScheduler(app: app),
      4 => _HodSpecialRequests(app: app),
      5 => _HodStudentDirectory(
        records: _records,
        app: app,
        initialLevel: _selectedAcademicLevel,
        onLevelChanged: (lvl) => setState(() => _selectedAcademicLevel = lvl),
      ),
      6 => _HodReports(records: _records, app: app),
      _ => _HodProfile(app: app),
    };

    return Container(color: RuslColors.bgCream, child: activeView);
  }

  Future<void> _showEndorsementDialog(
    _HodStudentRecord record,
    AppService app,
  ) async {
    final commentsController = TextEditingController(
      text: record.status == 'Department Endorsed'
          ? 'Department curriculum requirements and batch enrollment verified. Endorsed.'
          : 'Department curriculum requirements and prerequisite integrity verified. Endorsed for Faculty Coordination.',
    );

    final isLiveStudent = record.index == 0;
    final List<Course> selectedCourses;

    if (isLiveStudent) {
      final selectedOfferings = app.courseOfferings
          .where((o) => app.selectedOfferingIds.contains(o.id))
          .toList();
      selectedCourses = selectedOfferings
          .map((o) => app.courses.firstWhere((c) => c.id == o.courseId))
          .toList();
    } else {
      selectedCourses = app.courses.take(record.subjects.clamp(2, 6)).toList();
    }

    final isAlreadyEndorsed =
        record.status == 'Department Endorsed' ||
        app.activeRegistrationStatus == RegistrationStatus.departmentApproved ||
        app.activeRegistrationStatus == RegistrationStatus.facultyApproved ||
        app.activeRegistrationStatus == RegistrationStatus.registered ||
        app.activeRegistrationStatus == RegistrationStatus.locked;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 640,
          constraints: const BoxConstraints(maxHeight: 740),
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: RuslColors.darkText,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: RuslColors.accentYellow,
                      child: Text(
                        record.initials,
                        style: const TextStyle(
                          color: RuslColors.darkText,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  record.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isAlreadyEndorsed
                                      ? RuslColors.successGreen
                                      : RuslColors.accentYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAlreadyEndorsed ? 'Endorsed' : 'HoD Review',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: RuslColors.darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${record.registrationNumber} • Level 3 Semester 5 • CGPA: ${record.gpa.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adviser Recommendation Stamp
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RuslColors.accentYellow.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: RuslColors.accentYellow.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: RuslColors.darkText,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Registration Submission Received',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Undergraduate student course selections verified against curriculum requirements.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: RuslColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: RuslColors.darkText,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'STAGE 2 CLEARED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Live Workflow Timeline
                      const Text(
                        'University Approval Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: RuslColors.borderGrey),
                        ),
                        child: ApprovalTimelineWidget(
                          status: isLiveStudent
                              ? app.activeRegistrationStatus
                              : (isAlreadyEndorsed
                                    ? RegistrationStatus.departmentApproved
                                    : RegistrationStatus.submitted),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Curriculum Courses
                      Text(
                        'Registered Courses (${record.subjects} Subjects • ${record.credits} Credits)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...selectedCourses.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: RuslColors.borderGrey),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: c.courseType == CourseType.compulsory
                                      ? RuslColors.darkText
                                      : RuslColors.cardSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: c.courseType == CourseType.compulsory
                                        ? Colors.white
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
                                      c.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${c.creditValue} Credits • ${c.courseType == CourseType.compulsory ? "Compulsory Core" : "Elective Option"} • Prerequisites Satisfied',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: RuslColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: RuslColors.successGreen,
                                size: 18,
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 18),

                      // HoD Endorsement Remarks Field
                      const Text(
                        'HoD Departmental Endorsement Remarks:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: commentsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Enter departmental endorsement remarks or conditions...',
                          filled: true,
                          fillColor: RuslColors.cardSubtle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: RuslColors.borderGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: RuslColors.borderGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: RuslColors.borderGrey)),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (isLiveStudent) {
                          app.requestChangesByHod(
                            commentsController.text.isEmpty
                                ? 'HoD requested student to review elective selections.'
                                : commentsController.text,
                          );
                        } else {
                          setState(() => record.status = 'Changes Requested');
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Revisions requested. Notification dispatched to student and adviser.',
                            ),
                            backgroundColor: RuslColors.warningOrange,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Request Changes'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isLiveStudent) {
                          app.approveByHod(commentsController.text);
                        } else {
                          setState(() => record.status = 'Department Endorsed');
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registration officially endorsed by Head of Department! Forwarded to Assistant Registrar.',
                            ),
                            backgroundColor: RuslColors.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.verified_user_rounded, size: 18),
                      label: const Text('Endorse Registration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RuslColors.accentYellow,
                        foregroundColor: RuslColors.darkText,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION 0: DEPARTMENT OVERVIEW (SRI LANKAN STATE UNIVERSITY MODEL)
// ============================================================================
class _HodOverview extends StatelessWidget {
  final List<_HodStudentRecord> records;
  final AppService app;
  final ValueChanged<int> onNavigate;
  final void Function(int level)? onNavigateWithLevel;
  final ValueChanged<_HodStudentRecord> onReview;

  const _HodOverview({
    required this.records,
    required this.app,
    required this.onNavigate,
    this.onNavigateWithLevel,
    required this.onReview,
  });

  Widget _buildLevelCohortCard({
    required int level,
    required String title,
    required String intake,
    required int count,
    required int endorsed,
    required String focus,
    required Color color,
    required VoidCallback onTap,
  }) {
    final double pct = count > 0 ? endorsed / count : 1.0;
    return Container(
      width: 290,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHodLevelPill(level),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count Students',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          Text(
            intake,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            focus,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: RuslColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Endorsed: $endorsed / $count',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: RuslColors.cardSubtle,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.groups_outlined, size: 14, color: color),
              label: Text('Inspect Level $level Roster'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPendingHod =
        app.activeRegistrationStatus == RegistrationStatus.submitted;
    final totalOfferings = app.courses.length;
    final pendingPetitions = app.specialRequests
        .where((r) => r.status == SpecialRequestStatus.pending)
        .length;

    final compact = MediaQuery.sizeOf(context).width < 650;

    final l1Students = records.where((r) => r.level == 1).toList();
    final l2Students = records.where((r) => r.level == 2).toList();
    final l3Students = records.where((r) => r.level == 3).toList();
    final l4Students = records.where((r) => r.level == 4).toList();

    final l1Endorsed = l1Students.where((r) => r.status == 'Department Endorsed').length;
    final l2Endorsed = l2Students.where((r) => r.status == 'Department Endorsed').length;
    final l3Endorsed = l3Students.where((r) => r.status == 'Department Endorsed').length;
    final l4Endorsed = l4Students.where((r) => r.status == 'Department Endorsed').length;
    final totalEndorsed = records.where((r) => r.status == 'Department Endorsed').length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 14 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department Header Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: RuslColors.accentYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    size: 30,
                    color: RuslColors.darkText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Department of Information & Communication Technology',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: RuslColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Faculty of Technology • Rajarata University of Sri Lanka • Head of Department: Dr. Lahiru Jayasuriya',
                        style: TextStyle(
                          fontSize: 13,
                          color: RuslColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            'Academic Year 2025/2026 (Levels 1 - 4)',
                            Icons.calendar_month_rounded,
                          ),
                          _buildChip(
                            '4 Active Undergraduate Cohorts (160 Students)',
                            Icons.school_rounded,
                          ),
                          _buildChip(
                            'Registration Window: 01 Oct - 15 Oct 2026',
                            Icons.timer_outlined,
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Department Level Division Overview
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Department Academic Year Level Distribution (Levels 1 - 4)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onNavigate(5),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Open Student Directory'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Four concurrent undergraduate cohorts in the Faculty of Technology, spanning foundational 100-series courses through final-year capstone research & industrial training.',
                  style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _buildLevelCohortCard(
                      level: 1,
                      title: 'Level 1 (Freshers)',
                      intake: 'Intake 2024/2025',
                      count: l1Students.length,
                      endorsed: l1Endorsed,
                      focus: 'Foundational Programming, DB Systems & Discrete Math',
                      color: _getHodLevelColor(1),
                      onTap: () => onNavigateWithLevel?.call(1),
                    ),
                    _buildLevelCohortCard(
                      level: 2,
                      title: 'Level 2 (Sophomores)',
                      intake: 'Intake 2023/2024',
                      count: l2Students.length,
                      endorsed: l2Endorsed,
                      focus: 'DSA, Computer Networks, Advanced DB & Web Dev',
                      color: _getHodLevelColor(2),
                      onTap: () => onNavigateWithLevel?.call(2),
                    ),
                    _buildLevelCohortCard(
                      level: 3,
                      title: 'Level 3 (Juniors)',
                      intake: 'Intake 2022/2023 & Active Nafis',
                      count: l3Students.length,
                      endorsed: l3Endorsed,
                      focus: 'Mobile, Cloud, AI & Security Specialization Modules',
                      color: _getHodLevelColor(3),
                      onTap: () => onNavigateWithLevel?.call(3),
                    ),
                    _buildLevelCohortCard(
                      level: 4,
                      title: 'Level 4 (Final Honours)',
                      intake: 'Intake 2021/2022',
                      count: l4Students.length,
                      endorsed: l4Endorsed,
                      focus: 'Capstone Research Dissertation & Industrial Internship',
                      color: _getHodLevelColor(4),
                      onTap: () => onNavigateWithLevel?.call(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // State University Open Enrollment Policy Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: RuslColors.darkText,
                  size: 24,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'State University Cohort Policy: All 160 admitted students across Levels 1, 2, 3, and 4 in the ICT Department are entitled to register for their prescribed core and elective subjects. The department arranges lecture halls and laboratory practical sessions to accommodate each cohort without seat restrictions.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RuslColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // High Priority Action Required Banner (If student is waiting for HoD)
          if (isPendingHod) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RuslColors.accentYellow.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.accentYellow, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: RuslColors.darkText,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Action Required: Registration Pending HoD Endorsement',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: RuslColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${app.activeStudent.fullName} (${app.activeStudent.registrationNumber}) has been recommended by Dr. Chandana Jayawardena and awaits your departmental sign-off.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RuslColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => onReview(records[0]),
                    icon: const Icon(Icons.verified_user_rounded, size: 16),
                    label: const Text('Review & Endorse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.darkText,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Batch Registration Status Cards (State University Format)
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatMetricCard(
                value: '${records.length}',
                label: 'Department Students (Levels 1-4)',
                icon: Icons.groups_rounded,
              ),
              StatMetricCard(
                value: '$totalEndorsed',
                label: 'Department Endorsed',
                icon: Icons.check_circle_outline_rounded,
              ),
              StatMetricCard(
                value: isPendingHod ? '1' : '0',
                label: 'Pending HoD Review',
                icon: Icons.pending_actions_rounded,
              ),
              const StatMetricCard(
                value: '4',
                label: 'Pending Adviser Review',
                icon: Icons.hourglass_top_rounded,
              ),
              StatMetricCard(
                value: '$totalOfferings',
                label: 'Department Course Modules',
                icon: Icons.menu_book_rounded,
              ),
              StatMetricCard(
                value: '$pendingPetitions',
                label: 'Pending Academic Petitions',
                icon: Icons.assignment_turned_in_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Navigation Bar
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Department Governance Modules',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickButton(
                      label: 'Endorsement Queue',
                      badge: isPendingHod ? '1 Pending' : null,
                      icon: Icons.inbox_rounded,
                      onTap: () => onNavigate(1),
                    ),
                    _QuickButton(
                      label: 'Course Offerings & Lecturers',
                      icon: Icons.menu_book_outlined,
                      onTap: () => onNavigate(2),
                    ),
                    _QuickButton(
                      label: 'Timetable Scheduling',
                      icon: Icons.calendar_month_outlined,
                      onTap: () => onNavigate(3),
                    ),
                    _QuickButton(
                      label: 'Special Petitions & Waivers',
                      badge: pendingPetitions > 0 ? '$pendingPetitions' : null,
                      icon: Icons.assignment_turned_in_outlined,
                      onTap: () => onNavigate(4),
                    ),
                    _QuickButton(
                      label: 'Department Student Directory (160)',
                      icon: Icons.groups_outlined,
                      onTap: () => onNavigate(5),
                    ),
                    _QuickButton(
                      label: 'Senate Reports & Analytics',
                      icon: Icons.assessment_outlined,
                      onTap: () => onNavigate(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Course Offerings & Batch Enrollment Summary
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Level 3 Semester 5 Course Offerings & Student Enrollment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onNavigate(2),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('View All Teaching Allocations'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...app.courses.map((course) {
                  final isCompulsory =
                      course.courseType == CourseType.compulsory;
                  final enrolledCount = isCompulsory
                      ? 148
                      : (course.code == 'IT 3103'
                            ? 114
                            : (course.code == 'IT 3104' ? 92 : 76));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: RuslColors.borderGrey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isCompulsory
                                ? RuslColors.darkText
                                : RuslColors.accentYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.code,
                            style: TextStyle(
                              color: isCompulsory
                                  ? Colors.white
                                  : RuslColors.darkText,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${course.creditValue} Credits • ${isCompulsory ? "Compulsory Core" : "Elective Module"} • Department of ICT',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: RuslColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: RuslColors.pureWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: RuslColors.borderGrey),
                          ),
                          child: Text(
                            '$enrolledCount / 148 Students Enrolled',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: RuslColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Department Audit & Activity Stream
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Department Workflow Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onNavigate(6),
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('View Full Log'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (app.auditLogs.isEmpty)
                  const Text(
                    'No recent department activity recorded.',
                    style: TextStyle(color: RuslColors.textMuted),
                  )
                else
                  ...app.auditLogs.take(4).map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: RuslColors.cardSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              size: 18,
                              color: RuslColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.details,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${log.userName} (${log.userRole}) • ${_formatTimestamp(log.timestamp)}',
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
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? RuslColors.accentYellow.withValues(alpha: 0.3)
            : RuslColors.cardSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? RuslColors.accentYellow : RuslColors.borderGrey,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RuslColors.darkText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: RuslColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION 1: ENDORSEMENT QUEUE
// ============================================================================
class _HodEndorsementQueue extends StatefulWidget {
  final List<_HodStudentRecord> records;
  final AppService app;
  final ValueChanged<_HodStudentRecord> onReview;

  const _HodEndorsementQueue({
    required this.records,
    required this.app,
    required this.onReview,
  });

  @override
  State<_HodEndorsementQueue> createState() => _HodEndorsementQueueState();
}

class _HodEndorsementQueueState extends State<_HodEndorsementQueue> {
  int _levelFilter = 0; // 0 = All Levels, 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 4
  String _filter = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.records.where((r) {
      if (_levelFilter != 0 && r.level != _levelFilter) {
        return false;
      }
      if (_filter == 'Pending HoD' && r.status != 'Pending HoD Endorsement') {
        return false;
      }
      if (_filter == 'Endorsed' && r.status != 'Department Endorsed') {
        return false;
      }
      if (_filter == 'Changes Requested' && r.status != 'Changes Requested') {
        return false;
      }
      if (_search.isNotEmpty) {
        final query = _search.toLowerCase();
        return r.name.toLowerCase().contains(query) ||
            r.registrationNumber.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    final compact = MediaQuery.sizeOf(context).width < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 14 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Registration Endorsement Queue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Official departmental endorsement for submitted undergraduate student registrations across Levels 1 - 4.',
            style: TextStyle(fontSize: 13, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 18),

          // 4-Stage Workflow Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Row(
              children: [
                _buildProcessStep('1. Student', 'Submitted', true),
                _buildProcessDivider(),
                _buildProcessStep(
                  '2. HoD',
                  'Endorsing Now',
                  true,
                  isCurrent: true,
                ),
                _buildProcessDivider(),
                _buildProcessStep('3. Registrar', 'Upcoming', false),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _search = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText:
                        'Search by student name or registration number...',
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Cohort Level Filter
                Row(
                  children: const [
                    Icon(Icons.layers_rounded, size: 16, color: RuslColors.textMuted),
                    SizedBox(width: 8),
                    Text(
                      'COHORT ACADEMIC LEVEL:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: RuslColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 1, 2, 3, 4].map((lvl) {
                    final selected = _levelFilter == lvl;
                    final count = lvl == 0
                        ? widget.records.length
                        : widget.records.where((r) => r.level == lvl).length;
                    final label = lvl == 0 ? 'All Levels ($count)' : 'Level $lvl ($count)';
                    final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _levelFilter = lvl),
                      selectedColor: lvl == 0
                          ? RuslColors.accentYellow
                          : color.withValues(alpha: 0.2),
                      backgroundColor: RuslColors.cardSubtle,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected && lvl != 0 ? color : RuslColors.darkText,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Status Filter
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        'All',
                        'Pending HoD',
                        'Endorsed',
                        'Changes Requested',
                      ].map((filter) {
                        final selected = _filter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) => setState(() => _filter = filter),
                          selectedColor: RuslColors.accentYellow,
                          backgroundColor: RuslColors.cardSubtle,
                          labelStyle: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: RuslColors.darkText,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Registrations List
          ...filtered.map((record) {
            final isLiveStudent = record.index == 0;
            final isPending =
                record.status == 'Pending HoD Endorsement' ||
                (isLiveStudent &&
                    widget.app.activeRegistrationStatus ==
                        RegistrationStatus.submitted);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(compact ? 14 : 18),
              decoration: BoxDecoration(
                color: RuslColors.pureWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPending
                      ? RuslColors.accentYellow
                      : RuslColors.borderGrey,
                  width: isPending ? 1.5 : 1.0,
                ),
              ),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isPending
                                  ? RuslColors.accentYellow
                                  : RuslColors.cardSubtle,
                              child: Text(
                                record.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: RuslColors.darkText,
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
                                    record.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isLiveStudent) ...[
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RuslColors.darkText,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ACTIVE SESSION',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 7),
                                  Text(
                                    record.registrationNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${record.subjects} Courses • ${record.credits} Credits • CGPA ${record.gpa.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RuslColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildStatusBadge(record.status),
                            ElevatedButton.icon(
                              onPressed: () => widget.onReview(record),
                              icon: Icon(
                                isPending
                                    ? Icons.verified_user_rounded
                                    : Icons.visibility_rounded,
                                size: 16,
                              ),
                              label: Text(
                                isPending ? 'Review & Endorse' : 'Details',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPending
                                    ? RuslColors.accentYellow
                                    : RuslColors.cardSubtle,
                                foregroundColor: RuslColors.darkText,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isPending
                              ? RuslColors.accentYellow
                              : RuslColors.cardSubtle,
                          child: Text(
                            record.initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: RuslColors.darkText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      record.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isLiveStudent) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RuslColors.darkText,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ACTIVE SESSION',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${record.registrationNumber} • ${record.subjects} Courses (${record.credits} Credits) • CGPA ${record.gpa.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RuslColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(record.status),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => widget.onReview(record),
                          icon: Icon(
                            isPending
                                ? Icons.verified_user_rounded
                                : Icons.visibility_rounded,
                            size: 16,
                          ),
                          label: Text(
                            isPending ? 'Review & Endorse' : 'Details',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPending
                                ? RuslColors.accentYellow
                                : RuslColors.cardSubtle,
                            foregroundColor: RuslColors.darkText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProcessStep(
    String title,
    String state,
    bool done, {
    bool isCurrent = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCurrent
                ? RuslColors.accentYellow
                : (done ? RuslColors.successGreen : Colors.grey.shade300),
            child: Icon(
              done ? Icons.check : Icons.circle,
              size: 12,
              color: isCurrent ? RuslColors.darkText : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
              color: isCurrent ? RuslColors.darkText : Colors.grey.shade700,
            ),
          ),
          Text(
            state,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: RuslColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessDivider() {
    return Container(width: 16, height: 2, color: Colors.grey.shade300);
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Department Endorsed') {
      bg = RuslColors.successGreen.withValues(alpha: 0.15);
      text = RuslColors.successGreen;
    } else if (status == 'Pending HoD Endorsement') {
      bg = RuslColors.accentYellow;
      text = RuslColors.darkText;
    } else if (status == 'Changes Requested') {
      bg = RuslColors.warningOrange.withValues(alpha: 0.15);
      text = RuslColors.warningOrange;
    } else {
      bg = Colors.grey.shade200;
      text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION 2: DEPARTMENT COURSE OFFERINGS & LECTURERS (NO SLOT LIMITS!)
// ============================================================================
class _HodCourseOfferings extends StatefulWidget {
  final AppService app;

  const _HodCourseOfferings({required this.app});

  @override
  State<_HodCourseOfferings> createState() => _HodCourseOfferingsState();
}

class _HodCourseOfferingsState extends State<_HodCourseOfferings> {
  int _levelFilter = 0; // 0 = All, 1..4

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final lecturers = [
      'Dr. Lahiru Jayasuriya (Senior Lecturer Gr. I & Head of Department)',
      'Mr. Wiraj Wickramaarachchi (Senior Lecturer Gr. I)',
      'Dr. W. K. P. Chathurangika (Lecturer)',
      'Mrs. Nishadi Prasanthika (Lecturer - Probationary)',
      'Eng. T. Kugaranan (Lecturer - Probationary)',
      'Mr. Sahan Ekanayake (Lecturer - Probationary)',
      'Mr. M. U. I. Marasinghe (Lecturer - Probationary)',
      'Prof. Samantha Kumara (Professor of ICT & Chair of Faculty Research)',
    ];

    final venues = [
      'Lecture: Technology Complex Hall 01 • Practical: ICT Lab 01 (Parallel Batches A & B)',
      'Lecture: Technology Complex Hall 02 • Practical: Networking & Cloud Lab',
      'Lecture: Faculty Main Auditorium • Practical: ICT Lab 02 & 03',
      'Lecture: Technology Complex Hall 01 • Practical: Embedded Systems Lab',
      'Lecture: Technology Complex Hall 02 • Practical: ICT Lab 01',
      'Lecture: Technology Complex Hall 01 • Practical: AI & Deep Learning Research Lab',
      'Lecture: Technology Complex Hall 03 • Practical: Cybersecurity Lab',
    ];

    final displayedCourses = _levelFilter == 0
        ? app.courses
        : app.courses.where((c) => c.level == _levelFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department Course Offerings & Academic Staff',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Undergraduate course modules, assigned academic staff, and teaching schedule allocations divided across Levels 1 - 4.',
            style: TextStyle(fontSize: 13, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Cohort Level Selector Bar
          Container(
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
                  children: const [
                    Icon(Icons.layers_rounded, size: 16, color: RuslColors.textMuted),
                    SizedBox(width: 8),
                    Text(
                      'FILTER BY COHORT LEVEL (LEVELS 1 - 4):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: RuslColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 1, 2, 3, 4].map((lvl) {
                    final selected = _levelFilter == lvl;
                    final count = lvl == 0
                        ? app.courses.length
                        : app.courses.where((c) => c.level == lvl).length;
                    final label = lvl == 0
                        ? 'All Levels ($count Modules)'
                        : 'Level $lvl ($count Modules)';
                    final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _levelFilter = lvl),
                      selectedColor: lvl == 0
                          ? RuslColors.accentYellow
                          : color.withValues(alpha: 0.2),
                      backgroundColor: RuslColors.cardSubtle,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected && lvl != 0 ? color : RuslColors.darkText,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // State University Academic Model Explainer
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: RuslColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: RuslColors.accentYellow.withValues(alpha: 0.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: RuslColors.darkText,
                  size: 26,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'In Sri Lankan State Universities, course offerings do not impose artificial seat caps. Every student in their prescribed level cohort is eligible to register. The department arranges lecture halls and parallel practical lab sessions to accommodate all undergraduates.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: RuslColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Course Offerings Cards
          ...displayedCourses.indexed.map((entry) {
            final idx = entry.$1;
            final course = entry.$2;
            final isCompulsory = course.courseType == CourseType.compulsory;
            final enrolledStudents = isCompulsory
                ? 40
                : (course.code == 'IT 3103' || course.code == 'ICT 4304' ? 34 : 28);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RuslColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCompulsory
                              ? RuslColors.darkText
                              : RuslColors.accentYellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          course.code,
                          style: TextStyle(
                            color: isCompulsory
                                ? Colors.white
                                : RuslColors.darkText,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildHodLevelPill(course.level),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lecturer in Charge: ${lecturers[idx % lecturers.length]}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: RuslColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isCompulsory
                              ? RuslColors.darkText.withValues(alpha: 0.08)
                              : RuslColors.accentYellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompulsory ? 'COMPULSORY CORE' : 'ELECTIVE OPTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isCompulsory
                                ? RuslColors.darkText
                                : RuslColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Course Attributes Grid
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: RuslColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                venues[idx % venues.length],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Credit Value: ${course.creditValue} Credits • ${_getHodLevelTitle(course.level)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: RuslColors.textMuted,
                              ),
                            ),
                            Text(
                              'Cohort Enrollment: $enrolledStudents / 40 Students (${isCompulsory ? "100%" : "${((enrolledStudents / 40) * 100).toInt()}%"})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: RuslColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All registered students accommodated in teaching schedule',
                        style: TextStyle(
                          fontSize: 11,
                          color: RuslColors.successGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showEnrolledRosterDialog(
                          context,
                          course,
                          enrolledStudents,
                        ),
                        icon: const Icon(Icons.people_alt_outlined, size: 14),
                        label: const Text('View Enrolled Students'),
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
            );
          }),
        ],
      ),
    );
  }

  void _showEnrolledRosterDialog(
    BuildContext context,
    Course course,
    int count,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${course.code}: ${course.title}'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Enrolled: $count Students from Level 3 ICT Batch',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Student Sample from Batch Register:',
                style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 6),
              ...[
                'ICT/2021/045 - M. N. Mohamed Nafis (Regular)',
                'ICT/2021/001 - Amaya Perera (Regular)',
                'ICT/2021/002 - Kasun Silva (Regular)',
                'ICT/2021/003 - Tharushi Fernando (Regular)',
                'ICT/2021/004 - Dilan Bandara (Regular)',
                'ICT/2021/005 - Nethmi Herath (Regular)',
                '... and ${count - 6} additional students in department register.',
              ].map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(s, style: const TextStyle(fontSize: 12)),
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
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION 3: TIMETABLE SCHEDULING & CONFLICT-FREE ASSIGNMENT
// ============================================================================
class _HodTimetableScheduler extends StatefulWidget {
  final AppService app;

  const _HodTimetableScheduler({required this.app});

  @override
  State<_HodTimetableScheduler> createState() => _HodTimetableSchedulerState();
}

class _HodTimetableSchedulerState extends State<_HodTimetableScheduler> {
  int _levelFilter = 0; // 0 = All Levels, 1..4
  String _dayFilter = 'All'; // 'All', 'Monday', 'Tuesday', ...

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final clashes = app.getActiveTimetableClashes();

    final allSlotsWithInfo = <({CourseOffering offering, Course course, TimetableSlot slot})>[];
    for (final off in app.courseOfferings) {
      final c = app.courses.firstWhere(
        (item) => item.id == off.courseId,
        orElse: () => app.courses.first,
      );
      for (final s in off.slots) {
        allSlotsWithInfo.add((offering: off, course: c, slot: s));
      }
    }

    final distinctVenues = allSlotsWithInfo.map((e) => e.slot.venue.trim()).toSet();

    final filteredSlots = allSlotsWithInfo.where((item) {
      if (_levelFilter != 0 && item.course.level != _levelFilter) {
        return false;
      }
      if (_dayFilter != 'All' && item.slot.dayOfWeek != _dayFilter) {
        return false;
      }
      return true;
    }).toList();

    final daysToDisplay = _dayFilter == 'All'
        ? const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
        : [_dayFilter];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Timetable Scheduling & Conflict-Free Assignment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Assign lecture, practical, and tutorial slots across Levels 1 - 4 with real-time clash detection.',
                      style: TextStyle(fontSize: 13, color: RuslColors.textMuted),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showAssignSlotDialog(context, app),
                icon: const Icon(Icons.add_alarm_rounded, size: 18),
                label: const Text('Assign Lecture Slot'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Conflict Status Banner
          if (clashes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RuslColors.successGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: RuslColors.successGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: RuslColors.successGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '100% Conflict-Free Timetable Schedule Active',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: RuslColors.successGreen,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Zero venue overlaps, zero cohort level clashes, and zero academic staff conflicts verified across all Levels 1 - 4.',
                          style: TextStyle(fontSize: 12, color: RuslColors.darkText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '${clashes.length} Active Timetable Conflict(s) Detected',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...clashes.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
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
          const SizedBox(height: 20),

          // 2. Metrics Bar
          Row(
            children: [
              _buildSchedulerMetricCard(
                'Total Slots',
                '${allSlotsWithInfo.length}',
                Icons.calendar_month_rounded,
                RuslColors.primaryMaroon,
              ),
              const SizedBox(width: 14),
              _buildSchedulerMetricCard(
                'Schedule Status',
                clashes.isEmpty ? 'Conflict-Free' : '${clashes.length} Clashes',
                clashes.isEmpty ? Icons.check_circle_outline_rounded : Icons.warning_rounded,
                clashes.isEmpty ? RuslColors.successGreen : Colors.red,
              ),
              const SizedBox(width: 14),
              _buildSchedulerMetricCard(
                'Active Venues',
                '${distinctVenues.length}',
                Icons.meeting_room_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 14),
              _buildSchedulerMetricCard(
                'Cohorts Covered',
                'Levels 1 - 4',
                Icons.layers_rounded,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Filter Controls
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 95,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Level Filter:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [0, 1, 2, 3, 4].map((lvl) {
                          final selected = _levelFilter == lvl;
                          final count = lvl == 0
                              ? allSlotsWithInfo.length
                              : allSlotsWithInfo.where((item) => item.course.level == lvl).length;
                          final label = lvl == 0 ? 'All Levels ($count)' : 'Level $lvl ($count)';
                          final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) => setState(() => _levelFilter = lvl),
                            selectedColor: lvl == 0
                                ? RuslColors.accentYellow
                                : color.withValues(alpha: 0.25),
                            backgroundColor: RuslColors.cardSubtle,
                            labelStyle: TextStyle(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected && lvl != 0 ? color : RuslColors.darkText,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 95,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Day Filter:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((d) {
                          final selected = _dayFilter == d;
                          final count = d == 'All'
                              ? allSlotsWithInfo.length
                              : allSlotsWithInfo.where((item) => item.slot.dayOfWeek == d).length;
                          return ChoiceChip(
                            label: Text('$d ($count)'),
                            selected: selected,
                            onSelected: (_) => setState(() => _dayFilter = d),
                            selectedColor: RuslColors.accentYellow,
                            backgroundColor: RuslColors.cardSubtle,
                            labelStyle: TextStyle(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: RuslColors.darkText,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Daily Schedule Cards
          ...daysToDisplay.map((day) {
            final daySlots = filteredSlots
                .where((item) => item.slot.dayOfWeek == day)
                .toList();

            daySlots.sort((a, b) => a.slot.startTime.compareTo(b.slot.startTime));

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: RuslColors.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            day.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: daySlots.isEmpty
                              ? RuslColors.cardSubtle
                              : RuslColors.accentYellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${daySlots.length} Sessions Scheduled',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (daySlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 32, color: RuslColors.textMuted),
                          const SizedBox(height: 6),
                          Text(
                            'No sessions scheduled on $day for selected filter.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: RuslColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...daySlots.map((item) {
                      final slot = item.slot;
                      final course = item.course;
                      final offering = item.offering;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RuslColors.cardSubtle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: RuslColors.borderGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 110,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: RuslColors.borderGrey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${slot.startTime} – ${slot.endTime}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: RuslColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: slot.groupType == 'Practical'
                                          ? Colors.blue.withValues(alpha: 0.15)
                                          : Colors.teal.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      slot.groupType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: slot.groupType == 'Practical'
                                            ? Colors.blue[800]
                                            : Colors.teal[800],
                                      ),
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
                                      _buildHodLevelPill(course.level),
                                      const SizedBox(width: 8),
                                      Text(
                                        course.code,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          course.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15,
                                            color: RuslColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            slot.venue,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.person_outline_rounded,
                                            size: 15,
                                            color: RuslColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            offering.lecturerName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: RuslColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove Timetable Slot',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _deleteSlotDialog(
                                context,
                                app,
                                offering,
                                slot,
                                course,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSchedulerMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RuslColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSlotDialog(
    BuildContext context,
    AppService app,
    CourseOffering offering,
    TimetableSlot slot,
    Course course,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Timetable Slot • ${course.code}'),
        content: Text(
          'Are you sure you want to remove the ${slot.dayOfWeek} (${slot.startTime}–${slot.endTime}) session at ${slot.venue}?\n\nThis will free up the venue and schedule slot for other courses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Slot'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      app.deleteTimetableSlot(offering.id, slot.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timetable slot for ${course.code} removed successfully.'),
          ),
        );
      }
    }
  }

  Future<void> _showAssignSlotDialog(BuildContext context, AppService app) async {
    if (app.courseOfferings.isEmpty) return;

    var selectedOfferingId = app.courseOfferings.first.id;
    if (_levelFilter != 0) {
      final matching = app.courseOfferings.where((o) {
        final c = app.courses.firstWhere(
          (item) => item.id == o.courseId,
          orElse: () => app.courses.first,
        );
        return c.level == _levelFilter;
      }).toList();
      if (matching.isNotEmpty) {
        selectedOfferingId = matching.first.id;
      }
    }

    var day = _dayFilter != 'All' ? _dayFilter : 'Monday';
    var groupType = 'Lecture';
    final start = TextEditingController(text: '08:30');
    final end = TextEditingController(text: '10:30');
    final venue = TextEditingController(text: 'Technology Complex Hall 01');

    final standardVenues = [
      'Technology Complex Hall 01',
      'Technology Complex Hall 02',
      'Technology Complex Hall 03',
      'Faculty Main Auditorium',
      'ICT Lab 01',
      'ICT Lab 02',
      'ICT Lab 03',
      'Networking & Cloud Lab',
      'AI & Deep Learning Research Lab',
      'Embedded Systems Lab',
      'Cybersecurity Lab',
      'Mobile Computing Lab',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) {
          final clashError = app.checkTimetableClash(
            offeringId: selectedOfferingId,
            dayOfWeek: day,
            startTime: start.text.trim(),
            endTime: end.text.trim(),
            venue: venue.text.trim(),
          );

          final selectedOffering = app.courseOfferings.firstWhere(
            (o) => o.id == selectedOfferingId,
            orElse: () => app.courseOfferings.first,
          );
          final selectedCourse = app.courses.firstWhere(
            (c) => c.id == selectedOffering.courseId,
            orElse: () => app.courses.first,
          );

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: RuslColors.primaryMaroon),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Assign Timetable Slot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                _buildHodLevelPill(selectedCourse.level),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign a weekly teaching session across Level 1 - 4 modules. Conflict-free validation actively checks venue, cohort level, and lecturer availability.',
                      style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Course Offering Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedOfferingId,
                      decoration: const InputDecoration(
                        labelText: 'Course Module (All Levels 1 - 4)',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      isExpanded: true,
                      items: app.courseOfferings.map((offering) {
                        final course = app.courses.firstWhere(
                          (c) => c.id == offering.courseId,
                          orElse: () => app.courses.first,
                        );
                        return DropdownMenuItem(
                          value: offering.id,
                          child: Text(
                            '[L${course.level}] ${course.code} • ${course.title} (${offering.lecturerName})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => update(() => selectedOfferingId = v ?? selectedOfferingId),
                    ),
                    const SizedBox(height: 12),

                    // Day of Week & Group Type
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: day,
                            decoration: const InputDecoration(
                              labelText: 'Day of Week',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            items: const [
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                            ]
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) => update(() => day = v ?? day),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: groupType,
                            decoration: const InputDecoration(
                              labelText: 'Session Type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const ['Lecture', 'Practical', 'Tutorial']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => update(() => groupType = v ?? groupType),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Start Time & End Time
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: start,
                            decoration: const InputDecoration(
                              labelText: 'Start Time (e.g. 08:30)',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            onChanged: (_) => update(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: end,
                            decoration: const InputDecoration(
                              labelText: 'End Time (e.g. 10:30)',
                              prefixIcon: Icon(Icons.timelapse_rounded),
                            ),
                            onChanged: (_) => update(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick University Time Slots
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ('08:30', '10:30', '08:30–10:30'),
                        ('10:30', '12:30', '10:30–12:30'),
                        ('13:00', '15:00', '13:00–15:00'),
                        ('15:00', '17:00', '15:00–17:00'),
                      ].map((slot) {
                        return ActionChip(
                          label: Text(slot.$3, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            start.text = slot.$1;
                            end.text = slot.$2;
                            update(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Venue Selection
                    DropdownButtonFormField<String>(
                      initialValue: standardVenues.contains(venue.text) ? venue.text : standardVenues.first,
                      decoration: const InputDecoration(
                        labelText: 'Lecture Hall / Laboratory Venue',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                      ),
                      isExpanded: true,
                      items: standardVenues
                          .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          venue.text = v;
                          update(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Real-time Clash Indicator Box
                    if (clashError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                clashError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RuslColors.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: RuslColors.successGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_rounded, color: RuslColors.successGreen, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '✓ Conflict-Free Slot: Venue, Level cohort, and Lecturer are completely available.',
                                style: TextStyle(
                                  color: RuslColors.successGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
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
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Assign Slot'),
                onPressed: () {
                  final error = app.createTimetableSlot(
                    offeringId: selectedOfferingId,
                    dayOfWeek: day,
                    startTime: start.text.trim(),
                    endTime: end.text.trim(),
                    venue: venue.text.trim(),
                    groupType: groupType,
                  );
                  if (error == null) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Timetable slot assigned successfully without clash.'),
                        backgroundColor: RuslColors.successGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );

    start.dispose();
    end.dispose();
    venue.dispose();
  }
}

// ============================================================================
// SECTION 4: SPECIAL PETITIONS & STATUTORY WAIVERS
// ============================================================================
class _HodSpecialRequests extends StatefulWidget {
  final AppService app;

  const _HodSpecialRequests({required this.app});

  @override
  State<_HodSpecialRequests> createState() => _HodSpecialRequestsState();
}

class _HodSpecialRequestsState extends State<_HodSpecialRequests> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final petitions = widget.app.specialRequests.where((p) {
      if (_filter == 'Pending' && p.status != SpecialRequestStatus.pending) return false;
      if (_filter == 'Approved' && p.status != SpecialRequestStatus.approved) return false;
      if (_filter == 'Rejected' && p.status != SpecialRequestStatus.rejected) return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Academic Petitions & Exemptions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    Text(
                      'Statutory review of Credit Overload, Prerequisite Waiver, and Late Registration requests.',
                      style: TextStyle(
                        fontSize: 13,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showLogExemptionDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Board Exemption'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RuslColors.accentYellow,
                  foregroundColor: RuslColors.darkText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Wrap(
            spacing: 8,
            children: ['All', 'Pending', 'Approved', 'Rejected'].map((f) {
              final selected = _filter == f;
              return ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: RuslColors.accentYellow,
                backgroundColor: RuslColors.cardSubtle,
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: RuslColors.darkText,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Petitions List
          if (petitions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: RuslColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              alignment: Alignment.center,
              child: const Text(
                'No special academic petitions matching the current filter.',
                style: TextStyle(color: RuslColors.textMuted),
              ),
            )
          else
            ...petitions.map((req) {
              final isPending = req.status == SpecialRequestStatus.pending;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: RuslColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPending
                        ? RuslColors.accentYellow
                        : RuslColors.borderGrey,
                    width: isPending ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: RuslColors.cardSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            req.requestType == 'Credit Overload'
                                ? Icons.fitness_center_rounded
                                : (req.requestType == 'Prerequisite Waiver'
                                      ? Icons.lock_open_rounded
                                      : Icons.timer_outlined),
                            color: RuslColors.darkText,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    req.requestType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: req.status == SpecialRequestStatus.approved
                                          ? RuslColors.successGreen.withValues(
                                              alpha: 0.15,
                                            )
                                          : (req.status == SpecialRequestStatus.rejected
                                                ? RuslColors.warningOrange
                                                      .withValues(alpha: 0.15)
                                                : RuslColors.accentYellow),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req.status.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: req.status == SpecialRequestStatus.approved
                                            ? RuslColors.successGreen
                                            : (req.status == SpecialRequestStatus.rejected
                                                  ? RuslColors.warningOrange
                                                  : RuslColors.darkText),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Petitioner: ${req.studentName} (${req.studentId}) • Submitted ${_formatTimestamp(req.submittedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RuslColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Student Academic Justification: "${req.explanation}"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.app.reviewSpecialRequest(
                                req.id,
                                SpecialRequestStatus.approved,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Special petition endorsed by Head of Department.',
                                  ),
                                  backgroundColor: RuslColors.successGreen,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve Petition'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RuslColors.accentYellow,
                              foregroundColor: RuslColors.darkText,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              widget.app.reviewSpecialRequest(
                                req.id,
                                SpecialRequestStatus.rejected,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Special petition rejected with comments.',
                                  ),
                                  backgroundColor: RuslColors.warningOrange,
                                ),
                              );
                            },
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Reject Petition'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showLogExemptionDialog(BuildContext context) {
    final typeCtrl = TextEditingController(text: 'Credit Overload');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Faculty Board Exemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: 'Credit Overload',
              items: const [
                DropdownMenuItem(
                  value: 'Credit Overload',
                  child: Text('Credit Overload Exemption'),
                ),
                DropdownMenuItem(
                  value: 'Prerequisite Waiver',
                  child: Text('Prerequisite Waiver Exemption'),
                ),
                DropdownMenuItem(
                  value: 'Late Registration',
                  child: Text('Late Registration Exemption'),
                ),
              ],
              onChanged: (val) {
                if (val != null) typeCtrl.text = val;
              },
              decoration: const InputDecoration(labelText: 'Exemption Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Official Board Justification & Minute No.',
                hintText: 'e.g. Approved per Faculty Board Minute 142.3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.isNotEmpty) {
                widget.app.submitSpecialRequest(typeCtrl.text, reasonCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Faculty Board exemption successfully logged.',
                    ),
                    backgroundColor: RuslColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RuslColors.accentYellow,
              foregroundColor: RuslColors.darkText,
            ),
            child: const Text('Record Exemption'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION 4: DEPARTMENT STUDENT DIRECTORY (LEVELS 1 - 4 ENROLLMENT REGISTER)
// ============================================================================
class _HodStudentDirectory extends StatefulWidget {
  final List<_HodStudentRecord> records;
  final AppService app;
  final int initialLevel;
  final ValueChanged<int>? onLevelChanged;

  const _HodStudentDirectory({
    required this.records,
    required this.app,
    this.initialLevel = 0,
    this.onLevelChanged,
  });

  @override
  State<_HodStudentDirectory> createState() => _HodStudentDirectoryState();
}

class _HodStudentDirectoryState extends State<_HodStudentDirectory> {
  late int _levelFilter;
  String _filter = 'All';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _levelFilter = widget.initialLevel;
  }

  @override
  void didUpdateWidget(covariant _HodStudentDirectory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLevel != widget.initialLevel) {
      _levelFilter = widget.initialLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.records.where((r) {
      if (_levelFilter != 0 && r.level != _levelFilter) {
        return false;
      }
      if (_filter == 'Endorsed' && r.status != 'Department Endorsed') {
        return false;
      }
      if (_filter == 'Pending' && r.status != 'Pending HoD Endorsement') {
        return false;
      }
      if (_filter == 'Revisions' && r.status != 'Changes Requested') {
        return false;
      }
      if (_search.isNotEmpty) {
        final query = _search.toLowerCase();
        return r.name.toLowerCase().contains(query) ||
            r.registrationNumber.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department Student Directory & Enrollment Register',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Complete department student register divided across Levels 1, 2, 3, and 4 (Intakes 2024 to 2021) • 160 Students.',
            style: TextStyle(fontSize: 13, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Search and Cohort Level Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _search = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText:
                        'Search department by student name or registration number...',
                    filled: true,
                    fillColor: RuslColors.cardSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Academic Level Division Ribbon
                Row(
                  children: const [
                    Icon(Icons.layers_rounded, size: 16, color: RuslColors.textMuted),
                    SizedBox(width: 8),
                    Text(
                      'ACADEMIC LEVEL DIVISION (LEVELS 1 - 4):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: RuslColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 1, 2, 3, 4].map((lvl) {
                    final selected = _levelFilter == lvl;
                    final count = lvl == 0
                        ? widget.records.length
                        : widget.records.where((r) => r.level == lvl).length;
                    final label = lvl == 0 ? 'All Levels ($count)' : 'Level $lvl ($count)';
                    final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _levelFilter = lvl);
                        widget.onLevelChanged?.call(lvl);
                      },
                      selectedColor: lvl == 0
                          ? RuslColors.accentYellow
                          : color.withValues(alpha: 0.2),
                      backgroundColor: RuslColors.cardSubtle,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected && lvl != 0 ? color : RuslColors.darkText,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Endorsement Status Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', 'Endorsed', 'Pending', 'Revisions'].map((
                    filter,
                  ) {
                    final selected = _filter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: RuslColors.accentYellow,
                      backgroundColor: RuslColors.cardSubtle,
                      labelStyle: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: RuslColors.darkText,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Cohort Focus Banner (if specific level is selected)
          if (_levelFilter != 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _getHodLevelColor(_levelFilter).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _getHodLevelColor(_levelFilter).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  _buildHodLevelPill(_levelFilter),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getHodLevelTitle(_levelFilter)} • ${_getHodLevelIntake(_levelFilter)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _getHodLevelColor(_levelFilter),
                          ),
                        ),
                        Text(
                          _getHodLevelFocus(_levelFilter),
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
            ),
            const SizedBox(height: 16),
          ],

          // Students Count Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filtered.length} of ${widget.records.length} department students',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: RuslColors.textMuted,
                  ),
                ),
                Text(
                  _levelFilter == 0
                      ? 'All Undergraduate Levels Active'
                      : 'Cohort ${_getHodLevelTitle(_levelFilter)} Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: _levelFilter == 0
                        ? RuslColors.successGreen
                        : _getHodLevelColor(_levelFilter),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Students List
          ...filtered.map((record) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RuslColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: RuslColors.cardSubtle,
                    child: Text(
                      record.initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: RuslColors.darkText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildHodLevelPill(record.level),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${record.registrationNumber} • ${_getHodLevelTitle(record.level)} • ${_getHodLevelIntake(record.level)} • ${record.subjects} Subjects (${record.credits} Credits)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: record.status == 'Department Endorsed'
                          ? RuslColors.successGreen.withValues(alpha: 0.15)
                          : RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: record.status == 'Department Endorsed'
                            ? RuslColors.successGreen
                            : RuslColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onPressed: () => _showStudentBundleDialog(context, record),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showStudentBundleDialog(
    BuildContext context,
    _HodStudentRecord record,
  ) {
    final List<String> modules = switch (record.level) {
      1 => const [
        '• ICT 1101 - Introduction to Information Technology (1 Cr, Core)',
        '• ICT 1201 - Programming Fundamentals (2 Cr, Core)',
        '• ICT 1302 - Database Management Systems (3 Cr, Core)',
        '• ICT 1207 - Web Technologies (2 Cr, Core)',
        '• CMT 1204 - Discrete Mathematics (2 Cr, Core)',
      ],
      2 => const [
        '• ICT 2203 - Object Oriented Programming (3 Cr, Core)',
        '• ICT 2204 - Data Structures and Algorithms (3 Cr, Core)',
        '• ICT 2208 - Computer Networks (2 Cr, Core)',
        '• ICT 2210 - Advanced Database Systems (2 Cr, Core)',
        '• ICT 2214 - Web Application Development (2 Cr, Core)',
      ],
      3 => const [
        '• ICT 3202 - Mobile Application Development (2 Cr, Core)',
        '• ICT 3204 - Cloud Computing & Microservices (2 Cr, Core)',
        '• ICT 3214 - Human Computer Interaction (2 Cr, Core)',
        '• ICT 3216 - Information Assurance & Security (2 Cr, Core)',
        '• ICT 3310 - Machine Learning & Artificial Intelligence (3 Cr, Core)',
        '• CML 3202 - Research Methodology (1 Cr, Core)',
      ],
      4 => const [
        '• ICT 4601 - Capstone Research Project & Dissertation I (3 Cr, Core)',
        '• ICT 4301 - Advanced Enterprise Architecture & Governance (3 Cr, Core)',
        '• ICT 4302 - Deep Learning & Computer Vision (3 Cr, Core)',
        '• ICT 4203 - Information Systems Auditing & Quality Assurance (2 Cr, Core)',
        '• ICT 4304 - Cyber Threat Intelligence & Digital Forensics (3 Cr, Elective)',
        '• ICT 4602 - Industrial Training & Professional Internship (6 Cr, Core)',
      ],
      _ => const [],
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('${record.name} (${record.registrationNumber})')),
            const SizedBox(width: 8),
            _buildHodLevelPill(record.level),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Degree: B.Sc. (Hons) in Information & Communication Technology • ${_getHodLevelTitle(record.level)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Intake: ${_getHodLevelIntake(record.level)} • Registered Load: ${record.credits} Credits • ${record.subjects} Subjects',
            ),
            Text('Current Cumulative GPA: ${record.gpa.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text(
              'Enrolled Curricular Modules:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 6),
            ...modules.map((mod) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(mod, style: const TextStyle(fontSize: 12)),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RuslColors.cardSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Registration Status: ${record.status}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
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
}

// ============================================================================
// SECTION 5: DEPARTMENT ANALYTICS & REPORTS
// ============================================================================
class _HodReports extends StatelessWidget {
  final List<_HodStudentRecord> records;
  final AppService app;

  const _HodReports({required this.records, required this.app});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Analytics & Registration Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    Text(
                      'Curriculum progression metrics, workload distribution, and Senate submission reports.',
                      style: TextStyle(
                        fontSize: 13,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showExportSenateReport(context),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Generate Senate Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.accentYellow,
                      foregroundColor: RuslColors.darkText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Department enrollment roster exported as CSV.',
                          ),
                          backgroundColor: RuslColors.successGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Department Academic Level Progression Breakdown (Levels 1 - 4)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Department Registration Completion Rate (Levels 1 - 4)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${records.where((r) => r.status == "Department Endorsed").length} / ${records.length} Students Endorsed',
                      style: const TextStyle(
                        color: RuslColors.successGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Endorsement progression across all undergraduate cohort levels in the Department of ICT.',
                  style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
                ),
                const SizedBox(height: 16),

                // 4 Level Progress Rows
                ...[1, 2, 3, 4].map((lvl) {
                  final lvlStudents = records.where((r) => r.level == lvl).toList();
                  final lvlEndorsed = lvlStudents.where((r) => r.status == 'Department Endorsed').length;
                  final lvlPct = lvlStudents.isNotEmpty ? lvlEndorsed / lvlStudents.length : 1.0;
                  final color = _getHodLevelColor(lvl);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildHodLevelPill(lvl),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_getHodLevelTitle(lvl)} • ${_getHodLevelIntake(lvl)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '$lvlEndorsed / ${lvlStudents.length} (${(lvlPct * 100).toInt()}%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: lvlPct,
                            minHeight: 8,
                            backgroundColor: RuslColors.cardSubtle,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Elective Demand Breakdown (Real State University Enrollment Numbers)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elective Course Selection Distribution Across Batch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                ...app.courses.map((course) {
                  final isCompulsory =
                      course.courseType == CourseType.compulsory;
                  final count = isCompulsory
                      ? 148
                      : (course.code == 'IT 3103'
                            ? 114
                            : (course.code == 'IT 3104' ? 92 : 76));
                  final pct = count / 148;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${course.code} - ${course.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$count Students (${(pct * 100).toInt()}% of Batch)',
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              isCompulsory
                                  ? RuslColors.darkText
                                  : RuslColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Department Audit Trail
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Department Audit Trail & Governance History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ...app.auditLogs.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          size: 18,
                          color: RuslColors.darkText,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.details,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${log.userName} • ${log.userRole} • ${_formatTimestamp(log.timestamp)}',
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
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportSenateReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Official Senate Registration Report'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rajarata University of Sri Lanka • Faculty of Technology',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text('Department: Information & Communication Technology'),
            Text(
              'Academic Year: 2025/2026 • Semester 1 (Level 3 - Intake 2021)',
            ),
            SizedBox(height: 12),
            Text('• Batch Intake Size: 148 Students'),
            Text('• Department Endorsed: 143 (96.6%)'),
            Text('• Average Student Workload: 15.8 Credits'),
            Text('• Semester Course Modules Offered: 7 Courses'),
            SizedBox(height: 12),
            Text(
              'Official Department Seal and Head of Department Digital Signature verified for Faculty Senate submission.',
              style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Senate Registration Report PDF generated and downloaded.',
                  ),
                  backgroundColor: RuslColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RuslColors.accentYellow,
              foregroundColor: RuslColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION 6: HOD PROFILE & AUTHORITY
// ============================================================================
class _HodProfile extends StatelessWidget {
  final AppService app;

  const _HodProfile({required this.app});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Head of Department Profile & Statutory Authority',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Department head credentials, statutory governance mandates, and digital cryptographic seal.',
            style: TextStyle(fontSize: 13, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: RuslColors.accentYellow,
                  child: Text(
                    'SP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: RuslColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Dr. Lahiru Jayasuriya',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.designationOrReg ??
                            'Head, Department of Information & Communication Technology',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: RuslColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Faculty of Technology • Rajarata University of Sri Lanka',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Email: sarath.perera@rjt.ac.lk • Office: Technology Complex HOD-01, Mihintale',
                        style: TextStyle(
                          fontSize: 12,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statutory Powers & Delegated Authority
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statutory Powers & Delegated Authority',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _buildAuthorityItem(
                  'Curriculum Teaching & Timetable Allocations',
                  'Statutory authority to assign academic staff to semester course modules and schedule lecture/lab rooms.',
                  Icons.menu_book_rounded,
                ),
                _buildAuthorityItem(
                  'Departmental Registration Endorsement',
                  'Sole department authority to endorse student registration bundles to the Assistant Registrar.',
                  Icons.verified_user_rounded,
                ),
                _buildAuthorityItem(
                  'Credit Overload & Prerequisite Waivers',
                  'Faculty board delegate for reviewing student prerequisite and credit overload petitions.',
                  Icons.assignment_turned_in_rounded,
                ),
                _buildAuthorityItem(
                  'Cohort Progression & Senate Reporting',
                  'Official responsibility for signing off on department cohort registers for university Senate.',
                  Icons.assessment_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cryptographic Signature & Seal Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RuslColors.darkText,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: RuslColors.accentYellow,
                  size: 32,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Official Department Cryptographic Seal Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Endorsements are digitally timestamped and sealed under RUSL Technology Faculty Governance bylaws.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    color: RuslColors.successGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out from HoD Portal'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RuslColors.cardSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: RuslColors.darkText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
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
    );
  }
}

// ============================================================================
// HELPER MODELS & UTILS
// ============================================================================
class _QuickButton extends StatelessWidget {
  final String label;
  final String? badge;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickButton({
    required this.label,
    this.badge,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: RuslColors.cardSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RuslColors.borderGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: RuslColors.darkText),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: RuslColors.accentYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HodStudentRecord {
  final int index;
  final String name;
  final String registrationNumber;
  final int level;
  int subjects;
  int credits;
  String status;
  final double gpa;

  _HodStudentRecord({
    required this.index,
    required this.name,
    required this.registrationNumber,
    required this.level,
    required this.subjects,
    required this.credits,
    required this.status,
    required this.gpa,
  });

  String get initials => name.split(' ').take(2).map((p) => p[0]).join();
}

Color _getHodLevelColor(int level) => switch (level) {
  1 => const Color(0xFF2563EB), // Level 1 Blue
  2 => const Color(0xFF0D9488), // Level 2 Teal
  3 => const Color(0xFF7C3AED), // Level 3 Purple
  4 => const Color(0xFFD97706), // Level 4 Amber
  _ => RuslColors.primaryMaroon,
};

String _getHodLevelTitle(int level) => switch (level) {
  1 => 'Level 1 (1st Year)',
  2 => 'Level 2 (2nd Year)',
  3 => 'Level 3 (3rd Year)',
  4 => 'Level 4 (4th Year / Final)',
  _ => 'All Cohort Levels',
};

String _getHodLevelIntake(int level) => switch (level) {
  1 => 'Intake 2024/2025',
  2 => 'Intake 2023/2024',
  3 => 'Intake 2022/2023',
  4 => 'Intake 2021/2022',
  _ => 'All Cohorts',
};

String _getHodLevelFocus(int level) => switch (level) {
  1 => 'Foundational Programming, DB Systems & Discrete Math',
  2 => 'DSA, Computer Networks, Advanced DB & Web Dev',
  3 => 'Mobile, Cloud, AI & Security Specialization Modules',
  4 => 'Capstone Research Project & Industrial Internship',
  _ => 'Comprehensive Department Curriculum',
};

Widget _buildHodLevelPill(int level) {
  final color = _getHodLevelColor(level);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
        fontSize: 10,
        letterSpacing: 0.5,
      ),
    ),
  );
}

List<_HodStudentRecord> _makeHodStudentRecords() {
  const first = [
    'Nafis', 'Amaya', 'Kasun', 'Tharushi', 'Dilan', 'Nethmi', 'Ravindu',
    'Ishara', 'Sandeepa', 'Dulshan', 'Kavindi', 'Chamindu', 'Buddhika',
    'Dinithi', 'Nuwan', 'Sachini', 'Sanjaya', 'Chathurika', 'Thilina', 'Anuki',
  ];
  const last = [
    'Ahamed', 'Perera', 'Silva', 'Fernando', 'Bandara', 'Herath', 'Kumari',
    'Jayasinghe', 'Wickramasinghe', 'Rathnayake', 'Disanayake', 'Senaratne',
    'Abeywickrama', 'Gunawardena', 'Rajapaksha',
  ];

  return List.generate(
    160,
    (i) {
      if (i == 0) {
        return _HodStudentRecord(
          index: 0,
          name: 'M. N. Mohamed Nafis',
          registrationNumber: 'ICT/2021/045',
          level: 3,
          subjects: 6,
          credits: 12,
          status: 'Pending HoD Endorsement',
          gpa: 3.79,
        );
      }

      // 40 students per level (0-39: Level 1, 40-79: Level 2, 80-119: Level 3, 120-159: Level 4)
      final int level;
      final String intakeYear;
      final int serialInBatch;
      if (i < 40) {
        level = 1;
        intakeYear = '2024';
        serialInBatch = i + 1;
      } else if (i < 80) {
        level = 2;
        intakeYear = '2023';
        serialInBatch = (i - 40) + 1;
      } else if (i < 120) {
        level = 3;
        intakeYear = '2022';
        serialInBatch = (i - 80) + 1;
      } else {
        level = 4;
        intakeYear = '2021';
        serialInBatch = (i - 120) + 1;
      }

      final regNumber = 'ICT/$intakeYear/${serialInBatch.toString().padLeft(3, '0')}';
      final subjects = level == 4 ? (3 + (i % 2)) : (5 + (i % 3));
      final credits = level == 4 ? (12 + ((i % 3) * 3)) : (14 + ((i * 2) % 8));
      final status = (i % 28 == 0)
          ? 'Changes Requested'
          : (i % 55 == 0 ? 'Rejected' : (i % 15 == 0 ? 'Pending HoD Endorsement' : 'Department Endorsed'));
      final gpa = double.parse((2.80 + ((i * 7) % 115) * 0.01).toStringAsFixed(2));

      return _HodStudentRecord(
        index: i,
        name: '${first[i % first.length]} ${last[(i * 3) % last.length]}',
        registrationNumber: regNumber,
        level: level,
        subjects: subjects,
        credits: credits,
        status: status,
        gpa: gpa,
      );
    },
  );
}

String _formatTimestamp(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  } else {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
