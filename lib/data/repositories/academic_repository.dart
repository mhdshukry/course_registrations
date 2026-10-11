import '../../domain/models.dart';
import '../mock_data.dart';

abstract class AcademicRepository {
  List<Faculty> getFaculties();
  List<Department> getDepartments();
  List<Course> getCourses();
  List<CourseOffering> getCourseOfferings();
  List<DegreeProgramme> getDegreeProgrammes();
  List<Curriculum> getCurriculums();
}

class MockAcademicRepository implements AcademicRepository {
  List<Faculty>? _faculties;
  List<Department>? _departments;
  List<Course>? _courses;
  List<CourseOffering>? _offerings;
  List<DegreeProgramme>? _degreeProgrammes;
  List<Curriculum>? _curriculums;

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

  @override
  List<DegreeProgramme> getDegreeProgrammes() {
    _degreeProgrammes ??= MockData.getDegreeProgrammes();
    return _degreeProgrammes!;
  }

  @override
  List<Curriculum> getCurriculums() {
    _curriculums ??= MockData.getCurriculums();
    return _curriculums!;
  }
}

