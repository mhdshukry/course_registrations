import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ApprovalTimelineWidget extends StatelessWidget {
  final RegistrationStatus status;
  final List<dynamic>? history;

  const ApprovalTimelineWidget({super.key, required this.status, this.history});

  @override
  Widget build(BuildContext context) {
    final stages = [
      _StageInfo(
        stepNumber: 1,
        title: 'Draft & Submission',
        role: 'Student',
        subtitle: 'Course selection and prerequisite check',
        isReached: true,
        isCompleted: status != RegistrationStatus.draft,
        isCurrent: status == RegistrationStatus.draft,
      ),
      _StageInfo(
        stepNumber: 2,
        title: 'Department Endorsement',
        role: 'Head of Department',
        subtitle: 'Curriculum requirements & batch endorsement',
        isReached: status != RegistrationStatus.draft,
        isCompleted: _isPastHod(status),
        isCurrent:
            status == RegistrationStatus.submitted ||
            status == RegistrationStatus.changesRequested,
        isRejectedOrChanges: status == RegistrationStatus.changesRequested,
      ),
      _StageInfo(
        stepNumber: 3,
        title: 'Official Seal & Lock',
        role: 'Assistant Registrar',
        subtitle: 'Exam eligibility registry confirmed & sealed',
        isReached: _isPastHod(status),
        isCompleted:
            status == RegistrationStatus.registered ||
            status == RegistrationStatus.locked,
        isCurrent:
            status == RegistrationStatus.departmentApproved ||
            status == RegistrationStatus.facultyApproved,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuslColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: RuslColors.accentYellow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: RuslColors.darkText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Multi-Tier Approval Workflow',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: RuslColors.darkText,
                    ),
                  ),
                  Text(
                    'Current Status: ${status.label}',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            separatorBuilder: (context, index) {
              final isDone = stages[index].isCompleted;
              return Container(
                margin: const EdgeInsets.only(left: 17),
                height: 24,
                width: 2,
                color: isDone ? RuslColors.successGreen : Colors.grey.shade300,
              );
            },
            itemBuilder: (context, index) {
              final stage = stages[index];
              return _buildStageTile(stage);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStageTile(_StageInfo stage) {
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    if (stage.isRejectedOrChanges) {
      iconBgColor = RuslColors.warningOrange.withValues(alpha: 0.15);
      iconColor = RuslColors.warningOrange;
      icon = Icons.edit_note_rounded;
    } else if (stage.isCompleted) {
      iconBgColor = RuslColors.successGreen.withValues(alpha: 0.15);
      iconColor = RuslColors.successGreen;
      icon = Icons.check_circle_rounded;
    } else if (stage.isCurrent) {
      iconBgColor = RuslColors.accentYellow;
      iconColor = RuslColors.darkText;
      icon = Icons.hourglass_top_rounded;
    } else {
      iconBgColor = Colors.grey.shade100;
      iconColor = Colors.grey.shade400;
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Icon Indicator
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: stage.isCurrent ? RuslColors.darkText : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),

        // Text details
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
                    stage.title,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: stage.isReached
                          ? RuslColors.darkText
                          : Colors.grey.shade400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stage.role,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: stage.isReached
                            ? RuslColors.textMuted
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  if (stage.isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stage.isRejectedOrChanges
                            ? RuslColors.warningOrange.withValues(alpha: 0.15)
                            : RuslColors.accentYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stage.isRejectedOrChanges
                            ? 'Action Required'
                            : 'In Progress',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: stage.isRejectedOrChanges
                              ? RuslColors.warningOrange
                              : RuslColors.darkText,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                stage.subtitle,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  color: stage.isReached
                      ? RuslColors.textMuted
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isPastHod(RegistrationStatus s) {
    return s == RegistrationStatus.departmentApproved ||
        s == RegistrationStatus.facultyApproved ||
        s == RegistrationStatus.registered ||
        s == RegistrationStatus.locked;
  }

  static Color _getStatusColor(RegistrationStatus s) {
    switch (s) {
      case RegistrationStatus.draft:
        return RuslColors.textMuted;
      case RegistrationStatus.submitted:
        return RuslColors.warningOrange;
      case RegistrationStatus.changesRequested:
        return RuslColors.errorRed;
      case RegistrationStatus.departmentApproved:
      case RegistrationStatus.facultyApproved:
        return Colors.blue.shade700;
      case RegistrationStatus.registered:
      case RegistrationStatus.locked:
        return RuslColors.successGreen;
      case RegistrationStatus.rejected:
        return RuslColors.errorRed;
    }
  }
}

class _StageInfo {
  final int stepNumber;
  final String title;
  final String role;
  final String subtitle;
  final bool isReached;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRejectedOrChanges;

  _StageInfo({
    required this.stepNumber,
    required this.title,
    required this.role,
    required this.subtitle,
    required this.isReached,
    required this.isCompleted,
    required this.isCurrent,
    this.isRejectedOrChanges = false,
  });
}
