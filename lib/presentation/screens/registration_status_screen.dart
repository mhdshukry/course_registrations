import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/app_service.dart';
import '../widgets/approval_timeline.dart';
import '../widgets/custom_widgets.dart';

class RegistrationStatusScreen extends StatelessWidget {
  const RegistrationStatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2025/2026 • Semester 1',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  Text(
                    '${app.selectedOfferingIds.length} subjects • ${app.totalSelectedCredits} credits',
                    style: const TextStyle(color: RuslColors.textMuted),
                  ),
                ],
              ),
              StatusPillBadge(status: app.activeRegistrationStatus),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ApprovalTimelineWidget(
          status: app.activeRegistrationStatus,
          history: app.approvalHistoryList,
        ),
      ],
    );
  }
}
