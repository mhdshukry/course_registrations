import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../domain/validation_engine.dart';
import '../../services/app_service.dart';

class SubjectRegistrationScreen extends StatelessWidget {
  const SubjectRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final offerings = app.courseOfferings.where((offering) {
      final course = app.courses.firstWhere(
        (item) => item.id == offering.courseId,
      );
      return course.level == app.activeStudent.currentLevel &&
          course.semester == app.activeStudent.currentSemester;
    }).toList();
    final selectedCourses = app.courses
        .where(
          (course) => offerings.any(
            (offering) =>
                offering.courseId == course.id &&
                app.selectedOfferingIds.contains(offering.id),
          ),
        )
        .toList();
    final creditCheck = ValidationEngine.validateCreditLimits(
      student: app.activeStudent,
      selectedCourses: selectedCourses,
    );
    final editable =
        app.activeRegistrationStatus == RegistrationStatus.draft ||
        app.activeRegistrationStatus == RegistrationStatus.changesRequested;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _WindowBanner(app: app),
        const SizedBox(height: 20),
        Text(
          'Assigned semester subjects',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Compulsory subjects are assigned automatically. Select only the optional subjects you wish to register.',
          style: TextStyle(color: RuslColors.textMuted),
        ),
        const SizedBox(height: 16),
        ...offerings.map((offering) {
          final course = app.courses.firstWhere(
            (item) => item.id == offering.courseId,
          );
          final compulsory = course.courseType == CourseType.compulsory;
          final selected =
              compulsory || app.selectedOfferingIds.contains(offering.id);
          return _SubjectTile(
            course: course,
            offering: offering,
            compulsory: compulsory,
            selected: selected,
            enabled: editable && app.isRegistrationOpen,
            onChanged: compulsory
                ? null
                : (_) => app.toggleCourseSelection(offering.id),
          );
        }),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuslColors.borderGrey),
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
                  Text(
                    '${selectedCourses.length} subjects selected • ${app.totalSelectedCredits} credits',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Allowed credit load: ${app.activeStudent.minAllowedCredits}–${app.activeStudent.maxAllowedCredits} credits',
                    style: TextStyle(
                      color: creditCheck.isValid
                          ? RuslColors.textMuted
                          : RuslColors.errorRed,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: editable && app.isRegistrationOpen
                    ? () => _submit(context, app, creditCheck)
                    : null,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit registration'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit(
    BuildContext context,
    AppService app,
    ValidationResult creditCheck,
  ) {
    if (!creditCheck.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creditCheck.errors.join('\n')),
          backgroundColor: RuslColors.errorRed,
        ),
      );
      return;
    }
    final submitted = app.submitRegistration();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          submitted
              ? 'Your subject registration was submitted successfully.'
              : (app.selectedTimetableClashes.isNotEmpty
                  ? 'Registration blocked: Timetable clash between ${app.selectedTimetableClashes.first.courseA.code} and ${app.selectedTimetableClashes.first.courseB.code}.'
                  : 'Registration could not be submitted. Please verify credit limits and compulsory subjects.'),
        ),
        backgroundColor: submitted
            ? RuslColors.successGreen
            : RuslColors.errorRed,
      ),
    );
  }
}

class _WindowBanner extends StatelessWidget {
  final AppService app;
  const _WindowBanner({required this.app});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: app.isRegistrationOpen
          ? RuslColors.accentYellow.withValues(alpha: 0.28)
          : RuslColors.errorRed.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(
          app.isRegistrationOpen ? Icons.event_available : Icons.event_busy,
          color: RuslColors.darkText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.isRegistrationOpen
                    ? 'Registration is open'
                    : 'Registration is closed',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '${app.registrationStartLabel} to ${app.registrationEndLabel}',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SubjectTile extends StatelessWidget {
  final Course course;
  final CourseOffering offering;
  final bool compulsory;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool?>? onChanged;
  const _SubjectTile({
    required this.course,
    required this.offering,
    required this.compulsory,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: compulsory || !enabled ? null : onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${course.code} — ${course.title}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Chip(
                      label: Text(compulsory ? 'Compulsory' : 'Optional'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${course.creditValue} credits • ${offering.lecturerName}',
                  style: const TextStyle(color: RuslColors.textMuted),
                ),
                if (offering.slots.isNotEmpty)
                  Text(
                    '${offering.slots.first.dayOfWeek}, ${offering.slots.first.startTime}–${offering.slots.first.endTime} • ${offering.slots.first.venue}',
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
  );
}
