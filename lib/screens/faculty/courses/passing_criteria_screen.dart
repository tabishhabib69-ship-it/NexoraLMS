// ===== FILE GUIDE: lib/screens/faculty/courses/passing_criteria_screen.dart
// WHAT IT DOES : Passing criteria of a course.
// MANAGES      : Minimum attendance, midterm/final/assignment weights and pass mark.
// USED BY      : Faculty course hub.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/section_header.dart';

/// View / set passing criteria for a course.
class PassingCriteriaScreen extends StatefulWidget {
  final String courseId;
  PassingCriteriaScreen({super.key, required this.courseId});

  @override
  State<PassingCriteriaScreen> createState() => _PassingCriteriaScreenState();
}

class _PassingCriteriaScreenState extends State<PassingCriteriaScreen> {
  late PassingCriteria _criteria;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _criteria = DummyData.passingCriteria[widget.courseId] ?? PassingCriteria(courseId: widget.courseId);
  }

  void _save() {
    setState(() {
      DummyData.passingCriteria[widget.courseId] = _criteria;
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passing criteria updated')));
  }

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(widget.courseId);
    final totalWeight = _criteria.midtermWeight + _criteria.finalWeight + _criteria.assignmentWeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Passing Criteria'),
        actions: [
          TextButton(onPressed: () => setState(() => _editing = !_editing), child: Text(_editing ? 'Cancel' : 'Edit')),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          if (course != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Text(course.code, style: TextStyle(fontSize: 12.5, color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 22),
          SectionHeader(title: 'Requirements'),
          _criteriaRow(
            'Minimum Attendance',
            '${_criteria.attendancePercent}%',
            Icons.fact_check_rounded,
            AppColors.success,
            editing: _editing,
            onEdit: () => _editNumber(
              'Minimum Attendance %',
              _criteria.attendancePercent,
              0,
              100,
              (v) => setState(() => _criteria = _criteria.copyWith(attendancePercent: v)),
            ),
          ),
          _criteriaRow(
            'Pass Mark',
            '${_criteria.passMark}%',
            Icons.military_tech_rounded,
            AppColors.primary,
            editing: _editing,
            onEdit: () => _editNumber(
              'Pass Mark %',
              _criteria.passMark,
              0,
              100,
              (v) => setState(() => _criteria = _criteria.copyWith(passMark: v)),
            ),
          ),
          SizedBox(height: 18),
          SectionHeader(title: 'Grade Weighting'),
          _weightSlider(
            'Midterm',
            _criteria.midtermWeight,
            (v) => setState(() => _criteria = _criteria.copyWith(midtermWeight: v)),
          ),
          _weightSlider(
            'Final',
            _criteria.finalWeight,
            (v) => setState(() => _criteria = _criteria.copyWith(finalWeight: v)),
          ),
          _weightSlider(
            'Assignment',
            _criteria.assignmentWeight,
            (v) => setState(() => _criteria = _criteria.copyWith(assignmentWeight: v)),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: totalWeight == 100 ? AppColors.successSoft : AppColors.warningSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  totalWeight == 100 ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  size: 18,
                  color: totalWeight == 100 ? AppColors.success : AppColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  'Total weight: $totalWeight% ${totalWeight == 100 ? '' : '(should equal 100%)'}',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (_editing) ...[
            SizedBox(height: 24),
            AppButton(
              label: 'Save Criteria',
              icon: Icons.save_rounded,
              onPressed: totalWeight == 100
                  ? _save
                  : () =>
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weights must total 100%'))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _criteriaRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    required bool editing,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: editing ? onEdit : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color),
                ),
                if (editing)
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.edit_rounded, size: 17, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weightSlider(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Spacer(),
              Text(
                '$value%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: _editing ? (v) => onChanged(v.round()) : null,
          ),
        ],
      ),
    );
  }

  void _editNumber(String title, int current, int min, int max, ValueChanged<int> onSave) {
    final controller = TextEditingController(text: '$current');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '$min - $max'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v >= min && v <= max) {
                onSave(v);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Enter a value between $min and $max')));
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
