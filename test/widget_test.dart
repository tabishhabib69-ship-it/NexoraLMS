// ===== FILE GUIDE: test/widget_test.dart
// WHAT IT DOES : Automated tests (run with: flutter test).
// MANAGES      : App start flow, attendance maths, timetable clashes, grades/CGPA, demo AI, admin login, demo reset.
// USED BY      : flutter test.
// ======================================================================

import 'package:campus_connect/data/dummy_data.dart';
import 'package:campus_connect/main.dart';
import 'package:campus_connect/models/attendance.dart';
import 'package:campus_connect/services/academic_service.dart';
import 'package:campus_connect/services/app_settings.dart';
import 'package:campus_connect/services/attendance_service.dart';
import 'package:campus_connect/services/schedule_service.dart';
import 'package:campus_connect/models/user.dart';
import 'package:campus_connect/services/my_data.dart';
import 'package:campus_connect/services/session_service.dart';
import 'package:campus_connect/services/study_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash → onboarding → sign-in hub', (tester) async {
    AppSettings.onboardingSeen = false;
    await tester.pumpWidget(UniSphereApp());

    expect(find.text('Uni-Sphere'), findsOneWidget);
    expect(find.text('YOUR CAMPUS, REIMAGINED'), findsOneWidget);

    await tester.pump(Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Your whole campus in one place'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsWidgets); // tab + "Don't have an account?" link
    expect(find.text('Google'), findsNothing); // SSO buttons removed
    // Admin is never offered as a selectable role.
    expect(find.text('Admin'), findsNothing);
  });

  group('AttendanceService', () {
    test('percentage and recovery maths', () {
      final s = AttendanceService.summarize(
        AttendanceRecord(studentId: 's', courseId: 'c', totalClasses: 22, attended: 16),
      );
      expect(s.percentage, closeTo(72.7, 0.1));
      expect(s.status, AttendanceStatus.critical);
      // (16 + 2) / (22 + 2) = 75%
      expect(s.neededToReach, 2);
    });

    test('allowed absences while staying at 75%', () {
      final s = AttendanceService.summarize(
        AttendanceRecord(studentId: 's', courseId: 'c', totalClasses: 20, attended: 17),
      );
      expect(s.remainingAllowed, 2); // 17 / 22 = 77.3%, 17 / 23 = 73.9%
    });
  });

  group('ScheduleService', () {
    test('parses 12-hour times', () {
      expect(ScheduleService.minutesOf('08:00 AM'), 480);
      expect(ScheduleService.minutesOf('12:30 PM'), 750);
      expect(ScheduleService.minutesOf('01:00 PM'), 780);
      expect(ScheduleService.formatMinutes(780), '01:00 PM');
    });

    test('detects clashes with classes', () {
      // Find a Monday; the demo timetable has CS-301 at 08:00–09:30.
      var day = DateTime(2026, 10, 26);
      while (day.weekday != DateTime.monday) {
        day = day.add(Duration(days: 1));
      }
      expect(ScheduleService.clashFor(day, 8 * 60 + 30, 9 * 60), contains('CS-301'));
      expect(ScheduleService.clashFor(day, 17 * 60, 18 * 60), isNull);
    });
  });

  group('AcademicService', () {
    test('letter grades and CGPA', () {
      expect(AcademicService.letterFor(90), 'A');
      expect(AcademicService.letterFor(80), 'B+');
      expect(AcademicService.letterFor(40), 'F');
      expect(AcademicService.completedCredits, 72);
      expect(AcademicService.cgpa, closeTo(3.51, 0.01));
    });

    test('countdown wording', () {
      expect(AcademicService.countdown(DateTime.now().subtract(Duration(days: 2))), startsWith('Overdue'));
      final tomorrow = DateTime.now().add(Duration(days: 1));
      expect(AcademicService.countdown(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12)), 'Tomorrow');
    });
  });

  group('DemoStudyAssistant', () {
    final ai = DemoStudyAssistant();

    test('is clearly not live', () => expect(ai.isLive, isFalse));

    test('answers known topics and builds quizzes', () async {
      expect(await ai.reply('Explain recursion'), contains('Base case'));
      expect(await ai.reply('Create MCQs on BST'), contains('Q: '));
    });

    test('admits unknown topics instead of inventing answers', () async {
      expect(await ai.reply('history of the roman empire'), contains('demo build'));
    });
  });

  group('Authentication', () {
    tearDown(() {
      SessionService.signOut();
      DummyData.reset();
    });

    test('unknown emails and wrong passwords are rejected', () {
      expect(AuthService.signIn('random.person@riphah.edu.pk', 'whatever1').ok, isFalse);
      expect(AuthService.signIn('zara.ahmed@riphah.edu.pk', 'wrong-password').ok, isFalse);
      expect(SessionService.currentUser, isNull);
    });

    test('registered accounts sign in with their own password and role', () {
      final r = AuthService.signIn(' Zara.Ahmed@riphah.edu.pk ', AuthService.demoPassword);
      expect(r.ok, isTrue);
      expect(r.user!.role, UserRole.student);
      expect(AuthService.signIn('admin@riphah.edu.pk', AuthService.demoAdminPassword).user!.role, UserRole.admin);
    });

    test('sign up registers an account that can then sign in', () {
      final user = AppUser(
        id: 'u-test',
        name: 'Test Student',
        email: 'test.student@riphah.edu.pk',
        phone: '',
        role: UserRole.student,
        avatarColor: '#8A4A52',
      );
      expect(AuthService.register(user, 'Secret@123'), isNull);
      expect(AuthService.register(user, 'Secret@123'), isNotNull); // duplicate email
      expect(AuthService.signIn('test.student@riphah.edu.pk', 'Secret@123').ok, isTrue);
      expect(AuthService.signIn('test.student@riphah.edu.pk', AuthService.demoPassword).ok, isFalse);
    });

    test('suspended accounts cannot sign in', () {
      DummyData.suspendedUserIds.add('s2');
      expect(AuthService.signIn('ahmed.ali@riphah.edu.pk', AuthService.demoPassword).ok, isFalse);
    });

    test('password change requires the current password', () {
      const email = 'zara.ahmed@riphah.edu.pk';
      expect(AuthService.changePassword(email, 'wrong', 'NewPass@1'), isNotNull);
      expect(AuthService.changePassword(email, AuthService.demoPassword, 'NewPass@1'), isNull);
      expect(AuthService.signIn(email, AuthService.demoPassword).ok, isFalse);
      expect(AuthService.signIn(email, 'NewPass@1').ok, isTrue);
    });

    test("users only see their own chats, notifications and records", () {
      AuthService.signIn('ahmed.ali@riphah.edu.pk', AuthService.demoPassword);
      expect(MyData.conversations.where((c) => c.ownerId != 's2'), isEmpty);
      expect(MyData.notifications.any((n) => n.recipientId == 's1'), isFalse);
      expect(MyData.grades, isEmpty); // Zara's grades are not visible
      expect(MyData.courseIds, contains('c1')); // Ahmed is on the CS-301 roster
    });
  });

  group('Demo data', () {
    test('reset restores the original sample data', () {
      final before = DummyData.posts.length;
      DummyData.posts.clear();
      DummyData.suspendedUserIds.add('s2');
      DummyData.reset();
      expect(DummyData.posts.length, before);
      expect(DummyData.suspendedUserIds, isEmpty);
    });
  });
}
