import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/localization.dart';
import '../data/repositories/academic_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/registration_repository.dart';
import '../domain/models.dart';

class AppService extends ChangeNotifier {
  final AcademicRepository _academicRepository;
  final RegistrationRepository _registrationRepository;
  final NotificationRepository _notificationRepository;

  // Current active session state
  UserRole _currentRole = UserRole.student;
  String _currentLanguage = 'en';

  UserRole get currentRole => _currentRole;
  String get currentLanguage => _currentLanguage;

  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void switchLanguage(String lang) {
    _currentLanguage = lang;
    RuslLocalization.currentLanguage = lang;
    notifyListeners();
  }

  // Active Student Profile
  late StudentProfile activeStudent;

  // Repositories & State Lists
  List<Faculty> faculties = [];
  List<Department> departments = [];
  List<Course> courses = [];
  List<CourseOffering> courseOfferings = [];
  List<SpecialRequest> specialRequests = [];
  List<WaitingListEntry> waitingListEntries = [];

  // Active Student Draft Registration
  Set<String> selectedOfferingIds = {};
  RegistrationStatus activeRegistrationStatus = RegistrationStatus.draft;
  List<ApprovalHistory> approvalHistoryList = [];
  String verificationToken = 'RUSL-VERIFY-2026-98741-X';
  final DateTime registrationStartDate = DateTime(2026, 10, 1);
  final DateTime registrationEndDate = DateTime(2026, 10, 15, 23, 59);

  bool get isRegistrationOpen {
    final now = DateTime.now();
    return !now.isBefore(registrationStartDate) &&
        !now.isAfter(registrationEndDate);
  }

