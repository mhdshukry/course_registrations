import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final selected = app.timetableEligibleOfferings;
    final repeatRegistrations = app.activeRepeatOrMedicalRegistrations;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: RuslColors.darkText,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEEKLY ACADEMIC SCHEDULE',
                    style: TextStyle(
                      color: RuslColors.accentYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'My Timetable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    app.currentAcademicYearLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${selected.length} Lecture Module${selected.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (repeatRegistrations.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: RuslColors.accentYellow.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: RuslColors.accentYellow.withValues(alpha: .5),
                        ),
                      ),
                      child: Text(
                        '${repeatRegistrations.length} Repeat/Medical (Attendance-Exempt)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // University Attendance Policy Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RuslColors.accentYellow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: RuslColors.accentYellow.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: RuslColors.darkText,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Attendance Policy for Repeat & Medical Subjects',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: RuslColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Under Faculty of Technology Academic Regulations, students registering for Repeat Examination or Medical Concession subjects are NOT required to attend lectures. Consequently, these subjects are excluded from your lecture timetable and do not cause timetable clashes.',
                      style: TextStyle(
                        fontSize: 12,
                        color: RuslColors.darkText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Repeat & Medical Attendance-Exempt Subjects Section
        if (repeatRegistrations.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendance-Exempt Registered Subjects',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: RuslColors.darkText,
                            ),
                          ),
                          Text(
                            '${repeatRegistrations.length} Repeat / Medical Examination Module(s) • Examination Registration Active',
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
                const Divider(height: 24),
                ...repeatRegistrations.map((rec) {
                  final isMed = rec.isMedical;
                  final badgeColor = isMed ? Colors.teal : RuslColors.warningOrange;
                  final badgeLabel = isMed
                      ? 'MEDICAL CONCESSION (EXAM ONLY)'
                      : (rec.isFailGrade
                          ? 'FAILED REPEAT (EXAM ONLY)'
                          : 'GRADE UPGRADE (EXAM ONLY)');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: RuslColors.borderGrey.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isMed ? Icons.medical_services_outlined : Icons.replay_rounded,
                          color: badgeColor,
                          size: 22,
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
                                    rec.courseCode,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: RuslColors.darkText,
                                    ),
                                  ),
                                  Text(
                                    rec.courseTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      badgeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: RuslColors.borderGrey),
                                    ),
                                    child: Text(
                                      '${rec.credits} Credits • Level ${rec.level}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '• No lecture attendance required. You do not need this on your timetable. Sit for the end-semester examination as per the official exam timetable.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: RuslColors.textMuted,
                                  height: 1.3,
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

        if (app.selectedTimetableClashes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RuslColors.errorRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RuslColors.errorRed.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: RuslColors.errorRed,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timetable Schedule Clash Detected (${app.selectedTimetableClashes.length})',
                        style: const TextStyle(
                          color: RuslColors.errorRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Conflicting modules: ${app.selectedTimetableClashes.map((c) => "${c.courseA.code} & ${c.courseB.code} (${c.day} ${c.timeRange})").join("; ")}. Please drop one conflicting elective before submitting.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: RuslColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        if (selected.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: RuslColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    repeatRegistrations.isNotEmpty
                        ? 'No Weekly Lectures Required'
                        : 'No Classes Scheduled',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: RuslColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    repeatRegistrations.isNotEmpty
                        ? 'All your registered courses for this semester are Repeat / Medical examination modules. Lecture attendance is not required, so no class timetable is needed.'
                        : 'You have not enrolled in any lecture modules for this semester.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RuslColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...days.map((day) {
          final entries = <(Course, TimetableSlot)>[];
          for (final offering in selected) {
            final course = app.courses.firstWhere(
              (c) => c.id == offering.courseId,
            );
            for (final slot in offering.slots.where(
              (s) => s.dayOfWeek == day,
            )) {
              entries.add((course, slot));
            }
          }
          entries.sort((a, b) => a.$2.startTime.compareTo(b.$2.startTime));
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: RuslColors.accentYellow.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          day.substring(0, 3).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'class' : 'classes'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'No classes scheduled',
                        style: TextStyle(color: RuslColors.textMuted),
                      ),
                    )
                  else
                    ...entries.map(
                      (entry) {
                        final isClashing = app.selectedTimetableClashes.any(
                          (clash) =>
                              clash.day == day &&
                              (clash.courseA.id == entry.$1.id ||
                                  clash.courseB.id == entry.$1.id),
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: isClashing
                                ? RuslColors.errorRed.withValues(alpha: 0.08)
                                : RuslColors.cardSubtle,
                            borderRadius: BorderRadius.circular(13),
                            border: isClashing
                                ? Border.all(
                                    color: RuslColors.errorRed
                                        .withValues(alpha: 0.5),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 92,
                                child: Text(
                                  '${entry.$2.startTime}\n${entry.$2.endTime}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isClashing
                                        ? RuslColors.errorRed
                                        : RuslColors.darkText,
                                  ),
                                ),
                              ),
                              Container(
                                width: 3,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isClashing
                                      ? RuslColors.errorRed
                                      : RuslColors.accentYellow,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.$1.code} • ${entry.$1.title}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${entry.$2.groupType} • ${entry.$2.venue}',
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
                      );
                    }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
