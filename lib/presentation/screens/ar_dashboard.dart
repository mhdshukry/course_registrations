import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../core/pdf_generator.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class ArDashboardScreen extends StatefulWidget {
  const ArDashboardScreen({super.key});

  @override
  State<ArDashboardScreen> createState() => _ArDashboardScreenState();
}

class _ArDashboardScreenState extends State<ArDashboardScreen> {
  final TextEditingController _arComments = TextEditingController();

  @override
  void dispose() {
    _arComments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    final student = appService.activeStudent;
    final status = appService.activeRegistrationStatus;
    final isPendingAr = status == RegistrationStatus.facultyApproved;
    final isSealed =
        status == RegistrationStatus.registered ||
        status == RegistrationStatus.locked;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '${RuslLocalization.tr("role_ar")} Portal',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Rajarata University of Sri Lanka • Faculty of Technology Examination & Student Registry',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Overview Metrics
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              const StatMetricCard(
                value: '420',
                label: 'Eligible Candidates',
                icon: Icons.how_to_reg_rounded,
              ),
              StatMetricCard(
                value: isSealed ? '420' : '419',
                label: 'Officially Sealed',
                icon: Icons.verified_rounded,
              ),
              StatMetricCard(
                value: isPendingAr ? '1' : '0',
                label: 'Pending AR Seal',
                icon: Icons.hourglass_bottom_rounded,
              ),
              const StatMetricCard(
                value: '100%',
                label: 'Exam Admission Rate',
                icon: Icons.fact_check_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Official Student Registry Review Card
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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSealed
                                  ? RuslColors.successGreen
                                  : RuslColors.accentYellow,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSealed
                                  ? Icons.verified_rounded
                                  : Icons.account_balance_rounded,
                              color: isSealed
                                  ? RuslColors.pureWhite
                                  : RuslColors.darkText,
                              size: 24,
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
                                  'Reg: ${student.registrationNumber} • Token: ${appService.verificationToken}',
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

                // Live Timeline
                ApprovalTimelineWidget(status: status),
                const SizedBox(height: 20),

                // Exam Eligibility Criteria Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exam Eligibility & Compliance Criteria:',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCheckRow(
                        'Minimum Credit Threshold (>= 12 Credits)',
                        true,
                      ),
                      const SizedBox(height: 6),
                      _buildCheckRow(
                        'Prerequisite Clearance for all Compulsory Modules',
                        true,
                      ),
                      const SizedBox(height: 6),
                      _buildCheckRow(
                        'Department Quota & Endorsement Signed',
                        status != RegistrationStatus.draft &&
                            status != RegistrationStatus.submitted,
                      ),
                      const SizedBox(height: 6),
                      _buildCheckRow(
                        'Faculty Timetable Coordination Clearance',
                        status == RegistrationStatus.facultyApproved ||
                            isSealed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AR Actions
                if (isPendingAr) ...[
                  const Text(
                    'Registrar Seal Remarks & Examination Code:',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _arComments,
                    decoration: InputDecoration(
                      hintText: 'Enter registrar seal notes...',
                      filled: true,
                      fillColor: RuslColors.lightGreyBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appService.approveAndSealByAr(_arComments.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registration Officially Sealed & Confirmed!',
                              ),
                              backgroundColor: RuslColors.successGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_rounded, size: 20),
                        label: Text(RuslLocalization.tr('official_seal')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RuslColors.successGreen,
                          foregroundColor: RuslColors.pureWhite,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (isSealed) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final selectedCourses = appService.courses
                              .where(
                                (c) => appService.selectedOfferingIds.any(
                                  (o) => o.contains(c.id.replaceAll('c', '')),
                                ),
                              )
                              .toList();
                          PdfSlipGenerator.downloadOrPrintPdf(
                            student: student,
                            registeredCourses: selectedCourses.isNotEmpty
                                ? selectedCourses
                                : appService.courses.take(4).toList(),
                            totalCredits: appService.totalSelectedCredits > 0
                                ? appService.totalSelectedCredits
                                : 14,
                            academicYear: '2025/2026',
                            semesterNumber: 1,
                            verificationCode: appService.verificationToken,
                            status: 'OFFICIALLY REGISTERED & SEALED',
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text(
                          'Print Official Registration Record (A4)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RuslColors.accentYellow,
                          foregroundColor: RuslColors.darkText,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          appService.lockFacultyRegistration();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registration records frozen for semester.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_rounded, size: 18),
                        label: const Text('Freeze Records'),
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: passed ? RuslColors.successGreen : Colors.grey.shade400,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: passed ? RuslColors.darkText : RuslColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
