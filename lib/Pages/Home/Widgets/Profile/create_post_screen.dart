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
  final controller = PostController.instance;
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasWorkoutImage = controller.workoutImageUrl.value.isNotEmpty;
      
      return Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                _PostBackground(
                  imageFile: _imageFile, 
                  workoutImageUrl: controller.workoutImageUrl.value,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const Spacer(),
                      if (_imageFile == null && !hasWorkoutImage) _buildAddImageButton(),
                      const Spacer(),
                      _PostInputCard(
                        imageFile: _imageFile,
                        workoutImageUrl: controller.workoutImageUrl.value,
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
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: () {
          controller.clearWorkoutData();
          Get.back();
        },
      ),
      actions: [_buildPopupMenu()],
    );
  }

  Widget _buildPopupMenu() {
    final hasImage = _imageFile != null || controller.workoutImageUrl.value.isNotEmpty;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
      onSelected: (value) {
        if (value == 'change_image') _pickImage();
        else if (value == 'remove_image') {
          setState(() => _imageFile = null);
          controller.workoutImageUrl.value = "";
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'change_image', child: _buildPopupItem(Icons.image_outlined, 'Thay đổi ảnh', Colors.blue)),
        if (hasImage) PopupMenuItem(value: 'remove_image', child: _buildPopupItem(Icons.delete_outline, 'Xóa ảnh', Colors.red)),
      ],
    );
  }

  Widget _buildPopupItem(IconData icon, String label, Color color) {
    return Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Text(label, style: TextStyle(color: color))]);
  }

  Widget _buildHeader() {
    return const Column(children: [
      SizedBox(height: 12),
      Text('CHIA SẺ HOẠT ĐỘNG', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
  final String workoutImageUrl;
  const _PostBackground({this.imageFile, required this.workoutImageUrl});

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;

    if (imageFile != null) {
      imageWidget = kIsWeb
          ? Image.network(imageFile!.path, fit: BoxFit.cover)
          : Image.file(File(imageFile!.path), fit: BoxFit.cover);
    } else if (workoutImageUrl.isNotEmpty) {
      imageWidget = Image.network(workoutImageUrl, fit: BoxFit.cover);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.darkGrey,
      child: Stack(
        children: [
          if (imageWidget != null) Positioned.fill(child: imageWidget),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8)
                ],
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
  final String workoutImageUrl;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onPost;

  const _PostInputCard({
    required this.imageFile, 
    required this.workoutImageUrl,
    required this.titleController, 
    required this.contentController, 
    required this.onPost
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề buổi chạy', 
                        hintStyle: TextStyle(color: Colors.white60), 
                        border: InputBorder.none
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Bạn cảm thấy thế nào về buổi chạy hôm nay?', 
                        hintStyle: TextStyle(color: Colors.white38), 
                        border: InputBorder.none
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          child: GestureDetector(
            onTap: onPost,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: AppColors.buttonColor.withOpacity(0.4), blurRadius: 10)],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}
