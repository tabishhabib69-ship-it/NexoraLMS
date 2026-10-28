// ===== FILE GUIDE: lib/services/study_assistant.dart
// WHAT IT DOES : Uni-AI "brain" behind an interface.
// MANAGES      : StudyAssistant interface + DemoStudyAssistant (offline answers, summaries, quizzes, flashcards, study plans). A real AI can replace it later.
// USED BY      : Uni-AI screen.
// ======================================================================

import '../data/dummy_data.dart';
import 'academic_service.dart';

/// Contract for the Uni-AI study companion.
///
/// The app talks to this interface only, so a real AI provider can be added
/// later (implemented server-side — never ship API keys inside the app).
abstract class StudyAssistant {
  /// Whether answers come from a real model. The UI shows a demo notice when false.
  bool get isLive;

  /// Replies with lightweight markup: lines starting with `## ` are headings,
  /// `- ` are bullets, `Q:` / `A:` lines form quiz items; anything else is text.
  Future<String> reply(String prompt, {String? courseId});

  /// Follow-up suggestions shown under an answer.
  List<String> followUps(String prompt);
}

/// Offline demo engine: a small built-in knowledge base plus templates for
/// summaries, quizzes, flashcards and study plans built from the demo data.
class DemoStudyAssistant implements StudyAssistant {
  @override
  bool get isLive => false;

  static const Map<String, String> _topics = {
    'recursion':
        '## Recursion\n'
        'A function that solves a problem by calling itself on a smaller version of the same problem.\n'
        '## Two parts\n'
        '- Base case: the smallest input, answered directly (stops the calls).\n'
        '- Recursive case: reduce the input and call the function again.\n'
        '## Example — factorial\n'
        '- factorial(0) = 1 (base case)\n'
        '- factorial(n) = n × factorial(n − 1)\n'
        '- factorial(4) → 4 × 3 × 2 × 1 × 1 = 24\n'
        '## Watch out\n'
        '- Missing a base case causes a stack overflow.\n'
        '- Each call uses stack memory, so depth matters (O(n) space for factorial).',
    'binary search tree':
        '## Binary Search Tree (BST)\n'
        'A binary tree where every node\'s left subtree holds smaller keys and the right subtree holds larger keys.\n'
        '## Example\n'
        '- Insert 50, 30, 70, 20, 40 → 50 is the root, 30 and 70 its children, 20 and 40 under 30.\n'
        '- In-order traversal gives sorted output: 20, 30, 40, 50, 70.\n'
        '## Complexity\n'
        '- Search / insert / delete: O(h) where h is the height.\n'
        '- Balanced tree: O(log n). Skewed tree (sorted inserts): O(n).\n'
        '## Tip\n'
        '- Self-balancing trees (AVL, Red-Black) keep h close to log n.',
    'normalization':
        '## Normalization\n'
        'Organizing tables to reduce redundancy and update anomalies.\n'
        '## Normal forms\n'
        '- 1NF: every column holds atomic values; no repeating groups.\n'
        '- 2NF: 1NF + no partial dependency on part of a composite key.\n'
        '- 3NF: 2NF + no transitive dependency (non-key → non-key).\n'
        '- BCNF: every determinant is a candidate key.\n'
        '## Example\n'
        '- Orders(order_id, customer_id, customer_city): customer_city depends on customer_id, not the key → move it to a Customers table for 3NF.',
    'deadlock':
        '## Deadlock\n'
        'A set of processes each waiting for a resource held by another, so none can proceed.\n'
        '## Four necessary conditions\n'
        '- Mutual exclusion\n- Hold and wait\n- No preemption\n- Circular wait\n'
        '## Handling\n'
        '- Prevention: break one condition (e.g. order resource requests).\n'
        '- Avoidance: Banker\'s algorithm keeps the system in a safe state.\n'
        '- Detection & recovery: find cycles, then kill or roll back a process.',
    'tcp':
        '## TCP vs UDP\n'
        '- TCP: connection-oriented, reliable, ordered; three-way handshake (SYN, SYN-ACK, ACK); flow and congestion control.\n'
        '- UDP: connectionless, no delivery guarantee, low overhead.\n'
        '## When to use\n'
        '- TCP: web pages, email, file transfer.\n'
        '- UDP: live video, gaming, DNS lookups.',
    'big o':
        '## Big-O Notation\n'
        'Describes how running time or memory grows as the input size n grows (worst case, ignoring constants).\n'
        '## Common classes\n'
        '- O(1) constant: array index\n- O(log n): binary search\n- O(n): linear scan\n'
        '- O(n log n): merge sort\n- O(n²): nested loops / bubble sort',
    'hash':
        '## Hash Tables\n'
        'Store key–value pairs in buckets chosen by a hash function.\n'
        '## Collisions\n'
        '- Chaining: each bucket keeps a list.\n- Open addressing: probe for the next free slot.\n'
        '## Performance\n'
        '- Average O(1) insert/search/delete while the load factor stays low (≈ 0.75).',
  };

  static const Map<String, String> _aliases = {
    'bst': 'binary search tree',
    'binary tree': 'binary search tree',
    'recursive': 'recursion',
    'normal form': 'normalization',
    '3nf': 'normalization',
    'udp': 'tcp',
    'complexity': 'big o',
    'hashing': 'hash',
    'hash table': 'hash',
  };

