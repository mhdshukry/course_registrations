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
    required this.slots,
  });

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

class SpecialRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String
  requestType; // "Credit Overload", "Prerequisite Waiver", "Late Registration"
  final String explanation;
  final String status; // "Pending", "Approved", "Rejected"
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
