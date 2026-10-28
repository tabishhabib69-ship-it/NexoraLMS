// ===== FILE GUIDE: lib/widgets/image_picker_field.dart
// WHAT IT DOES : Pick-a-photo field.
// MANAGES      : Opens the gallery and shows a preview.
// USED BY      : Create post, report lost/found item.
// ======================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';

/// A reusable "pick an image from disk / gallery" field.
///
/// Shows a placeholder tap target when empty, or a preview with change/remove
/// controls once an image is selected. The picked bytes are reported through
/// [onChanged] (null when the image is removed) so the parent can attach them
/// to whatever it is creating.
class ImagePickerField extends StatefulWidget {
  final ValueChanged<Uint8List?> onChanged;
  final double height;
  final String label;

  ImagePickerField({super.key, required this.onChanged, this.height = 200, this.label = 'Add Photo'});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final _picker = ImagePicker();
  Uint8List? _bytes;
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _bytes = bytes);
      widget.onChanged(bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open the image picker on this device.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _remove() {
    setState(() => _bytes = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return _placeholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.memory(bytes, width: double.infinity, height: widget.height, fit: BoxFit.cover, gaplessPlayback: true),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _circleButton(Icons.swap_horiz_rounded, _pick),
                SizedBox(width: 8),
                _circleButton(Icons.close_rounded, _remove),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return InkWell(
      onTap: _busy ? null : _pick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: _busy
            ? CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pick an image from your device / desktop',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(7),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
