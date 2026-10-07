import '../../domain/models.dart';
import '../mock_data.dart';

abstract class RegistrationRepository {
  StudentProfile getActiveStudent();
  List<WaitingListEntry> getWaitingListEntries(String studentId);
  List<SpecialRequest> getSpecialRequests(String studentId, String studentName);
}

class MockRegistrationRepository implements RegistrationRepository {
  StudentProfile? _student;
  List<WaitingListEntry>? _waitingListEntries;
  List<SpecialRequest>? _specialRequests;

  @override
  StudentProfile getActiveStudent() {
    _student ??= MockData.getActiveStudent();
    return _student!;
  }

  @override
  List<WaitingListEntry> getWaitingListEntries(String studentId) {
    _waitingListEntries ??= MockData.getWaitingListEntries(studentId);
    return _waitingListEntries!;
  }

  @override
  List<SpecialRequest> getSpecialRequests(
    String studentId,
    String studentName,
  ) {
    _specialRequests ??= MockData.getSpecialRequests(studentId, studentName);
    return _specialRequests!;
  }
}
