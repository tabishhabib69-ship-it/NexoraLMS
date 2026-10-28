// ===== FILE GUIDE: lib/screens/admin/semesters/semester_management_screen.dart
// WHAT IT DOES : Semester management.
// MANAGES      : Add, edit and set the active semester.
// USED BY      : Admin dashboard, admin settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/semester.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/section_header.dart';

/// Admin semester management: add, edit, view and set the active semester.
class SemesterManagementScreen extends StatefulWidget {
  SemesterManagementScreen({super.key});

  @override
  State<SemesterManagementScreen> createState() => _SemesterManagementScreenState();
}

class _SemesterManagementScreenState extends State<SemesterManagementScreen> {
  void _setActive(Semester s) {
    setState(() {
      for (final sem in DummyData.semesters) {
        sem.isActive = sem.id == s.id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.name} is now the active semester')));
  }

  void _addOrEdit({Semester? existing}) async {
    final result = await showModalBottomSheet<Semester>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SemesterForm(existing: existing),
    );
    if (result != null) {
      setState(() {
        if (existing == null) {
          DummyData.semesters.insert(0, result);
        } else {
          final index = DummyData.semesters.indexWhere((s) => s.id == existing.id);
          if (index != -1) {
            result.isActive = DummyData.semesters[index].isActive;
            DummyData.semesters[index] = result;
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(existing == null ? 'Semester added' : 'Semester updated')));
      }
    }
  }

  void _delete(Semester s) {
    if (s.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot delete the active semester')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete semester?'),
        content: Text('${s.name} will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() => DummyData.semesters.removeWhere((x) => x.id == s.id));
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Semester Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: Icon(Icons.add_rounded),
        label: Text('Add Semester'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18, 8, 18, 90),
        children: [
          SectionHeader(title: 'All Semesters'),
          ...DummyData.semesters.map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: s.isActive ? AppColors.success : AppColors.border,
                    width: s.isActive ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (s.isActive ? AppColors.success : AppColors.primary).withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: s.isActive ? AppColors.success : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      s.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (s.isActive) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.successSoft,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 3),
                              Text(
                                '${s.startDate}  →  ${s.endDate}',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                          onSelected: (v) {
                            if (v == 'edit') _addOrEdit(existing: s);
                            if (v == 'activate') _setActive(s);
                            if (v == 'delete') _delete(s);
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            if (!s.isActive) PopupMenuItem(value: 'activate', child: Text('Set active')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    if (!s.isActive) ...[
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(minimumSize: Size.fromHeight(42)),
                          onPressed: () => _setActive(s),
                          icon: Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text('Set as active semester'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterForm extends StatefulWidget {
  final Semester? existing;
  _SemesterForm({this.existing});

  @override
  State<_SemesterForm> createState() => _SemesterFormState();
}

class _SemesterFormState extends State<_SemesterForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _start = TextEditingController(text: widget.existing?.startDate ?? '');
  late final _end = TextEditingController(text: widget.existing?.endDate ?? '');

  @override
  void dispose() {
    _name.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final semester = Semester(
      id: widget.existing?.id ?? 'sem${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      startDate: _start.text.trim(),
      endDate: _end.text.trim(),
    );
    Navigator.pop(context, semester);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            SizedBox(height: 18),
            Text(
              widget.existing == null ? 'Add Semester' : 'Edit Semester',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 18),
            AppTextField(
              label: 'Name',
              hint: 'e.g. Spring 2026',
              icon: Icons.label_outline_rounded,
              controller: _name,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Start date',
              hint: 'YYYY-MM-DD',
              icon: Icons.event_rounded,
              controller: _start,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Start date is required' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'End date',
              hint: 'YYYY-MM-DD',
              icon: Icons.event_available_rounded,
              controller: _end,
              textInputAction: TextInputAction.done,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'End date is required' : null,
            ),
            SizedBox(height: 22),
            AppButton(label: 'Save', icon: Icons.save_rounded, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
