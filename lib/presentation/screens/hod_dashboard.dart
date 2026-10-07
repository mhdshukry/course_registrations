import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class HodDashboardScreen extends StatefulWidget {
  const HodDashboardScreen({super.key});

  @override
  State<HodDashboardScreen> createState() => _HodDashboardScreenState();
}

class _HodDashboardScreenState extends State<HodDashboardScreen> {
  final TextEditingController _hodCommentsController = TextEditingController();

  @override
  void dispose() {
    _hodCommentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final student = appService.activeStudent;
    final status = appService.activeRegistrationStatus;
    final isPendingHod = status == RegistrationStatus.adviserApproved;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '${RuslLocalization.tr("role_hod")} Portal',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Department of Information & Communication Technology • Faculty of Technology',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Department Stats Row
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              const StatMetricCard(
                value: '148',
                label: 'Department Students',
                icon: Icons.groups_rounded,
              ),
              StatMetricCard(
                value: isPendingHod ? '1' : '0',
                label: 'Pending HoD Review',
                icon: Icons.pending_actions_rounded,
              ),
              const StatMetricCard(
                value: '7',
                label: 'Active Offerings',
                icon: Icons.menu_book_rounded,
              ),
              const StatMetricCard(
                value: '94.2%',
                label: 'Quota Utilization',
                icon: Icons.donut_large_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Course Quotas & Capacity Monitor
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Department Course Quotas & Seat Capacity',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RuslColors.borderGrey),
                      ),
                      child: const Text(
                        'Semester 5 (Level 3)',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...appService.courseOfferings.map((offering) {
                  final course = appService.courses.firstWhere(
                    (c) => c.id == offering.courseId,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildQuotaRow(
                      '${course.code} - ${course.title}',
                      offering.currentRegisteredCount,
                      offering.maxCapacity,
                      isWarning: offering.isFull,
                      onIncreaseCapacity: () {
                        appService.increaseOfferingCapacity(offering.id, 5);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${course.code}: ${RuslLocalization.tr("increase_capacity_msg")}',
                            ),
                            backgroundColor: RuslColors.successGreen,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Student Registration Review Section
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
                            radius: 22,
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
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${student.registrationNumber} • Level ${student.currentLevel} Semester ${student.currentSemester}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
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
                    StatusPillBadge(status: status),
                  ],
                ),
                const SizedBox(height: 20),

                // Live Approval Stepper
                ApprovalTimelineWidget(status: status),
                const SizedBox(height: 20),

                // Reviewer Comments Field
                if (isPendingHod) ...[
                  const Text(
                    'HoD Endorsement Comments / Waiver Notes:',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hodCommentsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          'Enter department endorsement comments or special conditions...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: RuslColors.lightGreyBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appService.approveByHod(_hodCommentsController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registration successfully endorsed by Head of Department!',
                              ),
                              backgroundColor: RuslColors.successGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_rounded, size: 18),
                        label: Text(RuslLocalization.tr('endorse_faculty')),
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
                      OutlinedButton.icon(
                        onPressed: () {
                          appService.requestChangesByAdviser(
                            _hodCommentsController.text.isEmpty
                                ? 'HoD requested revisions on course selection.'
                                : _hodCommentsController.text,
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(RuslLocalization.tr('request_changes')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RuslColors.darkText,
                          side: const BorderSide(color: RuslColors.borderGrey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RuslColors.lightGreyBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: RuslColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            status == RegistrationStatus.departmentApproved ||
                                    status ==
                                        RegistrationStatus.facultyApproved ||
                                    status == RegistrationStatus.registered ||
                                    status == RegistrationStatus.locked
                                ? 'This registration has already been endorsed by the Department.'
                                : 'Registration is pending student submission or Academic Adviser endorsement.',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              color: RuslColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Department Special Petitions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Department Special Requests & Waiver Petitions',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (appService.specialRequests.isEmpty)
                  const Text(
                    'No pending petitions.',
                    style: TextStyle(color: RuslColors.textMuted),
                  )
                else
                  ...appService.specialRequests.map((req) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: RuslColors.borderGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${req.studentName} — ${req.requestType}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: req.status == 'Approved'
                                      ? RuslColors.successGreen.withValues(
                                          alpha: 0.15,
                                        )
                                      : RuslColors.accentYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  req.status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: req.status == 'Approved'
                                        ? RuslColors.successGreen
                                        : RuslColors.darkText,
                                  ),
                                ),
                              ),
                              if (req.status == 'Pending') ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: RuslColors.successGreen,
                                  ),
                                  onPressed: () => appService
                                      .reviewSpecialRequest(req.id, 'Approved'),
                                ),
                              ],
                            ],
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

  Widget _buildQuotaRow(
    String courseTitle,
    int enrolled,
    int capacity, {
    bool isWarning = false,
    VoidCallback? onIncreaseCapacity,
  }) {
    final percentage = (enrolled / capacity).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                courseTitle,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '$enrolled / $capacity Seats (${(percentage * 100).toInt()}%)',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isWarning
                        ? RuslColors.warningOrange
                        : RuslColors.darkText,
                  ),
                ),
                if (onIncreaseCapacity != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onIncreaseCapacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: RuslColors.borderGrey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 12,
                            color: RuslColors.darkText,
                          ),
                          Text(
                            RuslLocalization.tr('increase_capacity'),
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            isWarning
                ? RuslColors.warningOrange
                : (percentage > 0.8
                      ? Colors.blue.shade600
                      : RuslColors.successGreen),
          ),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
