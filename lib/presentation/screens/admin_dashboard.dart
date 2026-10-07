import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../services/app_service.dart';
import '../widgets/custom_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUSL ${RuslLocalization.tr("role_admin")} Portal',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: RuslColors.darkText,
            ),
          ),
          const Text(
            'Rajarata University of Sri Lanka • Central Registration Division & IT Centre',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: RuslColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Overview Metrics Across All 6 Faculties
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatMetricCard(
                value: '6',
                label: 'RUSL Faculties',
                icon: Icons.account_balance_rounded,
              ),
              StatMetricCard(
                value: '4,850',
                label: 'Total Eligible Students',
                icon: Icons.groups_rounded,
              ),
              StatMetricCard(
                value: '92.4%',
                label: 'Registration Completion',
                icon: Icons.pie_chart_rounded,
              ),
              StatMetricCard(
                value: '18',
                label: 'Pending Overloads',
                icon: Icons.report_problem_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6 Faculties Grid View
          const Text(
            'Faculties Registration Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1
                      ? 3.2
                      : (crossAxisCount == 2 ? 2.5 : 2.1),
                ),
                itemCount: appService.faculties.length,
                itemBuilder: (context, index) {
                  final fac = appService.faculties[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: RuslColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: RuslColors.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fac.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: RuslColors.accentYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'OPEN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fac.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Real-time Audit Logs Browser
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
                const Text(
                  'System Audit Trail Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appService.auditLogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = appService.auditLogs[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RuslColors.cardSubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security_rounded,
                            size: 16,
                            color: RuslColors.darkText,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.userName} (${log.userRole}) - ${log.action}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  log.details,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
