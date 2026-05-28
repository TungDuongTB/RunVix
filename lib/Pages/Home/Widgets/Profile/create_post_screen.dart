import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:runvix/export.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final controller = Get.put(PostController());
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: _imageFile != null ? Colors.white : Colors.lightBlue,
                  size: 28,
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: _imageFile != null ? Colors.white : Colors.lightBlue,
                    size: 28,
                  ),
                  onSelected: (value) {
                    if (value == 'change_image') {
                      _pickImage();
                    } else if (value == 'remove_image') {
                      setState(() {
                        _imageFile = null;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'change_image',
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined, color: Colors.blue[700]),
                          const SizedBox(width: 10),
                          Text(_imageFile == null ? 'Chọn ảnh khác' : 'Thay đổi ảnh'),
                        ],
                      ),
                    ),
                    if (_imageFile != null)
                      const PopupMenuItem(
                        value: 'remove_image',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: Stack(
              children: [
                _buildBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const Spacer(),
                      if (_imageFile == null)
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      _buildInputCard(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        image: _imageFile != null
            ? DecorationImage(
                image: kIsWeb 
                    ? NetworkImage(_imageFile!.path) 
                    : FileImage(File(_imageFile!.path)) as ImageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _imageFile != null
                ? [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ]
                : [
                    Colors.white,
                    Colors.lightBlueAccent,
                    Colors.lightBlue.withOpacity(0.7),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          'RUNVIX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 25, 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Hôm nay của bạn thế nào?',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.content,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                      decoration: const InputDecoration(
                        hintText: 'Hãy viết những gì bạn muốn chia sẻ về cuộc sống này...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -35,
          child: GestureDetector(
            onTap: () => controller.createPost(_imageFile),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: AppColors.buttonColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}
