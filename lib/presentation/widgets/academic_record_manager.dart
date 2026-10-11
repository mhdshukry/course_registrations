import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

Future<void> showAcademicRecordManager(BuildContext context, AppService app) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: app,
        child: const _AcademicRecordManagerDialog(),
      ),
    );

class _AcademicRecordManagerDialog extends StatelessWidget {
  const _AcademicRecordManagerDialog();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    return AlertDialog(
      title: const Text(
        'Manage Academic Record',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${app.activeStudent.fullName} • ${app.activeStudent.registrationNumber}',
                style: const TextStyle(color: RuslColors.textMuted),
              ),
              const SizedBox(height: 12),
              ...app.academicRecords.map(
                (record) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RuslColors.cardSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.courseCode} — ${record.courseTitle}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${record.academicYear} • Semester ${record.semester} • ${record.credits} credits',
                              style: const TextStyle(
                                fontSize: 12,
                                color: RuslColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<AcademicRecordStatus>(
                        value: record.status,
                        onChanged: (status) {
                          if (status != null) {
                            app.updateAcademicRecordStatus(record.id, status);
                          }
                        },
                        items: AcademicRecordStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
