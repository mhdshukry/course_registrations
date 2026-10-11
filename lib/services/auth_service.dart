import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;

  static const Duration sessionTimeoutDuration = Duration(hours: 4);

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get sessionStartTime => _sessionStartTime;
  DateTime? get lastActivityTime => _lastActivityTime;

  bool get isSessionExpired {
    if (_currentUser == null || _sessionStartTime == null) return false;
    return DateTime.now().difference(_sessionStartTime!) > sessionTimeoutDuration;
  }

  /// Verify session validity and auto-logout on expiry
  bool validateSession() {
    if (isSessionExpired) {
      logout();
      _errorMessage = 'Session expired due to inactivity. Please log in again.';
      notifyListeners();
      return false;
    }
    _lastActivityTime = DateTime.now();
    return isAuthenticated;
  }

  void recordActivity() {
    if (isAuthenticated) {
      _lastActivityTime = DateTime.now();
    }
  }

  // Pre-configured Accounts with Publicly Available Staff of Rajarata University of Sri Lanka
  static final Map<UserRole, AuthUser> demoAccounts = {
    UserRole.student: const AuthUser(
      id: 'u_std01',
      username: 'student_nafis',
      email: 'student.nafis@rjt.ac.lk',
      role: UserRole.student,
      token: 'mock_token_student_nafis_2026',
      displayName: 'M. N. Mohamed Nafis',
      designationOrReg: 'ICT/2021/045',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.headOfDepartment: const AuthUser(
      id: 'u_hod01',
      username: 'hod_ict',
      email: 'lahiruj@tec.rjt.ac.lk',
      role: UserRole.headOfDepartment,
      token: 'mock_token_hod_jayasuriya_2026',
      displayName: 'Dr. Lahiru Jayasuriya',
      designationOrReg: 'Senior Lecturer Gr. I & Head of Department',
      faculty: 'Faculty of Technology',
      department: 'Information & Communication Technology',
    ),
    UserRole.assistantRegistrar: const AuthUser(
      id: 'u_ar001',
      username: 'ar_fot',
      email: 'ar@tec.rjt.ac.lk',
      role: UserRole.assistantRegistrar,
      token: 'mock_token_ar_kahawala_2026',
      displayName: 'Ms. K. H. Gaurika Kahawala',
      designationOrReg: 'Assistant Registrar (Faculty of Technology)',
      faculty: 'Faculty of Technology',
      department: "Office of the Assistant Registrar / Dean's Office",
    ),
    UserRole.dean: const AuthUser(
      id: 'u_dean_fot',
      username: 'dean_fot',
      email: 'dean@tec.rjt.ac.lk',
      role: UserRole.dean,
      token: 'mock_token_dean_bamunuarachchige_2026',
      displayName: 'Prof. T. C. Bamunuarachchige',
      designationOrReg: 'Professor & Dean, Faculty of Technology',
      faculty: 'Faculty of Technology',
      department: "Dean's Office",
    ),
    UserRole.systemAdmin: const AuthUser(
      id: 'u_sys01',
      username: 'sysadmin',
      email: 'director@cc.rjt.ac.lk',
      role: UserRole.systemAdmin,
      token: 'mock_token_sysadmin_palliyaguruge_2026',
      displayName: 'Mr. P. S. Palliyaguruge',
      designationOrReg: 'Director, Center for Information Technology Services (CITS)',
      faculty: 'University Administration',
      department: 'Center for Information Technology Services (CITS)',
    ),
  };

  /// Login with username or registration number and password
  Future<bool> login(
    String identifier,
    String password, {
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate realistic network handshake (350ms)
    await Future.delayed(const Duration(milliseconds: 350));

    final trimmedIdentifier = identifier.trim().toLowerCase();

    // Mapping known aliases to canonical usernames for flexibility
    const usernameAliases = {
      '2021ict01': 'student_nafis',
      'ict/2021/045': 'student_nafis',
      'student.nafis@rjt.ac.lk': 'student_nafis',
      'hod_perera': 'hod_ict',
      'hod_jayasuriya': 'hod_ict',
      'ar_dilhani': 'ar_fot',
      'ar_tec': 'ar_fot',
      'ar_gaurika': 'ar_fot',
      'dean_tec': 'dean_fot',
      'admin': 'sysadmin',
      'sys_admin': 'sysadmin',
      'itcenter@rjt.ac.lk': 'sysadmin',
    };
    final resolvedIdentifier = usernameAliases[trimmedIdentifier] ?? trimmedIdentifier;

    // Match against demo seeded accounts
    AuthUser? matched;
    for (var entry in demoAccounts.values) {
      if (entry.username.toLowerCase() == resolvedIdentifier ||
          entry.email.toLowerCase() == resolvedIdentifier ||
          entry.designationOrReg.toLowerCase() == resolvedIdentifier ||
          entry.username.toLowerCase() == trimmedIdentifier ||
          entry.email.toLowerCase() == trimmedIdentifier ||
          entry.designationOrReg.toLowerCase() == trimmedIdentifier) {
        matched = entry;
        break;
      }
    }

    final rolePasswords = {
      UserRole.student: 'Std@Rusl#2026',
      UserRole.headOfDepartment: 'Hod@Rusl#2026',
      UserRole.assistantRegistrar: 'Ar@Rusl#2026',
      UserRole.dean: 'Dean@Rusl#2026',
      UserRole.systemAdmin: 'Admin@Rusl#2026',
    };

    if (matched != null) {
      final isPasswordValid = password == 'RuslPass#2026' ||
          password == rolePasswords[matched.role];
      if (isPasswordValid) {
        _currentUser = matched;
        _sessionStartTime = DateTime.now();
        _lastActivityTime = DateTime.now();
        _isLoading = false;

        try {
          final prefs = await SharedPreferences.getInstance();
          if (rememberMe) {
            await prefs.setString('rusl_remembered_username', identifier.trim());
            await prefs.setBool('rusl_remember_me', true);
          } else {
            await prefs.remove('rusl_remembered_username');
            await prefs.setBool('rusl_remember_me', false);
          }
        } catch (_) {}

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

  static Future<String?> getRememberedUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('rusl_remembered_username');
    } catch (_) {
      return null;
    }
  }

  static Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('rusl_remember_me') ?? true;
    } catch (_) {
      return true;
    }
  }

  /// One-click quick login for testing any university actor role
  void quickLogin(UserRole role) {
    if (demoAccounts.containsKey(role)) {
      _currentUser = demoAccounts[role];
    } else {
      _currentUser = demoAccounts[UserRole.student];
    }
    _sessionStartTime = DateTime.now();
    _lastActivityTime = DateTime.now();
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout current session
  void logout() {
    _currentUser = null;
    _sessionStartTime = null;
    _lastActivityTime = null;
    _errorMessage = null;
    notifyListeners();
  }
}
