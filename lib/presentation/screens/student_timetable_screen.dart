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
    final selected = app.courseOfferings
        .where((o) => app.selectedOfferingIds.contains(o.id))
        .toList();
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY ACADEMIC SCHEDULE',
                    style: TextStyle(
                      color: RuslColors.accentYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'My Timetable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '2025/2026 • Semester 1',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
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
                  '${selected.length} registered subjects',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
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
                      (entry) => Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: RuslColors.cardSubtle,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 92,
                              child: Text(
                                '${entry.$2.startTime}\n${entry.$2.endTime}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 42,
                              decoration: BoxDecoration(
                                color: RuslColors.accentYellow,
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
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
