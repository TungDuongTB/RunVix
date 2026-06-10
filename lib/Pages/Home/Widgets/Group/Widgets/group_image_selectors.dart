import 'dart:io';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class GroupImageSelectors extends StatelessWidget {
  final XFile? coverImage;
  final XFile? logoImage;
  final VoidCallback onPickCover;
  final VoidCallback onPickLogo;

  const GroupImageSelectors({
    super.key,
    required this.coverImage,
    required this.logoImage,
    required this.onPickCover,
    required this.onPickLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover Photo Picker
        GestureDetector(
          onTap: onPickCover,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              image: coverImage != null
                  ? DecorationImage(
                      image: FileImage(File(coverImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: coverImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade600, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Tải lên ảnh bìa nhóm',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        radius: 14,
                        child: Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
          ),
        ),

        // Logo Picker
        Positioned(
          left: 20,
          bottom: 10,
          child: GestureDetector(
            onTap: onPickLogo,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.white, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
                image: logoImage != null
                    ? DecorationImage(
                        image: FileImage(File(logoImage!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoImage == null
                  ? Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 24)
                  : const Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: AppColors.buttonColor,
                        radius: 10,
                        child: Icon(Icons.edit, color: Colors.white, size: 10),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
