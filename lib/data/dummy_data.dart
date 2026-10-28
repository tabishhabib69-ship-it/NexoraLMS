// ===== FILE GUIDE: lib/data/dummy_data.dart
// WHAT IT DOES : The app's in-memory demo "database" (no backend yet).
// MANAGES      : Users, courses, timetable, attendance, grades, assignments, exams, posts, chats, notifications, lost & found, semesters, audit log. reset() restores the originals.
// USED BY      : Almost every screen and service reads or changes these lists.
// ======================================================================

import '../models/academics.dart';
import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/course.dart';
import '../models/lost_found.dart';
import '../models/material.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/post.dart';
import '../models/semester.dart';
import '../models/timetable.dart';
import '../models/user.dart';
import '../services/session_service.dart';

/// Central in-memory store of demo university data for Uni-Sphere.
///
/// Everything here is sample data for presentations — no real people or
/// records. Dates are relative to "now" so the demo never goes stale. Screens
/// mutate these lists for interactive demos; [reset] restores the originals.
class DummyData {
  DummyData._();

  static const String universityName = 'Riphah International University';

  /// Restores every mutable list to its original demo contents.
  static void reset() {
    users
      ..clear()
      ..addAll(_users());
    courses
      ..clear()
      ..addAll(_courses());
    studentAttendance
      ..clear()
      ..addAll(_studentAttendance());
    courseAttendance
      ..clear()
      ..addAll(_courseAttendance());
    passingCriteria
      ..clear()
      ..addAll(_passingCriteria());
    announcements
      ..clear()
      ..addAll(_announcements());
    materials
      ..clear()
      ..addAll(_materials());
    posts
      ..clear()
      ..addAll(_posts());
    conversations
      ..clear()
      ..addAll(_conversations());
    messages
      ..clear()
      ..addAll(_messages());
    chatRequests
      ..clear()
      ..addAll(_chatRequests());
    notifications
      ..clear()
      ..addAll(_notifications());
    lostFound
      ..clear()
      ..addAll(_lostFound());
    semesters
      ..clear()
      ..addAll(_semesters());
    assignments
      ..clear()
      ..addAll(_assignments());
    submissions
      ..clear()
      ..addAll(_submissions());
    publishedGrades
      ..clear()
      ..add('as6');
    gradeFeedback.clear();
    exams
      ..clear()
      ..addAll(_exams());
    events
      ..clear()
      ..addAll(_events());
    enrollmentRequests
      ..clear()
      ..addAll(_enrollmentRequests());
    auditLog
      ..clear()
      ..addAll(_auditLog());
    suspendedUserIds.clear();
    connections
      ..clear()
      ..addAll(_connections());
    connectionRequests
      ..clear()
      ..addAll(_connectionRequests());
    savedMaterials.clear();
    AuthService.reset();
  }

  // ------------------------------------------------------------- helpers --
  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// A moment [days] from today at [hour]:[minute].
  static DateTime _at(int days, int hour, [int minute = 0]) =>
      _today.add(Duration(days: days, hours: hour, minutes: minute));

  static DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
      DateTime.now().subtract(Duration(days: days, hours: hours, minutes: minutes));

  // ---------------------------------------------------------------- Users --
  static const AppUser student = AppUser(
    id: 's1',
    name: 'Zara Ahmed',
    email: 'zara.ahmed@riphah.edu.pk',
    phone: '+92 300 0000142',
    role: UserRole.student,
    avatarColor: '#8A4A52',
    department: 'Computer Science',
    studentId: 'CS-21-0142',
    semester: 5,
    program: 'BS Computer Science',
    bio: 'CS student who loves clean UI, competitive programming and chai.',
  );

  static const AppUser faculty = AppUser(
    id: 'f1',
    name: 'Dr. Sarah Khan',
    email: 'sarah.khan@riphah.edu.pk',
    phone: '+92 300 0000201',
    role: UserRole.faculty,
    avatarColor: '#B5A57C',
    department: 'Computer Science',
    designation: 'Senior Lecturer',
    bio: 'Teaches data structures and databases. Office hours Tue & Thu, 2–4 PM.',
  );

  static const AppUser admin = AppUser(
    id: 'a1',
    name: 'Nadia Karim',
    email: 'admin@riphah.edu.pk',
    phone: '+92 300 0000001',
    role: UserRole.admin,
    avatarColor: '#9A5560',
    department: 'Registrar Office',
    designation: 'System Administrator',
  );

  static final List<AppUser> users = _users();

  /// Ids of the built-in sample accounts (they use the documented demo passwords).
  static final Set<String> seedUserIds = {for (final u in _users()) u.id};
  static List<AppUser> _users() => [
    student,
    faculty,
    admin,
    const AppUser(
      id: 's2',
      name: 'Ahmed Ali',
      email: 'ahmed.ali@riphah.edu.pk',
      phone: '+92 300 0000110',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Computer Science',
      studentId: 'CS-22-0110',
      semester: 4,
      program: 'BS Computer Science',
    ),
    const AppUser(
      id: 's3',
      name: 'Fatima Malik',
      email: 'fatima.malik@riphah.edu.pk',
      phone: '+92 300 0000045',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Electrical Engineering',
      studentId: 'EE-23-0045',
      semester: 2,
      program: 'BS Electrical Engineering',
    ),
    const AppUser(
      id: 's4',
      name: 'Rania Tahir',
      email: 'rania.tahir@riphah.edu.pk',
      phone: '+92 300 0000089',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Computer Science',
      studentId: 'CS-21-0089',
      semester: 5,
      program: 'BS Computer Science',
    ),
    const AppUser(
      id: 's5',
      name: 'Hassan Khalid',
      email: 'hassan.khalid@riphah.edu.pk',
      phone: '+92 300 0000120',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Computer Science',
      studentId: 'CS-21-0120',
      semester: 5,
      program: 'BS Computer Science',
    ),
    const AppUser(
      id: 's6',
      name: 'Rania Baig',
      email: 'rania.baig@riphah.edu.pk',
      phone: '+92 300 0000198',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Computer Science',
      studentId: 'CS-21-0198',
      semester: 5,
      program: 'BS Computer Science',
    ),
    const AppUser(
      id: 's7',
      name: 'Ali Kazmi',
      email: 'ali.kazmi@riphah.edu.pk',
      phone: '+92 300 0000087',
      role: UserRole.student,
      avatarColor: '#8A4A52',
      department: 'Computer Science',
      studentId: 'CS-20-0087',
      semester: 7,
      program: 'BS Computer Science',
    ),
    const AppUser(
      id: 'f2',
      name: 'Prof. M. Asif',
      email: 'm.asif@riphah.edu.pk',
      phone: '+92 300 0000202',
      role: UserRole.faculty,
      avatarColor: '#B5A57C',
      department: 'Computer Science',
      designation: 'Professor',
    ),
    const AppUser(
      id: 'f3',
      name: 'Dr. Aisha Raza',
      email: 'aisha.raza@riphah.edu.pk',
      phone: '+92 300 0000203',
      role: UserRole.faculty,
      avatarColor: '#B5A57C',
      department: 'Computer Science',
      designation: 'Assistant Professor',
    ),
    const AppUser(
      id: 'f4',
      name: 'Dr. Bilal Hussain',
      email: 'bilal.hussain@riphah.edu.pk',
      phone: '+92 300 0000204',
      role: UserRole.faculty,
      avatarColor: '#B5A57C',
      department: 'Software Engineering',
      designation: 'Associate Professor',
    ),
    const AppUser(
      id: 'a2',
      name: 'Hassan Malik',
      email: 'hassan.m@riphah.edu.pk',
      phone: '+92 300 0000002',
      role: UserRole.admin,
      avatarColor: '#9A5560',
      department: 'Registrar Office',
      designation: 'Registrar Staff',
    ),
  ];

