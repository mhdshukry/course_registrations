import '../core/constants.dart';
import '../domain/models.dart';

class MockData {
  static List<Faculty> getFaculties() => const [
    Faculty(
      id: 'f1',
      code: 'FOT',
      name: RuslFaculties.technology,
      departmentCount: 3,
    ),
    Faculty(
      id: 'f2',
      code: 'FAS',
      name: RuslFaculties.appliedSciences,
      departmentCount: 4,
    ),
    Faculty(
      id: 'f3',
      code: 'FMS',
      name: RuslFaculties.managementStudies,
      departmentCount: 4,
    ),
    Faculty(
      id: 'f4',
      code: 'FOA',
      name: RuslFaculties.agriculture,
      departmentCount: 3,
    ),
    Faculty(
      id: 'f5',
      code: 'FMAS',
      name: RuslFaculties.medicine,
      departmentCount: 5,
    ),
    Faculty(
      id: 'f6',
      code: 'FSSH',
      name: RuslFaculties.socialSciences,
      departmentCount: 5,
    ),
  ];

  static List<Department> getDepartments() => const [
    Department(
      id: 'd1',
      facultyId: 'f1',
      code: 'ICT',
      name: 'Information & Communication Technology',
    ),
    Department(
      id: 'd2',
      facultyId: 'f1',
      code: 'BPT',
      name: 'Bio-Process Technology',
    ),
    Department(
      id: 'd3',
      facultyId: 'f1',
      code: 'EMT',
      name: 'Electrical & Media Technology',
    ),
    Department(
      id: 'd4',
      facultyId: 'f2',
      code: 'CS',
      name: 'Department of Computing',
    ),
  ];

  static StudentProfile getActiveStudent() => StudentProfile(
    id: 'st_001',
    userId: 'usr_001',
    registrationNumber: 'ICT/2021/045',
    fullName: 'Nafis Ahamed',
    facultyName: RuslFaculties.technology,
    departmentName: 'Information & Communication Technology',
    programmeName:
        'Bachelor of Information & Communication Technology (Honours)',
    curriculumVersion: '2024 Version 2.1',
    currentLevel: 3,
    currentSemester: 1,
    minAllowedCredits: 12,
    maxAllowedCredits: 24,
    completedCourseIds: ['c101', 'c102', 'c201', 'c202'],
    failedCourseIds: [],
  );

