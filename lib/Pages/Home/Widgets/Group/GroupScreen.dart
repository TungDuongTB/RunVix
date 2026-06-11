import 'package:runvix/export.dart';
import 'challenge_tab_content.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Mặc định ở tab "Nhóm"
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Top App Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C3FF).withOpacity(0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Obx(() {
                            final user = userController.user.value;
                            final profilePic = user.profilePicture;
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.buttonColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profilePic.isNotEmpty
                                    ? NetworkImage(profilePic)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                                child: profilePic.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.buttonColor,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'RunVix',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Custom Segmented Tab Bar
              const TabBar(
                indicator: GradientTabIndicator(
                  indicatorHeight: 3,
                  widthRatio: 0.5,
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Hanken Grotesk',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  fontFamily: 'Hanken Grotesk',
                ),
                tabs: [
                  Tab(text: 'Thử thách'),
                  Tab(text: 'Nhóm'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [ChallengeTabContent(), GroupTabContent()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientTabIndicator extends Decoration {
  final double indicatorHeight;
  final double widthRatio;
  final Gradient gradient;

  const GradientTabIndicator({
    this.indicatorHeight = 3.0,
    this.widthRatio = 0.5,
    this.gradient = const LinearGradient(
      colors: [AppColors.primary, AppColors.buttonColor],
    ),
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(this, onChanged);
  }
}

class _GradientPainter extends BoxPainter {
  final GradientTabIndicator decoration;

  _GradientPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final double width = rect.width * decoration.widthRatio;
    final double left = rect.left + (rect.width - width) / 2;
    final double top = rect.bottom - decoration.indicatorHeight;

    final Paint paint = Paint()
      ..shader = decoration.gradient.createShader(
        Rect.fromLTWH(left, top, width, decoration.indicatorHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, decoration.indicatorHeight),
        const Radius.circular(99),
      ),
      paint,
    );
  }
}
