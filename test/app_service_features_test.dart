import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course_registration/core/constants.dart';
import 'package:course_registration/domain/models.dart';
import 'package:course_registration/services/app_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppService - Complete End-to-End Governance Workflow', () {
    AppService createSubmittedApp() {
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

    test(
      'progresses through HoD, Dean, AR sealing, and Faculty Lock in sequence',
      () {
        final app = createSubmittedApp();
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.submitted),
        );

        // Step 1: HoD Endorsement
        app.approveByHod('Department curriculum checked.');
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.departmentApproved),
        );

        // Step 2: Dean Faculty Endorsement
        app.endorseByDean('Faculty board verified.');
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.facultyApproved),
        );

        // Step 3: AR Official Seal
        app.approveAndSealByAr('Registry confirmed.');
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.registered),
        );

        // Step 4: Final Faculty Lock
        app.lockFacultyRegistration();
        expect(app.activeRegistrationStatus, equals(RegistrationStatus.locked));

        // 1 submission + 4 approvals = 5 history entries
        expect(app.approvalHistoryList.length, equals(5));
        expect(
          app.approvalHistoryList[1].approverRole,
          equals('Head of Department'),
        );
        expect(app.approvalHistoryList[2].approverRole, equals('Dean'));
        expect(
          app.approvalHistoryList[3].approverRole,
          equals('Assistant Registrar'),
        );
      },
    );

    test(
      'endorseByDean blocks endorsement if not in departmentApproved state',
      () {
        final app = createSubmittedApp();
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.submitted),
        );

        // Attempt Dean endorsement before HoD
        app.endorseByDean('Premature dean endorsement');
        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.submitted),
        );
        expect(app.approvalHistoryList.length, equals(1));
      },
    );

    test('Dean return action requests revisions instead of rejecting', () {
      final app = createSubmittedApp();
      app.approveByHod('Department curriculum checked.');
      app.switchRole(UserRole.dean);

      expect(
        app.requestChangesByDean('Replace the ineligible optional subject.'),
        isTrue,
      );
      expect(app.activeRegistrationStatus, RegistrationStatus.changesRequested);
      expect(
        app.approvalHistoryList.last.decision,
        'Faculty Revisions Requested',
      );
      expect(
        app.auditLogs.any(
          (log) => log.action == 'REGISTRATION_CHANGES_REQUESTED_DEAN',
        ),
        isTrue,
      );
    });

    test(
      'rejectRegistration transitions status to rejected from any stage',
      () {
        final app = createSubmittedApp();
        app.switchRole(UserRole.headOfDepartment);
        app.rejectRegistration('Elective clash detected');

        expect(
          app.activeRegistrationStatus,
          equals(RegistrationStatus.rejected),
        );
        expect(app.approvalHistoryList.last.decision, equals('Rejected'));
      },
    );
  });

  group('AppService - Waiting List Queue & Promotion Engine', () {
    test('joinWaitingList queues student and assigns incremental position', () {
      final app = AppService();
      // Ensure off_304 (optional course) is not selected
      app.selectedOfferingIds.remove('off_304');
      app.waitingListEntries.removeWhere((w) => w.offeringId == 'off_304');

      app.joinWaitingList('off_304');
      expect(app.isInWaitingList('off_304'), isTrue);

      final entry = app.getWaitingListEntry('off_304');
      expect(entry, isNotNull);
      expect(entry?.position, equals(1));
      expect(entry?.status, equals(WaitingListStatus.waiting));
    });

    test('joinWaitingList prevents queuing for courses already enrolled', () {
      final app = AppService();
      app.selectedOfferingIds.add('off_304');
      app.waitingListEntries.removeWhere((w) => w.offeringId == 'off_304');

      app.joinWaitingList('off_304');
      expect(app.isInWaitingList('off_304'), isFalse);
    });

    test('leaveWaitingList cancels entry and compacts remaining positions', () {
      final app = AppService();
      app.selectedOfferingIds.remove('off_304');
      app.waitingListEntries.removeWhere((w) => w.offeringId == 'off_304');

      app.joinWaitingList('off_304');
      expect(app.isInWaitingList('off_304'), isTrue);

      app.leaveWaitingList('off_304');
      expect(app.isInWaitingList('off_304'), isFalse);
    });

    test(
      'increaseOfferingCapacity expands maxCapacity and triggers promotions',
      () {
        final app = AppService();
        final offering = app.courseOfferings.firstWhere(
          (o) => o.id == 'off_304',
        );
        final initialCap = offering.maxCapacity;

        app.selectedOfferingIds.remove('off_304');
        app.waitingListEntries.removeWhere((w) => w.offeringId == 'off_304');
        app.joinWaitingList('off_304');

        app.increaseOfferingCapacity('off_304', 5);

        expect(offering.maxCapacity, equals(initialCap + 5));
        final entry = app.getWaitingListEntry('off_304');
        expect(entry?.isPromoted, isTrue);
      },
    );

    test('acceptPromotedSeat claims promoted seat and enrolls student', () {
      final app = AppService();
      app.selectedOfferingIds.remove('off_304');
      app.waitingListEntries.removeWhere((w) => w.offeringId == 'off_304');
      app.joinWaitingList('off_304');

      app.processAutoSeatPromotion('off_304');
      expect(app.getWaitingListEntry('off_304')?.isPromoted, isTrue);

      final claimed = app.acceptPromotedSeat('off_304');
      expect(claimed, isTrue);
      expect(app.selectedOfferingIds.contains('off_304'), isTrue);
    });
  });

  group('AppService - Special Petitions & Admin Controls', () {
    test('submitSpecialRequest logs petition and prepends to list', () {
      final app = AppService();
      final initialCount = app.specialRequests.length;

      app.submitSpecialRequest(
        'Credit Overload',
        'Requesting 27 credits for final semester.',
      );
      expect(app.specialRequests.length, equals(initialCount + 1));
      expect(app.specialRequests.first.requestType, equals('Credit Overload'));
      expect(
        app.specialRequests.first.status,
        equals(SpecialRequestStatus.pending),
      );
    });

    test('reviewSpecialRequest updates status and logs audit entry', () {
      final app = AppService();
      app.submitSpecialRequest(
        'Prerequisite Waiver',
        'Completed equivalent online.',
      );
      final targetId = app.specialRequests.first.id;

      app.reviewSpecialRequest(targetId, SpecialRequestStatus.approved);
      final updated = app.specialRequests.firstWhere((r) => r.id == targetId);
      expect(updated.status, equals(SpecialRequestStatus.approved));
      expect(
        app.auditLogs.any((l) => l.action == 'SPECIAL_REQUEST_REVIEWED'),
        isTrue,
      );
    });

    test('adminToggleRegistrationWindow toggles registration availability', () {
      final app = AppService();
      expect(app.isRegistrationOpen, isTrue);

      app.adminToggleRegistrationWindow(false);
      expect(app.isRegistrationOpen, isFalse);

      app.adminToggleRegistrationWindow(true);
      expect(app.isRegistrationOpen, isTrue);
    });

    test('adminSetRegistrationStartDate updates date and formats label', () {
      final app = AppService();
      final newDate = DateTime(2026, 11, 15);
      app.adminSetRegistrationStartDate(newDate);

      expect(app.registrationStartDate, equals(newDate));
      expect(app.registrationStartLabel, contains('15 November 2026'));
      expect(
        app.auditLogs.any((l) => l.action == 'ADMIN_START_DATE_UPDATED'),
        isTrue,
      );
    });
  });

  group('AppService - Memoization & State Integrity', () {
    test(
      'memoizes prerequisiteValidation and invalidates upon selection toggle',
      () {
        final app = AppService();

        final firstCall = app.prerequisiteValidation;
        final secondCall = app.prerequisiteValidation;
        expect(identical(firstCall, secondCall), isTrue);

        // Mutate selection -> invalidates cache
        app.toggleCourseSelection('off_304');
        final thirdCall = app.prerequisiteValidation;
        expect(identical(firstCall, thirdCall), isFalse);
      },
    );

    test(
      'memoizes creditLimitValidation and invalidates upon state change',
      () {
        final app = AppService();

        final firstCall = app.creditLimitValidation;
        final secondCall = app.creditLimitValidation;
        expect(identical(firstCall, secondCall), isTrue);

        app.toggleCourseSelection('off_304');
        final thirdCall = app.creditLimitValidation;
        expect(identical(firstCall, thirdCall), isFalse);
      },
    );

    test('approvalHistoryList enforces bounded capacity of 50 entries', () {
      final app = AppService();
      app.approvalHistoryList.clear();

      for (int i = 1; i <= 55; i++) {
        app.approveByHod('Audit iteration $i');
        // Reset to submitted to allow re-approval
        app.activeRegistrationStatus = RegistrationStatus.submitted;
      }

      expect(app.approvalHistoryList.length, equals(50));
      expect(
        app.approvalHistoryList.last.comments,
        equals('Audit iteration 55'),
      );
    });

    test(
      'currentRegistrationRecord accurately reflects live state snapshot',
      () {
        final app = AppService();
        final record = app.currentRegistrationRecord;

        expect(record.studentId, equals(app.activeStudent.id));
        expect(record.status, equals(app.activeRegistrationStatus));
        expect(record.verificationToken, equals(app.verificationToken));
        expect(record.totalCredits, equals(app.totalSelectedCredits));
        expect(
          record.selectedItems.length,
          equals(app.selectedOfferingsList.length),
        );
      },
    );
  });
}