  /// Users an admin has suspended (they keep their data but cannot sign in).
  static final Set<String> suspendedUserIds = {};

  // -------------------------------------------------------------- Courses --
  static final List<Course> courses = _courses();
  static List<Course> _courses() => [
    const Course(
      id: 'c1',
      code: 'CS-301',
      title: 'Data Structures',
      facultyId: 'f1',
      facultyName: 'Dr. Sarah Khan',
      description:
          'Linear and non-linear data structures — lists, stacks, queues, trees, heaps, hash tables '
          'and graphs — with complexity analysis and classic algorithms on each.',
      credits: 3,
      semester: 5,
      department: 'Computer Science',
      schedule: 'Mon, Wed, Fri · 8:00 AM',
      room: 'LT-04',
      enrolledCount: 48,
      color: '#8A4A52',
    ),
    const Course(
      id: 'c2',
      code: 'CS-305',
      title: 'Database Systems',
      facultyId: 'f1',
      facultyName: 'Dr. Sarah Khan',
      description:
          'Relational model, SQL, ER modelling, normalization, indexing, transactions and '
          'an introduction to NoSQL stores.',
      credits: 3,
      semester: 5,
      department: 'Computer Science',
      schedule: 'Tue & Thu · 9:00 AM',
      room: 'LT-02',
      enrolledCount: 52,
      color: '#B5A57C',
    ),
    const Course(
      id: 'c3',
      code: 'CS-311',
      title: 'Operating Systems',
      facultyId: 'f4',
      facultyName: 'Dr. Bilal Hussain',
      description:
          'Processes, threads, CPU scheduling, synchronization, deadlocks, memory management '
          'and file systems.',
      credits: 3,
      semester: 5,
      department: 'Computer Science',
      schedule: 'Mon & Thu · 10:00 AM',
      room: 'LT-03',
      enrolledCount: 46,
      color: '#9A5560',
    ),
    const Course(
      id: 'c4',
      code: 'CS-321',
      title: 'Computer Networks',
      facultyId: 'f2',
      facultyName: 'Prof. M. Asif',
      description:
          'Layered architectures, TCP/IP, routing, congestion control, wireless networks and '
          'network security basics.',
      credits: 3,
      semester: 5,
      department: 'Computer Science',
      schedule: 'Mon & Wed · 1:00 PM',
      room: 'LT-01',
      enrolledCount: 50,
      color: '#6E6668',
    ),
    const Course(
      id: 'c5',
      code: 'CS-341',
      title: 'Mobile Application Development',
      facultyId: 'f3',
      facultyName: 'Dr. Aisha Raza',
      description:
          'Building cross-platform apps with Flutter: widgets, state management, navigation, '
          'persistence and publishing.',
      credits: 3,
      semester: 5,
      department: 'Computer Science',
      schedule: 'Tue & Wed · 10:00 AM',
      room: 'Lab-2B',
      enrolledCount: 40,
      color: '#7A7050',
    ),
    const Course(
      id: 'c6',
      code: 'SE-301',
      title: 'Software Engineering',
      facultyId: 'f4',
      facultyName: 'Dr. Bilal Hussain',
      description: 'Requirements, design, testing, agile process and team projects.',
      credits: 3,
      semester: 6,
      department: 'Software Engineering',
      schedule: 'Tue & Thu · 11:00 AM',
      room: 'LT-05',
      enrolledCount: 44,
      color: '#8A4A52',
    ),
    const Course(
      id: 'c7',
      code: 'DES-205',
      title: 'UI/UX Design',
      facultyId: 'f3',
      facultyName: 'Dr. Aisha Raza',
      description: 'User research, information architecture, prototyping and usability testing.',
      credits: 3,
      semester: 6,
      department: 'Computer Science',
      schedule: 'Fri · 10:00 AM',
      room: 'Lab-2B',
      enrolledCount: 35,
      color: '#B5A57C',
    ),
    const Course(
      id: 'c8',
      code: 'CS-401',
      title: 'Artificial Intelligence',
      facultyId: 'f2',
      facultyName: 'Prof. M. Asif',
      description: 'Search, knowledge representation, probabilistic reasoning and introductory machine learning.',
      credits: 3,
      semester: 7,
      department: 'Computer Science',
      schedule: 'Mon & Wed · 11:00 AM',
      room: 'LT-06',
      enrolledCount: 38,
      color: '#9A5560',
    ),
    const Course(
      id: 'c9',
      code: 'EE-101',
      title: 'Circuit Analysis',
      facultyId: 'f2',
      facultyName: 'Prof. M. Asif',
      description: 'Kirchhoff laws, network theorems and AC/DC circuit analysis.',
      credits: 3,
      semester: 2,
      department: 'Electrical Engineering',
      schedule: 'Wed & Fri · 1:00 PM',
      room: 'ENG-201',
      enrolledCount: 33,
      color: '#6E6668',
    ),
  ];

