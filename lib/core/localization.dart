import 'package:flutter/foundation.dart';

class RuslLocalization {
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>(
    'en',
  );

  static String get currentLanguage => languageNotifier.value;
  static set currentLanguage(String lang) {
    if (['en', 'si', 'ta'].contains(lang)) {
      languageNotifier.value = lang;
    }
  }

  static void switchLanguage(String lang) {
    currentLanguage = lang;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Brand
      'app_title': 'RUSL Smart Course Registration',
      'university_name': 'Rajarata University of Sri Lanka',
      'academic_portal': 'Academic Portal',
      'welcome_back': 'Welcome back',
      'faculty_of_technology': 'Faculty of Technology',
      'department_ict': 'Information & Communication Technology',
      'logout': 'Sign Out',
      'language': 'Language',

      // Roles
      'role_student': 'Student',
      'role_hod': 'Head of Department (HoD)',
      'role_coordinator': 'Faculty Academic Coordinator',
      'role_ar': 'Assistant Registrar (AR)',
      'role_admin': 'System Administrator',

      // Authentication
      'sign_in_title': 'Sign In to Your Account',
      'sign_in_subtitle': 'Enter your registration number or university email',
      'username_label': 'Username / Reg Number',
      'password_label': 'Password',
      'username_placeholder': 'e.g. ICT/2021/045 or student_nafis',
      'password_placeholder': 'Enter your password',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot password?',
      'sign_in_btn': 'Sign In',
      'quick_login_title': 'Quick Demo Role Switcher (One-Click Login):',
      'demo_credentials_hint':
          'All demo accounts pre-configured with RUSL security credentials',

      // Tabs & Navigation
      'tab_course_selection': 'Course Selection',
      'tab_my_selection': 'My Selection',
      'tab_timetable': 'Timetable Grid',
      'tab_special_requests': 'Special Requests',
      'tab_approval_status': 'Approval Status',
      'tab_waiting_lists': 'Waiting Lists',

      // Metrics & Labels
      'registered_credits': 'Registered Credits',
      'completed_courses': 'Completed Courses',
      'status': 'Status',
      'credits': 'Credits',
      'capacity': 'Capacity',
      'seats_available': 'Seats Available',
      'full_capacity': 'Full Capacity',
      'academic_standing': 'Academic Standing',
      'good_standing': 'Good Standing',
      'semester_offerings': 'Semester 5 Course Offerings',
      'showing_courses': 'Showing Courses',
      'seats_filled_label': 'Seats Filled',

      // Course Filter Chips & Search
      'filter_all': 'All Courses',
      'filter_compulsory': 'Core Compulsory',
      'filter_elective': 'Electives',
      'filter_audited': 'Audited / Non-GPA',
      'search_courses': 'Search course code or title...',

      // Workflow Statuses
      'status_draft': 'Draft',
      'status_submitted': 'Submitted',
      'status_changes_requested': 'Changes Requested',
      'status_adviser_approved': 'Adviser Approved',
      'status_hod_approved': 'HoD Approved',
      'status_faculty_approved': 'Faculty Approved',
      'status_registered': 'Registered & Confirmed',
      'status_locked': 'Locked & Confirmed',
      'status_rejected': 'Rejected',

      // Waiting List & Capacity
      'join_waiting_list': 'Join Waiting List',
      'leave_waiting_list': 'Leave Waiting List',
      'waiting_position': 'Waiting Queue Position',
      'seat_promoted': 'Seat Available! Promoted from Queue',
      'claim_seat': 'Claim Promoted Seat',
      'waiting_list_empty': 'You are not in any waiting lists.',
      'active_queues': 'Active Queues',
      'waiting_sub_header':
          'Automated seat promotion queue with 24-hour claim window',
      'queue_promoted_msg':
          'Seat vacated! Confirm enrollment within 24 hours to secure your seat.',
      'queue_waiting_msg':
          'You will be promoted automatically when an enrolled student drops the course or capacity is raised.',
      'seat_claimed_msg': 'Seat claimed! Course added to your registration.',
      'waitlist_joined_msg': 'Joined waiting queue at position',
      'increase_capacity': '+5 Seats',
      'increase_capacity_msg':
          'Capacity increased by +5 seats! Waiting list candidates promoted.',

      // Validation
      'clash_detected': 'Timetable Clash Detected',
      'prerequisite_missing': 'Prerequisite Requirement Missing',
      'credit_limit_warning': 'Credit limit bounds not satisfied',

      // Actions & Slips
      'submit_registration': 'Submit Registration',
      'download_slip': 'Download Official PDF Slip',
      'download_slip_qr': 'Download Slip & QR',
      'digital_token': 'Digital Verification Token',
      'official_slip_title': 'Official Registration Slip',
      'approve_registration': 'Approve Registration',
      'request_changes': 'Request Changes',
      'endorse_faculty': 'Endorse & Forward to Faculty',
      'official_seal': 'Affix Official University Seal & Register',

      // Special Requests
      'special_requests_title': 'Special Academic Requests & Waiver Petitions',
      'request_type': 'Request Type',
      'explanation': 'Explanation / Justification',
      'submit_petition': 'Submit Petition to HoD',
      'credit_overload': 'Credit Limit Overload',
      'prerequisite_waiver': 'Prerequisite Waiver',
      'cross_department': 'Cross-Department Elective Enrollment',
      'exam_repeat': 'Exam Repeat Registration',

      // Staff Dashboard Headers
      'assigned_students': 'Assigned Students',
      'submitted_registrations': 'Submitted Registrations',
      'pending_adviser_approvals': 'Pending Adviser Approvals',
      'department_metrics': 'Department Registration Metrics',
      'faculty_allocation': 'Faculty Course Allocation & Venues',
      'exam_compliance': 'Semester 5 Exam Registration Compliance',
      'system_health': 'System Health & Engine Services',
      'audit_logs': 'Security Audit Logs',
    },
    'si': {
      // General & Brand
      'app_title': 'RUSL ස්මාර්ට් පාඨමාලා ලියාපදිංචි පද්ධතිය',
      'university_name': 'ශ්‍රී ලංකා රජරට විශ්වවිද්‍යාලය',
      'academic_portal': 'අධ්‍යයන ද්වාරය',
      'welcome_back': 'නැවත සාදරයෙන් පිළිගනිමු',
      'faculty_of_technology': 'තාක්ෂණ පීඨය',
      'department_ict': 'තොරතුරු හා සන්නිවේදන තාක්ෂණ අධ්‍යයනාංශය',
      'logout': 'පිටවීම',
      'language': 'භාෂාව',

      // Roles
      'role_student': 'ශිෂ්‍යයා',
      'role_hod': 'අංශාධිපති (HoD)',
      'role_coordinator': 'පීඨ සම්බන්ධීකාරක',
      'role_ar': 'සහකාර ලේඛකාධිකාරී (AR)',
      'role_admin': 'පද්ධති පරිපාලක (Admin)',

      // Authentication
      'sign_in_title': 'ඔබගේ ගිණුමට ඇතුල් වන්න',
      'sign_in_subtitle':
          'ඔබගේ ලියාපදිංචි අංකය හෝ විශ්වවිද්‍යාල ඊමේල් ලිපිනය ඇතුළත් කරන්න',
      'username_label': 'පරිශීලක නාමය / ලියාපදිංචි අංකය',
      'password_label': 'මුරපදය',
      'username_placeholder': 'උදා: ICT/2021/045 හෝ student_nafis',
      'password_placeholder': 'ඔබගේ මුරපදය ඇතුළත් කරන්න',
      'remember_me': 'මතක තබා ගන්න',
      'forgot_password': 'මුරපදය අමතකද?',
      'sign_in_btn': 'ඇතුල් වන්න',
      'quick_login_title': 'ක්ෂණික ආදර්ශන පිවිසුම (තනි ක්ලික් කිරීමකින්):',
      'demo_credentials_hint':
          'සියලු ආදර්ශන ගිණුම් RUSL ආරක්ෂක මුරපද සමඟ සකස් කර ඇත',

      // Tabs & Navigation
      'tab_course_selection': 'පාඨමාලා තේරීම',
      'tab_my_selection': 'මගේ තේරීම්',
      'tab_timetable': 'කාලසටහන',
      'tab_special_requests': 'විශේෂ ඉල්ලීම්',
      'tab_approval_status': 'අනුමත තත්ත්වය',
      'tab_waiting_lists': 'පොරොත්තු ලේඛන',

      // Metrics & Labels
      'registered_credits': 'ලියාපදිංචි ක්‍රෙඩිට්',
      'completed_courses': 'සම්පූර්ණ කළ පාඨමාලා',
      'status': 'තත්ත්වය',
      'credits': 'ක්‍රෙඩිට්',
      'capacity': 'ධාරිතාව',
      'seats_available': 'ඇති ආසන ගණන',
      'full_capacity': 'ධාරිතාව පිරී ඇත',
      'academic_standing': 'අධ්‍යයන තත්ත්වය',
      'good_standing': 'යහපත් මට්ටම',
      'semester_offerings': '5 වන සමාසිකයේ පාඨමාලා',
      'showing_courses': 'පාඨමාලා පෙන්වයි',
      'seats_filled_label': 'පිරවුණු ආසන',

      // Course Filter Chips & Search
      'filter_all': 'සියලු පාඨමාලා',
      'filter_compulsory': 'අනිවාර්ය',
      'filter_elective': 'වරණීය',
      'filter_audited': 'විගණනය කළ',
      'search_courses': 'පාඨමාලා කේතය හෝ නම සොයන්න...',

      // Workflow Statuses
      'status_draft': 'කෙටුම්පත',
      'status_submitted': 'යොමු කරන ලදී',
      'status_changes_requested': 'වෙනස්කම් ඉල්ලා ඇත',
      'status_adviser_approved': 'උපදේශක අනුමතයි',
      'status_hod_approved': 'අංශාධිපති අනුමතයි',
      'status_faculty_approved': 'පීඨය අනුමතයි',
      'status_registered': 'නිල වශයෙන් ලියාපදිංචි විය',
      'status_locked': 'ස්ථිර කර අගුළු දමන ලදී',
      'status_rejected': 'ප්‍රතික්ෂේපිතයි',

      // Waiting List & Capacity
      'join_waiting_list': 'පොරොත්තු ලේඛනයට එක්වන්න',
      'leave_waiting_list': 'පොරොත්තු ලේඛනයෙන් ඉවත් වන්න',
      'waiting_position': 'පොරොත්තු පෝලිමේ අංකය',
      'seat_promoted': 'ආසනයක් හිමි විය! පෝලිමෙන් තෝරා ගැනුණි',
      'claim_seat': 'ආසනය තහවුරු කරගන්න',
      'waiting_list_empty': 'ඔබ කිසිදු පොරොත්තු ලේඛනයක නොමැත.',
      'active_queues': 'සක්‍රිය පෝලිම්',
      'waiting_sub_header':
          'පැය 24ක කාලයක් සහිත ස්වයංක්‍රීය ආසන ප්‍රවර්ධන පෝලිම',
      'queue_promoted_msg':
          'ආසනයක් හිස් විය! පැය 24ක් තුළ ලියාපදිංචිය තහවුරු කරගන්න.',
      'queue_waiting_msg':
          'ලියාපදිංචි ශිෂ්‍යයෙකු ඉවත් වූ විට හෝ ධාරිතාව වැඩි කළ විට ඔබට ස්වයංක්‍රීයව ආසනයක් හිමිවේ.',
      'seat_claimed_msg': 'ආසනය තහවුරු කරන ලදී! පාඨමාලාව ලියාපදිංචියට එක් විය.',
      'waitlist_joined_msg': 'පොරොත්තු පෝලිමේ අංකය',
      'increase_capacity': '+5 ආසන',
      'increase_capacity_msg':
          'ධාරිතාව ආසන +5 කින් වැඩි කරන ලදී! පොරොත්තු ලේඛන අපේක්ෂකයින් ප්‍රවර්ධනය විය.',

      // Validation
      'clash_detected': 'කාලසටහන් ගැටීමක් හඳුනාගන්නා ලදී',
      'prerequisite_missing': 'පූර්ව අවශ්‍යතා සම්පූර්ණ කර නොමැත',
      'credit_limit_warning': 'ක්‍රෙඩිට් සීමාවන් සපුරා නොමැත',

      // Actions & Slips
      'submit_registration': 'ලියාපදිංචිය යොමු කරන්න',
      'download_slip': 'නිල PDF පත්‍රිකාව බාගන්න',
      'download_slip_qr': 'PDF පත්‍රිකාව සහ QR බාගන්න',
      'digital_token': 'ඩිජිටල් තහවුරු කිරීමේ ටෝකනය',
      'official_slip_title': 'නිල ලියාපදිංචි පත්‍රිකාව',
      'approve_registration': 'ලියාපදිංචිය අනුමත කරන්න',
      'request_changes': 'වෙනස්කම් සිදුකිරීමට දන්වන්න',
      'endorse_faculty': 'තහවුරු කර පීඨයට යොමු කරන්න',
      'official_seal': 'නිල විශ්වවිද්‍යාල මුද්‍රාව තබා ලියාපදිංචි කරන්න',

      // Special Requests
      'special_requests_title': 'විශේෂ අධ්‍යයන ඉල්ලීම් සහ පෙත්සම්',
      'request_type': 'ඉල්ලීම් වර්ගය',
      'explanation': 'පැහැදිලි කිරීම / සාධාරණීකරණය',
      'submit_petition': 'අංශාධිපති වෙත පෙත්සම යොමු කරන්න',
      'credit_overload': 'ක්‍රෙඩිට් සීමාව ඉක්මවා ලියාපදිංචිය',
      'prerequisite_waiver': 'පූර්ව අවශ්‍යතා ලිහිල් කිරීමේ ඉල්ලීම',
      'cross_department': 'වෙනත් අධ්‍යයනාංශ පාඨමාලා ලියාපදිංචිය',
      'exam_repeat': 'නැවත විභාග පෙනී සිටීමේ ලියාපදිංචිය',

      // Staff Dashboard Headers
      'assigned_students': 'පවරා ඇති සිසුන්',
      'submitted_registrations': 'යොමු කළ ලියාපදිංචි කිරීම්',
      'pending_adviser_approvals': 'අනුමැතිය අපේක්ෂිත',
      'department_metrics': 'අධ්‍යයනාංශ ලියාපදිංචි ප්‍රමිතික',
      'faculty_allocation': 'පීඨ පාඨමාලා වෙන්කිරීම් සහ ශාලා',
      'exam_compliance': '5 වන සමාසික විභාග ලියාපදිංචි අනුකූලතාව',
      'system_health': 'පද්ධති ක්‍රියාකාරීත්වය සහ සේවා',
      'audit_logs': 'ආරක්ෂක විගණන සටහන්',
    },
    'ta': {
      // General & Brand
      'app_title': 'RUSL ஸ்மார்ட் பாடநெறி பதிவு முறைமை',
      'university_name': 'இலங்கை ரஜரட்ட பல்கலைக்கழகம்',
      'academic_portal': 'கல்வி தளம்',
      'welcome_back': 'மீண்டும் வருக',
      'faculty_of_technology': 'தொழில்நுட்ப பீடம்',
      'department_ict': 'தகவல் மற்றும் தொடர்பாடல் தொழில்நுட்பத் துறை',
      'logout': 'வெளியேறு',
      'language': 'மொழி',

      // Roles
      'role_student': 'மாணவர்',
      'role_hod': 'துறைத் தலைவர் (HoD)',
      'role_coordinator': 'பீட ஒருங்கிணைப்பாளர்',
      'role_ar': 'உதவி பதிவாளர் (AR)',
      'role_admin': 'கணினி நிர்வாகி (Admin)',

      // Authentication
      'sign_in_title': 'உங்கள் கணக்கில் உள்நுழையவும்',
      'sign_in_subtitle':
          'உங்கள் பதிவு எண் அல்லது பல்கலைக்கழக மின்னஞ்சலை உள்ளிடவும்',
      'username_label': 'பயனர்பெயர் / பதிவு எண்',
      'password_label': 'கடவுச்சொல்',
      'username_placeholder': 'எ.கா: ICT/2021/045 அல்லது student_nafis',
      'password_placeholder': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
      'remember_me': 'என்னை நினைவில் கொள்',
      'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'sign_in_btn': 'உள்நுழைக',
      'quick_login_title': 'விரைவு மாதிரி உள்நுழைவு (ஒரே கிளிக்கில்):',
      'demo_credentials_hint':
          'அனைத்து மாதிரி கணக்குகளும் RUSL கடவுச்சொற்களுடன் உள்ளமைக்கப்பட்டுள்ளன',

      // Tabs & Navigation
      'tab_course_selection': 'பாடநெறி தெரிவு',
      'tab_my_selection': 'எனது தெரிவுகள்',
      'tab_timetable': 'நேர அட்டவணை',
      'tab_special_requests': 'சிறப்பு கோரிக்கைகள்',
      'tab_approval_status': 'ஒப்புதல் நிலை',
      'tab_waiting_lists': 'காத்திருப்பு பட்டியல்கள்',

      // Metrics & Labels
      'registered_credits': 'பதிவுசெய்த கடன் புள்ளிகள்',
      'completed_courses': 'முடிக்கப்பட்ட பாடநெறிகள்',
      'status': 'நிலை',
      'credits': 'கடன் புள்ளிகள்',
      'capacity': 'கொள்ளளவு',
      'seats_available': 'இடங்கள் உள்ளன',
      'full_capacity': 'கொள்ளளவு நிறைவடைந்தது',
      'academic_standing': 'கல்வி நிலை',
      'good_standing': 'நல்நிலை',
      'semester_offerings': 'பருவம் 5 பாடநெறிகள்',
      'showing_courses': 'பாடநெறிகள் காண்பிக்கப்படுகின்றன',
      'seats_filled_label': 'நிரப்பப்பட்ட இடங்கள்',

      // Course Filter Chips & Search
      'filter_all': 'அனைத்து பாடநெறிகள்',
      'filter_compulsory': 'கட்டாய பாடங்கள்',
      'filter_elective': 'விருப்பத் தேர்வுகள்',
      'filter_audited': 'தணிக்கை செய்யப்பட்ட',
      'search_courses': 'பாடநெறி குறியீடு அல்லது பெயரைத் தேடுங்கள்...',

      // Workflow Statuses
      'status_draft': 'வரைவு',
      'status_submitted': 'சமர்ப்பிக்கப்பட்டது',
      'status_changes_requested': 'மாற்றங்கள் கோரப்பட்டன',
      'status_adviser_approved': 'ஆலோசகர் ஒப்புதல் அளித்தார்',
      'status_hod_approved': 'துறைத்தலைவர் ஒப்புதல் அளித்தார்',
      'status_faculty_approved': 'பீடம் ஒப்புதல் அளித்தது',
      'status_registered': 'அதிகாரப்பூர்வமாக பதிவு செய்யப்பட்டது',
      'status_locked': 'பூட்டப்பட்டு உறுதிப்படுத்தப்பட்டது',
      'status_rejected': 'நிராகரிக்கப்பட்டது',

      // Waiting List & Capacity
      'join_waiting_list': 'காத்திருப்போர் பட்டியலில் சேரவும்',
      'leave_waiting_list': 'காத்திருப்போர் பட்டியலிலிருந்து விலகவும்',
      'waiting_position': 'காத்திருப்பு வரிசை எண்',
      'seat_promoted': 'இடம் கிடைத்தது! வரிசையிலிருந்து பதவி உயர்வு',
      'claim_seat': 'இடத்தை உறுதிப்படுத்தவும்',
      'waiting_list_empty': 'நீங்கள் எந்த காத்திருப்பு பட்டியலிலும் இல்லை.',
      'active_queues': 'செயலில் உள்ள வரிசைகள்',
      'waiting_sub_header':
          '24 மணி நேர சாளரத்துடன் கூடிய தானியங்கி இருக்கை பதவி உயர்வு வரிசை',
      'queue_promoted_msg':
          'இடம் காலியானது! 24 மணி நேரத்திற்குள் பதிவை உறுதிப்படுத்தவும்.',
      'queue_waiting_msg':
          'மாணவர் விலகும்போதோ அல்லது கொள்ளளவு அதிகரிக்கப்படும்போதோ தானாக இடம் கிடைக்கும்.',
      'seat_claimed_msg':
          'இடம் உறுதி செய்யப்பட்டது! பாடநெறி உங்கள் பதிவில் சேர்க்கப்பட்டது.',
      'waitlist_joined_msg': 'காத்திருப்பு வரிசையில் சேர்ந்த எண்',
      'increase_capacity': '+5 இடங்கள்',
      'increase_capacity_msg':
          'கொள்ளளவு +5 இடங்களாக அதிகரிக்கப்பட்டது! காத்திருப்பு மாணவர்கள் பதவி உயர்த்தப்பட்டனர்.',

      // Validation
      'clash_detected': 'நேர அட்டவணை முரண்பாடு கண்டறியப்பட்டது',
      'prerequisite_missing': 'முன்நிபந்தனை பூர்த்தி செய்யப்படவில்லை',
      'credit_limit_warning': 'கடன் புள்ளி வரம்புகள் பூர்த்தியாகவில்லை',

      // Actions & Slips
      'submit_registration': 'பதிவைச் சமர்ப்பிக்கவும்',
      'download_slip': 'அதிகாரப்பூர்வ PDF பதிவிறக்கவும்',
      'download_slip_qr': 'PDF படிவம் மற்றும் QR பதிவிறக்கவும்',
      'digital_token': 'டிஜிட்டல் சரிபார்ப்பு டோக்கன்',
      'official_slip_title': 'அதிகாரப்பூர்வ பதிவு படிவம்',
      'approve_registration': 'பதிவை அங்கீகரிக்கவும்',
      'request_changes': 'மாற்றங்களை பரிந்துரைக்கவும்',
      'endorse_faculty': 'உறுதிப்படுத்தி பீடத்திற்கு அனுப்பவும்',
      'official_seal': 'பல்கலைக்கழக முத்திரையிட்டு பதிவு செய்யவும்',

      // Special Requests
      'special_requests_title': 'சிறப்பு கல்வி கோரிக்கைகள் மற்றும் மனுக்கள்',
      'request_type': 'கோரிக்கை வகை',
      'explanation': 'விளக்கம் / நியாயப்படுத்தல்',
      'submit_petition': 'துறைத்தலைவருக்கு மனு சமர்ப்பிக்கவும்',
      'credit_overload': 'கடன் புள்ளி வரம்பு மிகை பதிவு',
      'prerequisite_waiver': 'முன்நிபந்தனை தளர்வு கோரிக்கை',
      'cross_department': 'வேறு துறை பாடநெறி பதிவு',
      'exam_repeat': 'மீண்டும் தேர்வு எழுதும் பதிவு',

      // Staff Dashboard Headers
      'assigned_students': 'ஒதுக்கப்பட்ட மாணவர்கள்',
      'submitted_registrations': 'சமர்ப்பிக்கப்பட்ட பதிவுகள்',
      'pending_adviser_approvals': 'நிலுவையிலுள்ள ஆலோசகர் ஒப்புதல்கள்',
      'department_metrics': 'துறை பதிவு அளவீடுகள்',
      'faculty_allocation': 'பீட பாடநெறி ஒதுக்கீடு மற்றும் அரங்குகள்',
      'exam_compliance': 'பருவம் 5 தேர்வு பதிவு இணக்கம்',
      'system_health': 'அமைப்பு ஆரோக்கியம் மற்றும் சேவைகள்',
      'audit_logs': 'பாதுகாப்பு தணிக்கை பதிவுகள்',
    },
  };

  static String tr(String key) {
    return _localizedValues[currentLanguage]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}