  static List<Course> getCourses() => const [
    Course(
      id: 'c101',
      code: 'ICT 1201',
      title: 'Programming Fundamentals',
      description: 'Introduction to C, logic, arrays, and algorithms.',
      creditValue: 2,
      level: 1,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
    ),
    Course(
      id: 'c102',
      code: 'ICT 1202',
      title: 'Database Management Systems',
      description: 'Relational algebra, SQL, normalization, ER diagrams.',
      creditValue: 3,
      level: 1,
      semester: 2,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
      prerequisiteCourseIds: ['c101'],
    ),
    Course(
      id: 'c201',
      code: 'ICT 2203',
      title: 'Object Oriented Programming',
      description: 'Java & Dart OOP, polymorphism, design patterns.',
      creditValue: 3,
      level: 2,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
      prerequisiteCourseIds: ['c101'],
    ),
    Course(
      id: 'c301',
      code: 'ICT 3102',
      title: 'Software Engineering',
      description: 'Agile methodologies, SDLC, requirements engineering.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.compulsory,
      prerequisiteCourseIds: ['c201'],
    ),
    Course(
      id: 'c302',
      code: 'ICT 3205',
      title: 'UI/UX Design with Figma',
      description: 'User research, wireframing, interactive prototyping.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    ),
    Course(
      id: 'c303',
      code: 'ICT 3210',
      title: 'Framer & Web Development',
      description: 'Advanced frontend design, animation, component building.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    ),
    Course(
      id: 'c304',
      code: 'ICT 3212',
      title: 'Artificial Intelligence & Machine Learning',
      description: 'Supervised learning, neural networks, computer vision.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    ),
    Course(
      id: 'c305',
      code: 'ICT 3215',
      title: 'Cloud Computing & DevOps',
      description: 'Docker, Kubernetes, AWS infrastructure, CI/CD pipelines.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    ),
    Course(
      id: 'c306',
      code: 'ICT 3220',
      title: 'Mobile Application Development',
      description:
          'Flutter cross-platform development, state management, REST APIs.',
      creditValue: 3,
      level: 3,
      semester: 1,
      departmentId: 'd1',
      courseType: CourseType.elective,
    ),
  ];

  static List<CourseOffering> getCourseOfferings() => [
    CourseOffering(
      id: 'off_301',
      courseId: 'c301',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Dr. Chandana Jayawardena',
      maxCapacity: 60,
      currentRegisteredCount: 45,
      slots: const [
        TimetableSlot(
          id: 'ts1',
          dayOfWeek: 'Monday',
          startTime: '08:30',
          endTime: '10:30',
          venue: 'FOT Hall 01',
          groupType: 'Lecture',
        ),
      ],
    ),
    CourseOffering(
      id: 'off_302',
      courseId: 'c302',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Sarah Johnson',
      maxCapacity: 40,
      currentRegisteredCount: 38,
      slots: const [
        TimetableSlot(
          id: 'ts2',
          dayOfWeek: 'Tuesday',
          startTime: '10:30',
          endTime: '12:30',
          venue: 'Design Studio Lab',
          groupType: 'Practical',
        ),
      ],
    ),
    CourseOffering(
      id: 'off_303',
      courseId: 'c303',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Sarah Johnson',
      maxCapacity: 35,
      currentRegisteredCount: 32,
      slots: const [
        TimetableSlot(
          id: 'ts3',
          dayOfWeek: 'Wednesday',
          startTime: '08:30',
          endTime: '10:30',
          venue: 'Web Lab 02',
          groupType: 'Practical',
        ),
      ],
    ),
    CourseOffering(
      id: 'off_304',
      courseId: 'c304',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Prof. Sarath Perera',
      maxCapacity: 50,
      currentRegisteredCount: 50, // 100% Full Capacity
      slots: const [
        TimetableSlot(
          id: 'ts4',
          dayOfWeek: 'Thursday',
          startTime: '13:00',
          endTime: '15:00',
          venue: 'AI Research Lab',
          groupType: 'Lecture',
        ),
      ],
    ),
    CourseOffering(
      id: 'off_305',
      courseId: 'c305',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Dr. Kanthi Silva',
      maxCapacity: 30,
      currentRegisteredCount: 29,
      slots: const [
        TimetableSlot(
          id: 'ts5',
          dayOfWeek: 'Friday',
          startTime: '09:00',
          endTime: '11:00',
          venue: 'Network Lab',
          groupType: 'Practical',
        ),
      ],
    ),
    CourseOffering(
      id: 'off_306',
      courseId: 'c306',
      academicYear: '2025/2026',
      semesterNumber: 1,
      lecturerName: 'Nafis Ahamed',
      maxCapacity: 45,
      currentRegisteredCount: 40,
      slots: const [
        TimetableSlot(
          id: 'ts6',
          dayOfWeek: 'Monday',
          startTime: '13:00',
          endTime: '15:00',
          venue: 'Mobile Lab',
          groupType: 'Practical',
        ),
      ],
    ),
  ];

  static List<SpecialRequest> getSpecialRequests(
    String studentId,
    String studentName,
  ) => [
    SpecialRequest(
      id: 'req_101',
      studentId: studentId,
      studentName: studentName,
      requestType: 'Credit Overload',
      explanation:
          'Requesting permission to take 27 credits for research project completion.',
      status: 'Approved',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SpecialRequest(
      id: 'req_102',
      studentId: studentId,
      studentName: studentName,
      requestType: 'Prerequisite Waiver',
      explanation:
          'Waiver requested for ICT 3212 based on online certificate completion.',
      status: 'Pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<AuditLog> getAuditLogs() => [
    AuditLog(
      id: 'log_1',
      userName: 'Nafis Ahamed',
      userRole: 'Student',
      action: 'COURSE_SELECTED',
      details: 'Selected ICT 3205 UI/UX Design with Figma',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditLog(
      id: 'log_2',
      userName: 'Dr. Chandana Jayawardena',
      userRole: 'Academic Adviser',
      action: 'RECOMMENDATION_ADDED',
      details: 'Recommended ICT 3102 Software Engineering for Semester 5',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AuditLog(
      id: 'log_3',
      userName: 'Prof. Sarath Perera',
      userRole: 'Head of Department',
      action: 'CAPACITY_INCREASED',
      details: 'Increased ICT 3212 capacity from 40 to 50 seats',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<WaitingListEntry> getWaitingListEntries(String studentId) => [
    WaitingListEntry(
      id: 'wl_001',
      offeringId: 'off_304',
      courseCode: 'ICT 3212',
      courseTitle: 'Artificial Intelligence & Machine Learning',
      studentId: studentId,
      position: 2,
      status: WaitingListStatus.waiting,
      joinedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static List<AppNotification> getInitialNotifications() => [
    AppNotification(
      id: 'notif_1',
      title: 'Semester 5 Registration Open',
      message:
          'Course registration portal is open. Ensure total credits are between 12 and 24 before submitting.',
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
      isRead: false,
      type: NotificationType.system,
    ),
    AppNotification(
      id: 'notif_2',
      title: 'Special Petition Approved',
      message:
          'Your Credit Overload petition (27 credits) has been officially approved by the Head of Department.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: false,
      type: NotificationType.specialRequest,
      relatedId: 'req_101',
    ),
    AppNotification(
      id: 'notif_3',
      title: 'Waiting List Position: Queue #2',
      message:
          'You have been enrolled in the waiting queue for ICT 3212. You will be auto-promoted once a seat is vacated.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      type: NotificationType.promotion,
      relatedId: 'off_304',
    ),
  ];
}
