import '../core/constants.dart';

class Faculty {
  final String id;
  final String code;
  final String name;
  final int departmentCount;

  const Faculty({
    required this.id,
    required this.code,
    required this.name,
    required this.departmentCount,
  });
}

class Department {
  final String id;
  final String facultyId;
  final String code;
  final String name;

  const Department({
    required this.id,
    required this.facultyId,
    required this.code,
    required this.name,
  });
}

class DegreeProgramme {
  final String id;
  final String departmentId;
  final String code;
  final String name;
  final String degreeType;
  final int durationYears;
  final int totalCredits;

  const DegreeProgramme({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    required this.degreeType,
    required this.durationYears,
    required this.totalCredits,
  });
}

class Curriculum {
  final String id;
  final String programmeId;
  final String version; // e.g. "2024 Version 2.1"
  final int effectiveYear;
  final int totalCreditsRequired;

  const Curriculum({
    required this.id,
    required this.programmeId,
    required this.version,
    required this.effectiveYear,
    required this.totalCreditsRequired,
  });
}

class Course {
  final String id;
  final String code; // e.g. ICT 3102
  final String title;
  final String description;
  final int creditValue;
  final int level; // 1, 2, 3, 4
  final int semester; // 1 or 2
  final String departmentId;
  final CourseType courseType;
  final List<String> prerequisiteCourseIds;
  final List<String> corequisiteCourseIds;

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.creditValue,
    required this.level,
    required this.semester,
    required this.departmentId,
    required this.courseType,
    this.prerequisiteCourseIds = const [],
    this.corequisiteCourseIds = const [],
  });
}

class TimetableSlot {
  final String id;
  final String dayOfWeek; // Monday, Tuesday, etc.
  final String startTime; // "10:00"
  final String endTime; // "12:00"
  final String venue; // "Lecture Hall A"
  final String groupType; // Lecture, Practical, Tutorial

  const TimetableSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.groupType,
  });
}

class CourseOffering {
  final String id;
  final String courseId;
  final String academicYear; // "2025/2026"
  final int semesterNumber;
  final String lecturerName;
  int maxCapacity;
  int currentRegisteredCount;
  final List<TimetableSlot> slots;

  CourseOffering({
    required this.id,
    required this.courseId,
    required this.academicYear,
    required this.semesterNumber,
    required this.lecturerName,
    required this.maxCapacity,
    this.currentRegisteredCount = 0,
    required List<TimetableSlot> slots,
  }) : slots = List<TimetableSlot>.of(slots);

  bool get isFull => currentRegisteredCount >= maxCapacity;
}

class StudentProfile {
  final String id;
  final String userId;
  final String registrationNumber; // e.g. "ICT/2021/045"
  final String fullName;
  final String facultyName;
  final String departmentName;
  final String programmeName;
  final String curriculumVersion;
  final int currentLevel;
  final int currentSemester;
  final int minAllowedCredits;
  final int maxAllowedCredits;
  final List<String> completedCourseIds;
  final List<String> failedCourseIds;

  StudentProfile({
    required this.id,
    required this.userId,
    required this.registrationNumber,
    required this.fullName,
    required this.facultyName,
    required this.departmentName,
    required this.programmeName,
    required this.curriculumVersion,
    required this.currentLevel,
    required this.currentSemester,
    this.minAllowedCredits = 12,
    this.maxAllowedCredits = 24,
    required this.completedCourseIds,
    required this.failedCourseIds,
  });
}

class RegistrationItem {
  final String offeringId;
  final String courseId;
  final CourseType registrationType;
  final DateTime addedAt;

  RegistrationItem({
    required this.offeringId,
    required this.courseId,
    required this.registrationType,
    required this.addedAt,
  });
}

class ApprovalHistory {
  final String id;
  final String approverRole;
  final String approverName;
  final String decision;
  final String comments;
  final DateTime timestamp;

  ApprovalHistory({
    required this.id,
    required this.approverRole,
    required this.approverName,
    required this.decision,
    required this.comments,
    required this.timestamp,
  });
}

