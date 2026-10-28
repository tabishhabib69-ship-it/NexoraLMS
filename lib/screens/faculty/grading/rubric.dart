// ===== FILE GUIDE: lib/screens/faculty/grading/rubric.dart
// WHAT IT DOES : The grading rubric (criteria and their share of marks).
// MANAGES      : Code Correctness 40%, Documentation 30%, Efficiency 30%.
// USED BY      : Grading queue and Content Studio.
// ======================================================================

/// Grading rubric shared by the Content Studio card and the grading sheet.
/// Each criterion is a share of the assignment's total marks.
const List<(String, double)> gradingRubric = [('Code Correctness', 0.4), ('Documentation', 0.3), ('Efficiency', 0.3)];
