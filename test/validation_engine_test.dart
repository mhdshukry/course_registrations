import 'package:flutter_test/flutter_test.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/domain/models.dart';
import 'package:course_registration/domain/validation_engine.dart';
import 'package:course_registration/services/app_service.dart';

void main() {
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

    test('Fails when total credits are below the minimum threshold (12 credits)', () {
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
      expect(result.errors.any((e) => e.contains('below the minimum')), isTrue);
    });

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

    test('Fails when total credits exceed maximum allowed bound (24 credits)', () {
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
      expect(result.errors.any((e) => e.contains('exceeds the maximum')), isTrue);
    });
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

    test('Fails when student has not completed required prerequisite course', () {
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
    });

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

    test('Detects clash when two offerings overlap on the same day and time', () {
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
    });

    test('No clash when offerings are scheduled on different days or separate hours', () {
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
    });
  });

  group('AppService - Waiting List & Auto-Promotion Engine', () {
    test('Correctly enqueues candidate and auto-promotes upon vacancy', () {
      final appService = AppService();
      final fullOffering = appService.courseOfferings.firstWhere((o) => o.isFull); // off_304 (50/50)

      // Initial state: 1 student in queue
      expect(appService.waitingListEntries.isNotEmpty, isTrue);

      // Student joins waiting list
      appService.joinWaitingList(fullOffering.id);
      expect(appService.isInWaitingList(fullOffering.id), isTrue);

      // Auto promotion simulation
      appService.processAutoSeatPromotion(fullOffering.id);
      final promoted = appService.waitingListEntries.firstWhere((w) => w.isPromoted);
      expect(promoted.isPromoted, isTrue);

      // Accepting promoted seat adds offering to selectedOfferingIds
      appService.acceptPromotedSeat(promoted.offeringId);
      expect(appService.selectedOfferingIds.contains(promoted.offeringId), isTrue);
    });

    test('Expanding course capacity promotes waiting candidates automatically', () {
      final appService = AppService();
      final fullOffering = appService.courseOfferings.firstWhere((o) => o.id == 'off_304');
      final initialCap = fullOffering.maxCapacity;

      appService.increaseOfferingCapacity(fullOffering.id, 5);
      expect(fullOffering.maxCapacity, equals(initialCap + 5));
    });

    test('submitRegistration blocks submission if total credits are below minimum', () {
      final appService = AppService();
      appService.selectedOfferingIds.clear(); // 0 credits selected
      expect(appService.totalSelectedCredits, equals(0));

      final success = appService.submitRegistration();
      expect(success, isFalse);
      expect(appService.activeRegistrationStatus, equals(RegistrationStatus.draft));
    });

    test('submitRegistration succeeds when total credits are within allowed bounds', () {
      final appService = AppService();
      // Select 5 courses with 3 credits each = 15 credits (within 12-24 limit)
      appService.selectedOfferingIds.clear();
      appService.selectedOfferingIds.addAll(['off_301', 'off_302', 'off_303', 'off_305', 'off_306']);
      expect(appService.totalSelectedCredits, greaterThanOrEqualTo(12));
      expect(appService.totalSelectedCredits, lessThanOrEqualTo(24));

      final success = appService.submitRegistration();
      expect(success, isTrue);
      expect(appService.activeRegistrationStatus, equals(RegistrationStatus.submitted));
    });
  });
}