class CourseRegistrationRecord {
  final String id;
  final String studentId;
  final String academicYear;
  final int semesterNumber;
  List<RegistrationItem> selectedItems;
  int totalCredits;
  RegistrationStatus status;
  final DateTime submittedAt;
  DateTime? approvedAt;
  final String verificationToken;
  final List<ApprovalHistory> approvals;

  CourseRegistrationRecord({
    required this.id,
    required this.studentId,
    required this.academicYear,
    required this.semesterNumber,
    required this.selectedItems,
    required this.totalCredits,
    required this.status,
    required this.submittedAt,
    this.approvedAt,
    required this.verificationToken,
    required this.approvals,
  });
}

enum SpecialRequestStatus {
  pending,
  approved,
  rejected;

  String get label => switch (this) {
    SpecialRequestStatus.pending => 'Pending',
    SpecialRequestStatus.approved => 'Approved',
    SpecialRequestStatus.rejected => 'Rejected',
  };

  static SpecialRequestStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'approved':
        return SpecialRequestStatus.approved;
      case 'rejected':
        return SpecialRequestStatus.rejected;
      default:
        return SpecialRequestStatus.pending;
    }
  }
}

class SpecialRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String
  requestType; // "Credit Overload", "Prerequisite Waiver", "Late Registration"
  final String explanation;
  final SpecialRequestStatus status;
  final DateTime submittedAt;

  SpecialRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.requestType,
    required this.explanation,
    required this.status,
    required this.submittedAt,
  });
}

class AuditLog {
  final String id;
  final String userName;
  final String userRole;
  final String action;
  final String details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}

enum AcademicRecordStatus { completed, medical, dropped }

extension AcademicRecordStatusExtension on AcademicRecordStatus {
  String get label => switch (this) {
    AcademicRecordStatus.completed => 'Completed',
    AcademicRecordStatus.medical => 'Medical',
    AcademicRecordStatus.dropped => 'Dropped',
  };
}

enum UniversityResultType { pass, repeat, fail }

enum DegreeClassStanding {
  firstClass,
  secondUpper,
  secondLower,
  pass,
  batchMiss;

  String get label => switch (this) {
    DegreeClassStanding.firstClass => '1st Class',
    DegreeClassStanding.secondUpper => '2nd Class Upper',
    DegreeClassStanding.secondLower => '2nd Class Lower',
    DegreeClassStanding.pass => 'Pass',
    DegreeClassStanding.batchMiss => 'Batch Miss (<2.0)',
  };

  String get fullName => switch (this) {
    DegreeClassStanding.firstClass => 'First Class Honours (1st Class)',
    DegreeClassStanding.secondUpper => 'Second Class (Upper Division)',
    DegreeClassStanding.secondLower => 'Second Class (Lower Division)',
    DegreeClassStanding.pass => 'General Pass',
    DegreeClassStanding.batchMiss => 'Batch Miss (< 2.00)',
  };

  String get criteria => switch (this) {
    DegreeClassStanding.firstClass => 'CGPA ≥ 3.70',
    DegreeClassStanding.secondUpper => '3.50 ≤ CGPA < 3.70',
    DegreeClassStanding.secondLower => '3.00 ≤ CGPA < 3.50',
    DegreeClassStanding.pass => '2.00 ≤ CGPA < 3.00',
    DegreeClassStanding.batchMiss => 'CGPA < 2.00',
  };

  static DegreeClassStanding fromGpa(double gpa) {
    if (gpa >= 3.70) return DegreeClassStanding.firstClass;
    if (gpa >= 3.50) return DegreeClassStanding.secondUpper;
    if (gpa >= 3.00) return DegreeClassStanding.secondLower;
    if (gpa >= 2.00) return DegreeClassStanding.pass;
    return DegreeClassStanding.batchMiss;
  }
}

class UniversityGradingSystem {
  /// Pass: A+, A, A-, B+, B, B-, C+, C (≥ 2.0)
  static const passGrades = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C'];

  /// Repeat: C-, D+, D, D- (< 2.0, eligible to repeat for upgrade up to C)
  static const repeatGrades = ['C-', 'D+', 'D', 'D-'];

  /// Fail: F, E, FAIL, REFERRED, AB (0.0, must repeat)
  static const failGrades = ['F', 'E', 'FAIL', 'REFERRED', 'AB'];

