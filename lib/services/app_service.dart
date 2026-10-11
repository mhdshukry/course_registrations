import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/localization.dart';
import '../data/repositories/academic_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/registration_repository.dart';
import '../domain/models.dart';
import '../domain/validation_engine.dart';

class AppService extends ChangeNotifier {
  static const _stateKey = 'rusl_app_state_v1';
  final AcademicRepository _academicRepository;
  final RegistrationRepository _registrationRepository;
  final NotificationRepository _notificationRepository;

  // Current active session state
  UserRole _currentRole = UserRole.student;
  String _currentLanguage = 'en';
  ThemeMode _themeMode = ThemeMode.light;

  UserRole get currentRole => _currentRole;
  String get currentLanguage => _currentLanguage;
  ThemeMode get themeMode => _themeMode;

  /// Synchronizes active role with authenticated session from AuthService.
  /// Intended strictly for authentication flow synchronization.
  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void switchLanguage(String lang) {
    _currentLanguage = lang;
    RuslLocalization.currentLanguage = lang;
    notifyListeners();
  }

  void switchThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  String _actorNameForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return activeStudent.fullName;
      case UserRole.headOfDepartment:
        return 'Dr. Lahiru Jayasuriya';
      case UserRole.dean:
        return 'Prof. T. C. Bamunuarachchige';
      case UserRole.assistantRegistrar:
        return 'Ms. K. H. Gaurika Kahawala';
      case UserRole.systemAdmin:
        return 'Mr. P. S. Palliyaguruge';
    }
  }

  // Active Student Profile
  late StudentProfile activeStudent;

  // Repositories & State Lists
  List<Faculty> faculties = [];
  List<Department> departments = [];
  List<DegreeProgramme> degreeProgrammes = [];
  List<Curriculum> curriculums = [];
  List<Course> courses = [];
  List<CourseOffering> courseOfferings = [];
  List<SpecialRequest> specialRequests = [];
  List<WaitingListEntry> waitingListEntries = [];
  List<AcademicCourseRecord> academicRecords = [];
  Set<String> requestedRepeatRecordIds = {};

  // Active Student Draft Registration
  Set<String> selectedOfferingIds = {};
  RegistrationStatus activeRegistrationStatus = RegistrationStatus.draft;
  List<ApprovalHistory> approvalHistoryList = [];
  String verificationToken = 'RUSL-VERIFY-2026-98741-X';
  DateTime registrationStartDate = DateTime(2026, 10, 1);
  DateTime registrationEndDate = DateTime(2026, 10, 31, 23, 59);
  bool _registrationOpenOverride = true;
  bool _isRestoring = false;
  bool _isReady = false;

  ValidationResult? _cachedPrereqValidation;
  ValidationResult? _cachedCreditValidation;

  bool get isReady => _isReady;

  bool get isRegistrationOpen => _registrationOpenOverride;

  String get registrationStartLabel => _formatDate(registrationStartDate);
  String get registrationEndLabel => _formatDate(registrationEndDate);

  String get currentAcademicYearLabel {
    final firstYear = courseOfferings.isNotEmpty
        ? courseOfferings.first.academicYear
        : '2025/2026';
    final sem = activeStudent.currentSemester;
    return '$firstYear • Semester $sem';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  // Notifications & Audit Logs accessors
  List<AppNotification> get notifications =>
      _notificationRepository.getNotifications();
  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;
  List<AuditLog> get auditLogs => _notificationRepository.getAuditLogs();

  AppService({
    AcademicRepository? academicRepository,
    RegistrationRepository? registrationRepository,
    NotificationRepository? notificationRepository,
  }) : _academicRepository = academicRepository ?? MockAcademicRepository(),
       _registrationRepository =
           registrationRepository ?? MockRegistrationRepository(),
       _notificationRepository =
           notificationRepository ?? MockNotificationRepository() {
    _initializeData();
    unawaited(_restoreState());
  }

  Timer? _saveDebounceTimer;

  @override
  void notifyListeners() {
    _cachedPrereqValidation = null;
    _cachedCreditValidation = null;
    super.notifyListeners();
    if (!_isRestoring && _isReady) {
      _saveDebounceTimer?.cancel();
      _saveDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        unawaited(_saveState());
      });
    }
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreState() async {
    _isRestoring = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_stateKey);
      if (encoded != null) {
        final state = jsonDecode(encoded) as Map<String, dynamic>;
        _currentRole = UserRole.values.firstWhere(
          (value) => value.name == state['currentRole'],
          orElse: () => UserRole.student,
        );
        _currentLanguage = state['currentLanguage'] as String? ?? 'en';
        RuslLocalization.currentLanguage = _currentLanguage;
        _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == state['themeMode'],
          orElse: () => ThemeMode.light,
        );
        selectedOfferingIds = Set<String>.from(
          (state['selectedOfferingIds'] as List<dynamic>? ?? const []),
        );
        activeRegistrationStatus = RegistrationStatus.values.firstWhere(
          (value) => value.name == state['activeRegistrationStatus'],
          orElse: () => RegistrationStatus.draft,
        );
        verificationToken =
            state['verificationToken'] as String? ?? verificationToken;
        registrationStartDate =
            DateTime.tryParse(
              state['registrationStartDate'] as String? ?? '',
            ) ??
            registrationStartDate;
        registrationEndDate =
            DateTime.tryParse(state['registrationEndDate'] as String? ?? '') ??
            registrationEndDate;
        _registrationOpenOverride =
            state['registrationOpen'] as bool? ?? _registrationOpenOverride;

        final storedApprovals = state['approvalHistory'] as List<dynamic>?;
        if (storedApprovals != null) {
          approvalHistoryList = storedApprovals
              .map(
                (item) => ApprovalHistory(
                  id: item['id'] as String,
                  approverRole: item['approverRole'] as String,
                  approverName: item['approverName'] as String,
                  decision: item['decision'] as String,
                  comments: item['comments'] as String,
                  timestamp: DateTime.parse(item['timestamp'] as String),
                ),
              )
              .toList();
        }

        final storedRecords = state['academicRecords'] as List<dynamic>?;
        if (storedRecords != null) {
          academicRecords = storedRecords
              .map(
                (item) => AcademicCourseRecord(
                  id: item['id'] as String,
                  courseCode: item['courseCode'] as String,
                  courseTitle: item['courseTitle'] as String,
                  academicYear: item['academicYear'] as String,
                  level: item['level'] as int? ?? 1,
                  semester: item['semester'] as int,
                  credits: item['credits'] as int,
                  grade: item['grade'] as String?,
                  status: AcademicRecordStatus.values.firstWhere(
                    (value) => value.name == item['status'],
                  ),
                  updatedAt: DateTime.parse(item['updatedAt'] as String),
                ),
              )
              .toList();
        }

        requestedRepeatRecordIds = Set<String>.from(
          state['requestedRepeatRecordIds'] as List<dynamic>? ?? const [],
        );

        final storedRequests = state['specialRequests'] as List<dynamic>?;
        if (storedRequests != null) {
          specialRequests = storedRequests
              .map(
                (item) => SpecialRequest(
                  id: item['id'] as String,
                  studentId: item['studentId'] as String,
                  studentName: item['studentName'] as String,
                  requestType: item['requestType'] as String,
                  explanation: item['explanation'] as String,
                  status: SpecialRequestStatus.fromString(
                    item['status'] as String? ?? 'pending',
                  ),
                  submittedAt: DateTime.parse(item['submittedAt'] as String),
                ),
              )
              .toList();
        }

        final offeringState = state['courseOfferings'] as List<dynamic>?;
        if (offeringState != null) {
          for (final stored in offeringState) {
            final index = courseOfferings.indexWhere(
              (offering) => offering.id == stored['id'],
            );
            if (index == -1) continue;
            final offering = courseOfferings[index];
            offering.maxCapacity = stored['maxCapacity'] as int;
            offering.currentRegisteredCount =
                stored['currentRegisteredCount'] as int;
            final slots = stored['slots'] as List<dynamic>?;
            if (slots != null) {
              offering.slots
                ..clear()
                ..addAll(
                  slots.map(
                    (slot) => TimetableSlot(
                      id: slot['id'] as String,
                      dayOfWeek: slot['dayOfWeek'] as String,
                      startTime: slot['startTime'] as String,
                      endTime: slot['endTime'] as String,
                      venue: slot['venue'] as String,
                      groupType: slot['groupType'] as String,
                    ),
                  ),
                );
            }
          }
        }

        final storedNotifications = state['notifications'] as List<dynamic>?;
        if (storedNotifications != null) {
          _notificationRepository.setNotifications(
            storedNotifications
                .map(
                  (item) => AppNotification(
                    id: item['id'] as String,
                    title: item['title'] as String,
                    message: item['message'] as String,
                    timestamp: DateTime.parse(item['timestamp'] as String),
                    isRead: item['isRead'] as bool,
                    type: NotificationType.values.firstWhere(
                      (value) => value.name == item['type'],
                    ),
                    relatedId: item['relatedId'] as String?,
                  ),
                )
                .toList(),
          );
        }
        final storedAuditLogs = state['auditLogs'] as List<dynamic>?;
        if (storedAuditLogs != null) {
          _notificationRepository.setAuditLogs(
            storedAuditLogs
                .map(
                  (item) => AuditLog(
                    id: item['id'] as String,
                    userName: item['userName'] as String,
                    userRole: item['userRole'] as String,
                    action: item['action'] as String,
                    details: item['details'] as String,
                    timestamp: DateTime.parse(item['timestamp'] as String),
                  ),
                )
                .toList(),
          );
        }

        final storedWaiting = state['waitingListEntries'] as List<dynamic>?;
        if (storedWaiting != null) {
          waitingListEntries = storedWaiting
              .map(
                (item) => WaitingListEntry(
                  id: item['id'] as String,
                  offeringId: item['offeringId'] as String,
                  courseCode: item['courseCode'] as String,
                  courseTitle: item['courseTitle'] as String,
                  studentId: item['studentId'] as String,
                  position: item['position'] as int,
                  status: WaitingListStatus.values.firstWhere(
                    (s) => s.name == item['status'],
                    orElse: () => WaitingListStatus.waiting,
                  ),
                  joinedAt: DateTime.parse(item['joinedAt'] as String),
                ),
              )
              .toList();
        }
      }
    } catch (error) {
      debugPrint('Unable to restore persisted app state: $error');
    } finally {
      _isRestoring = false;
      _isReady = true;
      super.notifyListeners();
    }
  }

  Future<void> _saveState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final state = <String, dynamic>{
        'currentRole': _currentRole.name,
        'currentLanguage': _currentLanguage,
        'themeMode': _themeMode.name,
        'selectedOfferingIds': selectedOfferingIds.toList(),
        'activeRegistrationStatus': activeRegistrationStatus.name,
        'verificationToken': verificationToken,
        'registrationStartDate': registrationStartDate.toIso8601String(),
        'registrationEndDate': registrationEndDate.toIso8601String(),
        'registrationOpen': _registrationOpenOverride,
        'approvalHistory': approvalHistoryList
            .map(
              (item) => {
                'id': item.id,
                'approverRole': item.approverRole,
                'approverName': item.approverName,
                'decision': item.decision,
                'comments': item.comments,
                'timestamp': item.timestamp.toIso8601String(),
              },
            )
            .toList(),
        'academicRecords': academicRecords
            .map(
              (item) => {
                'id': item.id,
                'courseCode': item.courseCode,
                'courseTitle': item.courseTitle,
                'academicYear': item.academicYear,
                'level': item.level,
                'semester': item.semester,
                'credits': item.credits,
                'grade': item.grade,
                'status': item.status.name,
                'updatedAt': item.updatedAt.toIso8601String(),
              },
            )
            .toList(),
        'requestedRepeatRecordIds': requestedRepeatRecordIds.toList(),
        'specialRequests': specialRequests
            .map(
              (item) => {
                'id': item.id,
                'studentId': item.studentId,
                'studentName': item.studentName,
                'requestType': item.requestType,
                'explanation': item.explanation,
                'status': item.status.name,
                'submittedAt': item.submittedAt.toIso8601String(),
              },
            )
            .toList(),
        'courseOfferings': courseOfferings
            .map(
              (offering) => {
                'id': offering.id,
                'maxCapacity': offering.maxCapacity,
                'currentRegisteredCount': offering.currentRegisteredCount,
                'slots': offering.slots
                    .map(
                      (slot) => {
                        'id': slot.id,
                        'dayOfWeek': slot.dayOfWeek,
                        'startTime': slot.startTime,
                        'endTime': slot.endTime,
                        'venue': slot.venue,
                        'groupType': slot.groupType,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
        'notifications': notifications
            .map(
              (item) => {
                'id': item.id,
                'title': item.title,
                'message': item.message,
                'timestamp': item.timestamp.toIso8601String(),
                'isRead': item.isRead,
                'type': item.type.name,
                'relatedId': item.relatedId,
              },
            )
            .toList(),
        'auditLogs': auditLogs
            .map(
              (item) => {
                'id': item.id,
                'userName': item.userName,
                'userRole': item.userRole,
                'action': item.action,
                'details': item.details,
                'timestamp': item.timestamp.toIso8601String(),
              },
            )
            .toList(),
        'waitingListEntries': waitingListEntries
            .map(
              (item) => {
                'id': item.id,
                'offeringId': item.offeringId,
                'courseCode': item.courseCode,
                'courseTitle': item.courseTitle,
                'studentId': item.studentId,
                'position': item.position,
                'status': item.status.name,
                'joinedAt': item.joinedAt.toIso8601String(),
              },
            )
            .toList(),
      };
      await preferences.setString(_stateKey, jsonEncode(state));
    } catch (error) {
      debugPrint('Unable to persist app state: $error');
    }
  }

  void _initializeData() {
    faculties = _academicRepository.getFaculties();
    departments = _academicRepository.getDepartments();
    degreeProgrammes = _academicRepository.getDegreeProgrammes();
    curriculums = _academicRepository.getCurriculums();
    courses = _academicRepository.getCourses();
    courseOfferings = _academicRepository.getCourseOfferings();

    activeStudent = _registrationRepository.getActiveStudent();
    specialRequests = _registrationRepository.getSpecialRequests(
      activeStudent.id,
      activeStudent.fullName,
    );
    waitingListEntries = _registrationRepository.getWaitingListEntries(
      activeStudent.id,
    );

    academicRecords = [
      // --- Level 1 Semester 1 (2022/2023) ---
      AcademicCourseRecord(
        id: 'hist_101',
        courseCode: 'ICT 1101',
        courseTitle: 'Introduction to Information Technology',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 1,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),
      AcademicCourseRecord(
        id: 'hist_102',
        courseCode: 'ICT 1201',
        courseTitle: 'Programming Fundamentals',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),
      AcademicCourseRecord(
        id: 'hist_103',
        courseCode: 'ICT 1202',
        courseTitle: 'Computer Systems and Organization',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),
      AcademicCourseRecord(
        id: 'hist_104',
        courseCode: 'CMT 1201',
        courseTitle: 'Communication Skills I',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 2,
        grade: 'B+',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),
      AcademicCourseRecord(
        id: 'hist_105',
        courseCode: 'CMT 1202',
        courseTitle: 'Basic Mathematics for Technology',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),
      AcademicCourseRecord(
        id: 'hist_106',
        courseCode: 'CML 1101',
        courseTitle: 'Principles of Management',
        academicYear: '2022/2023',
        level: 1,
        semester: 1,
        credits: 1,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 4, 15),
      ),

      // --- Level 1 Semester 2 (2022/2023) ---
      AcademicCourseRecord(
        id: 'hist_107',
        courseCode: 'ICT 1302',
        courseTitle: 'Database Management Systems',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 3,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_108',
        courseCode: 'ICT 1207',
        courseTitle: 'Web Technologies',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_109',
        courseCode: 'ICT 1209',
        courseTitle: 'System Analysis and Design',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_110',
        courseCode: 'ICT 1108',
        courseTitle: 'Skill Development Project I',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 1,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_111',
        courseCode: 'CMT 1203',
        courseTitle: 'Communication Skills II',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 2,
        grade: 'B+',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_112',
        courseCode: 'CMT 1204',
        courseTitle: 'Discrete Mathematics',
        academicYear: '2022/2023',
        level: 1,
        semester: 2,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2023, 10, 20),
      ),

      // --- Level 2 Semester 1 (2023/2024) ---
      AcademicCourseRecord(
        id: 'hist_201',
        courseCode: 'ICT 2203',
        courseTitle: 'Object Oriented Programming',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 3,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_202',
        courseCode: 'ICT 2205',
        courseTitle: 'Operating Systems',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_203',
        courseCode: 'ICT 2207',
        courseTitle: 'Software System Design',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 2,
        grade: 'B+',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_204',
        courseCode: 'CMT 2201',
        courseTitle: 'Probability and Statistics',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_205',
        courseCode: 'CMT 2202',
        courseTitle: 'Communication Skills III',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),
      AcademicCourseRecord(
        id: 'hist_206',
        courseCode: 'CML 2101',
        courseTitle: 'Professional Ethics in IT',
        academicYear: '2023/2024',
        level: 2,
        semester: 1,
        credits: 1,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 4, 20),
      ),

      // --- Level 2 Semester 2 (2023/2024) ---
      AcademicCourseRecord(
        id: 'hist_207',
        courseCode: 'ICT 2204',
        courseTitle: 'Data Structures and Algorithms',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 3,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_208',
        courseCode: 'ICT 2208',
        courseTitle: 'Computer Networks',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_209',
        courseCode: 'ICT 2210',
        courseTitle: 'Advanced Database Systems',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_210',
        courseCode: 'ICT 2212',
        courseTitle: 'Skill Development Project II',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_211',
        courseCode: 'CML 2202',
        courseTitle: 'Engineering Economics',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        grade: 'B+',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_212',
        courseCode: 'ICT 2214',
        courseTitle: 'Web Application Development',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_213',
        courseCode: 'ICT 2216',
        courseTitle: 'Embedded Systems',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        status: AcademicRecordStatus.medical,
        updatedAt: DateTime(2024, 10, 18),
      ),
      AcademicCourseRecord(
        id: 'hist_214',
        courseCode: 'ICT 2218',
        courseTitle: 'Graphic Design Fundamentals',
        academicYear: '2023/2024',
        level: 2,
        semester: 2,
        credits: 2,
        status: AcademicRecordStatus.dropped,
        updatedAt: DateTime(2024, 8, 2),
      ),

      // --- Level 3 Semester 1 (2024/2025) ---
      AcademicCourseRecord(
        id: 'hist_301',
        courseCode: 'ICT 3201',
        courseTitle: 'Software Project Management',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_302',
        courseCode: 'ICT 3203',
        courseTitle: 'Scientific Computer Applications',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 2,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_303',
        courseCode: 'ICT 3206',
        courseTitle: 'Skill Development Project III',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 2,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_304',
        courseCode: 'ICT 3307',
        courseTitle: 'Computational Statistics',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 3,
        grade: 'A-',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_305',
        courseCode: 'ICT 3208',
        courseTitle: 'Design and Analysis of Algorithms',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 2,
        grade: 'B+',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_306',
        courseCode: 'ICT 3312',
        courseTitle: 'Software Verification and Validation',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 3,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
      AcademicCourseRecord(
        id: 'hist_307',
        courseCode: 'CML 3101',
        courseTitle: 'Legal and Patent Aspects',
        academicYear: '2024/2025',
        level: 3,
        semester: 1,
        credits: 1,
        grade: 'A',
        status: AcademicRecordStatus.completed,
        updatedAt: DateTime(2025, 4, 25),
      ),
    ];

    // Initial draft selection: Compulsory Level 3 Semester 2 courses
    selectedOfferingIds = {
      'off_301',
      'off_302',
      'off_303',
      'off_305',
      'off_306',
      'off_307',
    };
  }

  static double _gradeToGpa(String grade) =>
      UniversityGradingSystem.gradeToPoint(grade);

  double get currentCgpa {
    final completed = academicRecords.where(
      (r) => r.status == AcademicRecordStatus.completed && r.grade != null,
    );
    if (completed.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final r in completed) {
      final point = _gradeToGpa(r.grade!);
      totalPoints += point * r.credits;
      totalCredits += r.credits;
    }
    return totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  }

  DegreeClassStanding get currentDegreeClass =>
      DegreeClassStanding.fromGpa(currentCgpa > 0 ? currentCgpa : 3.79);

  String get currentDegreeClassLabel => currentDegreeClass.label;

  int creditsForAcademicStatus(AcademicRecordStatus status) => academicRecords
      .where((record) => record.status == status)
      .fold(0, (total, record) => total + record.credits);

  int get completedAcademicCredits =>
      creditsForAcademicStatus(AcademicRecordStatus.completed);

  List<AcademicCourseRecord> get repeatEligibleAcademicRecords =>
      academicRecords.where((record) => record.canRegisterAgain).toList();

  List<AcademicCourseRecord> get droppedAcademicRecords =>
      academicRecords.where((record) => record.isDropped).toList();

  String repeatReasonFor(AcademicCourseRecord record) =>
      record.repeatEligibilityLabel;

  bool isCourseDropped(String courseCode) =>
      academicRecords.any((r) => r.courseCode == courseCode && r.isDropped);

  List<AcademicCourseRecord> get requestedRepeatRecords => academicRecords
      .where((record) => requestedRepeatRecordIds.contains(record.id))
      .toList();

  /// Check if a course is considered a repeat or medical concession module for the student.
  /// Under university regulations, students registering for repeat/medical subjects
  /// do not attend regular lectures and are exempt from timetable scheduling.
  bool isCourseRepeatOrMedical(Course course) {
    // 1. Explicitly requested in repeat examination registration
    final isExplicitlyRequested = requestedRepeatRecords.any(
      (r) =>
          r.courseCode.trim().toUpperCase() == course.code.trim().toUpperCase(),
    );
    if (isExplicitlyRequested) return true;

    // 2. Previous attempt recorded as Medical, Fail, or Repeat grade
    final pastRecord = academicRecords.cast<AcademicCourseRecord?>().firstWhere(
      (r) =>
          r?.courseCode.trim().toUpperCase() ==
          course.code.trim().toUpperCase(),
      orElse: () => null,
    );
    if (pastRecord != null &&
        (pastRecord.isMedical ||
            pastRecord.isRepeatGrade ||
            pastRecord.isFailGrade)) {
      return true;
    }

    // 3. Module belongs to a lower level than student's current standing
    if (course.level < activeStudent.currentLevel) {
      return true;
    }

    return false;
  }

  /// Check if an offering represents a repeat or medical registration for this student.
  bool isOfferingRepeatOrMedical(CourseOffering offering) {
    final course = courses.cast<Course?>().firstWhere(
      (c) => c?.id == offering.courseId,
      orElse: () => null,
    );
    if (course == null) return false;
    return isCourseRepeatOrMedical(course);
  }

  /// Active course offerings requiring lecture attendance on the student timetable.
  /// Repeat and Medical concession subjects are exempt from lecture attendance,
  /// do not require lecture slots, and are excluded from the weekly timetable.
  List<CourseOffering> get timetableEligibleOfferings {
    return selectedOfferingsList
        .where((offering) => !isOfferingRepeatOrMedical(offering))
        .toList();
  }

  /// List of all active repeat or medical registrations (attendance-exempt).
  List<AcademicCourseRecord> get activeRepeatOrMedicalRegistrations {
    final list = <AcademicCourseRecord>[...requestedRepeatRecords];
    for (final offering in selectedOfferingsList) {
      final course = courses.cast<Course?>().firstWhere(
        (c) => c?.id == offering.courseId,
        orElse: () => null,
      );
      if (course != null && isCourseRepeatOrMedical(course)) {
        final existing = academicRecords
            .cast<AcademicCourseRecord?>()
            .firstWhere(
              (r) =>
                  r?.courseCode.trim().toUpperCase() ==
                  course.code.trim().toUpperCase(),
              orElse: () => null,
            );
        if (existing != null && !list.any((r) => r.id == existing.id)) {
          list.add(existing);
        } else if (existing == null &&
            !list.any(
              (r) =>
                  r.courseCode.trim().toUpperCase() ==
                  course.code.trim().toUpperCase(),
            )) {
          list.add(
            AcademicCourseRecord(
              id: 'synthetic_repeat_${course.id}',
              courseCode: course.code,
              courseTitle: course.title,
              credits: course.creditValue,
              level: course.level,
              semester: course.semester,
              grade: 'F',
              status: AcademicRecordStatus.completed,
              updatedAt: DateTime.now(),
              academicYear: 'Repeat Attempt',
            ),
          );
        }
      }
    }
    return list;
  }

  bool get hasRepeatOrMedicalRegistrations =>
      activeRepeatOrMedicalRegistrations.isNotEmpty;

  bool toggleRepeatSubjectRequest(String recordId) {
    if (_currentRole != UserRole.student || !isRegistrationOpen) return false;
    final record = academicRecords.cast<AcademicCourseRecord?>().firstWhere(
      (r) => r?.id == recordId,
      orElse: () => null,
    );
    if (record == null) return false;
    if (record.isDropped) {
      addNotification(
        title: 'Cannot Re-register Dropped Subject',
        message:
            'Cannot re-register ${record.courseCode}: Under faculty academic regulations, dropped subjects cannot be registered again.',
        type: NotificationType.system,
      );
      return false;
    }
    if (!record.canRegisterAgain) {
      return false;
    }
    if (!requestedRepeatRecordIds.add(recordId)) {
      requestedRepeatRecordIds.remove(recordId);
    }
    notifyListeners();
    return true;
  }

  bool updateAcademicRecordStatus(
    String recordId,
    AcademicRecordStatus newStatus,
  ) {
    if (_currentRole != UserRole.assistantRegistrar &&
        _currentRole != UserRole.systemAdmin) {
      return false;
    }
    final recordIndex = academicRecords.indexWhere((r) => r.id == recordId);
    if (recordIndex == -1) return false;
    final record = academicRecords[recordIndex];
    if (record.status == newStatus) return true;

    final previousStatus = record.status;
    record.status = newStatus;
    record.updatedAt = DateTime.now();
    if (newStatus == AcademicRecordStatus.dropped) {
      requestedRepeatRecordIds.remove(recordId);
    }
    _cachedPrereqValidation = null;
    final isAdmin = _currentRole == UserRole.systemAdmin;
    final actorName = isAdmin
        ? 'Mr. P. S. Palliyaguruge'
        : 'Ms. K. H. Gaurika Kahawala';
    final actorRole = isAdmin ? 'System Administrator' : 'Assistant Registrar';

    _notificationRepository.addAuditLog(
      AuditLog(
        id: 'academic_${DateTime.now().microsecondsSinceEpoch}',
        userName: actorName,
        userRole: actorRole,
        action: 'ACADEMIC_RECORD_STATUS_UPDATED',
        details:
            '${activeStudent.registrationNumber}: ${record.courseCode} changed from ${previousStatus.label} to ${newStatus.label}',
        timestamp: DateTime.now(),
      ),
    );
    addNotification(
      title: 'Academic Record Updated',
      message:
          '${record.courseCode} was updated to ${newStatus.label} by the $actorRole.',
      type: NotificationType.approval,
      relatedId: record.id,
    );
    notifyListeners();
    return true;
  }

  bool insertAcademicCourseRecord({
    required String courseCode,
    required String courseTitle,
    required String academicYear,
    int level = 1,
    required int semester,
    required int credits,
    String? grade,
    AcademicRecordStatus status = AcademicRecordStatus.completed,
    String? studentRegNumber,
  }) {
    final existingIndex = academicRecords.indexWhere(
      (r) =>
          r.courseCode.toUpperCase().replaceAll(' ', '') ==
              courseCode.toUpperCase().replaceAll(' ', '') &&
          r.academicYear == academicYear,
    );

    AcademicCourseRecord record;
    if (existingIndex != -1) {
      final existing = academicRecords[existingIndex];
      record = AcademicCourseRecord(
        id: existing.id,
        courseCode: courseCode,
        courseTitle: courseTitle,
        academicYear: academicYear,
        level: level,
        semester: semester,
        credits: credits,
        grade: grade,
        status: status,
        updatedAt: DateTime.now(),
      );
      academicRecords[existingIndex] = record;
    } else {
      record = AcademicCourseRecord(
        id: 'rec_${DateTime.now().microsecondsSinceEpoch}',
        courseCode: courseCode,
        courseTitle: courseTitle,
        academicYear: academicYear,
        level: level,
        semester: semester,
        credits: credits,
        grade: grade,
        status: status,
        updatedAt: DateTime.now(),
      );
      academicRecords.add(record);
    }

    _cachedPrereqValidation = null;
    _cachedCreditValidation = null;

    const actorName = 'Ms. K. H. Gaurika Kahawala (AR)';
    final targetReg = studentRegNumber ?? activeStudent.registrationNumber;

    _notificationRepository.addAuditLog(
      AuditLog(
        id: 'exam_${DateTime.now().microsecondsSinceEpoch}',
        userName: actorName,
        userRole: 'Assistant Registrar',
        action: 'EXAM_RESULT_PUBLISHED',
        details:
            '$targetReg: $courseCode ($courseTitle) - Grade: ${grade ?? "Pending"} ($credits Cr, Level $level Sem $semester)',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Exam Result Published',
      message:
          'Official result for $courseCode has been entered by the AR Division (Grade: ${grade ?? status.label}).',
      type: NotificationType.approval,
      relatedId: record.id,
    );

    notifyListeners();
    return true;
  }

  bool updateAcademicRecordGrade({
    required String recordId,
    required String newGrade,
    AcademicRecordStatus? newStatus,
  }) {
    final recordIndex = academicRecords.indexWhere((r) => r.id == recordId);
    if (recordIndex == -1) return false;
    final oldRecord = academicRecords[recordIndex];
    final oldGrade = oldRecord.grade;

    final updated = AcademicCourseRecord(
      id: oldRecord.id,
      courseCode: oldRecord.courseCode,
      courseTitle: oldRecord.courseTitle,
      academicYear: oldRecord.academicYear,
      level: oldRecord.level,
      semester: oldRecord.semester,
      credits: oldRecord.credits,
      grade: newGrade,
      status: newStatus ?? oldRecord.status,
      updatedAt: DateTime.now(),
    );
    academicRecords[recordIndex] = updated;

    _cachedPrereqValidation = null;
    _cachedCreditValidation = null;

    _notificationRepository.addAuditLog(
      AuditLog(
        id: 'grade_${DateTime.now().microsecondsSinceEpoch}',
        userName: 'Ms. K. H. Gaurika Kahawala (AR)',
        userRole: 'Assistant Registrar',
        action: 'EXAM_GRADE_MODIFIED',
        details:
            '${activeStudent.registrationNumber}: ${oldRecord.courseCode} grade updated from ${oldGrade ?? "None"} to $newGrade',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Grade Updated',
      message:
          '${oldRecord.courseCode} result updated to $newGrade by Assistant Registrar.',
      type: NotificationType.approval,
      relatedId: updated.id,
    );

    notifyListeners();
    return true;
  }

  // Notifications Management
  void markNotificationAsRead(String id) {
    _notificationRepository.markAsRead(id);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _notificationRepository.markAllAsRead();
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) {
    // Prevent duplicate unread notification with identical title, message & relatedId
    final isDuplicate = notifications.any(
      (n) =>
          !n.isRead &&
          n.title == title &&
          n.message == message &&
          n.relatedId == relatedId,
    );
    if (isDuplicate) return;

    _notificationRepository.addNotification(
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
        relatedId: relatedId,
      ),
    );
    notifyListeners();
  }

  // Semester subject selection. Compulsory subjects are assigned and cannot be removed.
  void toggleCourseSelection(String offeringId) {
    if (!isRegistrationOpen ||
        (activeRegistrationStatus != RegistrationStatus.draft &&
            activeRegistrationStatus != RegistrationStatus.changesRequested)) {
      return;
    }

    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);
    if (course.courseType == CourseType.compulsory) return;

    if (!selectedOfferingIds.contains(offeringId) &&
        isCourseDropped(course.code)) {
      addNotification(
        title: 'Subject Dropped',
        message:
            'Cannot select ${course.code} (${course.title}): Under university academic regulations, dropped subjects cannot be registered again.',
        type: NotificationType.system,
      );
      return;
    }

    if (selectedOfferingIds.contains(offeringId)) {
      selectedOfferingIds.remove(offeringId);
    } else {
      selectedOfferingIds.add(offeringId);
    }
    notifyListeners();
  }

  bool reopenRegistrationForEditing() {
    if (!isRegistrationOpen ||
        activeRegistrationStatus != RegistrationStatus.submitted) {
      return false;
    }
    activeRegistrationStatus = RegistrationStatus.draft;
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: activeStudent.fullName,
        userRole: 'Student',
        action: 'REGISTRATION_REOPENED',
        details: 'Reopened submitted registration for editing',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  // Get total selected credits
  int get totalSelectedCredits {
    int total = 0;
    for (var offeringId in selectedOfferingIds) {
      final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
      final course = courses.firstWhere((c) => c.id == offering.courseId);
      total += course.creditValue;
    }
    return total;
  }

  List<CourseOffering> get selectedOfferingsList =>
      courseOfferings.where((o) => selectedOfferingIds.contains(o.id)).toList();

  ValidationResult get prerequisiteValidation {
    if (_cachedPrereqValidation == null) {
      final selectedCourses = courses
          .where((c) => selectedOfferingsList.any((o) => o.courseId == c.id))
          .toList();
      final prereqRes = ValidationEngine.validatePrerequisites(
        student: activeStudent,
        selectedCourses: selectedCourses,
        allCourses: courses,
      );
      final droppedRes = ValidationEngine.validateDroppedCourses(
        selectedCourses: selectedCourses,
        academicRecords: academicRecords,
      );
      _cachedPrereqValidation = ValidationResult(
        isValid: prereqRes.isValid && droppedRes.isValid,
        warnings: [...prereqRes.warnings, ...droppedRes.warnings],
        errors: [...prereqRes.errors, ...droppedRes.errors],
      );
    }
    return _cachedPrereqValidation!;
  }

  ValidationResult get creditLimitValidation {
    if (_cachedCreditValidation == null) {
      final selectedCourses = courses
          .where((c) => selectedOfferingsList.any((o) => o.courseId == c.id))
          .toList();
      _cachedCreditValidation = ValidationEngine.validateCreditLimits(
        student: activeStudent,
        selectedCourses: selectedCourses,
      );
    }
    return _cachedCreditValidation!;
  }

  CourseRegistrationRecord get currentRegistrationRecord =>
      CourseRegistrationRecord(
        id: 'reg_${activeStudent.id}_sem${activeStudent.currentSemester}',
        studentId: activeStudent.id,
        academicYear: courseOfferings.isNotEmpty
            ? courseOfferings.first.academicYear
            : '2025/2026',
        semesterNumber: activeStudent.currentSemester,
        selectedItems: selectedOfferingsList.map((off) {
          final course = courses.firstWhere((c) => c.id == off.courseId);
          return RegistrationItem(
            offeringId: off.id,
            courseId: off.courseId,
            registrationType: course.courseType,
            addedAt: DateTime(2026, 10, 5),
          );
        }).toList(),
        totalCredits: totalSelectedCredits,
        status: activeRegistrationStatus,
        submittedAt: DateTime(2026, 10, 5, 14, 30),
        approvedAt:
            (activeRegistrationStatus == RegistrationStatus.registered ||
                activeRegistrationStatus == RegistrationStatus.locked)
            ? DateTime(2026, 10, 8, 11, 45)
            : null,
        verificationToken: verificationToken,
        approvals: List.unmodifiable(approvalHistoryList),
      );

  void _addApprovalHistory(ApprovalHistory entry) {
    const maxHistoryCount = 50;
    approvalHistoryList.add(entry);
    if (approvalHistoryList.length > maxHistoryCount) {
      approvalHistoryList.removeRange(
        0,
        approvalHistoryList.length - maxHistoryCount,
      );
    }
  }

  List<TimetableClashInfo> get selectedTimetableClashes {
    // Repeat and medical subjects are exempt from lecture attendance,
    // so they do not attend lectures and must not trigger timetable clashes.
    return ValidationEngine.detectTimetableClashes(
      selectedOfferings: timetableEligibleOfferings,
      allCourses: courses,
    );
  }

  // Submit registration workflow
  bool submitRegistration() {
    if (!isRegistrationOpen) return false;
    final compulsoryOfferingIds = courseOfferings
        .where((offering) {
          final course = courses.firstWhere((c) => c.id == offering.courseId);
          return course.courseType == CourseType.compulsory &&
              course.level == activeStudent.currentLevel &&
              course.semester == activeStudent.currentSemester;
        })
        .map((offering) => offering.id);
    if (!selectedOfferingIds.containsAll(compulsoryOfferingIds)) return false;
    if (totalSelectedCredits < activeStudent.minAllowedCredits ||
        totalSelectedCredits > activeStudent.maxAllowedCredits) {
      return false;
    }

    final clashes = selectedTimetableClashes;
    if (clashes.isNotEmpty) {
      final firstClash = clashes.first;
      addNotification(
        title: 'Timetable Clash Detected',
        message:
            'Registration could not be submitted due to schedule clash between ${firstClash.courseA.code} and ${firstClash.courseB.code} on ${firstClash.day} (${firstClash.timeRange}).',
        type: NotificationType.system,
      );
      return false;
    }

    final selectedCoursesList = courses
        .where((c) => selectedOfferingsList.any((o) => o.courseId == c.id))
        .toList();
    final droppedValidation = ValidationEngine.validateDroppedCourses(
      selectedCourses: selectedCoursesList,
      academicRecords: academicRecords,
    );
    if (!droppedValidation.isValid) {
      addNotification(
        title: 'Registration Error',
        message: droppedValidation.errors.first,
        type: NotificationType.system,
      );
      return false;
    }

    activeRegistrationStatus = RegistrationStatus.submitted;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Student',
        approverName: activeStudent.fullName,
        decision: 'Submitted',
        comments: 'Initial registration submitted for HoD verification.',
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: activeStudent.fullName,
        userRole: 'Student',
        action: 'REGISTRATION_SUBMITTED',
        details: 'Submitted registration with $totalSelectedCredits credits',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Registration Submitted',
      message:
          'Your registration ($totalSelectedCredits credits) was submitted to the Head of Department.',
      type: NotificationType.approval,
    );

    notifyListeners();
    return true;
  }

  // Request Changes by HoD
  void requestChangesByHod(String comments) {
    if (activeRegistrationStatus != RegistrationStatus.submitted) return;
    activeRegistrationStatus = RegistrationStatus.changesRequested;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Head of Department',
        approverName: 'Dr. Lahiru Jayasuriya',
        decision: 'Changes Requested',
        comments: comments.isEmpty
            ? 'Department requires revisions to subject selection.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Lahiru Jayasuriya',
        userRole: 'Head of Department',
        action: 'CHANGES_REQUESTED',
        details: 'Requested modifications: $comments',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Course Changes Requested',
      message: 'Head of Department requested course revisions: "$comments"',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // ============================================================================
  // SYSTEM ADMINISTRATOR FULL CONTROL & GOVERNANCE METHODS
  // ============================================================================
  void adminSetRegistrationStatus(
    RegistrationStatus newStatus,
    String comments,
  ) {
    activeRegistrationStatus = newStatus;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'System Administrator',
        approverName: 'Mr. P. S. Palliyaguruge',
        decision: 'Administrative Override: ${newStatus.label}',
        comments: comments.isEmpty
            ? 'Administrative status override applied.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_REGISTRATION_STATUS_OVERRIDE',
        details:
            'Admin overrode status of ${activeStudent.fullName} (${activeStudent.registrationNumber}) to ${newStatus.label}: $comments',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Administrative Status Override',
      message:
          'System Administrator updated your registration status to "${newStatus.label}".',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  void adminForceEnrollCourse(String offeringId) {
    if (selectedOfferingIds.contains(offeringId)) return;
    selectedOfferingIds.add(offeringId);
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_FORCE_ENROLL',
        details:
            'Force enrolled ${activeStudent.registrationNumber} into ${course.code} (${course.title})',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Administrative Course Enrollment',
      message:
          'System Administrator enrolled you in ${course.code} (${course.title}).',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  void adminForceDropCourse(String offeringId) {
    if (!selectedOfferingIds.contains(offeringId)) return;
    selectedOfferingIds.remove(offeringId);
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_FORCE_DROP',
        details:
            'Force dropped ${activeStudent.registrationNumber} from ${course.code}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Administrative Course Dropped',
      message:
          'System Administrator dropped your registration for ${course.code} (${course.title}).',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  void adminToggleRegistrationWindow(bool isOpen) {
    _registrationOpenOverride = isOpen;
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: isOpen ? 'ADMIN_WINDOW_OPENED' : 'ADMIN_WINDOW_CLOSED',
        details:
            'University registration window was ${isOpen ? "opened" : "closed"} by Administrator',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void adminExtendDeadline(int additionalDays) {
    registrationEndDate = registrationEndDate.add(
      Duration(days: additionalDays),
    );
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_DEADLINE_EXTENDED',
        details:
            'Registration deadline extended by +$additionalDays days to $registrationEndLabel',
        timestamp: DateTime.now(),
      ),
    );
    addNotification(
      title: 'Registration Deadline Extended',
      message:
          'Course registration deadline has been extended by +$additionalDays days to $registrationEndLabel. Please finalize course choices before the deadline.',
      type: NotificationType.system,
    );
    notifyListeners();
  }

  void adminSetRegistrationStartDate(DateTime newStartDate) {
    registrationStartDate = newStartDate;
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_START_DATE_UPDATED',
        details:
            'Registration window start adjusted to $registrationStartLabel',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void adminResetRegistration() {
    activeRegistrationStatus = RegistrationStatus.draft;
    approvalHistoryList.clear();
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Mr. P. S. Palliyaguruge',
        userRole: 'System Administrator',
        action: 'ADMIN_REGISTRATION_RESET',
        details:
            'Reset registration status to Draft and cleared prior approval chain for ${activeStudent.registrationNumber}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Registration Reset to Draft',
      message:
          'System Administrator reset your course registration to Draft. Previous endorsements were cleared.',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // HoD Approval
  void approveByHod(String comments) {
    if (activeRegistrationStatus != RegistrationStatus.submitted) return;
    activeRegistrationStatus = RegistrationStatus.departmentApproved;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Head of Department',
        approverName: 'Dr. Lahiru Jayasuriya',
        decision: 'Approved & Endorsed',
        comments: comments.isEmpty
            ? 'Department curriculum & batch enrollment verified. Endorsed.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Lahiru Jayasuriya',
        userRole: 'Head of Department',
        action: 'REGISTRATION_APPROVED_HOD',
        details:
            'Endorsed registration for ${activeStudent.fullName} (${activeStudent.registrationNumber})',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Department Endorsement Approved',
      message:
          'Head of Department endorsed your registration. Forwarded to the Assistant Registrar.',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Approve by Dean (Faculty Endorsement)
  void endorseByDean(String comments) => approveByDean(comments);

  bool requestChangesByDean(String comments) {
    if (_currentRole != UserRole.dean ||
        activeRegistrationStatus != RegistrationStatus.departmentApproved) {
      return false;
    }
    final reason = comments.trim().isEmpty
        ? 'Faculty Academic Board requested registration revisions.'
        : comments.trim();
    activeRegistrationStatus = RegistrationStatus.changesRequested;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        approverRole: 'Dean',
        approverName: 'Prof. T. C. Bamunuarachchige',
        decision: 'Faculty Revisions Requested',
        comments: reason,
        timestamp: DateTime.now(),
      ),
    );
    _notificationRepository.addAuditLog(
      AuditLog(
        id: 'dean_revision_${DateTime.now().microsecondsSinceEpoch}',
        userName: 'Prof. T. C. Bamunuarachchige',
        userRole: 'Dean',
        action: 'REGISTRATION_CHANGES_REQUESTED_DEAN',
        details:
            '${activeStudent.registrationNumber}: returned for revision. $reason',
        timestamp: DateTime.now(),
      ),
    );
    addNotification(
      title: 'Faculty Revisions Requested',
      message: 'The Dean returned your registration for revision: $reason',
      type: NotificationType.changesRequested,
    );
    notifyListeners();
    return true;
  }

  void approveByDean(String comments) {
    if (activeRegistrationStatus != RegistrationStatus.departmentApproved) {
      return;
    }
    activeRegistrationStatus = RegistrationStatus.facultyApproved;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Dean',
        approverName: 'Prof. T. C. Bamunuarachchige',
        decision: 'Faculty Endorsed',
        comments: comments.isEmpty
            ? 'Faculty academic board and credit quota verified. Endorsed.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Prof. T. C. Bamunuarachchige',
        userRole: 'Dean',
        action: 'REGISTRATION_APPROVED_DEAN',
        details:
            'Faculty-level endorsement for ${activeStudent.fullName} (${activeStudent.registrationNumber})',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Dean Faculty Endorsement Approved',
      message:
          'Dean of Faculty endorsed your registration. Forwarded to the Assistant Registrar for sealing.',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Final AR Official Seal and Registration Lock
  void approveAndSealByAr(String comments) {
    if (activeRegistrationStatus != RegistrationStatus.departmentApproved &&
        activeRegistrationStatus != RegistrationStatus.facultyApproved) {
      return;
    }
    activeRegistrationStatus = RegistrationStatus.registered;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Ms. K. H. Gaurika Kahawala',
        decision: 'Officially Sealed',
        comments: comments.isEmpty
            ? 'Verified against university exam criteria. Officially sealed.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Ms. K. H. Gaurika Kahawala',
        userRole: 'Assistant Registrar',
        action: 'REGISTRATION_OFFICIALLY_REGISTERED',
        details:
            'Issued official registration seal for ${activeStudent.registrationNumber}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Official University Seal Affixed',
      message:
          'Assistant Registrar officially confirmed & sealed your Semester 5 registration. Verification Code: $verificationToken',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Reject Registration
  void rejectRegistration(String comments, {String? actorName}) {
    final approver = actorName ?? _actorNameForRole(_currentRole);
    activeRegistrationStatus = RegistrationStatus.rejected;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: _currentRole.displayName,
        approverName: approver,
        decision: 'Rejected',
        comments: comments.isEmpty
            ? 'Registration rejected during ${_currentRole.displayName} review.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: approver,
        userRole: _currentRole.displayName,
        action: 'REGISTRATION_REJECTED',
        details:
            'Rejected registration for ${activeStudent.fullName} (${activeStudent.registrationNumber}). Reason: $comments',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Registration Rejected',
      message:
          'Your registration was rejected by ${_currentRole.displayName}: $comments',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // Final Faculty Lock
  void lockFacultyRegistration() {
    if (activeRegistrationStatus != RegistrationStatus.registered) return;
    activeRegistrationStatus = RegistrationStatus.locked;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Ms. K. H. Gaurika Kahawala',
        decision: 'Locked & Confirmed',
        comments: 'Faculty registration locked. Verification QR generated.',
        timestamp: DateTime.now(),
      ),
    );
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Ms. K. H. Gaurika Kahawala',
        userRole: 'Assistant Registrar',
        action: 'FACULTY_REGISTRATION_LOCKED',
        details:
            'Locked faculty registration for ${activeStudent.fullName} (${activeStudent.registrationNumber})',
        timestamp: DateTime.now(),
      ),
    );
    addNotification(
      title: 'Faculty Registration Frozen',
      message:
          'Faculty course registration has been locked and frozen by Assistant Registrar. Official candidate records confirmed.',
      type: NotificationType.system,
    );
    notifyListeners();
  }

  // Lift Faculty Lock / Unlock
  void unlockFacultyRegistration() {
    if (activeRegistrationStatus != RegistrationStatus.locked) return;
    activeRegistrationStatus = RegistrationStatus.registered;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Ms. K. H. Gaurika Kahawala',
        decision: 'Lock Lifted / Re-opened',
        comments:
            'Faculty registration freeze lifted for administrative review.',
        timestamp: DateTime.now(),
      ),
    );
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Ms. K. H. Gaurika Kahawala',
        userRole: 'Assistant Registrar',
        action: 'FACULTY_REGISTRATION_UNLOCKED',
        details:
            'Lifted faculty registration freeze for ${activeStudent.fullName} (${activeStudent.registrationNumber})',
        timestamp: DateTime.now(),
      ),
    );
    addNotification(
      title: 'Faculty Registration Freeze Lifted',
      message:
          'Faculty registration freeze has been lifted by Assistant Registrar. Open for administrative review.',
      type: NotificationType.system,
    );
    notifyListeners();
  }

  // Return with Registry Query (AR sends back with formal query)
  void arReturnWithRegistryQuery(String comments) {
    if (activeRegistrationStatus != RegistrationStatus.departmentApproved &&
        activeRegistrationStatus != RegistrationStatus.submitted &&
        activeRegistrationStatus != RegistrationStatus.facultyApproved) {
      return;
    }
    activeRegistrationStatus = RegistrationStatus.changesRequested;
    _addApprovalHistory(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Ms. K. H. Gaurika Kahawala',
        decision: 'Registry Query Raised',
        comments: comments.isEmpty
            ? 'Registry query raised. Please update course selections and re-endorse.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Ms. K. H. Gaurika Kahawala',
        userRole: 'Assistant Registrar',
        action: 'REGISTRY_QUERY_RAISED',
        details:
            'Registry query raised for ${activeStudent.registrationNumber}: $comments',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Registry Query from Assistant Registrar',
      message: 'AR Query: $comments',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // Bulk Seal all eligible registrations
  void arBulkSealEligibleRegistrations() {
    approveAndSealByAr(
      'Batch sealed by Assistant Registrar for examination compliance.',
    );
  }

  // Review Special Request
  void reviewSpecialRequest(
    String requestId,
    dynamic newStatus, {
    String? reviewerName,
  }) {
    final SpecialRequestStatus statusEnum = newStatus is SpecialRequestStatus
        ? newStatus
        : SpecialRequestStatus.fromString(newStatus.toString());

    final index = specialRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final old = specialRequests[index];
      specialRequests[index] = SpecialRequest(
        id: old.id,
        studentId: old.studentId,
        studentName: old.studentName,
        requestType: old.requestType,
        explanation: old.explanation,
        status: statusEnum,
        submittedAt: old.submittedAt,
      );

      final reviewer = reviewerName ?? _actorNameForRole(_currentRole);
      _notificationRepository.addAuditLog(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: reviewer,
          userRole: _currentRole.displayName,
          action: 'SPECIAL_REQUEST_REVIEWED',
          details:
              'Special petition "${old.requestType}" was marked as ${statusEnum.label}',
          timestamp: DateTime.now(),
        ),
      );

      addNotification(
        title: 'Special Petition ${statusEnum.label}',
        message:
            'Your request for "${old.requestType}" was ${statusEnum.label.toLowerCase()} by ${_currentRole.displayName}.',
        type: NotificationType.specialRequest,
      );

      notifyListeners();
    }
  }

  void updateSpecialRequestStatus(
    String requestId,
    SpecialRequestStatus newStatus, {
    String? reviewerName,
  }) => reviewSpecialRequest(requestId, newStatus, reviewerName: reviewerName);

  // Waiting list state & actions
  bool isInWaitingList(String offeringId) => waitingListEntries.any(
    (w) =>
        w.offeringId == offeringId && w.status != WaitingListStatus.cancelled,
  );

  WaitingListEntry? getWaitingListEntry(String offeringId) {
    try {
      return waitingListEntries.firstWhere(
        (w) =>
            w.offeringId == offeringId &&
            w.status != WaitingListStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  void joinWaitingList(String offeringId) {
    if (isInWaitingList(offeringId)) return;
    if (selectedOfferingIds.contains(offeringId)) return;
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);

    final waiting = waitingListEntries
        .where(
          (w) =>
              w.offeringId == offeringId &&
              w.status == WaitingListStatus.waiting,
        )
        .toList();
    final maxPos = waiting.isEmpty
        ? 0
        : waiting.map((w) => w.position).reduce((a, b) => a > b ? a : b);
    final newPosition = maxPos + 1;

    final newEntry = WaitingListEntry(
      id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
      offeringId: offeringId,
      courseCode: course.code,
      courseTitle: course.title,
      studentId: activeStudent.id,
      position: newPosition,
      status: WaitingListStatus.waiting,
      joinedAt: DateTime.now(),
    );
    waitingListEntries.add(newEntry);

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: activeStudent.fullName,
        userRole: 'Student',
        action: 'WAITING_LIST_JOINED',
        details: 'Joined queue for ${course.code} at position #$newPosition',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Joined Waiting List: ${course.code}',
      message:
          'You are at Queue position #$newPosition for ${course.code} (${course.title}).',
      type: NotificationType.promotion,
      relatedId: offeringId,
    );

    notifyListeners();
  }

  void leaveWaitingList(String offeringId) {
    final entry = getWaitingListEntry(offeringId);
    if (entry != null) {
      entry.status = WaitingListStatus.cancelled;
      // Re-order remaining waiting students
      int pos = 1;
      for (var w in waitingListEntries.where(
        (w) =>
            w.offeringId == offeringId && w.status == WaitingListStatus.waiting,
      )) {
        w.position = pos++;
      }
      notifyListeners();
    }
  }

  void processAutoSeatPromotion(String offeringId) {
    final waiting = waitingListEntries
        .where(
          (w) =>
              w.offeringId == offeringId &&
              w.status == WaitingListStatus.waiting,
        )
        .toList();

    if (waiting.isNotEmpty) {
      waiting.sort((a, b) => a.position.compareTo(b.position));
      final top = waiting.first;
      top.status = WaitingListStatus.promoted;
      top.promotedAt = DateTime.now();

      // Compact remaining positions
      int pos = 1;
      for (var w in waitingListEntries.where(
        (w) =>
            w.offeringId == offeringId && w.status == WaitingListStatus.waiting,
      )) {
        w.position = pos++;
      }

      addNotification(
        title: 'Seat Promoted! (${top.courseCode})',
        message:
            'A seat has become available for ${top.courseCode}. Confirm enrollment within 24 hours to secure it.',
        type: NotificationType.promotion,
        relatedId: offeringId,
      );

      notifyListeners();
    }
  }

  bool acceptPromotedSeat(String offeringId) {
    final entry = getWaitingListEntry(offeringId);
    if (entry != null && entry.isPromoted) {
      final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
      final course = courses.firstWhere((c) => c.id == offering.courseId);

      if (totalSelectedCredits + course.creditValue >
          activeStudent.maxAllowedCredits) {
        addNotification(
          title: 'Credit Limit Exceeded',
          message:
              'Cannot accept promoted seat for ${entry.courseCode}. It would exceed your maximum allowed credits (${activeStudent.maxAllowedCredits}).',
          type: NotificationType.changesRequested,
          relatedId: offeringId,
        );
        return false;
      }

      selectedOfferingIds.add(offeringId);
      offering.currentRegisteredCount++;
      waitingListEntries.remove(entry);

      _notificationRepository.addAuditLog(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: activeStudent.fullName,
          userRole: 'Student',
          action: 'PROMOTED_SEAT_CLAIMED',
          details:
              'Enrolled in ${entry.courseCode} after waiting list promotion',
          timestamp: DateTime.now(),
        ),
      );

      addNotification(
        title: 'Seat Confirmed: ${entry.courseCode}',
        message:
            'You successfully enrolled in ${entry.courseCode} (${entry.courseTitle}).',
        type: NotificationType.approval,
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  void increaseOfferingCapacity(String offeringId, int additionalSeats) {
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);
    offering.maxCapacity += additionalSeats;

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Lahiru Jayasuriya',
        userRole: 'Head of Department',
        action: 'CAPACITY_EXPANDED',
        details:
            'Expanded ${course.code} capacity by +$additionalSeats seats (New limit: ${offering.maxCapacity})',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Course Quota Expanded: ${course.code}',
      message:
          'Capacity for ${course.code} was expanded to ${offering.maxCapacity} seats by Department HoD.',
      type: NotificationType.capacityIncrease,
      relatedId: offeringId,
    );

    for (int i = 0; i < additionalSeats; i++) {
      processAutoSeatPromotion(offeringId);
    }
    notifyListeners();
  }

  String? createTimetableSlot({
    required String offeringId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String venue,
    required String groupType,
  }) {
    final validation = _validateTimetableSlot(
      offeringId: offeringId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      venue: venue,
    );
    if (validation != null) return validation;
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    offering.slots.add(
      TimetableSlot(
        id: 'ts_${DateTime.now().microsecondsSinceEpoch}',
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        venue: venue.trim(),
        groupType: groupType,
      ),
    );
    _logTimetableChange('TIMETABLE_SLOT_CREATED', offeringId);
    notifyListeners();
    return null;
  }

  void deleteTimetableSlot(String offeringId, String slotId) {
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    offering.slots.removeWhere((slot) => slot.id == slotId);
    _logTimetableChange('TIMETABLE_SLOT_DELETED', offeringId);
    notifyListeners();
  }

  String? _validateTimetableSlot({
    required String offeringId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String venue,
    String? ignoreSlotId,
  }) {
    if (venue.trim().isEmpty) return 'Venue is required.';
    final start = _minutes(startTime);
    final end = _minutes(endTime);
    if (start == null || end == null || start >= end) {
      return 'Enter a valid start and end time (Start must precede End).';
    }

    final targetOffering = courseOfferings.firstWhere(
      (o) => o.id == offeringId,
      orElse: () => courseOfferings.first,
    );
    final targetCourse = courses.firstWhere(
      (c) => c.id == targetOffering.courseId,
      orElse: () => courses.first,
    );

    for (final offering in courseOfferings) {
      final offeringCourse = courses.firstWhere(
        (c) => c.id == offering.courseId,
        orElse: () => courses.first,
      );

      for (final slot in offering.slots) {
        if (ignoreSlotId != null && slot.id == ignoreSlotId) continue;
        if (slot.dayOfWeek == dayOfWeek) {
          final existingStart = _minutes(slot.startTime);
          final existingEnd = _minutes(slot.endTime);
          if (existingStart != null && existingEnd != null) {
            final hasOverlap = start < existingEnd && end > existingStart;
            if (hasOverlap) {
              // 1. Venue Clash Check
              if (slot.venue.trim().toLowerCase() ==
                  venue.trim().toLowerCase()) {
                return 'Venue clash: ${offeringCourse.code} (${offeringCourse.title}) is already booked in ${slot.venue} on $dayOfWeek ($startTime–$endTime).';
              }

              // 2. Cohort Level Clash Check (Compulsory courses in the same level & semester)
              if (offeringCourse.id != targetCourse.id &&
                  offeringCourse.level == targetCourse.level &&
                  offeringCourse.semester == targetCourse.semester &&
                  offeringCourse.courseType == CourseType.compulsory &&
                  targetCourse.courseType == CourseType.compulsory) {
                return 'Cohort Level ${targetCourse.level} clash: Compulsory modules ${offeringCourse.code} and ${targetCourse.code} cannot overlap on $dayOfWeek (${slot.startTime}–${slot.endTime}). All students in Level ${targetCourse.level} must attend.';
              }

              // 3. Lecturer Clash Check
              if (offering.lecturerName.trim().isNotEmpty &&
                  targetOffering.lecturerName.trim().isNotEmpty &&
                  offering.lecturerName.trim().toLowerCase() ==
                      targetOffering.lecturerName.trim().toLowerCase()) {
                return 'Lecturer clash: ${targetOffering.lecturerName} is already lecturing ${offeringCourse.code} on $dayOfWeek (${slot.startTime}–${slot.endTime}).';
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// Public clash checking for UI real-time validation before submitting
  String? checkTimetableClash({
    required String offeringId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String venue,
    String? ignoreSlotId,
  }) {
    return _validateTimetableSlot(
      offeringId: offeringId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      venue: venue,
      ignoreSlotId: ignoreSlotId,
    );
  }

  /// Detects all current timetable conflicts across all department offerings
  List<String> getActiveTimetableClashes() {
    final List<String> clashes = [];
    final allSlots =
        <({CourseOffering offering, Course course, TimetableSlot slot})>[];
    for (final off in courseOfferings) {
      final c = courses.firstWhere(
        (item) => item.id == off.courseId,
        orElse: () => courses.first,
      );
      for (final s in off.slots) {
        allSlots.add((offering: off, course: c, slot: s));
      }
    }

    for (int i = 0; i < allSlots.length; i++) {
      for (int j = i + 1; j < allSlots.length; j++) {
        final a = allSlots[i];
        final b = allSlots[j];
        if (a.slot.dayOfWeek == b.slot.dayOfWeek) {
          final startA = _minutes(a.slot.startTime);
          final endA = _minutes(a.slot.endTime);
          final startB = _minutes(b.slot.startTime);
          final endB = _minutes(b.slot.endTime);
          if (startA != null &&
              endA != null &&
              startB != null &&
              endB != null) {
            if (startA < endB && endA > startB) {
              if (a.slot.venue.trim().toLowerCase() ==
                  b.slot.venue.trim().toLowerCase()) {
                clashes.add(
                  'Venue Clash: ${a.course.code} and ${b.course.code} in ${a.slot.venue} on ${a.slot.dayOfWeek} (${a.slot.startTime}-${a.slot.endTime})',
                );
              }
              if (a.course.id != b.course.id &&
                  a.course.level == b.course.level &&
                  a.course.semester == b.course.semester &&
                  a.course.courseType == CourseType.compulsory &&
                  b.course.courseType == CourseType.compulsory) {
                clashes.add(
                  'Cohort Level ${a.course.level} Clash: Compulsory ${a.course.code} and ${b.course.code} overlap on ${a.slot.dayOfWeek} (${a.slot.startTime}-${a.slot.endTime})',
                );
              }
            }
          }
        }
      }
    }
    return clashes;
  }

  int? _minutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  void _logTimetableChange(String action, String offeringId) {
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);
    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userName: _actorNameForRole(_currentRole),
        userRole: _currentRole.displayName,
        action: action,
        details: 'Updated timetable for ${course.code}',
        timestamp: DateTime.now(),
      ),
    );
  }

  // Submit special request
  void submitSpecialRequest(String type, String explanation) {
    final req = SpecialRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      studentId: activeStudent.id,
      studentName: activeStudent.fullName,
      requestType: type,
      explanation: explanation,
      status: SpecialRequestStatus.pending,
      submittedAt: DateTime.now(),
    );
    specialRequests.insert(0, req);

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: activeStudent.fullName,
        userRole: 'Student',
        action: 'SPECIAL_REQUEST_SUBMITTED',
        details: 'Submitted petition for $type: $explanation',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Special Request Logged',
      message: 'Your petition for "$type" was submitted for Department review.',
      type: NotificationType.specialRequest,
    );

    notifyListeners();
  }
}
