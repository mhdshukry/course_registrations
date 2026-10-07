import '../core/constants.dart';
import 'models.dart';

class ValidationResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.warnings,
    required this.errors,
  });
}

class TimetableClashInfo {
  final Course courseA;
  final Course courseB;
  final String day;
  final String timeRange;

  TimetableClashInfo({
    required this.courseA,
    required this.courseB,
    required this.day,
    required this.timeRange,
  });
}

class ValidationEngine {
  /// Check prerequisites for selected courses against student completed history
  static ValidationResult validatePrerequisites({
    required StudentProfile student,
    required List<Course> selectedCourses,
    required List<Course> allCourses,
  }) {
    List<String> errors = [];
    List<String> warnings = [];

    for (var course in selectedCourses) {
      for (var prereqId in course.prerequisiteCourseIds) {
        if (!student.completedCourseIds.contains(prereqId)) {
          final prereqCourse = allCourses.firstWhere(
            (c) => c.id == prereqId,
            orElse: () => Course(
              id: prereqId,
              code: prereqId,
              title: 'Prerequisite Subject',
              description: '',
              creditValue: 0,
              level: 1,
              semester: 1,
              departmentId: '',
              courseType: CourseType.compulsory,
            ),
          );
          errors.add(
            'Cannot select ${course.code}: Missing prerequisite "${prereqCourse.code} - ${prereqCourse.title}".',
          );
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }

  /// Check min and max credit limits
  static ValidationResult validateCreditLimits({
    required StudentProfile student,
    required List<Course> selectedCourses,
  }) {
    List<String> errors = [];
    List<String> warnings = [];

    int totalCredits = selectedCourses.fold(0, (sum, c) => sum + c.creditValue);

    if (totalCredits < student.minAllowedCredits) {
      errors.add(
        'Selected credit total is below the minimum: $totalCredits credits selected; ${student.minAllowedCredits} required.',
      );
    }

    if (totalCredits > student.maxAllowedCredits) {
      errors.add(
        'Selected credit total exceeds the maximum: $totalCredits credits selected; ${student.maxAllowedCredits} allowed. Please submit a Credit Overload Special Request.',
      );
    } else if (totalCredits >= student.maxAllowedCredits - 2) {
      warnings.add(
        'Approaching maximum credit limit: Total credits = $totalCredits / ${student.maxAllowedCredits}.',
      );
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }

  /// Detect timetable clashes between selected course offerings
  static List<TimetableClashInfo> detectTimetableClashes({
    required List<CourseOffering> selectedOfferings,
    required List<Course> allCourses,
  }) {
    List<TimetableClashInfo> clashes = [];

    for (int i = 0; i < selectedOfferings.length; i++) {
      for (int j = i + 1; j < selectedOfferings.length; j++) {
        final offeringA = selectedOfferings[i];
        final offeringB = selectedOfferings[j];

        for (var slotA in offeringA.slots) {
          for (var slotB in offeringB.slots) {
            if (slotA.dayOfWeek == slotB.dayOfWeek) {
              if (_hasTimeOverlap(
                slotA.startTime,
                slotA.endTime,
                slotB.startTime,
                slotB.endTime,
              )) {
                final courseA = allCourses.firstWhere(
                  (c) => c.id == offeringA.courseId,
                );
                final courseB = allCourses.firstWhere(
                  (c) => c.id == offeringB.courseId,
                );

                clashes.add(
                  TimetableClashInfo(
                    courseA: courseA,
                    courseB: courseB,
                    day: slotA.dayOfWeek,
                    timeRange: '${slotA.startTime} - ${slotA.endTime}',
                  ),
                );
              }
            }
          }
        }
      }
    }

    return clashes;
  }

  static bool _hasTimeOverlap(
    String startA,
    String endA,
    String startB,
    String endB,
  ) {
    int minutesAStart = _timeToMinutes(startA);
    int minutesAEnd = _timeToMinutes(endA);
    int minutesBStart = _timeToMinutes(startB);
    int minutesBEnd = _timeToMinutes(endB);

    return minutesAStart < minutesBEnd && minutesBStart < minutesAEnd;
  }

  static int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
