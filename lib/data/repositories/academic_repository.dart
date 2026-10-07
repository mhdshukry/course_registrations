import '../../domain/models.dart';
import '../mock_data.dart';

abstract class AcademicRepository {
  List<Faculty> getFaculties();
  List<Department> getDepartments();
  List<Course> getCourses();
  List<CourseOffering> getCourseOfferings();
}

class MockAcademicRepository implements AcademicRepository {
  List<Faculty>? _faculties;
  List<Department>? _departments;
  List<Course>? _courses;
  List<CourseOffering>? _offerings;

  @override
  List<Faculty> getFaculties() {
    _faculties ??= MockData.getFaculties();
    return _faculties!;
  }

  @override
  List<Department> getDepartments() {
    _departments ??= MockData.getDepartments();
    return _departments!;
  }

  @override
  List<Course> getCourses() {
    _courses ??= MockData.getCourses();
    return _courses!;
  }

  @override
  List<CourseOffering> getCourseOfferings() {
    _offerings ??= MockData.getCourseOfferings();
    return _offerings!;
  }
}