  /// Course ids the demo student is enrolled in this term.
  static const List<String> studentCourseIds = ['c1', 'c2', 'c3', 'c4', 'c5'];

  /// Course ids taught by the demo faculty member.
  static const List<String> facultyCourseIds = ['c1', 'c2'];

  /// Course completion (syllabus covered) for the demo term, 0..1.
  static const Map<String, double> courseProgress = {'c1': 0.70, 'c2': 0.45, 'c3': 0.55, 'c4': 0.50, 'c5': 0.62};

  /// Prerequisites and interest tags, used by course recommendations.
  static const Map<String, List<String>> prerequisites = {
    'c6': ['c1'],
    'c7': [],
    'c8': ['c1'],
    'c9': [],
  };
  static const Map<String, List<String>> courseTags = {
    'c1': ['Algorithms'],
    'c2': ['Data'],
    'c3': ['Systems'],
    'c4': ['Systems'],
    'c5': ['Mobile', 'Design'],
    'c6': ['Software'],
    'c7': ['Design'],
    'c8': ['AI', 'Algorithms'],
    'c9': ['Hardware'],
  };

  /// Weekly syllabus outline per course.
  static const Map<String, List<String>> syllabus = {
    'c1': [
      'Complexity & Big-O',
      'Arrays, Linked Lists',
      'Stacks & Queues',
      'Hash Tables',
      'Trees & BST',
      'Tree Traversals',
      'Heaps & Priority Queues',
      'Graphs: BFS & DFS',
      'Shortest Paths',
      'Sorting Algorithms',
    ],
    'c2': [
      'Relational Model',
      'SQL Basics',
      'Joins & Subqueries',
      'ER Modelling',
      'Normalization (1NF–BCNF)',
      'Indexing',
      'Transactions & ACID',
      'Concurrency Control',
      'NoSQL Overview',
    ],
    'c3': [
      'OS Structures',
      'Processes & Threads',
      'CPU Scheduling',
      'Synchronization',
      'Deadlocks',
      'Memory Management',
      'Virtual Memory',
      'File Systems',
    ],
    'c4': [
      'Network Models (OSI, TCP/IP)',
      'Application Layer',
      'Transport: TCP & UDP',
      'Congestion Control',
      'Network Layer & Routing',
      'Link Layer',
      'Wireless Networks',
      'Security Basics',
    ],
    'c5': [
      'Dart Essentials',
      'Widgets & Layout',
      'State Management',
      'Navigation',
      'Networking & JSON',
      'Local Storage',
      'Testing',
      'Publishing',
    ],
  };