  static double gradeToPoint(String grade) {
    return switch (grade.toUpperCase().trim()) {
      'A+' || 'A' => 4.0,
      'A-' => 3.7,
      'B+' => 3.3,
      'B' => 3.0,
      'B-' => 2.7,
      'C+' => 2.3,
      'C' => 2.0,
      'C-' => 1.7,
      'D+' => 1.3,
      'D' => 1.0,
      'D-' => 0.7,
      _ => 0.0,
    };
  }

  static UniversityResultType? resultTypeFor(String? grade) {
    if (grade == null) return null;
    final g = grade.toUpperCase().trim();
    if (passGrades.contains(g)) return UniversityResultType.pass;
    if (repeatGrades.contains(g)) return UniversityResultType.repeat;
    if (failGrades.contains(g)) return UniversityResultType.fail;
    return null;
  }

  static bool isPass(String? grade) =>
      resultTypeFor(grade) == UniversityResultType.pass;

  static bool isRepeat(String? grade) =>
      resultTypeFor(grade) == UniversityResultType.repeat;

  static bool isFail(String? grade) =>
      resultTypeFor(grade) == UniversityResultType.fail;
}

class AcademicCourseRecord {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String academicYear;
  final int level;
  final int semester;
  final int credits;
  String? grade;
  AcademicRecordStatus status;
  DateTime updatedAt;

  AcademicCourseRecord({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.academicYear,
    this.level = 1,
    required this.semester,
    required this.credits,
    this.grade,
    required this.status,
    required this.updatedAt,
  });

  AcademicCourseRecord copyWith({
    String? id,
    String? courseCode,
    String? courseTitle,
    String? academicYear,
    int? level,
    int? semester,
    int? credits,
    String? grade,
    AcademicRecordStatus? status,
    DateTime? updatedAt,
  }) {
    return AcademicCourseRecord(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      academicYear: academicYear ?? this.academicYear,
      level: level ?? this.level,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get semesterLabel => 'Level $level Sem $semester';

  /// Under faculty regulations:
  /// - Dropped subjects CANNOT be registered again.
  /// - Medical concession or Failed / Repeat results CAN be registered again.
  bool get isDropped => status == AcademicRecordStatus.dropped;
  bool get isMedical => status == AcademicRecordStatus.medical;

  bool get isPassGrade => UniversityGradingSystem.isPass(grade);
  bool get isRepeatGrade => UniversityGradingSystem.isRepeat(grade);
  bool get isFailGrade => UniversityGradingSystem.isFail(grade);

  bool get isFailedResult => isFailGrade;

  bool get canRegisterAgain {
    if (isDropped) return false;
    if (isMedical) return true;
    return isRepeatGrade || isFailGrade;
  }

  String get repeatEligibilityLabel {
    if (isDropped) {
      return 'Dropped (Cannot re-register)';
    }
    if (isMedical) {
      return 'Medical Concession — Eligible to re-register';
    }
    if (isFailGrade) {
      final g = grade?.trim().toUpperCase() ?? 'F';
      return 'Failed Result ($g) — Must re-register';
    }
    if (isRepeatGrade) {
      final g = grade?.trim().toUpperCase() ?? 'Repeat';
      return 'Repeat to Upgrade ($g) — Eligible to re-register';
    }
    return 'Pass (Completed)';
  }
}

enum WaitingListStatus { waiting, promoted, expired, cancelled }

class WaitingListEntry {
  final String id;
  final String offeringId;
  final String courseCode;
  final String courseTitle;
  final String studentId;
  int position;
  WaitingListStatus status;
  final DateTime joinedAt;
  DateTime? promotedAt;

  WaitingListEntry({
    required this.id,
    required this.offeringId,
    required this.courseCode,
    required this.courseTitle,
    required this.studentId,
    required this.position,
    this.status = WaitingListStatus.waiting,
    required this.joinedAt,
    this.promotedAt,
  });

  bool get isPromoted => status == WaitingListStatus.promoted;
}

enum NotificationType {
  system,
  promotion,
  approval,
  changesRequested,
  specialRequest,
  capacityIncrease,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final NotificationType type;
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.relatedId,
  });
}