  String? _topicFor(String prompt) {
    final p = prompt.toLowerCase();
    for (final key in _topics.keys) {
      if (p.contains(key)) return key;
    }
    for (final entry in _aliases.entries) {
      if (p.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Future<String> reply(String prompt, {String? courseId}) async {
    await Future.delayed(const Duration(milliseconds: 900)); // simulated thinking time
    final p = prompt.toLowerCase();
    final course = courseId == null ? null : DummyData.courseById(courseId);

    if (p.contains('summar')) return _summary(courseId);
    if (p.contains('mcq') || p.contains('quiz')) return _quiz(_topicFor(p) ?? 'binary search tree');
    if (p.contains('flashcard')) return _flashcards(_topicFor(p) ?? 'recursion');
    if (p.contains('plan')) return _studyPlan();

    final topic = _topicFor(p);
    if (topic != null) return _topics[topic]!;

    return '## I can help with that in the full version\n'
        'This demo build answers a fixed set of topics${course == null ? '' : ' and your ${course.code} materials'}.\n'
        '## Try asking about\n'
        '- Recursion, BSTs, hash tables or Big-O\n'
        '- Normalization, deadlocks or TCP vs UDP\n'
        '- "Summarize lecture", "Create MCQs", "Make study plan" or "Flashcards"';
  }

  String _summary(String? courseId) {
    final id = courseId ?? 'c1';
    final mats = DummyData.materials.where((m) => m.courseId == id && m.summary.isNotEmpty).toList();
    final course = DummyData.courseById(id);
    if (mats.isEmpty) {
      return '## No materials to summarize\nThere are no uploaded materials for ${course?.code ?? 'this course'} yet.';
    }
    final b = StringBuffer('## Summary — ${course?.code} ${course?.title}\n');
    for (final m in mats) {
      b.writeln('## ${m.title}');
      for (final sentence in m.summary.split('. ').where((s) => s.trim().isNotEmpty).take(3)) {
        b.writeln('- ${sentence.trim().replaceAll(RegExp(r'\.$'), '')}.');
      }
    }
    b.write('## Next step\n- Ask "Create MCQs" to test yourself on this content.');
    return b.toString();
  }

  String _quiz(String topic) {
    const banks = {
      'binary search tree': [
        ['In-order traversal of a BST returns keys in…', 'Sorted (ascending) order'],
        ['Worst-case search time in a skewed BST?', 'O(n)'],
        ['Where is the smallest key in a BST?', 'The left-most node'],
      ],
      'recursion': [
        ['What stops a recursive function from running forever?', 'The base case'],
        ['Space used by recursive factorial(n)?', 'O(n) stack frames'],
        ['factorial(3) = ?', '6'],
      ],
      'normalization': [
        ['Which normal form removes transitive dependencies?', '3NF'],
        ['1NF requires values to be…', 'Atomic'],
        ['BCNF: every determinant must be a…', 'Candidate key'],
      ],
    };
    final bank = banks[topic] ?? banks['binary search tree']!;
    final b = StringBuffer('## Quick quiz — ${_title(topic)}\nTap each question to reveal the answer.\n');
    for (final qa in bank) {
      b.writeln('Q: ${qa[0]}');
      b.writeln('A: ${qa[1]}');
    }
    return b.toString().trimRight();
  }

  String _flashcards(String topic) {
    final body = _topics[topic] ?? _topics['recursion']!;
    final bullets = body.split('\n').where((l) => l.startsWith('- ')).take(4).toList();
    final b = StringBuffer('## Flashcards — ${_title(topic)}\n');
    for (var i = 0; i < bullets.length; i++) {
      final text = bullets[i].substring(2);
      final split = text.indexOf(':');
      if (split > 0) {
        b.writeln('Q: ${text.substring(0, split).trim()}?');
        b.writeln('A: ${text.substring(split + 1).trim()}');
      } else {
        b.writeln('Q: Card ${i + 1}');
        b.writeln('A: $text');
      }
    }
    return b.toString().trimRight();
  }

  String _studyPlan() {
    final exams = AcademicService.upcomingExams.take(3).toList();
    if (exams.isEmpty) return '## No upcoming exams\nYou have no exams scheduled — a great time to review weak topics.';
    final b = StringBuffer('## Study plan for your next exams\n');
    for (final e in exams) {
      final c = DummyData.courseById(e.courseId);
      final days = e.date.difference(DateTime.now()).inDays;
      final topics = DummyData.syllabus[e.courseId] ?? const [];
      b.writeln('## ${e.title} — in ${days <= 0 ? 'under a day' : '$days day${days == 1 ? '' : 's'}'}');
      final perDay = topics.isEmpty ? 0 : (topics.length / (days < 1 ? 1 : days)).ceil();
      if (topics.isEmpty) {
        b.writeln('- Review ${c?.title ?? 'course'} notes daily.');
      } else {
        for (var d = 0; d < (days < 1 ? 1 : days) && d * perDay < topics.length && d < 5; d++) {
          final chunk = topics.skip(d * perDay).take(perDay).join(', ');
          b.writeln('- Day ${d + 1}: $chunk');
        }
      }
    }
    b.write('## Tip\n- Use the Exam Planner to save this plan as a checklist.');
    return b.toString();
  }

  String _title(String topic) => topic.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  @override
  List<String> followUps(String prompt) {
    final topic = _topicFor(prompt);
    if (topic != null) {
      return ['Create MCQs on ${_title(topic)}', 'Flashcards for ${_title(topic)}', 'Make study plan'];
    }
    return ['Explain recursion', 'Summarize lecture', 'Create MCQs'];
  }
}
