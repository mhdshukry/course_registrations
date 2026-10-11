import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../domain/validation_engine.dart';
import '../../services/app_service.dart';

class SubjectRegistrationProScreen extends StatelessWidget {
  const SubjectRegistrationProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final offerings = app.courseOfferings.where((o) {
      final c = app.courses.firstWhere((c) => c.id == o.courseId);
      return c.level == app.activeStudent.currentLevel &&
          c.semester == app.activeStudent.currentSemester;
    }).toList();
    final compulsory = offerings
        .where((o) => _course(app, o).courseType == CourseType.compulsory)
        .toList();
    final optional = offerings
        .where((o) => _course(app, o).courseType != CourseType.compulsory)
        .toList();
    final selected = offerings
        .where((o) => app.selectedOfferingIds.contains(o.id))
        .map((o) => _course(app, o))
        .toList();
    final validation = ValidationEngine.validateCreditLimits(
      student: app.activeStudent,
      selectedCourses: selected,
    );
    final editable =
        app.activeRegistrationStatus == RegistrationStatus.draft ||
        app.activeRegistrationStatus == RegistrationStatus.changesRequested ||
        app.activeRegistrationStatus == RegistrationStatus.submitted;

    return LayoutBuilder(
      builder: (context, viewport) {
        final desktop = viewport.maxWidth >= 980;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 32 : 16,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero(app: app),
                  const SizedBox(height: 18),
                  const _Steps(),
                  const SizedBox(height: 24),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SubjectSections(
                            app: app,
                            compulsory: compulsory,
                            optional: optional,
                            editable: editable,
                          ),
                        ),
                        const SizedBox(width: 22),
                        SizedBox(
                          width: 330,
                          child: _Summary(
                            app: app,
                            selected: selected,
                            validation: validation,
                            editable: editable,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _Summary(
                      app: app,
                      selected: selected,
                      validation: validation,
                      editable: editable,
                    ),
                    const SizedBox(height: 24),
                    _SubjectSections(
                      app: app,
                      compulsory: compulsory,
                      optional: optional,
                      editable: editable,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Course _course(AppService app, CourseOffering o) =>
      app.courses.firstWhere((c) => c.id == o.courseId);
}

class _Hero extends StatelessWidget {
  final AppService app;
  const _Hero({required this.app});
  @override
  Widget build(BuildContext context) {
    final days = app.registrationEndDate.difference(DateTime.now()).inDays + 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RuslColors.darkText,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 18,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: RuslColors.accentYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.isRegistrationOpen
                        ? 'REGISTRATION OPEN'
                        : 'REGISTRATION CLOSED',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Semester Subject Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${app.activeStudent.programmeName}  •  Level ${app.activeStudent.currentLevel}  •  Semester ${app.activeStudent.currentSemester}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: RuslColors.accentYellow,
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.isRegistrationOpen && days > 0
                          ? '$days days remaining'
                          : 'Window unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Closes ${app.registrationEndLabel}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();
  @override
  Widget build(BuildContext context) {
    const data = [
      (Icons.menu_book_rounded, 'Review subjects'),
      (Icons.checklist_rounded, 'Choose optional'),
      (Icons.verified_outlined, 'Review & submit'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuslColors.borderGrey),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final items = data.indexed
              .map(
                (e) => _Step(number: e.$1 + 1, icon: e.$2.$1, label: e.$2.$2),
              )
              .toList();
          if (box.maxWidth < 620) {
            return Column(
              children: items
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: w,
                    ),
                  )
                  .toList(),
            );
          }
          return Row(
            children: items.indexed
                .expand(
                  (e) => [
                    Expanded(child: e.$2),
                    if (e.$1 < items.length - 1)
                      const Expanded(child: Divider()),
                  ],
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;
  const _Step({required this.number, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: RuslColors.accentYellow.withValues(alpha: .35),
        child: Icon(icon, size: 17),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          '$number. $label',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _SubjectSections extends StatelessWidget {
  final AppService app;
  final List<CourseOffering> compulsory;
  final List<CourseOffering> optional;
  final bool editable;
  const _SubjectSections({
    required this.app,
    required this.compulsory,
    required this.optional,
    required this.editable,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(
        icon: Icons.lock_outline,
        title: 'Compulsory subjects',
        subtitle: '${compulsory.length} assigned by your curriculum',
      ),
      const SizedBox(height: 10),
      ...compulsory.map(
        (o) => _SubjectCard(
          course: SubjectRegistrationProScreen._course(app, o),
          offering: o,
          compulsory: true,
          selected: true,
          enabled: false,
          onTap: null,
        ),
      ),
      const SizedBox(height: 24),
      const _SectionTitle(
        icon: Icons.tune_rounded,
        title: 'Optional subjects',
        subtitle: 'Select the subjects you want to register',
      ),
      const SizedBox(height: 10),
      ...optional.map(
        (o) {
          final course = SubjectRegistrationProScreen._course(app, o);
          final isDropped = app.isCourseDropped(course.code);
          return _SubjectCard(
            course: course,
            offering: o,
            compulsory: false,
            selected: app.selectedOfferingIds.contains(o.id),
            enabled: editable && app.isRegistrationOpen && !isDropped,
            onTap: isDropped ? null : () => app.toggleCourseSelection(o.id),
          );
        },
      ),
      if (app.repeatEligibleAcademicRecords.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.replay_rounded,
          title: 'Repeat Examination Subjects',
          subtitle:
              '${app.repeatEligibleAcademicRecords.length} subject(s) eligible (Medical / Results Failed)',
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF0D9488).withValues(alpha: .3),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.event_available_rounded,
                color: Color(0xFF0F766E),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lecture Attendance Exemption: Under university regulations, students registered for Repeat or Medical concession subjects are exempt from lecture attendance. Repeat modules are exam-only, do not appear on your weekly timetable, and will not cause schedule clashes.',
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
        const SizedBox(height: 12),
        ...app.repeatEligibleAcademicRecords.map(
          (record) => _RepeatSubjectCard(
            record: record,
            reason: app.repeatReasonFor(record),
            requested: app.requestedRepeatRecordIds.contains(record.id),
            enabled: editable && app.isRegistrationOpen,
            onChanged: () => app.toggleRepeatSubjectRequest(record.id),
          ),
        ),
      ],
      if (app.droppedAcademicRecords.isNotEmpty) ...[
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: RuslColors.errorRed.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RuslColors.errorRed.withValues(alpha: .25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.block_rounded, color: RuslColors.errorRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dropped Subjects (Cannot Re-register)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: RuslColors.errorRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Under faculty academic regulations, once a student drops a subject, they cannot register for it again. Dropped: ${app.droppedAcademicRecords.map((r) => "${r.courseCode} (${r.courseTitle})").join(", ")}.',
                      style: const TextStyle(
                        fontSize: 11,
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
      ],
    ],
  );
}

class _RepeatSubjectCard extends StatelessWidget {
  final AcademicCourseRecord record;
  final String reason;
  final bool requested;
  final bool enabled;
  final VoidCallback onChanged;

  const _RepeatSubjectCard({
    required this.record,
    required this.reason,
    required this.requested,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: requested
          ? RuslColors.warningOrange.withValues(alpha: .08)
          : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: requested ? RuslColors.warningOrange : RuslColors.borderGrey,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: RuslColors.warningOrange.withValues(alpha: .15),
          foregroundColor: RuslColors.warningOrange,
          child: const Icon(Icons.replay_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record.courseCode} - ${record.courseTitle}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 7,
                runSpacing: 5,
                children: [
                  _Tag(reason, strong: true),
                  _Tag('${record.credits} credits'),
                  _Tag(record.semesterLabel),
                  const _Tag('Exam Only • Attendance Exempt', strong: true),
                ],
              ),
              const SizedBox(height: 7),
              const Text(
                'The original attempt remains in the academic record. AR verifies eligibility and assigns the exam offering. No lecture attendance or weekly timetable schedule is required.',
                style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
              ),
            ],
          ),
        ),
        Checkbox(
          value: requested,
          onChanged: enabled ? (_) => onChanged() : null,
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: RuslColors.accentYellow.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SubjectCard extends StatelessWidget {
  final Course course;
  final CourseOffering offering;
  final bool compulsory;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  const _SubjectCard({
    required this.course,
    required this.offering,
    required this.compulsory,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final slot = offering.slots.firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? RuslColors.accentYellow.withValues(alpha: .1)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? RuslColors.accentYellow : RuslColors.borderGrey,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: selected
                        ? RuslColors.accentYellow
                        : RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    compulsory
                        ? Icons.lock_rounded
                        : (selected ? Icons.check_rounded : Icons.add_rounded),
                  ),
                ),
                const SizedBox(width: 14),
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
                            course.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          _Tag(course.courseType.nameLabel, strong: compulsory),
                          _Tag('${course.creditValue} credits'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _Meta(Icons.person_outline, offering.lecturerName),
                          if (slot != null)
                            _Meta(
                              Icons.calendar_today_outlined,
                              '${slot.dayOfWeek} • ${slot.startTime}–${slot.endTime}',
                            ),
                          if (slot != null)
                            _Meta(Icons.location_on_outlined, slot.venue),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!compulsory) ...[
                  const SizedBox(width: 6),
                  Checkbox(
                    value: selected,
                    onChanged: enabled ? (_) => onTap?.call() : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool strong;
  const _Tag(this.text, {this.strong = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: strong ? RuslColors.darkText : RuslColors.cardSubtle,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: strong ? Colors.white : RuslColors.darkText,
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: RuslColors.textMuted),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
      ),
    ],
  );
}

class _Summary extends StatelessWidget {
  final AppService app;
  final List<Course> selected;
  final ValidationResult validation;
  final bool editable;
  const _Summary({
    required this.app,
    required this.selected,
    required this.validation,
    required this.editable,
  });
  @override
  Widget build(BuildContext context) {
    final credits = app.totalSelectedCredits;
    final max = app.activeStudent.maxAllowedCredits;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RuslColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registration summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _Metric('${selected.length}', 'Subjects')),
              const SizedBox(width: 10),
              Expanded(child: _Metric('$credits', 'Credits')),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Credit load',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '$credits / $max',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (credits / max).clamp(0, 1),
              minHeight: 9,
              backgroundColor: RuslColors.cardSubtle,
              valueColor: AlwaysStoppedAnimation(
                validation.isValid
                    ? RuslColors.successGreen
                    : RuslColors.warningOrange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Required range: ${app.activeStudent.minAllowedCredits}–$max credits',
            style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (validation.isValid
                          ? RuslColors.successGreen
                          : RuslColors.warningOrange)
                      .withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  validation.isValid
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 19,
                  color: validation.isValid
                      ? RuslColors.successGreen
                      : RuslColors.warningOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validation.isValid
                        ? 'Your selection meets the credit requirement.'
                        : validation.errors.first,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: editable && app.isRegistrationOpen
                  ? () => _review(context)
                  : null,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Review & submit'),
            ),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'You can review everything before final submission.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: RuslColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _review(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm subject registration'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selected.length} subjects • ${app.totalSelectedCredits} credits',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...selected.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 17,
                        color: RuslColors.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${c.code} — ${c.title}')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'After submission, changes require approval or a returned registration.',
                style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continue editing'),
          ),
          FilledButton(
            onPressed: validation.isValid
                ? () => Navigator.pop(dialogContext, true)
                : null,
            child: const Text('Confirm submission'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = app.submitRegistration();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Subject registration submitted successfully.'
              : (app.selectedTimetableClashes.isNotEmpty
                    ? 'Registration blocked: Timetable clash between ${app.selectedTimetableClashes.first.courseA.code} and ${app.selectedTimetableClashes.first.courseB.code} on ${app.selectedTimetableClashes.first.day}.'
                    : 'Registration could not be submitted. Verify credit limits and compulsory course requirements.'),
        ),
        backgroundColor: ok ? RuslColors.successGreen : RuslColors.errorRed,
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: RuslColors.cardSubtle,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: RuslColors.textMuted),
        ),
      ],
    ),
  );
}
