import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class AdviserDashboardScreen extends StatefulWidget {
  const AdviserDashboardScreen({super.key});

  @override
  State<AdviserDashboardScreen> createState() => _AdviserDashboardScreenState();
}

class _AdviserDashboardScreenState extends State<AdviserDashboardScreen> {
  final TextEditingController _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final student = appService.activeStudent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${RuslLocalization.tr("role_adviser")} Portal',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Faculty of Technology • Assigned Advising Batch (ICT 2021 Intake)',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Overview Stats
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatMetricCard(
                value: '42',
                label: RuslLocalization.tr('assigned_students'),
                icon: Icons.people_outline_rounded,
              ),
              StatMetricCard(
                value: '38',
                label: RuslLocalization.tr('submitted_registrations'),
                icon: Icons.task_rounded,
              ),
              StatMetricCard(
                value: '4',
                label: RuslLocalization.tr('pending_adviser_approvals'),
                icon: Icons.pending_actions_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Student Review Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: RuslColors.accentYellow,
                            child: Text(
                              'NA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                                  student.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Reg No: ${student.registrationNumber} • Level ${student.currentLevel} Sem ${student.currentSemester}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: RuslColors.accentYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Status: ${appService.activeRegistrationStatus.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, color: RuslColors.borderGrey),

                const Text(
                  'Selected Courses for Review:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appService.selectedOfferingIds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final offeringId = appService.selectedOfferingIds.elementAt(
                      index,
                    );
                    final offering = appService.courseOfferings.firstWhere(
                      (o) => o.id == offeringId,
                    );
                    final course = appService.courses.firstWhere(
                      (c) => c.id == offering.courseId,
                    );

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: RuslColors.darkText,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${course.code} - ${course.title} (${course.creditValue} Credits)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            course.courseType.nameLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: RuslColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Approval Progress Stepper
                ApprovalTimelineWidget(
                  status: appService.activeRegistrationStatus,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _commentsController,
                  decoration: const InputDecoration(
                    hintText:
                        'Add adviser recommendation or change request comments...',
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RuslColors.darkText,
                        foregroundColor: RuslColors.accentYellow,
                      ),
                      onPressed: () {
                        appService.approveByAdviser(_commentsController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registration Approved by Academic Adviser!',
                            ),
                          ),
                        );
                      },
                      child: Text(RuslLocalization.tr('approve_registration')),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (_commentsController.text.isNotEmpty) {
                          appService.requestChangesByAdviser(
                            _commentsController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Changes Requested sent back to Student.',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(RuslLocalization.tr('request_changes')),
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
