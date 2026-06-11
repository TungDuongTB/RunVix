import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class GroupImageSelectors extends StatefulWidget {
  final XFile? coverImage;
  final XFile? logoImage;
  final String? initialCoverUrl;
  final String? initialLogoUrl;
  final VoidCallback onPickCover;
  final VoidCallback onPickLogo;

  const GroupImageSelectors({
    super.key,
    required this.coverImage,
    required this.logoImage,
    this.initialCoverUrl,
    this.initialLogoUrl,
    required this.onPickCover,
    required this.onPickLogo,
  });

  @override
  State<GroupImageSelectors> createState() => _GroupImageSelectorsState();
}

class _GroupImageSelectorsState extends State<GroupImageSelectors> {
  // Cache bytes để tránh đọc lại mỗi lần rebuild
  ImageProvider? _coverProvider;
  ImageProvider? _logoProvider;
  String? _lastCoverPath;
  String? _lastLogoPath;

  @override
  void didUpdateWidget(GroupImageSelectors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coverImage?.path != _lastCoverPath) {
      _coverProvider = null;
      _lastCoverPath = widget.coverImage?.path;
      if (widget.coverImage != null) _loadCover();
    }
    if (widget.logoImage?.path != _lastLogoPath) {
      _logoProvider = null;
      _lastLogoPath = widget.logoImage?.path;
      if (widget.logoImage != null) _loadLogo();
    }
  }

  Future<void> _loadCover() async {
    if (widget.coverImage == null) return;
    if (kIsWeb) {
      final bytes = await widget.coverImage!.readAsBytes();
      if (mounted) {
        setState(() => _coverProvider = MemoryImage(bytes));
      }
    } else {
      // ignore: avoid_slow_async_io
      final bytes = await widget.coverImage!.readAsBytes();
      if (mounted) {
        setState(() => _coverProvider = MemoryImage(bytes));
      }
    }
  }

  Future<void> _loadLogo() async {
    if (widget.logoImage == null) return;
    final bytes = await widget.logoImage!.readAsBytes();
    if (mounted) {
      setState(() => _logoProvider = MemoryImage(bytes));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.coverImage != null) {
      _lastCoverPath = widget.coverImage!.path;
      _loadCover();
    }
    if (widget.logoImage != null) {
      _lastLogoPath = widget.logoImage!.path;
      _loadLogo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover Photo Picker
        GestureDetector(
          onTap: widget.onPickCover,
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
              image: _coverProvider != null
                  ? DecorationImage(
                      image: _coverProvider!,
                      fit: BoxFit.cover,
                    )
                  : (widget.coverImage == null && widget.initialCoverUrl != null && widget.initialCoverUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(widget.initialCoverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: widget.coverImage == null && (widget.initialCoverUrl == null || widget.initialCoverUrl!.isEmpty)
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
                : _coverProvider == null
                    // Đang tải bytes
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
            onTap: widget.onPickLogo,
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
                image: _logoProvider != null
                    ? DecorationImage(
                        image: _logoProvider!,
                        fit: BoxFit.cover,
                      )
                    : (widget.logoImage == null && widget.initialLogoUrl != null && widget.initialLogoUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(widget.initialLogoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: widget.logoImage == null && (widget.initialLogoUrl == null || widget.initialLogoUrl!.isEmpty)
                  ? Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 24)
                  : _logoProvider == null
                      // Đang tải bytes
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
