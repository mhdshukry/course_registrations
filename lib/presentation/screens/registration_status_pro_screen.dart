import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';
import '../widgets/custom_widgets.dart';

class RegistrationStatusProScreen extends StatelessWidget {
  final VoidCallback? onEditRegistration;
  const RegistrationStatusProScreen({super.key, this.onEditRegistration});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final subjects = app.courseOfferings
        .where((o) => app.selectedOfferingIds.contains(o.id))
        .map((o) => (app.courses.firstWhere((c) => c.id == o.courseId), o))
        .toList();
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
                  _StatusHero(app: app),
                  const SizedBox(height: 20),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _ApprovalJourney(
                            status: app.activeRegistrationStatus,
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _NextAction(
                                app: app,
                                onEditRegistration: onEditRegistration,
                              ),
                              const SizedBox(height: 16),
                              _RegistrationDetails(app: app),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _NextAction(
                      app: app,
                      onEditRegistration: onEditRegistration,
                    ),
                    const SizedBox(height: 16),
                    _ApprovalJourney(status: app.activeRegistrationStatus),
                    const SizedBox(height: 16),
                    _RegistrationDetails(app: app),
                  ],
                  const SizedBox(height: 22),
                  _RegisteredSubjects(subjects: subjects),
                  if (app.approvalHistoryList.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _DecisionHistory(history: app.approvalHistoryList),
                  ],
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusHero extends StatelessWidget {
  final AppService app;
  const _StatusHero({required this.app});
  @override
  Widget build(BuildContext context) {
    final progress = _statusProgress(app.activeRegistrationStatus);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RuslColors.darkText,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 14,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REGISTRATION APPLICATION',
                    style: TextStyle(
                      color: RuslColors.accentYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    '2025/2026 • Semester 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              StatusPillBadge(status: app.activeRegistrationStatus),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: Icons.menu_book_outlined,
                  value: '${app.selectedOfferingIds.length}',
                  label: 'Subjects',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.school_outlined,
                  value: '${app.totalSelectedCredits}',
                  label: 'Credits',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.percent_rounded,
                  value: '${(progress * 100).round()}%',
                  label: 'Progress',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(RuslColors.accentYellow),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: RuslColors.accentYellow, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ApprovalJourney extends StatelessWidget {
  final RegistrationStatus status;
  const _ApprovalJourney({required this.status});
  @override
  Widget build(BuildContext context) {
    final current = _stageIndex(status);
    const stages = [
      (
        'Submitted by student',
        'Your subject selection was sent for review',
        Icons.send_rounded,
      ),
      (
        'Academic Adviser',
        'Curriculum and credit-load verification',
        Icons.person_search_rounded,
      ),
      (
        'Head of Department',
        'Department academic endorsement',
        Icons.account_balance_outlined,
      ),
      (
        'Faculty Coordinator',
        'Faculty-level verification',
        Icons.rule_folder_outlined,
      ),
      (
        'Assistant Registrar',
        'Final confirmation and registration lock',
        Icons.verified_user_outlined,
      ),
    ];
    return _Panel(
      title: 'Approval journey',
      subtitle: 'Track each stage of your registration',
      icon: Icons.route_rounded,
      child: Column(
        children: stages.indexed.map((entry) {
          final index = entry.$1;
          final stage = entry.$2;
          final complete =
              index < current ||
              status == RegistrationStatus.registered ||
              status == RegistrationStatus.locked;
          final active = index == current && !complete;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 42,
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: complete
                              ? RuslColors.successGreen
                              : active
                              ? RuslColors.accentYellow
                              : RuslColors.cardSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          complete ? Icons.check_rounded : stage.$3,
                          size: 17,
                          color: complete ? Colors.white : RuslColors.darkText,
                        ),
                      ),
                      if (index < stages.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: complete
                                ? RuslColors.successGreen
                                : RuslColors.borderGrey,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                stage.$1,
                                style: TextStyle(
                                  fontWeight: active || complete
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: index <= current
                                      ? RuslColors.darkText
                                      : RuslColors.textMuted,
                                ),
                              ),
                            ),
                            if (active) const _MiniBadge('IN PROGRESS'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  final AppService app;
  final VoidCallback? onEditRegistration;
  const _NextAction({required this.app, this.onEditRegistration});
  @override
  Widget build(BuildContext context) {
    final status = app.activeRegistrationStatus;
    final (title, message, icon, color) = switch (status) {
      RegistrationStatus.draft => (
        'Submission required',
        'Review your selected subjects and submit before the registration deadline.',
        Icons.edit_note_rounded,
        RuslColors.warningOrange,
      ),
      RegistrationStatus.changesRequested => (
        'Changes requested',
        'Your adviser returned the registration. Review the comments, update it, and resubmit.',
        Icons.sync_problem_rounded,
        RuslColors.warningOrange,
      ),
      RegistrationStatus.rejected => (
        'Registration rejected',
        'Contact your Academic Adviser for guidance on the next steps.',
        Icons.cancel_outlined,
        RuslColors.errorRed,
      ),
      RegistrationStatus.registered || RegistrationStatus.locked => (
        'Registration complete',
        'Your semester subject registration is officially confirmed.',
        Icons.verified_rounded,
        RuslColors.successGreen,
      ),
      _ => (
        'No action required',
        'Your registration is under review. You will be notified when its status changes.',
        Icons.hourglass_top_rounded,
        RuslColors.successGreen,
      ),
    };
    final canEdit =
        app.isRegistrationOpen && status == RegistrationStatus.submitted;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .28)),
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
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
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
          if (canEdit) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (app.reopenRegistrationForEditing()) {
                    onEditRegistration?.call();
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit registration before deadline'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RegistrationDetails extends StatelessWidget {
  final AppService app;
  const _RegistrationDetails({required this.app});
  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Application details',
    subtitle: 'Reference information',
    icon: Icons.receipt_long_outlined,
    child: Column(
      children: [
        _Detail('Student', app.activeStudent.fullName),
        _Detail('Registration No.', app.activeStudent.registrationNumber),
        const _Detail('Academic year', '2025/2026'),
        const _Detail('Semester', 'Semester 1'),
        _Detail('Reference token', app.verificationToken, mono: true),
      ],
    ),
  );
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Detail(this.label, this.value, {this.mono = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RegisteredSubjects extends StatelessWidget {
  final List<(Course, CourseOffering)> subjects;
  const _RegisteredSubjects({required this.subjects});
  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Submitted subjects',
    subtitle: '${subjects.length} subjects included in this registration',
    icon: Icons.menu_book_outlined,
    child: Column(
      children: subjects.map((item) {
        final course = item.$1;
        final offering = item.$2;
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: RuslColors.cardSubtle,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RuslColors.accentYellow.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${course.creditValue}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course.code} • ${course.title}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      offering.lecturerName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: RuslColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniBadge(
                course.courseType == CourseType.compulsory
                    ? 'COMPULSORY'
                    : 'OPTIONAL',
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

class _DecisionHistory extends StatelessWidget {
  final List<ApprovalHistory> history;
  const _DecisionHistory({required this.history});
  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Activity history',
    subtitle: 'Recorded decisions and submissions',
    icon: Icons.history_rounded,
    child: Column(
      children: history.reversed
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: RuslColors.cardSubtle,
                child: Icon(Icons.history_edu_rounded, size: 19),
              ),
              title: Text(
                item.decision,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${item.approverName} • ${item.comments}'),
              trailing: Text(
                _date(item.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: RuslColors.textMuted,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: RuslColors.borderGrey),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
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
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class _MiniBadge extends StatelessWidget {
  final String text;
  const _MiniBadge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: RuslColors.accentYellow.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}

int _stageIndex(RegistrationStatus status) => switch (status) {
  RegistrationStatus.draft => 0,
  RegistrationStatus.submitted || RegistrationStatus.changesRequested => 1,
  RegistrationStatus.adviserApproved => 2,
  RegistrationStatus.departmentApproved => 3,
  RegistrationStatus.facultyApproved => 4,
  RegistrationStatus.registered || RegistrationStatus.locked => 5,
  RegistrationStatus.rejected => 1,
};

double _statusProgress(RegistrationStatus status) =>
    (_stageIndex(status) / 5).clamp(0, 1);

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
