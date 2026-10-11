import 'package:flutter_test/flutter_test.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/domain/models.dart';

void main() {
  group('Domain Models - Course & Offerings', () {
    test('CourseOffering isFull evaluates correctly against maxCapacity', () {
      final offering = CourseOffering(
        id: 'off_test',
        courseId: 'c_test',
        academicYear: '2025/2026',
        semesterNumber: 1,
        lecturerName: 'Dr. Test',
        maxCapacity: 30,
        currentRegisteredCount: 29,
        slots: [],
      );

      expect(offering.isFull, isFalse);

      offering.currentRegisteredCount = 30;
      expect(offering.isFull, isTrue);

      offering.currentRegisteredCount = 31;
      expect(offering.isFull, isTrue);
    });

    test('Course model preserves prerequisite and corequisite IDs', () {
      const course = Course(
        id: 'c_adv',
        code: 'ICT 3201',
        title: 'Advanced Software',
        description: 'Advanced topics',
        creditValue: 3,
        level: 3,
        semester: 1,
        departmentId: 'dept_1',
        courseType: CourseType.compulsory,
        prerequisiteCourseIds: ['c_prereq_1', 'c_prereq_2'],
        corequisiteCourseIds: ['c_coreq_1'],
      );

      expect(course.prerequisiteCourseIds, containsAll(['c_prereq_1', 'c_prereq_2']));
      expect(course.corequisiteCourseIds, contains('c_coreq_1'));
      expect(course.creditValue, equals(3));
    });
  });

  group('Domain Models - Student Profile & Limits', () {
    test('StudentProfile assigns default credit limits of 12 and 24', () {
      final student = StudentProfile(
        id: 'st_01',
        userId: 'usr_01',
        registrationNumber: 'ICT/2021/001',
        fullName: 'Test Student',
        facultyName: RuslFaculties.technology,
        departmentName: 'ICT',
        programmeName: 'BICT',
        curriculumVersion: '2024 V2.1',
        currentLevel: 3,
        currentSemester: 1,
        completedCourseIds: ['c1', 'c2'],
        failedCourseIds: [],
      );

      expect(student.minAllowedCredits, equals(12));
      expect(student.maxAllowedCredits, equals(24));
      expect(student.completedCourseIds.length, equals(2));
      expect(student.failedCourseIds, isEmpty);
    });
  });

  group('Domain Models - Status Enums & Parsing', () {
    test('SpecialRequestStatus.fromString parses case-insensitively with fallback', () {
      expect(SpecialRequestStatus.fromString('approved'), equals(SpecialRequestStatus.approved));
      expect(SpecialRequestStatus.fromString('APPROVED'), equals(SpecialRequestStatus.approved));
      expect(SpecialRequestStatus.fromString('  Rejected  '), equals(SpecialRequestStatus.rejected));
      expect(SpecialRequestStatus.fromString('pending'), equals(SpecialRequestStatus.pending));
      expect(SpecialRequestStatus.fromString('random_value'), equals(SpecialRequestStatus.pending));
    });

    test('SpecialRequestStatus label getter formats names cleanly', () {
      expect(SpecialRequestStatus.pending.label, equals('Pending'));
      expect(SpecialRequestStatus.approved.label, equals('Approved'));
      expect(SpecialRequestStatus.rejected.label, equals('Rejected'));
    });

    test('AcademicRecordStatusExtension returns expected human-readable labels', () {
      expect(AcademicRecordStatus.completed.label, equals('Completed'));
      expect(AcademicRecordStatus.medical.label, equals('Medical'));
      expect(AcademicRecordStatus.dropped.label, equals('Dropped'));
    });

    test('UniversityGradingSystem accurately classifies Pass, Repeat, and Fail', () {
      // Pass: A+, A, A-, B+, B, B-, C+, C
      for (final g in ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C']) {
        expect(UniversityGradingSystem.isPass(g), isTrue, reason: '$g should be pass');
        expect(UniversityGradingSystem.isRepeat(g), isFalse);
        expect(UniversityGradingSystem.isFail(g), isFalse);
        expect(UniversityGradingSystem.gradeToPoint(g), greaterThanOrEqualTo(2.0));
      }

      // Repeat: C-, D+, D, D-
      for (final g in ['C-', 'D+', 'D', 'D-']) {
        expect(UniversityGradingSystem.isRepeat(g), isTrue, reason: '$g should be repeat');
        expect(UniversityGradingSystem.isPass(g), isFalse);
        expect(UniversityGradingSystem.isFail(g), isFalse);
        expect(UniversityGradingSystem.gradeToPoint(g), lessThan(2.0));
        expect(UniversityGradingSystem.gradeToPoint(g), greaterThan(0.0));
      }

      // Fail: F, E, FAIL, REFERRED
      for (final g in ['F', 'E', 'FAIL', 'REFERRED']) {
        expect(UniversityGradingSystem.isFail(g), isTrue, reason: '$g should be fail');
        expect(UniversityGradingSystem.isPass(g), isFalse);
        expect(UniversityGradingSystem.isRepeat(g), isFalse);
        expect(UniversityGradingSystem.gradeToPoint(g), equals(0.0));
      }
    });

    test('DegreeClassStanding accurately calculates honors thresholds', () {
      // >= 3.7 => 1st Class
      expect(DegreeClassStanding.fromGpa(4.00), equals(DegreeClassStanding.firstClass));
      expect(DegreeClassStanding.fromGpa(3.70), equals(DegreeClassStanding.firstClass));
      expect(DegreeClassStanding.firstClass.label, equals('1st Class'));

      // >= 3.5 => 2nd Class Upper
      expect(DegreeClassStanding.fromGpa(3.69), equals(DegreeClassStanding.secondUpper));
      expect(DegreeClassStanding.fromGpa(3.50), equals(DegreeClassStanding.secondUpper));
      expect(DegreeClassStanding.secondUpper.label, equals('2nd Class Upper'));

      // >= 3.0 => 2nd Class Lower
      expect(DegreeClassStanding.fromGpa(3.49), equals(DegreeClassStanding.secondLower));
      expect(DegreeClassStanding.fromGpa(3.00), equals(DegreeClassStanding.secondLower));
      expect(DegreeClassStanding.secondLower.label, equals('2nd Class Lower'));

      // >= 2.0 => Pass
      expect(DegreeClassStanding.fromGpa(2.99), equals(DegreeClassStanding.pass));
      expect(DegreeClassStanding.fromGpa(2.00), equals(DegreeClassStanding.pass));
      expect(DegreeClassStanding.pass.label, equals('Pass'));

      // < 2.0 => Batch Miss
      expect(DegreeClassStanding.fromGpa(1.99), equals(DegreeClassStanding.batchMiss));
      expect(DegreeClassStanding.fromGpa(1.20), equals(DegreeClassStanding.batchMiss));
      expect(DegreeClassStanding.fromGpa(0.00), equals(DegreeClassStanding.batchMiss));
      expect(DegreeClassStanding.batchMiss.label, equals('Batch Miss (<2.0)'));
    });

    test('AcademicCourseRecord enforces regulations for dropped, medical, and failed subjects', () {
      final droppedRecord = AcademicCourseRecord(
        id: 'rec_dropped',
        courseCode: 'ICT 2218',
        courseTitle: 'Graphic Design Fundamentals',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        status: AcademicRecordStatus.dropped,
        updatedAt: DateTime.now(),
      );
      expect(droppedRecord.isDropped, isTrue);
      expect(droppedRecord.canRegisterAgain, isFalse);
      expect(droppedRecord.repeatEligibilityLabel, contains('Cannot re-register'));

      final medicalRecord = AcademicCourseRecord(
        id: 'rec_medical',
        courseCode: 'ICT 2216',
        courseTitle: 'Embedded Systems',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        status: AcademicRecordStatus.medical,
        updatedAt: DateTime.now(),
      );
      expect(medicalRecord.isMedical, isTrue);
      expect(medicalRecord.canRegisterAgain, isTrue);
      expect(medicalRecord.repeatEligibilityLabel, contains('Eligible to re-register'));

      final failedRecord = AcademicCourseRecord(
        id: 'rec_failed',
        courseCode: 'ICT 2203',
        courseTitle: 'Object Oriented Programming',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 3,
        grade: 'F',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime.now(),
      );
      expect(failedRecord.isFailedResult, isTrue);
      expect(failedRecord.canRegisterAgain, isTrue);
      expect(failedRecord.repeatEligibilityLabel, contains('Eligible to re-register'));

      final passedRecord = AcademicCourseRecord(
        id: 'rec_passed',
        courseCode: 'ICT 2204',
        courseTitle: 'Data Structures and Algorithms',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 3,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime.now(),
      );
      expect(passedRecord.canRegisterAgain, isFalse);
    });

    test('UserRoleExtension provides displayName, shortLabel, and code', () {
      expect(UserRole.student.displayName, equals('Student'));
      expect(UserRole.student.shortLabel, equals('Student'));
      expect(UserRole.headOfDepartment.shortLabel, equals('HoD'));
      expect(UserRole.assistantRegistrar.shortLabel, equals('AR'));
      expect(UserRole.dean.shortLabel, equals('Dean'));
      expect(UserRole.systemAdmin.shortLabel, equals('SysAdmin'));
      expect(UserRole.systemAdmin.code, equals('systemAdmin'));
    });

    test('WaitingListEntry isPromoted evaluates to true only on promoted status', () {
      final entry = WaitingListEntry(
        id: 'wl_01',
        offeringId: 'off_01',
        courseCode: 'ICT 3307',
        courseTitle: 'Computational Stats',
        studentId: 'st_01',
        position: 1,
        status: WaitingListStatus.waiting,
        joinedAt: DateTime.now(),
      );

      expect(entry.isPromoted, isFalse);

      entry.status = WaitingListStatus.promoted;
      expect(entry.isPromoted, isTrue);

      entry.status = WaitingListStatus.expired;
      expect(entry.isPromoted, isFalse);

      entry.status = WaitingListStatus.cancelled;
      expect(entry.isPromoted, isFalse);
    });
  });

  group('Domain Models - Academic Governance & Curriculum', () {
    test('DegreeProgramme and Curriculum contain all metadata fields', () {
      const programme = DegreeProgramme(
        id: 'p_bict',
        departmentId: 'd1',
        code: 'BICT',
        name: 'Bachelor of Information and Communication Technology Honours',
        degreeType: 'Honours',
        durationYears: 4,
        totalCredits: 120,
      );

      const curriculum = Curriculum(
        id: 'curr_2024',
        programmeId: 'p_bict',
        version: '2024 Version 2.1',
        effectiveYear: 2024,
        totalCreditsRequired: 120,
      );

      expect(programme.code, equals('BICT'));
      expect(programme.totalCredits, equals(120));
      expect(curriculum.version, equals('2024 Version 2.1'));
      expect(curriculum.effectiveYear, equals(2024));
    });

    test('CourseRegistrationRecord instantiates with full approval trail', () {
      final approval = ApprovalHistory(
        id: 'app_1',
        approverRole: 'HoD',
        approverName: 'Dr. Lahiru Jayasuriya',
        decision: 'Approved',
        comments: 'Curriculum verified',
        timestamp: DateTime.now(),
      );

      final item = RegistrationItem(
        offeringId: 'off_301',
        courseId: 'c301',
        registrationType: CourseType.compulsory,
        addedAt: DateTime.now(),
      );

      final record = CourseRegistrationRecord(
        id: 'reg_rec_1',
        studentId: 'st_001',
        academicYear: '2025/2026',
        semesterNumber: 1,
        selectedItems: [item],
        totalCredits: 3,
        status: RegistrationStatus.departmentApproved,
        submittedAt: DateTime.now(),
        verificationToken: 'RUSL-TEST-TOKEN',
        approvals: [approval],
      );

      expect(record.studentId, equals('st_001'));
      expect(record.selectedItems.length, equals(1));
      expect(record.approvals.first.decision, equals('Approved'));
      expect(record.verificationToken, equals('RUSL-TEST-TOKEN'));
    });
  });
}
