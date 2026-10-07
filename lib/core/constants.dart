import 'package:flutter/material.dart';

class RuslColors {
  static const Color accentYellow = Color(0xFFFFD85F); // #FFD85F Accent
  static const Color pureWhite = Color(0xFFFFFFFF); // #FFFFFF Card / Container
  static const Color darkText = Color(0xFF000000); // #000000 Dark Text
  static const Color borderGrey = Color(0xFFC6C6C6); // #C6C6C6 Subtle Border
  static const Color bgCream = Color(
    0xFFFAF8EE,
  ); // Warm Soft Cream Background (from Behance UI sample)
  static const Color cardSubtle = Color(
    0xFFF6F4EB,
  ); // Inner pill card background
  static const Color lightGreyBg = Color(
    0xFFF3F3F1,
  ); // Neutral secondary background
  static const Color textMuted = Color(0xFF666666); // Muted grey text
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color errorRed = Color(0xFFC62828);
}

enum UserRole {
  student,
  academicAdviser,
  lecturer,
  headOfDepartment,
  facultyCoordinator,
  assistantRegistrar,
  centralAdmin,
  systemAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.academicAdviser:
        return 'Academic Adviser';
      case UserRole.lecturer:
        return 'Lecturer';
      case UserRole.headOfDepartment:
        return 'Head of Department (HoD)';
      case UserRole.facultyCoordinator:
        return 'Faculty Academic Coordinator';
      case UserRole.assistantRegistrar:
        return 'Assistant Registrar (AR)';
      case UserRole.centralAdmin:
        return 'Central University Admin';
      case UserRole.systemAdmin:
        return 'System Administrator';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.academicAdviser:
        return 'Adviser';
      case UserRole.lecturer:
        return 'Lecturer';
      case UserRole.headOfDepartment:
        return 'HoD';
      case UserRole.facultyCoordinator:
        return 'Coord';
      case UserRole.assistantRegistrar:
        return 'AR';
      case UserRole.centralAdmin:
        return 'Admin';
      case UserRole.systemAdmin:
        return 'SysAdmin';
    }
  }

  String get code {
    return name;
  }
}

class RuslFaculties {
  static const String agriculture = 'Faculty of Agriculture';
  static const String appliedSciences = 'Faculty of Applied Sciences';
  static const String managementStudies = 'Faculty of Management Studies';
  static const String medicine = 'Faculty of Medicine and Allied Sciences';
  static const String socialSciences =
      'Faculty of Social Sciences and Humanities';
  static const String technology = 'Faculty of Technology';

  static const List<String> allFaculties = [
    technology,
    appliedSciences,
    managementStudies,
    agriculture,
    medicine,
    socialSciences,
  ];

  static const Map<String, String> facultyCodes = {
    technology: 'FOT',
    appliedSciences: 'FAS',
    managementStudies: 'FMS',
    agriculture: 'FOA',
    medicine: 'FMAS',
    socialSciences: 'FSSH',
  };
}

enum RegistrationStatus {
  draft,
  submitted,
  changesRequested,
  adviserApproved,
  departmentApproved,
  facultyApproved,
  registered,
  rejected,
  locked,
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.draft:
        return 'Draft';
      case RegistrationStatus.submitted:
        return 'Submitted';
      case RegistrationStatus.changesRequested:
        return 'Changes Requested';
      case RegistrationStatus.adviserApproved:
        return 'Adviser Approved';
      case RegistrationStatus.departmentApproved:
        return 'HoD Approved';
      case RegistrationStatus.facultyApproved:
        return 'Faculty Approved';
      case RegistrationStatus.registered:
        return 'Registered';
      case RegistrationStatus.rejected:
        return 'Rejected';
      case RegistrationStatus.locked:
        return 'Locked & Confirmed';
    }
  }
}

enum CourseType { compulsory, elective, optional, repeat, nonCredit, audit }

extension CourseTypeExtension on CourseType {
  String get nameLabel {
    switch (this) {
      case CourseType.compulsory:
        return 'Compulsory';
      case CourseType.elective:
        return 'Elective';
      case CourseType.optional:
        return 'Optional';
      case CourseType.repeat:
        return 'Repeat';
      case CourseType.nonCredit:
        return 'Non-Credit';
      case CourseType.audit:
        return 'Audit';
    }
  }
}
