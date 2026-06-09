import 'package:runvix/export.dart';

class ProfilePostGridComponent extends StatelessWidget {
  final List<String> postImages;
  final String? title;
  final int crossAxisCount;
  final double spacing;
  final VoidCallback? onPostTap;

  const ProfilePostGridComponent({
    super.key,
    required this.postImages,
    this.title,
    this.crossAxisCount = 3,
    this.spacing = 8.0,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

        // Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: postImages.length,
            itemBuilder: (context, index) {
              return _buildPostItem(postImages[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostItem(String imageUrl) {
    return GestureDetector(
      onTap: onPostTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

