import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/app_service.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final student = app.activeStudent;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Welcome, ${student.fullName}',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '${student.programmeName} • Level ${student.currentLevel} • Semester ${student.currentSemester}',
          style: const TextStyle(color: RuslColors.textMuted),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 700
                ? constraints.maxWidth
                : (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _summaryCard(
                  width,
                  Icons.school_outlined,
                  'Current CGPA',
                  '3.42',
                  'Updated after the latest published results',
                ),
                _summaryCard(
                  width,
                  Icons.event_available_outlined,
                  'Registration window',
                  app.isRegistrationOpen ? 'Open now' : 'Closed',
                  '${app.registrationStartLabel} – ${app.registrationEndLabel}',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Text(
          'Announcements',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const _Announcement(
          icon: Icons.campaign_outlined,
          title: 'Semester subject registration is open',
          body:
              'Review the assigned compulsory subjects, choose your optional subjects, and submit before the closing date.',
          date: '06 October 2026',
        ),
        const _Announcement(
          icon: Icons.calendar_month_outlined,
          title: 'Academic calendar update',
          body: 'Lectures for the new semester begin on 19 October 2026.',
          date: '03 October 2026',
        ),
        const _Announcement(
          icon: Icons.article_outlined,
          title: 'Faculty notice',
          body:
              'Students should verify their profile and programme details before submitting registration.',
          date: '30 September 2026',
        ),
      ],
    );
  }

  Widget _summaryCard(
    double width,
    IconData icon,
    String title,
    String value,
    String detail,
  ) => Container(
    width: width,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: RuslColors.pureWhite,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: RuslColors.borderGrey),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: RuslColors.accentYellow,
          child: Icon(icon, color: RuslColors.darkText),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: RuslColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
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
  );
}

class _Announcement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String date;
  const _Announcement({
    required this.icon,
    required this.title,
    required this.body,
    required this.date,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RuslColors.warningOrange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(body),
                const SizedBox(height: 8),
                Text(
                  date,
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
    ),
  );
}
