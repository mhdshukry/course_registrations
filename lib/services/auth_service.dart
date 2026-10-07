import 'package:flutter/foundation.dart';
import '../core/constants.dart';

class AuthUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String token;
  final String displayName;
  final String designationOrReg;
  final String faculty;
  final String department;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.token,
    required this.displayName,
    required this.designationOrReg,
    required this.faculty,
    required this.department,
  });
}

class AuthService extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Pre-configured Demo Accounts matching database seed.sql
  static final Map<UserRole, AuthUser> demoAccounts = {
    UserRole.student: const AuthUser(
      id: 'u_std01',
      username: 'student_nafis',
      email: 'student.nafis@rjt.ac.lk',
      role: UserRole.student,
      token: 'mock_token_student_nafis_2026',
      displayName: 'Nafis Ahamed',
      designationOrReg: 'ICT/2021/045',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.academicAdviser: const AuthUser(
      id: 'u_adv01',
      username: 'adviser_chanda',
      email: 'chandanajay@rjt.ac.lk',
      role: UserRole.academicAdviser,
      token: 'mock_token_adviser_chanda_2026',
      displayName: 'Dr. Chandana Jayawardena',
      designationOrReg: 'Senior Lecturer & Academic Adviser',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.headOfDepartment: const AuthUser(
      id: 'u_hod01',
      username: 'hod_perera',
      email: 'sarath.perera@rjt.ac.lk',
      role: UserRole.headOfDepartment,
      token: 'mock_token_hod_perera_2026',
      displayName: 'Prof. Sarath Perera',
      designationOrReg: 'Head of Department (HoD)',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.facultyCoordinator: const AuthUser(
      id: 'u_coo01',
      username: 'coord_kanthi',
      email: 'kanthi.silva@rjt.ac.lk',
      role: UserRole.facultyCoordinator,
      token: 'mock_token_coord_kanthi_2026',
      displayName: 'Dr. Kanthi Silva',
      designationOrReg: 'Faculty Academic Coordinator',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.assistantRegistrar: const AuthUser(
      id: 'u_ar001',
      username: 'ar_dilhani',
      email: 'ar.fot@rjt.ac.lk',
      role: UserRole.assistantRegistrar,
      token: 'mock_token_ar_dilhani_2026',
      displayName: 'Mrs. Dilhani Rajapaksha',
      designationOrReg: 'Assistant Registrar (Faculty of Technology)',
      faculty: 'Faculty of Technology',
      department: "Dean's Office",
    ),
    UserRole.centralAdmin: const AuthUser(
      id: 'u_cen01',
      username: 'central_admin',
      email: 'registration@rjt.ac.lk',
      role: UserRole.centralAdmin,
      token: 'mock_token_central_admin_2026',
      displayName: 'Central Admin Officer',
      designationOrReg:
          'Senior Assistant Registrar (Examinations & Registrations)',
      faculty: 'Central Administration',
      department: 'Student Affairs & Registration Division',
    ),
    UserRole.systemAdmin: const AuthUser(
      id: 'u_sys01',
      username: 'sys_admin',
      email: 'itcenter@rjt.ac.lk',
      role: UserRole.systemAdmin,
      token: 'mock_token_sys_admin_2026',
      displayName: 'University IT Administrator',
      designationOrReg: 'Director / IT Centre RUSL',
      faculty: 'University Services',
      department: 'Center for Information & Communication Technology',
    ),
  };

  /// Login with username or registration number and password
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate realistic network handshake (350ms)
    await Future.delayed(const Duration(milliseconds: 350));

    final trimmedIdentifier = identifier.trim().toLowerCase();

    // Match against demo seeded accounts
    AuthUser? matched;
    for (var entry in demoAccounts.values) {
      if (entry.username.toLowerCase() == trimmedIdentifier ||
          entry.email.toLowerCase() == trimmedIdentifier ||
          entry.designationOrReg.toLowerCase() == trimmedIdentifier) {
        matched = entry;
        break;
      }
    }

    if (matched != null) {
      if (password == 'RuslPass#2026') {
        _currentUser = matched;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Incorrect username or password.';
        notifyListeners();
        return false;
      }
    }

    _isLoading = false;
    _errorMessage = 'Incorrect username or password.';
    notifyListeners();
    return false;
  }

  /// One-click quick login for testing any university actor role
  void quickLogin(UserRole role) {
    if (demoAccounts.containsKey(role)) {
      _currentUser = demoAccounts[role];
    } else {
      _currentUser = demoAccounts[UserRole.student];
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout current session
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
