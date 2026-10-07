import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/app_service.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final student = context.watch<AppService>().activeStudent;
    final rows = <(String, String)>[
      ('Registration number', student.registrationNumber),
      ('Full name', student.fullName),
      ('Faculty', student.facultyName),
      ('Department', student.departmentName),
      ('Degree programme', student.programmeName),
      ('Curriculum', student.curriculumVersion),
      ('Current level', '${student.currentLevel}'),
      ('Current semester', '${student.currentSemester}'),
      ('Current CGPA', '3.42'),
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
      ],
    );
  }
}
