import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends State<CoordinatorDashboardScreen> {
  final TextEditingController _coordComments = TextEditingController();

  @override
  void dispose() {
    _coordComments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final student = appService.activeStudent;
    final status = appService.activeRegistrationStatus;
    final isPendingCoord = status == RegistrationStatus.departmentApproved;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${RuslLocalization.tr("role_coordinator")} Portal',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Faculty of Technology • Inter-Department Timetable & Level Coordination',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Faculty Level Metrics
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatMetricCard(
                value: '3',
                label: 'Academic Departments',
                icon: Icons.domain_rounded,
              ),
              StatMetricCard(
                value: '420',
                label: 'Faculty Registrations',
                icon: Icons.badge_outlined,
              ),
              StatMetricCard(
                value: '0',
                label: 'Timetable Clashes',
                icon: Icons.check_circle_outline_rounded,
              ),
              StatMetricCard(
                value: '98.1%',
                label: 'Timetable Coverage',
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inter-Department Timetable Balance
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cross-Department Course Allocation & Venues',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      Icons.hub_outlined,
                      color: RuslColors.darkText,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDepartmentRow(
                  'ICT Department',
                  '6 Offerings',
                  '148 Students',
                  'LT-01, LT-02, Web Lab',
                ),
                const Divider(height: 20),
                _buildDepartmentRow(
                  'Bio-Process Technology (BPT)',
                  '5 Offerings',
                  '132 Students',
                  'Bio Lab 1, Science Complex',
                ),
                const Divider(height: 20),
                _buildDepartmentRow(
                  'Electrical & Media Tech (EMT)',
                  '5 Offerings',
                  '140 Students',
                  'Media Studio, Electronics Lab',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Faculty Coordinator Registration Endorsement Card
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
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${student.registrationNumber} • Faculty of Technology',
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

                // Approval Timeline Widget
                ApprovalTimelineWidget(status: status),
                const SizedBox(height: 20),

                if (isPendingCoord) ...[
                  const Text(
                    'Faculty Coordination Verification Notes:',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _coordComments,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          'Enter coordinator notes or timetable verification confirmation...',
                      filled: true,
                      fillColor: RuslColors.lightGreyBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      appService.approveByCoordinator(_coordComments.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Registration coordinated and forwarded to Assistant Registrar!',
                          ),
                          backgroundColor: RuslColors.successGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.rule_folder_rounded, size: 18),
                    label: const Text(
                      'Verify & Forward to Assistant Registrar (AR)',
                    ),
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
                            status == RegistrationStatus.facultyApproved ||
                                    status == RegistrationStatus.registered ||
                                    status == RegistrationStatus.locked
                                ? 'This registration has passed Faculty Coordination review.'
                                : 'Waiting for Department / HoD endorsement before coordination review.',
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
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(
    String dept,
    String offerings,
    String students,
    String venues,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dept,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Venues: $venues',
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
        const SizedBox(width: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RuslColors.cardSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                offerings,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RuslColors.accentYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                students,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
