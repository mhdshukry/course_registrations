import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

class StudentAcademicRecordScreen extends StatefulWidget {
  const StudentAcademicRecordScreen({super.key});

  @override
  State<StudentAcademicRecordScreen> createState() =>
      _StudentAcademicRecordScreenState();
}

class _StudentAcademicRecordScreenState
    extends State<StudentAcademicRecordScreen> {
  String _selectedSemesterFilter = 'all';

  Color _statusColor(AcademicRecordStatus status) => switch (status) {
    AcademicRecordStatus.completed => RuslColors.successGreen,
    AcademicRecordStatus.medical => RuslColors.warningOrange,
    AcademicRecordStatus.dropped => RuslColors.errorRed,
  };

  Color _gradeColor(String? grade) {
    if (grade == null) return RuslColors.textMuted;
    final g = grade.toUpperCase().trim();
    if (g.startsWith('A')) return RuslColors.successGreen;
    if (g.startsWith('B')) return const Color(0xFF1976D2);
    if (g.startsWith('C')) return RuslColors.warningOrange;
    return RuslColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final completed = app.completedAcademicCredits;
    final medical = app.creditsForAcademicStatus(AcademicRecordStatus.medical);
    final dropped = app.creditsForAcademicStatus(AcademicRecordStatus.dropped);
    const degreeCredits = 120;
    final cgpa = app.currentCgpa;

    final allRecords = app.academicRecords;
    final filteredRecords = switch (_selectedSemesterFilter) {
      'l1s1' => allRecords.where((r) => r.level == 1 && r.semester == 1).toList(),
      'l1s2' => allRecords.where((r) => r.level == 1 && r.semester == 2).toList(),
      'l2s1' => allRecords.where((r) => r.level == 2 && r.semester == 1).toList(),
      'l2s2' => allRecords.where((r) => r.level == 2 && r.semester == 2).toList(),
      'l3s1' => allRecords.where((r) => r.level == 3 && r.semester == 1).toList(),
      _ => allRecords,
    };

    final semesterCredits = filteredRecords
        .where((r) => r.status == AcademicRecordStatus.completed)
        .fold(0, (acc, r) => acc + r.credits);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title & Verification Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF800000), Color(0xFF5A0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: RuslColors.accentYellow,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Official Academic Record & Transcript History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.activeStudent.fullName} (${app.activeStudent.registrationNumber})\n'
                      'Enrolled: Level ${app.activeStudent.currentLevel} Semester ${app.activeStudent.currentSemester} • Certified by Examination Division RUSL',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Metrics Summary Cards
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Cumulative GPA',
              value: cgpa > 0 ? cgpa.toStringAsFixed(2) : '3.79',
              subtitle: app.currentDegreeClass.fullName,
              color: const Color(0xFF2E7D32),
              icon: Icons.star_rate_rounded,
            ),
            _SummaryCard(
              label: 'Completed credits',
              value: '$completed / $degreeCredits',
              subtitle: '${((completed / degreeCredits) * 100).toStringAsFixed(1)}% Degree completion',
              color: RuslColors.primaryMaroon,
              icon: Icons.school_outlined,
            ),
            _SummaryCard(
              label: 'Previous semesters',
              value: '5 Semesters',
              subtitle: 'Level 1 S1/S2, Level 2 S1/S2, Level 3 S1',
              color: const Color(0xFF1565C0),
              icon: Icons.history_edu_outlined,
            ),
            _SummaryCard(
              label: 'Medical & Dropped',
              value: '$medical Med • $dropped Drop',
              subtitle: 'Audit trail registered',
              color: RuslColors.warningOrange,
              icon: Icons.info_outline,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Filter Bar / Semester Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                key: 'all',
                label: 'All Semesters',
                count: '${allRecords.length} subjects',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'l1s1',
                label: 'Level 1 Sem 1',
                count: '10 Cr',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'l1s2',
                label: 'Level 1 Sem 2',
                count: '12 Cr',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'l2s1',
                label: 'Level 2 Sem 1',
                count: '12 Cr',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'l2s2',
                label: 'Level 2 Sem 2',
                count: '13 Cr',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                key: 'l3s1',
                label: 'Level 3 Sem 1',
                count: '15 Cr',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subject Records Table Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSemesterFilter == 'all'
                        ? 'Full Subject History (${filteredRecords.length} courses)'
                        : 'Subjects: ${_filterLabel(_selectedSemesterFilter)} (${filteredRecords.length} courses)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.primaryMaroon.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Credits: $semesterCredits',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: RuslColors.primaryMaroon,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                        'Code',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Subject Title',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Academic Year',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Semester',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Credits',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Grade',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                  rows: filteredRecords.map((record) {
                    final statusCol = _statusColor(record.status);
                    final gradeCol = _gradeColor(record.grade);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            record.courseCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: RuslColors.primaryMaroon,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 260,
                            child: Text(
                              record.courseTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(record.academicYear)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              record.semesterLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              '${record.credits}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        DataCell(
                          record.grade != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gradeCol.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    record.grade!,
                                    style: TextStyle(
                                      color: gradeCol,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              : const Text('—', style: TextStyle(color: Colors.grey)),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusCol.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              record.isDropped
                                  ? 'Dropped (No Re-reg)'
                                  : (record.isMedical
                                      ? 'Medical (Can Re-reg)'
                                      : (record.isFailedResult
                                          ? 'Failed (Can Re-reg)'
                                          : record.status.label)),
                              style: TextStyle(
                                color: statusCol,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
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
        const SizedBox(height: 14),

        // Information notes
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 16,
                    color: RuslColors.primaryMaroon,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Faculty of Technology Academic Regulations',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: RuslColors.primaryMaroon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• Student is currently registering for Level 3 Semester 2 (2025/2026 Academic Year).\n'
                '• All 5 preceding semesters (Level 1 S1/S2, Level 2 S1/S2, Level 3 S1) totaling 62 completed credits are validated.',
                style: TextStyle(
                  fontSize: 11,
                  color: RuslColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Results & Grading Scale Summary Table
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: RuslColors.borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Official University Results & Grading System',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Pass Grades (≥ 2.0 GP, Credits Earned): A+ (4.0), A (4.0), A- (3.7), B+ (3.3), B (3.0), B- (2.7), C+ (2.3), C (2.0)\n'
                      '• Repeat Grades (< 2.0 GP, Eligible to Upgrade): C- (1.7), D+ (1.3), D (1.0), D- (0.7)\n'
                      '• Fail Results (0.0 GP, Must Repeat Exam): F (0.0), E (0.0), FAIL, REFERRED\n'
                      '• Special Status: Medical Concession (First-attempt repeat allowed) | Dropped (Re-registration strictly prohibited)',
                      style: TextStyle(
                        fontSize: 11,
                        color: RuslColors.darkText,
                        height: 1.5,
                      ),
                    ),
                    const Divider(height: 16),
                    const Text(
                      'Degree Honours Classification (Cumulative GPA)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildDegreeTierBadge(
                          '1st Class',
                          'CGPA ≥ 3.70',
                          const Color(0xFF1B5E20),
                          const Color(0xFFE8F5E9),
                        ),
                        _buildDegreeTierBadge(
                          '2nd Class Upper',
                          '3.50 ≤ CGPA < 3.70',
                          const Color(0xFF0D47A1),
                          const Color(0xFFE3F2FD),
                        ),
                        _buildDegreeTierBadge(
                          '2nd Class Lower',
                          '3.00 ≤ CGPA < 3.50',
                          const Color(0xFF006064),
                          const Color(0xFFE0F7FA),
                        ),
                        _buildDegreeTierBadge(
                          'General Pass',
                          '2.00 ≤ CGPA < 3.00',
                          const Color(0xFFE65100),
                          const Color(0xFFFFF3E0),
                        ),
                        _buildDegreeTierBadge(
                          'Batch Miss',
                          'CGPA < 2.00',
                          RuslColors.errorRed,
                          const Color(0xFFFFEBEE),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String key,
    required String label,
    required String count,
  }) {
    final isSelected = _selectedSemesterFilter == key;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedSemesterFilter = key),
      selectedColor: RuslColors.primaryMaroon,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? RuslColors.primaryMaroon : RuslColors.borderGrey,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : RuslColors.darkText,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(String filter) => switch (filter) {
    'l1s1' => 'Level 1 Semester 1',
    'l1s2' => 'Level 1 Semester 2',
    'l2s1' => 'Level 2 Semester 1',
    'l2s2' => 'Level 2 Semester 2',
    'l3s1' => 'Level 3 Semester 1',
    _ => 'All Semesters',
  };

  Widget _buildDegreeTierBadge(
    String title,
    String criteria,
    Color fg,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$title ($criteria)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 172,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: RuslColors.pureWhite,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: RuslColors.borderGrey),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RuslColors.textMuted,
              ),
            ),
            Icon(icon, size: 16, color: color),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: RuslColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
