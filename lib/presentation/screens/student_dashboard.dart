import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../core/pdf_generator.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

/// Legacy monolithic tabbed student screen.
/// Note: The production app shell in `main.dart` uses specialized modular screens:
/// [StudentHomeScreen], [SubjectRegistrationProScreen], [RegistrationStatusProScreen],
/// [StudentTimetableScreen], [SpecialRequestsScreen], and [StudentAcademicRecordScreen].
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _activeTabIndex =
      0; // 0: Courses, 1: Selection, 2: Timetable, 3: Requests, 4: Status
  final TextEditingController _specialReasonController =
      TextEditingController();
  final TextEditingController _specialTypeController = TextEditingController(
    text: 'Credit Overload',
  );
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'all'; // 'all', 'compulsory', 'elective'

  @override
  void dispose() {
    _specialReasonController.dispose();
    _specialTypeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final student = appService.activeStudent;
    final totalCredits = appService.totalSelectedCredits;

    // Perform real-time validation checks
    final selectedOfferings = appService.courseOfferings
        .where((o) => appService.selectedOfferingIds.contains(o.id))
        .toList();

    final selectedCourses = appService.courses
        .where((c) => selectedOfferings.any((o) => o.courseId == c.id))
        .toList();

    final prereqValidation = appService.prerequisiteValidation;
    final creditValidation = appService.creditLimitValidation;
    final clashes = appService.selectedTimetableClashes;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Welcome Banner & Stats Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${RuslLocalization.tr("welcome_back")}, ${student.fullName}! 👋',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: isWide ? 32 : 24,
                                fontWeight: FontWeight.w800,
                                color: RuslColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${student.facultyName} • ${student.programmeName} • Level ${student.currentLevel} Sem ${student.currentSemester}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: isWide ? 14 : 12,
                                fontWeight: FontWeight.w500,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Responsive Stat Cards Row / Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      StatMetricCard(
                        value: '$totalCredits / ${student.maxAllowedCredits}',
                        label: RuslLocalization.tr('registered_credits'),
                        icon: Icons.auto_awesome_rounded,
                      ),
                      StatMetricCard(
                        value: '${student.completedCourseIds.length}',
                        label: RuslLocalization.tr('completed_courses'),
                        icon: Icons.task_alt_rounded,
                      ),
                      StatMetricCard(
                        value: appService.activeRegistrationStatus.label,
                        label: RuslLocalization.tr('status'),
                        icon: Icons.verified_user_rounded,
                      ),
                      StatMetricCard(
                        value: RuslLocalization.tr('good_standing'),
                        label: RuslLocalization.tr('academic_standing'),
                        icon: Icons.school_rounded,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Real-time Validation Warning / Error Banners
          if (!prereqValidation.isValid)
            ...prereqValidation.errors.map(
              (err) => _buildAlertBanner(
                context,
                err,
                Icons.error_outline_rounded,
                RuslColors.errorRed,
              ),
            ),

          if (!creditValidation.isValid)
            ...creditValidation.errors.map(
              (err) => _buildAlertBanner(
                context,
                err,
                Icons.warning_amber_rounded,
                RuslColors.warningOrange,
              ),
            ),

          if (clashes.isNotEmpty)
            ...clashes.map(
              (clash) => _buildAlertBanner(
                context,
                '${RuslLocalization.tr("clash_detected")}: "${clash.courseA.code}" & "${clash.courseB.code}" on ${clash.day} at ${clash.timeRange}.',
                Icons.schedule_rounded,
                RuslColors.errorRed,
              ),
            ),

          const SizedBox(height: 16),

          // Navigation Pill Tabs Row
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              PillTab(
                label: RuslLocalization.tr('tab_course_selection'),
                isActive: _activeTabIndex == 0,
                onTap: () => setState(() => _activeTabIndex = 0),
              ),
              PillTab(
                label:
                    '${RuslLocalization.tr("tab_my_selection")} (${selectedOfferings.length})',
                isActive: _activeTabIndex == 1,
                onTap: () => setState(() => _activeTabIndex = 1),
              ),
              PillTab(
                label: RuslLocalization.tr('tab_timetable'),
                isActive: _activeTabIndex == 2,
                onTap: () => setState(() => _activeTabIndex = 2),
              ),
              PillTab(
                label: RuslLocalization.tr('tab_special_requests'),
                isActive: _activeTabIndex == 3,
                onTap: () => setState(() => _activeTabIndex = 3),
              ),
              PillTab(
                label: RuslLocalization.tr('tab_approval_status'),
                isActive: _activeTabIndex == 4,
                onTap: () => setState(() => _activeTabIndex = 4),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TAB 0: Course Catalog Grid
          if (_activeTabIndex == 0) _buildCourseSelectionGrid(appService),

          // TAB 1: Selected Courses Review & Action Bar
          if (_activeTabIndex == 1)
            _buildSelectedCoursesView(
              appService,
              selectedOfferings,
              selectedCourses,
            ),

          // TAB 2: Timetable Visualizer
          if (_activeTabIndex == 2)
            _buildTimetableGrid(
              appService.timetableEligibleOfferings,
              appService,
            ),

          // TAB 3: Special Requests Manager
          if (_activeTabIndex == 3) _buildSpecialRequestsView(appService),

          // TAB 4: Multi-Tier Approval Status & Verification Slip
          if (_activeTabIndex == 4) _buildApprovalStatusView(appService),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(
    BuildContext context,
    String message,
    IconData icon,
    Color color, {
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _buildCourseSelectionGrid(AppService appService) {
    // Filter courses by category and search query
    final query = _searchController.text.toLowerCase().trim();
    final filteredOfferings = appService.courseOfferings.where((offering) {
      final course = appService.courses.firstWhere(
        (c) => c.id == offering.courseId,
      );

      // Category filter
      if (_selectedCategoryFilter == 'compulsory' &&
          course.courseType != CourseType.compulsory) {
        return false;
      }
      if (_selectedCategoryFilter == 'elective' &&
          course.courseType != CourseType.elective) {
        return false;
      }

      // Search filter
      if (query.isNotEmpty) {
        final matchesCode = course.code.toLowerCase().contains(query);
        final matchesTitle = course.title.toLowerCase().contains(query);
        final matchesLecturer = offering.lecturerName.toLowerCase().contains(
          query,
        );
        if (!matchesCode && !matchesTitle && !matchesLecturer) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header & Search / Filter Controls
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RuslLocalization.tr('semester_offerings'),
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: RuslColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${RuslLocalization.tr("showing_courses")}: ${filteredOfferings.length} / ${appService.courseOfferings.length}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: RuslColors.textMuted,
                  ),
                ),
              ],
            ),

            // Search Bar & Filters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search Input Box
                SizedBox(
                  width: 220,
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: RuslLocalization.tr('search_courses'),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      filled: true,
                      fillColor: RuslColors.pureWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: RuslColors.borderGrey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: RuslColors.borderGrey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Category Filter Chips
                _buildFilterChip('all', RuslLocalization.tr('filter_all')),
                _buildFilterChip(
                  'compulsory',
                  RuslLocalization.tr('filter_compulsory'),
                ),
                _buildFilterChip(
                  'elective',
                  RuslLocalization.tr('filter_elective'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1100
                ? 3
                : constraints.maxWidth > 700
                ? 2
                : 1;

            if (filteredOfferings.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RuslColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RuslColors.borderGrey),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No course offerings match your filter query.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: crossAxisCount == 1
                    ? 1.5
                    : (crossAxisCount == 2 ? 1.25 : 1.18),
              ),
              itemCount: filteredOfferings.length,
              itemBuilder: (context, index) {
                final offering = filteredOfferings[index];
                final course = appService.courses.firstWhere(
                  (c) => c.id == offering.courseId,
                );
                final isSelected = appService.selectedOfferingIds.contains(
                  offering.id,
                );
                return CourseCardItem(
                  course: course,
                  offering: offering,
                  isSelected: isSelected,
                  onToggle: () => appService.toggleCourseSelection(offering.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategoryFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedCategoryFilter = value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RuslColors.darkText : RuslColors.pureWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? RuslColors.darkText : RuslColors.borderGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? RuslColors.accentYellow : RuslColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCoursesView(
    AppService appService,
    List<CourseOffering> selectedOfferings,
    List<Course> selectedCourses,
  ) {
    final prereqValidation = appService.prerequisiteValidation;
    final creditValidation = appService.creditLimitValidation;
    final clashes = appService.selectedTimetableClashes;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 14,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Registration Summary',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: RuslColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Selected: ${appService.totalSelectedCredits} Credits (Min 12 - Max 24)',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      color: RuslColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(RuslLocalization.tr('download_slip_qr')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RuslColors.cardSubtle,
                      foregroundColor: RuslColors.darkText,
                      elevation: 0,
                      side: const BorderSide(color: RuslColors.borderGrey),
                    ),
                    onPressed: () {
                      RuslPdfGenerator.downloadPdf(
                        appService.activeStudent,
                        selectedOfferings,
                        appService.courses,
                        appService.verificationToken,
                      );
                    },
                  ),
                  if (appService.activeRegistrationStatus ==
                          RegistrationStatus.draft ||
                      appService.activeRegistrationStatus ==
                          RegistrationStatus.changesRequested)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RuslColors.darkText,
                        foregroundColor: RuslColors.accentYellow,
                      ),
                      onPressed: () {
                        if (!creditValidation.isValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(creditValidation.errors.join('\n')),
                            ),
                          );
                          return;
                        }
                        if (!prereqValidation.isValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(prereqValidation.errors.join('\n')),
                            ),
                          );
                          return;
                        }
                        if (clashes.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(
                                'Timetable clash detected between ${clashes.first.courseA.code} and ${clashes.first.courseB.code}. Please resolve before submitting.',
                              ),
                            ),
                          );
                          return;
                        }

                        appService.submitRegistration();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Course registration submitted successfully for Head of Department (HoD) endorsement.',
                            ),
                          ),
                        );
                      },
                      child: Text(RuslLocalization.tr('submit_registration')),
                    ),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: RuslColors.borderGrey),

          // Course Table
          if (selectedOfferings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No courses selected yet. Please select courses from Course Selection tab.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedOfferings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offering = selectedOfferings[index];
                final course = selectedCourses.firstWhere(
                  (c) => c.id == offering.courseId,
                );

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: RuslColors.accentYellow,
                        child: Text(
                          '${course.creditValue}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: RuslColors.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${course.code} - ${course.title}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lecturer: ${offering.lecturerName} • Venue: ${offering.slots.firstOrNull?.venue ?? "TBA"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: RuslColors.errorRed,
                        ),
                        onPressed: () =>
                            appService.toggleCourseSelection(offering.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid(
    List<CourseOffering> selectedOfferings,
    AppService appService,
  ) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final repeatRegistrations = appService.activeRepeatOrMedicalRegistrations;
    final hasRepeatExemptions = repeatRegistrations.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
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
                  'Weekly Timetable Schedule (${RuslLocalization.tr("tab_timetable")})',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: RuslColors.darkText,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedOfferings.length} Scheduled Courses',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (hasRepeatExemptions)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${repeatRegistrations.length} Repeat/Medical (Exempt)',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Policy notification banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lecture Attendance Policy: Under university regulations, students registered for Repeat or Medical concession subjects are exempt from lecture attendance. Repeat/medical subjects do not require weekly timetable slots and do not cause timetable clashes.',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF134E4A),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (selectedOfferings.isEmpty && hasRepeatExemptions)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: Colors.amber.shade900,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Weekly Lectures Required',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All your currently registered subjects are Repeat or Medical exam-only modules. You do not need to attend lectures, and no timetable scheduling is required.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: Colors.brown.shade800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: days.map((day) {
                final daySlots = <TimetableSlot>[];
                for (var offering in selectedOfferings) {
                  for (var slot in offering.slots) {
                    if (slot.dayOfWeek.toLowerCase() == day.toLowerCase()) {
                      daySlots.add(slot);
                    }
                  }
                }

                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: RuslColors.pureWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (daySlots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Free Day',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ),
                        )
                      else
                        ...daySlots.map((slot) {
                          final offering = appService.courseOfferings
                              .firstWhere((o) => o.slots.contains(slot));
                          final course = appService.courses.firstWhere(
                            (c) => c.id == offering.courseId,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: RuslColors.pureWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: RuslColors.accentYellow,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${slot.startTime} - ${slot.endTime}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  slot.venue,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (hasRepeatExemptions) ...[
            const SizedBox(height: 24),
            const Divider(color: RuslColors.borderGrey),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    size: 18,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance-Exempt Registered Subjects (Exam Only)',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: RuslColors.darkText,
                        ),
                      ),
                      Text(
                        'These subjects are registered for examination only and are exempt from weekly lecture attendance.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
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
            ...repeatRegistrations.map((record) {
              final isMedical = record.isMedical;
              final badgeLabel = isMedical
                  ? 'MEDICAL CONCESSION (EXAM ONLY)'
                  : record.isFailGrade
                      ? 'FAILED REPEAT (EXAM ONLY)'
                      : 'GRADE UPGRADE (EXAM ONLY)';
              final badgeColor = isMedical
                  ? const Color(0xFF2563EB)
                  : record.isFailGrade
                      ? RuslColors.errorRed
                      : RuslColors.warningOrange;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RuslColors.borderGrey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                record.courseCode,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            record.courseTitle,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: RuslColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No Lectures',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialRequestsView(AppService appService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            RuslLocalization.tr('special_requests_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            RuslLocalization.tr('request_type'),
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _specialTypeController.text.isNotEmpty
                ? _specialTypeController.text
                : 'Credit Overload',
            items: [
              DropdownMenuItem(
                value: 'Credit Overload',
                child: Text(RuslLocalization.tr('credit_overload')),
              ),
              DropdownMenuItem(
                value: 'Prerequisite Waiver',
                child: Text(RuslLocalization.tr('prerequisite_waiver')),
              ),
              DropdownMenuItem(
                value: 'Cross-Department Elective',
                child: Text(RuslLocalization.tr('cross_department')),
              ),
              DropdownMenuItem(
                value: 'Exam Repeat',
                child: Text(RuslLocalization.tr('exam_repeat')),
              ),
            ],
            onChanged: (v) {
              if (v != null) _specialTypeController.text = v;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: RuslColors.lightGreyBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            RuslLocalization.tr('explanation'),
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _specialReasonController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: RuslColors.lightGreyBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText:
                  'Enter justification (e.g. Requesting credit overload for research completion)',
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RuslColors.accentYellow,
              foregroundColor: RuslColors.darkText,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_specialReasonController.text.isNotEmpty) {
                appService.submitSpecialRequest(
                  _specialTypeController.text,
                  _specialReasonController.text,
                );
                _specialReasonController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Special Request Submitted Successfully!'),
                    backgroundColor: RuslColors.successGreen,
                  ),
                );
              }
            },
            child: Text(
              RuslLocalization.tr('submit_petition'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Request History & HoD Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (appService.specialRequests.isEmpty)
            const Text(
              'No special petitions submitted yet.',
              style: TextStyle(color: RuslColors.textMuted),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appService.specialRequests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = appService.specialRequests[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.requestType,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              req.explanation,
                              style: const TextStyle(
                                fontSize: 12,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: req.status == SpecialRequestStatus.approved
                              ? RuslColors.accentYellow
                              : RuslColors.cardSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RuslColors.borderGrey),
                        ),
                        child: Text(
                          req.status.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatusView(AppService appService) {
    final status = appService.activeRegistrationStatus;
    final student = appService.activeStudent;
    final selectedOfferings = appService.courseOfferings
        .where((o) => appService.selectedOfferingIds.contains(o.id))
        .toList();
    final selectedCourses = appService.courses
        .where((c) => selectedOfferings.any((o) => o.courseId == c.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Approval Stepper Timeline
        ApprovalTimelineWidget(
          status: status,
          history: appService.approvalHistoryList,
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Text(
                    RuslLocalization.tr('official_slip_title'),
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  StatusPillBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${RuslLocalization.tr("digital_token")}: ${appService.verificationToken}',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  color: RuslColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  PdfSlipGenerator.downloadOrPrintPdf(
                    student: student,
                    registeredCourses: selectedCourses,
                    totalCredits: appService.totalSelectedCredits,
                    academicYear: '2025/2026',
                    semesterNumber: 1,
                    verificationCode: appService.verificationToken,
                    status: status.label,
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(RuslLocalization.tr('download_slip')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RuslColors.accentYellow,
                  foregroundColor: RuslColors.darkText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (status == RegistrationStatus.registered ||
                  status == RegistrationStatus.locked) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    AdmissionCardPdfGenerator.download(
                      student: student,
                      courses: selectedCourses,
                      verificationCode: appService.verificationToken,
                    );
                  },
                  icon: const Icon(Icons.badge_rounded, size: 18),
                  label: const Text('Download Examination Admission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RuslColors.darkText,
                    foregroundColor: RuslColors.accentYellow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildWaitingListsView(AppService appService) {
    final activeEntries = appService.waitingListEntries
        .where((w) => w.status != WaitingListStatus.cancelled)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 14,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RuslLocalization.tr('tab_waiting_lists'),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RuslLocalization.tr('waiting_sub_header'),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Demo Simulate Drop Action Button
                      if (activeEntries.any(
                        (w) => w.status == WaitingListStatus.waiting,
                      ))
                        OutlinedButton.icon(
                          onPressed: () {
                            final waitItem = activeEntries.firstWhere(
                              (w) => w.status == WaitingListStatus.waiting,
                            );
                            appService.processAutoSeatPromotion(
                              waitItem.offeringId,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Simulation: Seat dropped! Candidate promoted for ${waitItem.courseCode}.',
                                ),
                                backgroundColor: RuslColors.successGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.flash_on_rounded, size: 14),
                          label: const Text('Simulate Seat Drop (Demo)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RuslColors.darkText,
                            side: const BorderSide(
                              color: RuslColors.borderGrey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: RuslColors.accentYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${activeEntries.length} ${RuslLocalization.tr("active_queues")}',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (activeEntries.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        RuslLocalization.tr('waiting_list_empty'),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = activeEntries[index];
                    final isPromoted = entry.isPromoted;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isPromoted
                            ? RuslColors.successGreen.withValues(alpha: 0.08)
                            : RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isPromoted
                              ? RuslColors.successGreen
                              : RuslColors.borderGrey,
                          width: isPromoted ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isPromoted
                                  ? RuslColors.successGreen
                                  : RuslColors.accentYellow,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPromoted
                                  ? Icons.notification_important_rounded
                                  : Icons.hourglass_top_rounded,
                              color: isPromoted
                                  ? RuslColors.pureWhite
                                  : RuslColors.darkText,
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
                                    Expanded(
                                      child: Text(
                                        '${entry.courseCode} — ${entry.courseTitle}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPromoted
                                            ? RuslColors.successGreen
                                            : RuslColors.warningOrange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isPromoted
                                            ? RuslLocalization.tr(
                                                'seat_promoted',
                                              )
                                            : 'Queue #${entry.position}',
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPromoted
                                      ? RuslLocalization.tr(
                                          'queue_promoted_msg',
                                        )
                                      : RuslLocalization.tr(
                                          'queue_waiting_msg',
                                        ),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: isPromoted
                                        ? RuslColors.successGreen
                                        : RuslColors.textMuted,
                                    fontWeight: isPromoted
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isPromoted)
                            ElevatedButton.icon(
                              onPressed: () {
                                appService.acceptPromotedSeat(entry.offeringId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      RuslLocalization.tr('seat_claimed_msg'),
                                    ),
                                    backgroundColor: RuslColors.successGreen,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                              ),
                              label: Text(RuslLocalization.tr('claim_seat')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RuslColors.successGreen,
                                foregroundColor: RuslColors.pureWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () =>
                                  appService.leaveWaitingList(entry.offeringId),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: Text(
                                RuslLocalization.tr('leave_waiting_list'),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RuslColors.errorRed,
                                side: BorderSide(
                                  color: RuslColors.errorRed.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
