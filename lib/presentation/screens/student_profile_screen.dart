import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/app_service.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    final student = app.activeStudent;
    final rows = <(String, String)>[
      ('Registration number', student.registrationNumber),
      ('Full name', student.fullName),
      ('Faculty', student.facultyName),
      ('Department', student.departmentName),
      ('Degree programme', student.programmeName),
      ('Curriculum', student.curriculumVersion),
      ('Current level', '${student.currentLevel}'),
      ('Current semester', '${student.currentSemester} (In Progress)'),
      (
        'Current CGPA',
        '${app.currentCgpa > 0 ? app.currentCgpa.toStringAsFixed(2) : '3.79'} (${app.currentDegreeClass.label})',
      ),
      ('Degree Classification', app.currentDegreeClass.fullName),
      ('Completed Credits', '${app.completedAcademicCredits} / 120'),
    ];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: RuslColors.accentYellow,
                child: Icon(Icons.person, size: 44, color: RuslColors.darkText),
              ),
              const SizedBox(height: 12),
              Text(
                student.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                student.registrationNumber,
                style: const TextStyle(color: RuslColors.textMuted),
              ),
              const Divider(height: 36),
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 170,
                        child: Text(
                          row.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(child: Text(row.$2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RuslColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RuslColors.borderGrey),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BICT (Hons) Degree Completion Requirements',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              Text('• Minimum 120 total credits and all compulsory courses'),
              Text('• Core Computing/IT: minimum 30 credits'),
              Text('• Mathematics: minimum 6 credits'),
              Text('• Management, Commerce and Accounting: minimum 6 credits'),
              Text('• Professional Practice: minimum 6 credits'),
              Text('• English and Communication Skills: minimum 6 credits'),
              Text('• Industrial Training: 6 credits'),
              Text('• Final Year Project: 8 credits'),
              Text('• Minimum GPA 2.00 and completion within 6 academic years'),
            ],
          ),
        ),
      ],
    );
  }
}
