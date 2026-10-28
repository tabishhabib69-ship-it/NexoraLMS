// ===== FILE GUIDE: lib/screens/faculty/materials/upload_material_screen.dart
// WHAT IT DOES : Old upload form (only used by the old faculty_materials_screen).
// STATUS       : NOT USED anymore — replaced by the material form inside content_studio_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// Upload a new material or edit an existing one. Returns the material.
class UploadMaterialScreen extends StatefulWidget {
  final LearningMaterial? existing;
  UploadMaterialScreen({super.key, this.existing});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _size = TextEditingController(text: widget.existing?.size ?? '');

  late String _courseId = widget.existing?.courseId ?? DummyData.facultyCourseIds.first;
  late LearningMaterialType _type = widget.existing?.type ?? LearningMaterialType.pdf;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _size.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final material = LearningMaterial(
      id: widget.existing?.id ?? 'm${DateTime.now().microsecondsSinceEpoch}',
      courseId: _courseId,
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      size: _size.text.trim().isEmpty ? '—' : _size.text.trim(),
      date: widget.existing?.date ?? DateTime.now(),
      downloads: widget.existing?.downloads ?? 0,
    );
    Navigator.pop(context, material);
  }

  @override
  Widget build(BuildContext context) {
    final myCourses = DummyData.courses.where((c) => DummyData.facultyCourseIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Material' : 'Upload Material')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(18),
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.lavenderSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 42, color: AppColors.lavender),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('File picker is a UI placeholder'))),
                    child: Text('Choose file (placeholder)'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AppTextField(
              label: 'Title',
              hint: 'e.g. Lecture 06 — Graph Algorithms',
              icon: Icons.title_rounded,
              controller: _title,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              hint: 'Short summary of this material',
              controller: _description,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
            ),
            SizedBox(height: 16),
            Text(
              'Course',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              decoration: InputDecoration(prefixIcon: Icon(Icons.class_rounded, size: 20)),
              items: myCourses
                  .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.code} · ${c.title}')))
                  .toList(),
              onChanged: _isEdit ? null : (v) => setState(() => _courseId = v ?? _courseId),
            ),
            SizedBox(height: 16),
            Text(
              'Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<LearningMaterialType>(
              initialValue: _type,
              decoration: InputDecoration(prefixIcon: Icon(Icons.category_rounded, size: 20)),
              items: LearningMaterialType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Size (optional)',
              hint: 'e.g. 2.4 MB',
              icon: Icons.sd_storage_rounded,
              controller: _size,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 26),
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Upload Material',
              icon: _isEdit ? Icons.save_rounded : Icons.upload_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