  /// Display order for timetable day grouping.
  static const List<String> timetableDayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Weekly class timetable for the demo student.
  static const List<TimetableEntry> studentTimetable = <TimetableEntry>[
    TimetableEntry(day: 'Mon', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lecture', room: 'LT-04'),
    TimetableEntry(day: 'Mon', start: '10:00 AM', end: '11:30 AM', courseId: 'c3', type: 'Lecture', room: 'LT-03'),
    TimetableEntry(day: 'Mon', start: '01:00 PM', end: '02:30 PM', courseId: 'c4', type: 'Lecture', room: 'LT-01'),
    TimetableEntry(day: 'Tue', start: '09:00 AM', end: '10:30 AM', courseId: 'c2', type: 'Lecture', room: 'LT-02'),
    TimetableEntry(day: 'Tue', start: '11:00 AM', end: '12:30 PM', courseId: 'c5', type: 'Lab', room: 'Lab-2B'),
    TimetableEntry(day: 'Wed', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lecture', room: 'LT-04'),
    TimetableEntry(day: 'Wed', start: '10:00 AM', end: '11:30 AM', courseId: 'c5', type: 'Lecture', room: 'Lab-2B'),
    TimetableEntry(day: 'Wed', start: '01:00 PM', end: '02:30 PM', courseId: 'c4', type: 'Lecture', room: 'LT-01'),
    TimetableEntry(day: 'Thu', start: '09:00 AM', end: '10:30 AM', courseId: 'c2', type: 'Lecture', room: 'LT-02'),
    TimetableEntry(day: 'Thu', start: '11:00 AM', end: '12:30 PM', courseId: 'c3', type: 'Tutorial', room: 'LT-03'),
    TimetableEntry(day: 'Fri', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lab', room: 'LAB-1'),
  ];

  /// Weekly teaching timetable for the demo faculty member.
  static const List<TimetableEntry> facultyTimetable = <TimetableEntry>[
    TimetableEntry(day: 'Mon', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lecture', room: 'LT-04'),
    TimetableEntry(day: 'Tue', start: '09:00 AM', end: '10:30 AM', courseId: 'c2', type: 'Lecture', room: 'LT-02'),
    TimetableEntry(day: 'Wed', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lecture', room: 'LT-04'),
    TimetableEntry(day: 'Thu', start: '09:00 AM', end: '10:30 AM', courseId: 'c2', type: 'Lecture', room: 'LT-02'),
    TimetableEntry(day: 'Fri', start: '08:00 AM', end: '09:30 AM', courseId: 'c1', type: 'Lab', room: 'LAB-1'),
  ];

  static Course? courseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  static AppUser? userById(String id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  // ----------------------------------------------------------- Attendance --
  /// Varied on purpose so good / at-risk / below-75% states all appear.
  static final List<AttendanceRecord> studentAttendance = _studentAttendance();
  static List<AttendanceRecord> _studentAttendance() => [
    AttendanceRecord(studentId: 's1', courseId: 'c1', totalClasses: 20, attended: 17), // 85%
    AttendanceRecord(studentId: 's1', courseId: 'c2', totalClasses: 18, attended: 14), // 77.8%
    AttendanceRecord(studentId: 's1', courseId: 'c3', totalClasses: 22, attended: 16), // 72.7%
    AttendanceRecord(studentId: 's1', courseId: 'c4', totalClasses: 16, attended: 12), // 75%
    AttendanceRecord(studentId: 's1', courseId: 'c5', totalClasses: 14, attended: 14), // 100%
  ];

  /// Attendance for all students in a course (faculty views).
  static final Map<String, List<AttendanceRecord>> courseAttendance = _courseAttendance();
  static Map<String, List<AttendanceRecord>> _courseAttendance() => {
    'c1': [
      const AttendanceRecord(studentId: 's1', courseId: 'c1', totalClasses: 20, attended: 17),
      const AttendanceRecord(studentId: 's2', courseId: 'c1', totalClasses: 20, attended: 12),
      const AttendanceRecord(studentId: 's4', courseId: 'c1', totalClasses: 20, attended: 19),
      const AttendanceRecord(studentId: 's5', courseId: 'c1', totalClasses: 20, attended: 15),
    ],
    'c2': [
      const AttendanceRecord(studentId: 's1', courseId: 'c2', totalClasses: 18, attended: 14),
      const AttendanceRecord(studentId: 's4', courseId: 'c2', totalClasses: 18, attended: 16),
      const AttendanceRecord(studentId: 's5', courseId: 'c2', totalClasses: 18, attended: 11),
    ],
  };

  static final Map<String, PassingCriteria> passingCriteria = _passingCriteria();
  static Map<String, PassingCriteria> _passingCriteria() => {
    'c1': const PassingCriteria(courseId: 'c1'),
    'c2': const PassingCriteria(courseId: 'c2', midtermWeight: 25, finalWeight: 55),
  };

  // ------------------------------------------------------ Grades & GPA --
  static const List<GradeItem> grades = [
    GradeItem(courseId: 'c1', title: 'Quiz 1', obtained: 9, total: 10, feedback: 'Clean traversal logic.'),
    GradeItem(
      courseId: 'c1',
      title: 'Assignment 1',
      obtained: 18,
      total: 20,
      feedback: 'Good use of recursion; add complexity notes.',
    ),
    GradeItem(courseId: 'c1', title: 'Assignment 2', obtained: 17, total: 20),
    GradeItem(courseId: 'c2', title: 'Quiz 1', obtained: 7, total: 10),
    GradeItem(courseId: 'c2', title: 'SQL Lab', obtained: 16, total: 20, feedback: 'Joins correct; avoid SELECT *.'),
    GradeItem(courseId: 'c3', title: 'Quiz 1', obtained: 6, total: 10, feedback: 'Revise round-robin scheduling.'),
    GradeItem(courseId: 'c3', title: 'Assignment 1', obtained: 14, total: 20),
    GradeItem(courseId: 'c4', title: 'Quiz 1', obtained: 6, total: 10),
    GradeItem(
      courseId: 'c4',
      title: 'Assignment 1',
      obtained: 12,
      total: 20,
      feedback: 'Subnetting answers incomplete.',
    ),
    GradeItem(courseId: 'c5', title: 'Lab 1', obtained: 10, total: 10),
    GradeItem(courseId: 'c5', title: 'UI Assignment', obtained: 19, total: 20, feedback: 'Excellent layout work.'),
  ];

  /// Completed terms (credits sum to 72 — the PDF's "72 of 120").
  static const List<TermResult> termResults = [
    TermResult(term: 'Fall 24', gpa: 3.20, credits: 18),
    TermResult(term: 'Spr 25', gpa: 3.45, credits: 18),
    TermResult(term: 'Fall 25', gpa: 3.60, credits: 18),
    TermResult(term: 'Spr 26', gpa: 3.80, credits: 18),
  ];
  static const int programCredits = 120;

  // -------------------------------------------------------- Assignments --
  static final List<Assignment> assignments = _assignments();
  static List<Assignment> _assignments() => [
    Assignment(
      id: 'as1',
      courseId: 'c1',
      title: 'Lab 3 — BST Operations',
      instructions:
          'Implement insert, delete and search for a binary search tree. Include in-order, pre-order '
          'and post-order traversals and report the time complexity of each operation.',
      due: _at(1, 23, 59),
      totalMarks: 20,
    ),
    Assignment(
      id: 'as2',
      courseId: 'c2',
      title: 'ER Diagram — Library System',
      instructions:
          'Design an ER diagram for a university library (books, members, loans, fines). Convert it '
          'to relational tables and normalize to 3NF.',
      due: _at(4, 23, 59),
      totalMarks: 25,
    ),
    Assignment(
      id: 'as3',
      courseId: 'c4',
      title: 'Quiz 2 — Transport Layer',
      type: TaskType.quiz,
      instructions: '10 MCQs on TCP/UDP, flow control and congestion control. 20 minutes, in class.',
      due: _at(6, 13),
      totalMarks: 10,
    ),
    Assignment(
      id: 'as4',
      courseId: 'c5',
      title: 'Flutter Profile Screen',
      instructions:
          'Build a responsive profile screen with a header, stats row and tabbed content. Submit a '
          'screenshot of the running app and your main widget file.',
      due: _at(9, 23, 59),
      totalMarks: 20,
    ),
    Assignment(
      id: 'as5',
      courseId: 'c3',
      title: 'CPU Scheduling Simulation',
      instructions: 'Simulate FCFS, SJF and Round Robin for the given process set and compare waiting times.',
      due: _ago(days: 2),
      totalMarks: 20,
      status: SubmissionStatus.submitted,
      submittedAt: _ago(days: 3),
      attachmentName: 'scheduling_report.pdf',
    ),
    Assignment(
      id: 'as6',
      courseId: 'c1',
      title: 'Assignment 2 — Linked Lists',
      instructions: 'Implement a doubly linked list with reverse and merge operations.',
      due: _ago(days: 9),
      totalMarks: 20,
      status: SubmissionStatus.graded,
      submittedAt: _ago(days: 10),
      attachmentName: 'linked_list.zip',
      obtained: 17,
      feedback: 'Merge is correct. Handle the empty-list edge case in reverse().',
    ),
    Assignment(
      id: 'as7',
      courseId: 'c4',
      title: 'Subnetting Worksheet',
      instructions: 'Solve the 8 subnetting problems on the worksheet.',
      due: _ago(days: 1),
      totalMarks: 10,
    ),
  ];

  // ------------------------------------------------------ Faculty grading --
  /// assignmentId → studentId → marks. A null value means submitted but not
  /// yet graded; students missing from the map have not submitted.
  static final Map<String, Map<String, double?>> submissions = _submissions();
  static Map<String, Map<String, double?>> _submissions() => {
    'as1': {'s2': null, 's4': null, 's5': null},
    'as2': {'s4': null, 's5': null},
    'as6': {'s1': 17, 's2': 14, 's4': 19, 's5': 12},
  };

  /// Written grading feedback per "assignmentId:studentId" (shown once published).
  static final Map<String, String> gradeFeedback = {};

  /// Assignments whose grades the instructor has published to students.
  static final Set<String> publishedGrades = {'as6'};

  /// Student ids enrolled in a course (from the attendance roster).
  static List<String> rosterFor(String courseId) => [
    for (final r in courseAttendance[courseId] ?? const <AttendanceRecord>[]) r.studentId,
  ];

  // -------------------------------------------------------------- Exams --
  static final List<Exam> exams = _exams();
  static List<Exam> _exams() => [
    Exam(id: 'ex1', courseId: 'c1', title: 'Data Structures Mid', date: _at(3, 9), venue: 'Hall B', seat: 'Seat 42'),
    Exam(id: 'ex2', courseId: 'c4', title: 'Computer Networks Mid', date: _at(8, 9), venue: 'Hall A', seat: 'Seat 17'),
    Exam(id: 'ex3', courseId: 'c3', title: 'Operating Systems Mid', date: _at(12, 13), venue: 'Hall C', seat: 'Seat 8'),
    Exam(
      id: 'ex4',
      courseId: 'c2',
      title: 'Database Systems Final',
      date: _at(45, 9),
      venue: 'Hall B',
      seat: 'Seat 30',
    ),
  ];

  // ------------------------------------------------------ Personal events --
  static final List<CalendarEvent> events = _events();
  static List<CalendarEvent> _events() => [
    CalendarEvent(
      id: 'ev1',
      title: 'Study group — DS revision',
      date: _at(1, 0),
      startMinutes: 16 * 60,
      endMinutes: 17 * 60 + 30,
      note: 'Library, 2nd floor',
      ownerId: 's1',
    ),
  ];

  // -------------------------------------------------------- Announcements --
  static final List<Announcement> announcements = _announcements();
  static List<Announcement> _announcements() => [
    Announcement(
      id: 'an1',
      title: 'Midterm Seating Plan Published',
      body:
          'The CS-301 midterm will be held in Hall B. Check your seat number in the exam schedule and bring '
          'your university ID card.',
      authorName: 'Dr. Sarah Khan',
      authorRole: 'Faculty',
      courseId: 'c1',
      courseCode: 'CS-301',
      date: _ago(hours: 5),
      pinned: true,
      priority: AnnouncementPriority.important,
    ),
    Announcement(
      id: 'an2',
      title: 'Database Lab Moved to Friday',
      body: "Thursday's CS-305 lab moves to Friday 10:00 AM in LAB-2 due to a room clash.",
      authorName: 'Dr. Sarah Khan',
      authorRole: 'Faculty',
      courseId: 'c2',
      courseCode: 'CS-305',
      date: _ago(days: 1),
    ),
    Announcement(
      id: 'an3',
      title: 'Fee Deadline Reminder',
      body: 'Fall 2026 second-instalment fee is due by the end of this month. Late fee applies afterwards.',
      authorName: 'Registrar Office',
      authorRole: 'Admin',
      date: _ago(days: 2),
      priority: AnnouncementPriority.urgent,
    ),
  ];

  // -------------------------------------------------------------- Materials --
  static final List<LearningMaterial> materials = _materials();
  static List<LearningMaterial> _materials() => [
    LearningMaterial(
      id: 'm1',
      courseId: 'c1',
      title: 'Lecture 01-05 — Trees & Graphs',
      description: 'Lecture notes on trees, BSTs, traversals and graph representations.',
      type: LearningMaterialType.pdf,
      size: '2.4 MB',
      week: 'Week 1–3',
      date: _ago(days: 20),
      downloads: 88,
      summary:
          'Chapter 5: Tree Traversal Algorithms. Trees are hierarchical structures with a root node and '
          'subtrees of children. Traversals visit every node: in-order (left, root, right) gives sorted output '
          'for a BST; pre-order (root first) copies a tree; post-order (root last) deletes it safely. Level-order '
          'uses a queue and is the tree form of BFS. All traversals run in O(n) time.',
    ),
    LearningMaterial(
      id: 'm2',
      courseId: 'c1',
      title: 'Week 4 Slides — Hash Tables',
      description: 'Hash functions, collision handling and load factor.',
      type: LearningMaterialType.slides,
      size: '5.1 MB',
      week: 'Week 4',
      date: _ago(days: 13),
      downloads: 64,
      summary:
          'A hash table maps keys to buckets with a hash function. Collisions are handled by chaining '
          '(lists per bucket) or open addressing (probing). Keeping the load factor below ~0.75 keeps average '
          'insert/search/delete at O(1); resizing rehashes every key.',
    ),
    LearningMaterial(
      id: 'm3',
      courseId: 'c1',
      title: 'Recorded Lecture — BFS & DFS',
      description: '48-minute recording of the graph traversal lecture.',
      type: LearningMaterialType.video,
      size: '142 MB',
      week: 'Week 5',
      date: _ago(days: 6),
      downloads: 51,
      summary:
          'BFS explores a graph level by level using a queue and finds shortest paths in unweighted '
          'graphs. DFS goes deep first using recursion or a stack and is used for cycle detection and '
          'topological sort. Both run in O(V + E).',
    ),
    LearningMaterial(
      id: 'm4',
      courseId: 'c2',
      title: 'Normalization Notes',
      description: '1NF to BCNF with worked examples.',
      type: LearningMaterialType.document,
      size: '840 KB',
      week: 'Week 5',
      date: _ago(days: 9),
      downloads: 67,
      summary:
          'Normalization removes redundancy: 1NF needs atomic values, 2NF removes partial dependencies on '
          'a composite key, 3NF removes transitive dependencies, and BCNF requires every determinant to be a '
          'candidate key.',
    ),
    LearningMaterial(
      id: 'm5',
      courseId: 'c2',
      title: 'SQL Joins Workshop',
      description: 'Hands-on joins workshop slides.',
      type: LearningMaterialType.slides,
      size: '3.2 MB',
      week: 'Week 3',
      date: _ago(days: 15),
      downloads: 72,
      summary:
          'INNER JOIN keeps matching rows, LEFT JOIN keeps all rows from the left table, and FULL JOIN '
          'keeps all rows from both. Join on keys and filter early with WHERE for performance.',
    ),
    LearningMaterial(
      id: 'm6',
      courseId: 'c3',
      title: 'CPU Scheduling Handout',
      description: 'FCFS, SJF, Priority and Round Robin with Gantt charts.',
      type: LearningMaterialType.pdf,
      size: '1.6 MB',
      week: 'Week 3',
      date: _ago(days: 11),
      downloads: 40,
      summary:
          'Scheduling picks the next ready process. FCFS is simple but suffers convoy effects; SJF minimizes '
          'average waiting time but needs burst estimates; Round Robin uses a time quantum for fairness.',
    ),
    LearningMaterial(
      id: 'm7',
      courseId: 'c4',
      title: 'TCP vs UDP Slides',
      description: 'Transport layer comparison and handshake.',
      type: LearningMaterialType.slides,
      size: '4.0 MB',
      week: 'Week 4',
      date: _ago(days: 8),
      downloads: 35,
      summary:
          'TCP is connection-oriented and reliable (three-way handshake, acknowledgements, flow and '
          'congestion control). UDP is connectionless and lightweight, suited to streaming and DNS.',
    ),
    LearningMaterial(
      id: 'm8',
      courseId: 'c5',
      title: 'Flutter State Management',
      description: 'setState, InheritedWidget and Provider compared.',
      type: LearningMaterialType.pdf,
      size: '2.1 MB',
      week: 'Week 4',
      date: _ago(days: 5),
      downloads: 58,
      summary:
          'Keep state as close to where it is used as possible. setState suits local UI state; '
          'InheritedWidget and Provider share state down the tree and rebuild only listeners.',
    ),
  ];

  /// Materials the student bookmarked.
  /// userId → ids of course materials they bookmarked.
  static final Map<String, Set<String>> savedMaterials = {};

  // ------------------------------------------------------------ Feed Posts --
  static final List<Post> posts = _posts();
  static List<Post> _posts() => [
    Post(
      id: 'p1',
      authorId: 's4',
      authorName: 'Rania Tahir',
      authorRole: 'Student',
      authorColor: '#8A4A52',
      content:
          "Honored to receive the Dean's Merit Scholarship this semester! Grateful for my professors and "
          'study group. Hard work truly pays off.',
      date: _ago(hours: 2),
      likes: 45,
      shares: 3,
      category: PostCategory.achievement,
      highlightTitle: "Dean's Merit Scholarship",
      highlightSubtitle: 'Academic Excellence · Fall 2025',
      comments: [
        Comment(
          id: 'cm1',
          authorName: 'Ahmed Ali',
          authorColor: '#8A4A52',
          body: 'Well deserved, congrats!',
          date: _ago(hours: 1),
        ),
      ],
    ),
    Post(
      id: 'p2',
      authorId: 's5',
      authorName: 'Hassan Khalid',
      authorRole: 'Student',
      authorColor: '#2E2729',
      content: 'Just finished the Google UX Design certificate. The usability-testing module was the best part.',
      date: _ago(hours: 5),
      likes: 31,
      shares: 2,
      category: PostCategory.certificate,
      highlightTitle: 'Google UX Design',
      highlightSubtitle: 'Professional Certificate · Coursera',
    ),
    Post(
      id: 'p3',
      authorId: 'a1',
      authorName: 'Riphah Official',
      authorRole: 'Admin',
      authorColor: '#9A5560',
      content:
          'Fall 2026 Career Fair is on Friday in the Main Auditorium, 10 AM – 4 PM. Bring printed CVs — '
          '30+ companies attending.',
      date: _ago(hours: 8),
      likes: 124,
      shares: 18,
      official: true,
      category: PostCategory.event,
    ),
    Post(
      id: 'p4',
      authorId: 's2',
      authorName: 'Ahmed Ali',
      authorRole: 'Student',
      authorColor: '#8A4A52',
      content:
          'Coding Club is hosting a beginner-friendly Flutter workshop this Saturday. Laptops required, '
          'snacks provided!',
      date: _ago(days: 1),
      likes: 37,
      shares: 4,
      category: PostCategory.club,
      comments: [
        Comment(
          id: 'cm2',
          authorName: 'Fatima Malik',
          authorColor: '#8A4A52',
          body: 'Can EE students join?',
          date: _ago(hours: 20),
        ),
        Comment(
          id: 'cm3',
          authorName: 'Ahmed Ali',
          authorColor: '#8A4A52',
          body: 'Of course, everyone welcome.',
          date: _ago(hours: 19),
        ),
      ],
    ),
    Post(
      id: 'p5',
      authorId: 'f1',
      authorName: 'Dr. Sarah Khan',
      authorRole: 'Faculty',
      authorColor: '#B5A57C',
      content: 'Reminder for CS-301: the midterm covers weeks 1–6. Practice problems are in the Materials tab.',
      date: _ago(days: 1, hours: 3),
      likes: 61,
      shares: 7,
      category: PostCategory.academic,
    ),
  ];

  // ------------------------------------------------------- Connections --
  /// userId → ids of people they are connected with.
  static final Map<String, Set<String>> connections = _connections();
  static Map<String, Set<String>> _connections() => {
    's1': {'s4', 's5', 'f1'},
    's4': {'s1'},
    's5': {'s1'},
    'f1': {'s1'},
  };

  /// userId → ids of people who sent them a pending connection request.
  static final Map<String, Set<String>> connectionRequests = _connectionRequests();
  static Map<String, Set<String>> _connectionRequests() => {
    's1': {'s7'},
  };

  static const List<StudyGroup> studyGroups = [
    StudyGroup(
      id: 'g1',
      name: 'Study Group · CS-301',
      courseId: 'c1',
      memberIds: ['s1', 's2', 's4', 's5'],
      description: 'Weekly problem-solving sessions for Data Structures.',
      meeting: 'Thursdays, 4:00 PM · Library 2nd floor',
    ),
  ];

  // ------------------------------------------------------- Conversations --
  static final List<Conversation> conversations = _conversations();
  static List<Conversation> _conversations() => [
    Conversation(
      id: 'cv1',
      peerId: 's4',
      peerName: 'Rania Tahir',
      peerRole: 'Student',
      peerColor: '#8A4A52',
      lastMessage: 'Thanks for the notes! Really saved me',
      lastTime: _ago(minutes: 2),
      unread: 3,
      ownerId: 's1',
    ),
    Conversation(
      id: 'cv2',
      peerId: 'g1',
      peerName: 'Study Group · CS-301',
      peerRole: 'Group',
      peerColor: '#8A4A52',
      lastMessage: 'Ahmed: Meeting at the library at 4pm?',
      lastTime: _ago(minutes: 15),
      unread: 1,
      groupId: 'g1',
      ownerId: 's1',
    ),
    Conversation(
      id: 'cv3',
      peerId: 'f1',
      peerName: 'Dr. Sarah Khan',
      peerRole: 'Faculty',
      peerColor: '#2E2729',
      lastMessage: 'Office hours reminder for this week',
      lastTime: _ago(hours: 1),
      ownerId: 's1',
    ),
    Conversation(
      id: 'cv4',
      peerId: 's1',
      peerName: 'Zara Ahmed',
      peerRole: 'Student',
      peerColor: '#8A4A52',
      lastMessage: 'You: Office hours reminder for this week',
      lastTime: _ago(hours: 1),
      ownerId: 'f1',
    ),
  ];

  static final Map<String, List<ChatMessage>> messages = _messages();
  static Map<String, List<ChatMessage>> _messages() => {
    'cv1': [
      ChatMessage(
        id: 'ms1',
        senderId: 's4',
        text: 'Hey! Do you have the hash tables notes?',
        time: _ago(days: 1, hours: 2),
        fromMe: false,
      ),
      ChatMessage(
        id: 'ms2',
        senderId: 's1',
        text: 'Yes, sharing them now 📎',
        time: _ago(days: 1, hours: 1),
        fromMe: true,
      ),
      ChatMessage(id: 'ms3', senderId: 's4', text: 'You are the best', time: _ago(minutes: 4), fromMe: false),
      ChatMessage(
        id: 'ms4',
        senderId: 's4',
        text: 'Thanks for the notes! Really saved me',
        time: _ago(minutes: 2),
        fromMe: false,
      ),
    ],
    'cv2': [
      ChatMessage(
        id: 'ms5',
        senderId: 's5',
        text: 'Hassan: Who is solving Q3 of the practice set?',
        time: _ago(hours: 3),
        fromMe: false,
      ),
      ChatMessage(id: 'ms6', senderId: 's1', text: 'I can take Q3 and Q4.', time: _ago(hours: 2), fromMe: true),
      ChatMessage(
        id: 'ms7',
        senderId: 's2',
        text: 'Ahmed: Meeting at the library at 4pm?',
        time: _ago(minutes: 15),
        fromMe: false,
      ),
    ],
    'cv4': [
      ChatMessage(
        id: 'ms9',
        senderId: 'f1',
        text: 'Office hours reminder for this week: Tue & Thu, 2–4 PM.',
        time: _ago(hours: 1),
        fromMe: true,
      ),
    ],
    'cv3': [
      ChatMessage(
        id: 'ms8',
        senderId: 'f1',
        text: 'Office hours reminder for this week: Tue & Thu, 2–4 PM.',
        time: _ago(hours: 1),
        fromMe: false,
      ),
    ],
  };

  static final List<ChatRequest> chatRequests = _chatRequests();
  static List<ChatRequest> _chatRequests() => [
    ChatRequest(
      id: 'cr1',
      studentId: 's2',
      studentName: 'Ahmed Ali',
      studentColor: '#8A4A52',
      courseCode: 'CS-301',
      message: 'Could we discuss my Lab 3 approach before the deadline?',
      date: _ago(hours: 4),
    ),
    ChatRequest(
      id: 'cr2',
      studentId: 's5',
      studentName: 'Hassan Khalid',
      studentColor: '#8A4A52',
      courseCode: 'CS-305',
      message: 'I would like feedback on my ER diagram draft.',
      date: _ago(days: 1),
    ),
  ];

  // ------------------------------------------------- Enrollment requests --
  static final List<EnrollmentRequest> enrollmentRequests = _enrollmentRequests();
  static List<EnrollmentRequest> _enrollmentRequests() => [
    EnrollmentRequest(
      id: 'er1',
      studentId: 's6',
      courseId: 'c1',
      gpa: 3.5,
      message: 'I missed the regular enrollment window due to medical leave. Please consider my application.',
    ),
    EnrollmentRequest(
      id: 'er2',
      studentId: 's7',
      courseId: 'c1',
      gpa: 3.2,
      message: 'Interested in auditing for advanced study. Already covered the prerequisites independently.',
    ),
    EnrollmentRequest(
      id: 'er3',
      studentId: 's3',
      courseId: 'c2',
      gpa: 3.8,
      message: 'Requesting to take Database Systems as a cross-department elective.',
    ),
  ];

  // ------------------------------------------------------- Notifications --
  static final List<AppNotification> notifications = _notifications();
  static List<AppNotification> _notifications() => [
    AppNotification(
      recipientId: 's1',
      id: 'n1',
      type: NotificationType.assignment,
      title: 'Assignment due tomorrow',
      body: 'Lab 3 — BST Operations (CS-301) is due tomorrow at 11:59 PM.',
      date: _ago(minutes: 30),
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n2',
      type: NotificationType.attendance,
      title: 'Attendance below 75%',
      body: 'Your Operating Systems attendance is 72.7%. Attend the next classes to recover.',
      date: _ago(hours: 1),
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n3',
      type: NotificationType.exam,
      title: 'Midterm in 3 days',
      body: 'Data Structures Mid · Hall B · Seat 42.',
      date: _ago(hours: 3),
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n4',
      type: NotificationType.announcement,
      title: 'New announcement in CS-301',
      body: 'Midterm seating plan published.',
      date: _ago(hours: 5),
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n5',
      type: NotificationType.message,
      title: 'New message',
      body: 'Rania Tahir: "Thanks for the notes! Really saved me"',
      date: _ago(minutes: 2),
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n6',
      type: NotificationType.university,
      title: 'Career Fair on Friday',
      body: 'Main Auditorium, 10 AM – 4 PM.',
      date: _ago(hours: 8),
      read: true,
    ),
    AppNotification(
      recipientId: 's1',
      id: 'n7',
      type: NotificationType.faculty,
      title: 'New material uploaded',
      body: 'Dr. Sarah Khan added "Recorded Lecture — BFS & DFS".',
      date: _ago(days: 6),
      read: true,
    ),
  ];

  // -------------------------------------------------------- Lost & Found --
  static const List<String> lostFoundCategories = ['Electronics', 'Accessories', 'Books', 'ID Cards', 'Other'];

  static final List<LostFoundItem> lostFound = _lostFound();
  static List<LostFoundItem> _lostFound() => [
    LostFoundItem(
      id: 'lf1',
      type: LostFoundType.lost,
      title: 'HP Laptop Bag',
      description: 'Black HP laptop bag with a charger inside. Left near the CS Block stairs.',
      location: 'CS Block',
      reporterName: 'Ahmed Ali',
      reporterColor: '#8A4A52',
      category: 'Accessories',
      date: _ago(days: 1),
      emoji: '💼',
    ),
    LostFoundItem(
      id: 'lf2',
      type: LostFoundType.found,
      title: 'Samsung Earpods',
      description: 'White Samsung earbuds case found on a cafeteria table.',
      location: 'Cafeteria',
      reporterName: 'Fatima Malik',
      reporterColor: '#8A4A52',
      category: 'Electronics',
      date: _ago(hours: 6),
      emoji: '🎧',
      contactPreference: 'Campus security desk',
    ),
    LostFoundItem(
      id: 'lf3',
      type: LostFoundType.lost,
      title: 'DBMS Textbook',
      description: 'Database System Concepts (7th ed.), name written inside the cover.',
      location: 'Library',
      reporterName: 'Hassan Khalid',
      reporterColor: '#8A4A52',
      category: 'Books',
      date: _ago(days: 2),
      emoji: '📘',
    ),
    LostFoundItem(
      id: 'lf4',
      type: LostFoundType.found,
      title: 'ID Card Wallet',
      description: 'Brown wallet with a student ID card. Returned to the owner.',
      location: 'Admin Block',
      reporterName: 'Campus Security',
      reporterColor: '#2E2729',
      category: 'ID Cards',
      date: _ago(days: 3),
      emoji: '🪪',
      status: LostFoundStatus.resolved,
      contactPreference: 'Campus security desk',
    ),
  ];

  // ---------------------------------------------------------- Semesters --
  static final List<Semester> semesters = _semesters();
  static List<Semester> _semesters() => [
    Semester(id: 'sem1', name: 'Fall 2026', startDate: '2026-08-24', endDate: '2026-12-18', isActive: true),
    Semester(id: 'sem2', name: 'Spring 2026', startDate: '2026-01-12', endDate: '2026-05-22'),
    Semester(id: 'sem3', name: 'Fall 2025', startDate: '2025-08-25', endDate: '2025-12-19'),
  ];

  // ------------------------------------------------------------- Profile --
  static const List<AchievementBadge> badges = [
    AchievementBadge(title: 'Merit Scholar', subtitle: 'Fall 2025', icon: 'trophy', tone: 'amber'),
    AchievementBadge(title: 'Code Sprint Winner', subtitle: 'Apr 2026', icon: 'bolt', tone: 'wine'),
    AchievementBadge(title: '100% Attendance', subtitle: 'Sem 3', icon: 'check', tone: 'ink'),
    AchievementBadge(title: "Dean's List", subtitle: 'Spring 2026', icon: 'star', tone: 'sand'),
    AchievementBadge(title: 'Hackathon Finalist', subtitle: 'Feb 2026', icon: 'code', tone: 'wine'),
  ];

  static const List<Map<String, String>> portfolio = [
    {'title': 'Campus Navigator App', 'detail': 'Flutter · indoor maps for new students'},
    {'title': 'Library Seat Tracker', 'detail': 'Firebase · real-time seat availability (course project)'},
  ];

  // ---------------------------------------------------------------- Help --
  static const List<FaqItem> faqs = [
    FaqItem(
      'How is my attendance percentage calculated?',
      'Attended classes ÷ total classes held × 100. The 75% minimum is the university requirement; the '
          'Performance screen shows how many classes you can still miss or need to attend.',
    ),
    FaqItem(
      'Are Uni-AI answers official course material?',
      'No. In this demo build Uni-AI uses a small built-in response engine. Always verify answers with your '
          'lecture notes and instructor.',
    ),
    FaqItem(
      'Why can\'t I download some materials?',
      'Demo materials have no real files attached. Use Quick Preview to read the summary instead.',
    ),
    FaqItem(
      'How do I report a lost item?',
      'Open Lost & Found and tap Report Item. Your contact details are never shown publicly.',
    ),
    FaqItem(
      'Can I undo a submitted assignment?',
      'You can resubmit until the deadline. After the deadline, contact your instructor.',
    ),
  ];

  // ------------------------------------------------------ Admin activity --
  static final List<AuditEntry> auditLog = _auditLog();
  static List<AuditEntry> _auditLog() => [
    AuditEntry(
      action: 'Student enrolled',
      detail: 'Rania Tahir · CS-21-0089 → CS-301',
      actor: 'Nadia Karim',
      time: _ago(hours: 2),
    ),
    AuditEntry(
      action: 'Course created',
      detail: 'CS-341 Mobile Application Development',
      actor: 'Nadia Karim',
      time: _ago(hours: 5),
    ),
    AuditEntry(
      action: 'Faculty assigned',
      detail: 'Dr. Aisha Raza → CS-341',
      actor: 'Hassan Malik',
      time: _ago(days: 1),
    ),
    AuditEntry(
      action: 'Semester activated',
      detail: 'Fall 2026 set as active',
      actor: 'Nadia Karim',
      time: _ago(days: 2),
    ),
  ];

  /// Records an admin action in the audit log (newest first).
  static void logAction(String action, String detail, {String actor = 'Nadia Karim'}) {
    auditLog.insert(0, AuditEntry(action: action, detail: detail, actor: actor, time: DateTime.now()));
  }

  /// Short "time ago" summaries of the newest audit entries (dashboard card).
  static List<Map<String, String>> get recentActivity => [
    for (final e in auditLog.take(4)) {'title': e.action, 'detail': e.detail, 'time': _timeAgo(e.time)},
  ];

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
