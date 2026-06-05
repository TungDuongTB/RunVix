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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              _PostBackground(imageFile: _imageFile),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const Spacer(),
                    if (_imageFile == null) _buildAddImageButton(),
                    const Spacer(),
                    _PostInputCard(
                      imageFile: _imageFile,
                      titleController: controller.title,
                      contentController: controller.content,
                      onPost: () => controller.createPost(_imageFile),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (controller.isLoading.value) _buildLoadingOverlay(),
      ],
    ));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: _imageFile != null ? Colors.white : Colors.lightBlue, size: 28),
        onPressed: () => Get.back(),
      ),
      actions: [_buildPopupMenu()],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: _imageFile != null ? Colors.white : Colors.lightBlue, size: 28),
      onSelected: (value) {
        if (value == 'change_image') _pickImage();
        else if (value == 'remove_image') setState(() => _imageFile = null);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'change_image', child: _buildPopupItem(Icons.image_outlined, _imageFile == null ? 'Chọn ảnh khác' : 'Thay đổi ảnh', Colors.blue)),
        if (_imageFile != null) PopupMenuItem(value: 'remove_image', child: _buildPopupItem(Icons.delete_outline, 'Xóa ảnh', Colors.red)),
      ],
    );
  }

  Widget _buildPopupItem(IconData icon, String label, Color color) {
    return Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Text(label, style: TextStyle(color: color))]);
  }

  Widget _buildHeader() {
    return const Column(children: [
      SizedBox(height: 12),
      Text('RUNVIX', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 6)),
    ]);
  }

  Widget _buildAddImageButton() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: const Icon(Icons.add_circle_outline, size: 70, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(color: Colors.white)));
  }
}

class _PostBackground extends StatelessWidget {
  final XFile? imageFile;
  const _PostBackground({this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1C1C1E),
      child: Stack(
        children: [
          if (imageFile != null)
            Positioned.fill(
              child: kIsWeb
                  ? Image.network(imageFile!.path, fit: BoxFit.cover)
                  : Image.file(File(imageFile!.path), fit: BoxFit.cover),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: imageFile != null
                    ? [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)]
                    : [Colors.white, Colors.lightBlueAccent, Colors.lightBlue.withOpacity(0.7)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostInputCard extends StatelessWidget {
  final XFile? imageFile;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onPost;

  const _PostInputCard({required this.imageFile, required this.titleController, required this.contentController, required this.onPost});

  @override
  Widget build(BuildContext context) {
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
                      controller: titleController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(hintText: 'Hôm nay của bạn thế nào?', hintStyle: TextStyle(color: Colors.white60), border: InputBorder.none),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                      decoration: const InputDecoration(hintText: 'Hãy viết những gì bạn muốn chia sẻ...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none),
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
            onTap: onPost,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: AppColors.buttonColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}
