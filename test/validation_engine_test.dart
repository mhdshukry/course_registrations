import 'package:flutter_test/flutter_test.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/domain/models.dart';
import 'package:course_registration/domain/validation_engine.dart';
import 'package:course_registration/services/app_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ValidationEngine - Credit Limit Tests', () {
    final student = StudentProfile(
      id: 'st_test_1',
      userId: 'usr_test_1',
      registrationNumber: 'ICT/2021/001',
      fullName: 'Test Student',
      facultyName: RuslFaculties.technology,
      departmentName: 'ICT',
      programmeName: 'BICT (Hons)',
      curriculumVersion: '2024 V2.1',
      currentLevel: 3,
      currentSemester: 1,
      minAllowedCredits: 12,
      maxAllowedCredits: 24,
      completedCourseIds: [],
      failedCourseIds: [],
    );

    test(
      'Fails when total credits are below the minimum threshold (12 credits)',
      () {
        final courses = [
          const Course(
            id: 'c1',
            code: 'ICT 3101',
            title: 'Course 1',
            description: '',
            creditValue: 3,
            level: 3,
            semester: 1,
            departmentId: 'd1',
            courseType: CourseType.compulsory,
          ),
          const Course(
            id: 'c2',
            code: 'ICT 3102',
            title: 'Course 2',
            description: '',
            creditValue: 3,
            level: 3,
            semester: 1,
            departmentId: 'd1',
            courseType: CourseType.compulsory,
          ),
        ];

        final result = ValidationEngine.validateCreditLimits(
          student: student,
          selectedCourses: courses, // Total = 6 credits
        );

        expect(result.isValid, isFalse);
        expect(
          result.errors.any((e) => e.contains('below the minimum')),
          isTrue,
        );
      },
    );

    test('Passes when total credits are between 12 and 24 credits', () {
      final courses = [
        const Course(
          id: 'c1',
          code: 'ICT 3101',
          title: 'Course 1',
          description: '',
          creditValue: 3,
          level: 3,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.compulsory,
        ),
        const Course(
          id: 'c2',
          code: 'ICT 3102',
          title: 'Course 2',
          description: '',
          creditValue: 3,
          level: 3,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.compulsory,
        ),
        const Course(
          id: 'c3',
          code: 'ICT 3103',
          title: 'Course 3',
          description: '',
          creditValue: 3,
          level: 3,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.compulsory,
        ),
        const Course(
          id: 'c4',
          code: 'ICT 3104',
          title: 'Course 4',
          description: '',
          creditValue: 3,
          level: 3,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.compulsory,
        ),
        const Course(
          id: 'c5',
          code: 'ICT 3105',
          title: 'Course 5',
          description: '',
          creditValue: 3,
          level: 3,
          semester: 1,
          departmentId: 'd1',
          courseType: CourseType.elective,
        ),
      ];

      final result = ValidationEngine.validateCreditLimits(
        student: student,
        selectedCourses: courses, // Total = 15 credits
      );

      expect(result.isValid, isTrue);
      expect(result.errors.isEmpty, isTrue);
    });

    test(
      'Fails when total credits exceed maximum allowed bound (24 credits)',
      () {
        final courses = List.generate(
          9,
          (i) => Course(
            id: 'c_$i',
            code: 'ICT 310$i',
            title: 'Course $i',
            description: '',
            creditValue: 3,
            level: 3,
            semester: 1,
            departmentId: 'd1',
            courseType: CourseType.elective,
          ),
        ); // Total = 27 credits

        final result = ValidationEngine.validateCreditLimits(
          student: student,
          selectedCourses: courses,
        );

        expect(result.isValid, isFalse);
        expect(
          result.errors.any((e) => e.contains('exceeds the maximum')),
          isTrue,
        );
      },
    );
  });

  group('ValidationEngine - Prerequisite Tests', () {
    const prereqCourse = Course(
      id: 'c_prereq',
      code: 'ICT 1201',
      title: 'Programming Fundamentals',
      description: '',
      creditValue: 3,
      level: 1,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
    );

    const targetCourse = Course(
      id: 'c_target',
      code: 'ICT 2203',
      title: 'Object Oriented Programming',
      description: '',
      creditValue: 3,
      level: 2,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
      prerequisiteCourseIds: ['c_prereq'],
    );

    test(
      'Fails when student has not completed required prerequisite course',
      () {
        final student = StudentProfile(
          id: 'st_1',
          userId: 'u_1',
          registrationNumber: 'ICT/2021/010',
          fullName: 'Jane Doe',
          facultyName: RuslFaculties.technology,
          departmentName: 'ICT',
          programmeName: 'BICT (Hons)',
          curriculumVersion: '2024 V2.1',
          currentLevel: 2,
          currentSemester: 1,
          minAllowedCredits: 12,
          maxAllowedCredits: 24,
          completedCourseIds: [], // Prerequisite missing!
          failedCourseIds: [],
        );

        final result = ValidationEngine.validatePrerequisites(
          student: student,
          selectedCourses: [targetCourse],
          allCourses: [prereqCourse, targetCourse],
        );

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('ICT 1201')), isTrue);
      },
    );

    test('Passes when student has completed prerequisite course', () {
      final student = StudentProfile(
        id: 'st_2',
        userId: 'u_2',
        registrationNumber: 'ICT/2021/011',
        fullName: 'John Doe',
        facultyName: RuslFaculties.technology,
        departmentName: 'ICT',
        programmeName: 'BICT (Hons)',
        curriculumVersion: '2024 V2.1',
        currentLevel: 2,
        currentSemester: 1,
        minAllowedCredits: 12,
        maxAllowedCredits: 24,
        completedCourseIds: ['c_prereq'], // Completed!
        failedCourseIds: [],
      );

      final result = ValidationEngine.validatePrerequisites(
        student: student,
        selectedCourses: [targetCourse],
        allCourses: [prereqCourse, targetCourse],
      );

      expect(result.isValid, isTrue);
      expect(result.errors.isEmpty, isTrue);
    });
  });

  group('ValidationEngine - Timetable Clash Tests', () {
    const courseA = Course(
      id: 'cA',
      code: 'ICT 3101',
      title: 'Course A',
      description: '',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
    );

    const courseB = Course(
      id: 'cB',
      code: 'ICT 3102',
      title: 'Course B',
      description: '',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    );

    test(
      'Detects clash when two offerings overlap on the same day and time',
      () {
        final offeringA = CourseOffering(
          id: 'offA',
          courseId: 'cA',
          academicYear: '2025/2026',
          semesterNumber: 1,
          lecturerName: 'Lecturer A',
          maxCapacity: 50,
          currentRegisteredCount: 30,
          slots: const [
            TimetableSlot(
              id: 'tsA',
              dayOfWeek: 'Monday',
              startTime: '09:00',
              endTime: '11:00',
              venue: 'Hall 1',
              groupType: 'Lecture',
            ),
          ],
        );

        final offeringB = CourseOffering(
          id: 'offB',
          courseId: 'cB',
          academicYear: '2025/2026',
          semesterNumber: 1,
          lecturerName: 'Lecturer B',
          maxCapacity: 50,
          currentRegisteredCount: 30,
          slots: const [
            TimetableSlot(
              id: 'tsB',
              dayOfWeek: 'Monday',
              startTime: '10:00', // Overlaps with 09:00 - 11:00
              endTime: '12:00',
              venue: 'Hall 2',
              groupType: 'Lecture',
            ),
          ],
        );

        final clashes = ValidationEngine.detectTimetableClashes(
          selectedOfferings: [offeringA, offeringB],
          allCourses: [courseA, courseB],
        );

        expect(clashes.isNotEmpty, isTrue);
        expect(clashes.first.day, equals('Monday'));
      },
    );

    test(
      'No clash when offerings are scheduled on different days or separate hours',
      () {
        final offeringA = CourseOffering(
          id: 'offA',
          courseId: 'cA',
          academicYear: '2025/2026',
          semesterNumber: 1,
          lecturerName: 'Lecturer A',
          maxCapacity: 50,
          currentRegisteredCount: 30,
          slots: const [
            TimetableSlot(
              id: 'tsA',
              dayOfWeek: 'Monday',
              startTime: '08:30',
              endTime: '10:30',
              venue: 'Hall 1',
              groupType: 'Lecture',
            ),
          ],
        );

        final offeringB = CourseOffering(
          id: 'offB',
          courseId: 'cB',
          academicYear: '2025/2026',
          semesterNumber: 1,
          lecturerName: 'Lecturer B',
          maxCapacity: 50,
          currentRegisteredCount: 30,
          slots: const [
            TimetableSlot(
              id: 'tsB',
              dayOfWeek: 'Monday',
              startTime: '11:00', // No overlap
              endTime: '13:00',
              venue: 'Hall 2',
              groupType: 'Lecture',
            ),
          ],
        );

        final clashes = ValidationEngine.detectTimetableClashes(
          selectedOfferings: [offeringA, offeringB],
          allCourses: [courseA, courseB],
        );

        expect(clashes.isEmpty, isTrue);
      },
    );
  });

  group('AppService - Curriculum Registration', () {
    test('assigns every compulsory semester course automatically', () {
      final appService = AppService();
      final compulsoryIds = appService.courseOfferings
          .where(
            (offering) {
              final course = appService.courses
                  .firstWhere((c) => c.id == offering.courseId);
              return course.courseType == CourseType.compulsory &&
                  course.level == appService.activeStudent.currentLevel &&
                  course.semester == appService.activeStudent.currentSemester;
            },
          )
          .map((offering) => offering.id);

      expect(appService.selectedOfferingIds.containsAll(compulsoryIds), isTrue);
      expect(appService.totalSelectedCredits, equals(12));
    });

    test('allows optional selection but never removes compulsory courses', () {
      final appService = AppService();
      appService.toggleCourseSelection('off_301');
      expect(appService.selectedOfferingIds.contains('off_301'), isTrue);

      appService.toggleCourseSelection('off_304');
      expect(appService.selectedOfferingIds.contains('off_304'), isTrue);
      appService.toggleCourseSelection('off_304');
      expect(appService.selectedOfferingIds.contains('off_304'), isFalse);
    });

    test(
      'submitRegistration blocks submission if total credits are below minimum',
      () {
        final appService = AppService();
        appService.selectedOfferingIds.clear(); // 0 credits selected
        expect(appService.totalSelectedCredits, equals(0));

        final success = appService.submitRegistration();
        expect(success, isFalse);
        expect(
          appService.activeRegistrationStatus,
          equals(RegistrationStatus.draft),
        );
      },
    );

    test(
      'submitRegistration succeeds when total credits are within allowed bounds',
      () {
        final appService = AppService();
        // Select 5 courses with 3 credits each = 15 credits (within 12-24 limit)
        appService.selectedOfferingIds.clear();
        appService.selectedOfferingIds.addAll([
          'off_301',
          'off_302',
          'off_303',
          'off_305',
          'off_306',
          'off_307',
        ]);
        expect(appService.totalSelectedCredits, greaterThanOrEqualTo(12));
        expect(appService.totalSelectedCredits, lessThanOrEqualTo(24));

        final success = appService.submitRegistration();
        expect(success, isTrue);
        expect(
          appService.activeRegistrationStatus,
          equals(RegistrationStatus.submitted),
        );
      },
    );
  });

  group('AppService - Cross-portal approval workflow', () {
    AppService submittedRegistration() {
      final app = AppService();
      app.selectedOfferingIds
        ..clear()
        ..addAll([
          'off_301',
          'off_302',
          'off_303',
          'off_305',
          'off_306',
          'off_307',
        ]);
      expect(app.submitRegistration(), isTrue);
      return app;
    }

    test('connects Student, HoD, AR, and final lock in order', () {
      final app = submittedRegistration();

      app.approveByHod('Curriculum checked.');
      expect(
        app.activeRegistrationStatus,
        RegistrationStatus.departmentApproved,
      );

      app.approveAndSealByAr('Registry checked.');
      expect(app.activeRegistrationStatus, RegistrationStatus.registered);

      app.lockFacultyRegistration();
      expect(app.activeRegistrationStatus, RegistrationStatus.locked);
      expect(app.approvalHistoryList.length, 4);
    });

    test('blocks portal decisions made out of sequence', () {
      final app = submittedRegistration();

      app.approveAndSealByAr('Attempted early seal.');
      app.lockFacultyRegistration();

      expect(app.activeRegistrationStatus, RegistrationStatus.submitted);
      expect(app.approvalHistoryList.length, 1);
    });

    test('creates timetable slots and blocks venue clashes', () {
      final app = AppService();
      final created = app.createTimetableSlot(
        offeringId: 'off_301',
        dayOfWeek: 'Tuesday',
        startTime: '13:00',
        endTime: '15:00',
        venue: 'New Lecture Hall',
        groupType: 'Lecture',
      );
      expect(created, isNull);

      final clash = app.createTimetableSlot(
        offeringId: 'off_302',
        dayOfWeek: 'Tuesday',
        startTime: '14:00',
        endTime: '16:00',
        venue: 'New Lecture Hall',
        groupType: 'Practical',
      );
      expect(clash, contains('clash'));
    });

    test('formats an extended deadline using its actual month', () {
      final app = AppService();
      app.adminExtendDeadline(1);

      expect(app.registrationEndLabel, '01 November 2026');
    });

    test('academic history counts only completed credits', () {
      final app = AppService();

      expect(app.completedAcademicCredits, 62);
      expect(app.creditsForAcademicStatus(AcademicRecordStatus.medical), 2);
      expect(app.creditsForAcademicStatus(AcademicRecordStatus.dropped), 2);
    });

    test('only AR and system admin can change academic record status', () {
      final app = AppService();
      final record = app.academicRecords.first;

      expect(
        app.updateAcademicRecordStatus(record.id, AcademicRecordStatus.medical),
        isFalse,
      );
      expect(record.status, AcademicRecordStatus.completed);

      app.switchRole(UserRole.assistantRegistrar);
      expect(
        app.updateAcademicRecordStatus(record.id, AcademicRecordStatus.medical),
        isTrue,
      );
      expect(record.status, AcademicRecordStatus.medical);
      expect(
        app.auditLogs.any(
          (log) => log.action == 'ACADEMIC_RECORD_STATUS_UPDATED',
        ),
        isTrue,
      );
    });

    test('medical and failed results can be requested as repeats but dropped cannot', () {
      final app = AppService()..switchRole(UserRole.student);

      // Dropped course cannot be re-registered
      expect(app.isCourseDropped('ICT 2218'), isTrue);
      expect(app.repeatEligibleAcademicRecords.any((r) => r.courseCode == 'ICT 2218'), isFalse);
      expect(app.toggleRepeatSubjectRequest('hist_214'), isFalse);
      expect(app.requestedRepeatRecordIds.contains('hist_214'), isFalse);

      // Medical concession course can be re-registered
      expect(app.repeatEligibleAcademicRecords.any((r) => r.courseCode == 'ICT 2216'), isTrue);
      final medical = app.repeatEligibleAcademicRecords.firstWhere(
        (record) => record.courseCode == 'ICT 2216',
      );
      expect(medical.isMedical, isTrue);
      expect(medical.canRegisterAgain, isTrue);
      expect(app.toggleRepeatSubjectRequest(medical.id), isTrue);
      expect(app.requestedRepeatRecordIds, contains(medical.id));
      expect(app.completedAcademicCredits, 62);

      // ValidationEngine blocks dropped subjects
      final droppedCourse = app.courses.firstWhere(
        (c) => c.code == 'ICT 2218',
        orElse: () => Course(
          id: 'test_drop',
          code: 'ICT 2218',
          title: 'Graphic Design',
          description: '',
          creditValue: 2,
          level: 2,
          semester: 2,
          departmentId: 'dept_ict',
          courseType: CourseType.elective,
        ),
      );
      final validation = ValidationEngine.validateDroppedCourses(
        selectedCourses: [droppedCourse],
        academicRecords: app.academicRecords,
      );
      expect(validation.isValid, isFalse);
      expect(validation.errors.first, contains('dropped subjects cannot be registered again'));
    });

    test('restores registration workflow after application restart', () async {
      SharedPreferences.setMockInitialValues({});
      final firstInstance = AppService();
      while (!firstInstance.isReady) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      firstInstance.switchRole(UserRole.student);
      firstInstance.toggleCourseSelection('off_304');
      expect(firstInstance.selectedOfferingIds, contains('off_304'));
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final restartedInstance = AppService();
      while (!restartedInstance.isReady) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      expect(restartedInstance.selectedOfferingIds, contains('off_304'));
      expect(restartedInstance.currentRole, UserRole.student);
      SharedPreferences.setMockInitialValues({});
    });

    test('Repeat/Medical subjects do not require lecture attendance and are excluded from timetable clashes', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppService();
      while (!app.isReady) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      app.switchRole(UserRole.student);

      // Student is Level 3 Semester 2
      expect(app.activeStudent.currentLevel, 3);
      expect(app.activeStudent.currentSemester, 2);

      // Regular Level 3 offering matching current semester
      final regularOffering = app.courseOfferings.firstWhere((o) {
        final course = app.courses.firstWhere((c) => c.id == o.courseId);
        return course.level == app.activeStudent.currentLevel &&
            course.semester == app.activeStudent.currentSemester;
      });

      // Medical concession course (ICT 2216 from Level 2)
      final medicalRecord = app.repeatEligibleAcademicRecords.firstWhere(
        (r) => r.isMedical,
      );
      expect(app.toggleRepeatSubjectRequest(medicalRecord.id), isTrue);
      expect(app.hasRepeatOrMedicalRegistrations, isTrue);

      // Verify that repeat/medical subjects are recognized by isCourseRepeatOrMedical
      final medicalCourse = app.courses.firstWhere(
        (c) => c.code.trim().toUpperCase() == medicalRecord.courseCode.trim().toUpperCase(),
      );
      expect(app.isCourseRepeatOrMedical(medicalCourse), isTrue);

      // Offerings requiring lecture attendance filter out repeat/medical courses
      expect(app.timetableEligibleOfferings.every((o) => !app.isOfferingRepeatOrMedical(o)), isTrue);

      // Create repeat offering with overlapping slot to regular offering
      final repeatOffering = CourseOffering(
        id: 'test_repeat_offering',
        courseId: medicalCourse.id,
        academicYear: '2025/2026',
        semesterNumber: 1,
        maxCapacity: 50,
        currentRegisteredCount: 10,
        lecturerName: 'Dr. Test',
        slots: regularOffering.slots,
      );
      app.courseOfferings.add(repeatOffering);

      // Both regular offering and repeat offering are selected
      app.selectedOfferingIds.add(regularOffering.id);
      app.selectedOfferingIds.add(repeatOffering.id);

      // Repeat offering is recognized as repeat/medical
      expect(app.isOfferingRepeatOrMedical(repeatOffering), isTrue);

      // Regular offering is on the timetable, but repeat offering is excluded
      expect(app.timetableEligibleOfferings.contains(repeatOffering), isFalse);
      expect(app.timetableEligibleOfferings.contains(regularOffering), isTrue);

      // Even though slots overlap, repeat courses are attendance-exempt,
      // so zero timetable clashes occur!
      expect(app.selectedTimetableClashes, isEmpty);

      // When student only has repeat offerings:
      app.selectedOfferingIds.clear();
      app.selectedOfferingIds.add(repeatOffering.id);
      expect(app.timetableEligibleOfferings, isEmpty);
      expect(app.hasRepeatOrMedicalRegistrations, isTrue);
      expect(app.selectedTimetableClashes, isEmpty);

      SharedPreferences.setMockInitialValues({});
    });
  });
}