  String get registrationStartLabel => '01 October 2026';
  String get registrationEndLabel => '15 October 2026';

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
  }

  void _initializeData() {
    faculties = _academicRepository.getFaculties();
    departments = _academicRepository.getDepartments();
    courses = _academicRepository.getCourses();
    courseOfferings = _academicRepository.getCourseOfferings();

    activeStudent = _registrationRepository.getActiveStudent();
    waitingListEntries = _registrationRepository.getWaitingListEntries(
      activeStudent.id,
    );
    specialRequests = _registrationRepository.getSpecialRequests(
      activeStudent.id,
      activeStudent.fullName,
    );

    // Initial draft selection: Compulsory Software Engineering + 2 electives
    selectedOfferingIds = {'off_301', 'off_302', 'off_303'};
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
            activeRegistrationStatus != RegistrationStatus.changesRequested &&
            activeRegistrationStatus != RegistrationStatus.submitted)) {
      return;
    }

    if (activeRegistrationStatus == RegistrationStatus.submitted) {
      activeRegistrationStatus = RegistrationStatus.draft;
    }

    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);
    if (course.courseType == CourseType.compulsory) return;

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

  // Submit registration workflow
  bool submitRegistration() {
    if (!isRegistrationOpen) return false;
    if (totalSelectedCredits < activeStudent.minAllowedCredits ||
        totalSelectedCredits > activeStudent.maxAllowedCredits) {
      return false;
    }

    activeRegistrationStatus = RegistrationStatus.submitted;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Student',
        approverName: activeStudent.fullName,
        decision: 'Submitted',
        comments: 'Initial registration submitted for adviser review.',
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
          'Your registration ($totalSelectedCredits credits) was submitted to your Academic Adviser.',
      type: NotificationType.approval,
    );

    notifyListeners();
    return true;
  }

  // Adviser Approval
  void approveByAdviser(String comments) {
    activeRegistrationStatus = RegistrationStatus.adviserApproved;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Academic Adviser',
        approverName: 'Dr. Chandana Jayawardena',
        decision: 'Approved',
        comments: comments.isEmpty
            ? 'Checked curriculum & prerequisites. Approved.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Chandana Jayawardena',
        userRole: 'Academic Adviser',
        action: 'REGISTRATION_APPROVED_ADVISER',
        details: 'Adviser endorsed registration for ${activeStudent.fullName}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Adviser Endorsement Granted',
      message:
          'Dr. Chandana Jayawardena approved your course registration. Forwarded to Head of Department.',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Request Changes
  void requestChangesByAdviser(String comments) {
    activeRegistrationStatus = RegistrationStatus.changesRequested;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Academic Adviser',
        approverName: 'Dr. Chandana Jayawardena',
        decision: 'Changes Requested',
        comments: comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Chandana Jayawardena',
        userRole: 'Academic Adviser',
        action: 'CHANGES_REQUESTED',
        details: 'Requested modifications: $comments',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Course Changes Requested',
      message: 'Reviewer requested course revisions: "$comments"',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // HoD Approval
  void approveByHod(String comments) {
    activeRegistrationStatus = RegistrationStatus.departmentApproved;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Head of Department',
        approverName: 'Prof. Sarath Perera',
        decision: 'Approved & Endorsed',
        comments: comments.isEmpty
            ? 'Department quotas verified. Endorsed.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Prof. Sarath Perera',
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
          'Head of Department endorsed your registration. Forwarded to Faculty Coordinator.',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Faculty Coordinator Approval
  void approveByCoordinator(String comments) {
    activeRegistrationStatus = RegistrationStatus.facultyApproved;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Faculty Coordinator',
        approverName: 'Dr. Kanthi Silva',
        decision: 'Faculty Verified',
        comments: comments.isEmpty
            ? 'Timetable clashes resolved. Verified.'
            : comments,
        timestamp: DateTime.now(),
      ),
    );

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Dr. Kanthi Silva',
        userRole: 'Faculty Coordinator',
        action: 'REGISTRATION_APPROVED_COORDINATOR',
        details:
            'Faculty coordinated registration for ${activeStudent.registrationNumber}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Faculty Coordination Cleared',
      message:
          'Faculty Coordinator verified your course selection against venue & timetable schedules.',
      type: NotificationType.approval,
    );

    notifyListeners();
  }

  // Final AR Official Seal and Registration Lock
  void approveAndSealByAr(String comments) {
    activeRegistrationStatus = RegistrationStatus.registered;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Mrs. Dilhani Rajapaksha',
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
        userName: 'Mrs. Dilhani Rajapaksha',
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
  void rejectRegistration(String comments) {
    activeRegistrationStatus = RegistrationStatus.rejected;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: _currentRole.displayName,
        approverName: 'University Academic Officer',
        decision: 'Rejected',
        comments: comments,
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Registration Rejected',
      message: 'Your registration was rejected: $comments',
      type: NotificationType.changesRequested,
    );

    notifyListeners();
  }

  // Final Faculty Lock
  void lockFacultyRegistration() {
    activeRegistrationStatus = RegistrationStatus.locked;
    approvalHistoryList.add(
      ApprovalHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverRole: 'Assistant Registrar',
        approverName: 'Mrs. Dilhani Rajapaksha',
        decision: 'Locked & Confirmed',
        comments: 'Faculty registration locked. Verification QR generated.',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Review Special Request
  void reviewSpecialRequest(String requestId, String newStatus) {
    final index = specialRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final old = specialRequests[index];
      specialRequests[index] = SpecialRequest(
        id: old.id,
        studentId: old.studentId,
        studentName: old.studentName,
        requestType: old.requestType,
        explanation: old.explanation,
        status: newStatus,
        submittedAt: old.submittedAt,
      );

      _notificationRepository.addAuditLog(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: 'Prof. Sarath Perera',
          userRole: 'Head of Department',
          action: 'SPECIAL_REQUEST_REVIEWED',
          details:
              'Special petition "${old.requestType}" was marked as $newStatus',
          timestamp: DateTime.now(),
        ),
      );

      addNotification(
        title: 'Special Petition $newStatus',
        message:
            'Your request for "${old.requestType}" was $newStatus by Department.',
        type: NotificationType.specialRequest,
      );

      notifyListeners();
    }
  }

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
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);

    final queueCount = waitingListEntries
        .where(
          (w) =>
              w.offeringId == offeringId &&
              w.status == WaitingListStatus.waiting,
        )
        .length;

    final newEntry = WaitingListEntry(
      id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
      offeringId: offeringId,
      courseCode: course.code,
      courseTitle: course.title,
      studentId: activeStudent.id,
      position: queueCount + 1,
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
        details:
            'Joined queue for ${course.code} at position #${queueCount + 1}',
        timestamp: DateTime.now(),
      ),
    );

    addNotification(
      title: 'Joined Waiting List: ${course.code}',
      message:
          'You are at Queue position #${queueCount + 1} for ${course.code} (${course.title}).',
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

  void acceptPromotedSeat(String offeringId) {
    final entry = getWaitingListEntry(offeringId);
    if (entry != null && entry.isPromoted) {
      selectedOfferingIds.add(offeringId);
      final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
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
    }
  }

  void increaseOfferingCapacity(String offeringId, int additionalSeats) {
    final offering = courseOfferings.firstWhere((o) => o.id == offeringId);
    final course = courses.firstWhere((c) => c.id == offering.courseId);
    offering.maxCapacity += additionalSeats;

    _notificationRepository.addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Prof. Sarath Perera',
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

  // Submit special request
  void submitSpecialRequest(String type, String explanation) {
    final req = SpecialRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      studentId: activeStudent.id,
      studentName: activeStudent.fullName,
      requestType: type,
      explanation: explanation,
      status: 'Pending',
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
