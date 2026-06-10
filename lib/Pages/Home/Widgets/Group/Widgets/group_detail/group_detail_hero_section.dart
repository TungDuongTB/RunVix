import 'package:runvix/export.dart';

class GroupDetailHeroSection extends StatelessWidget {
  final GroupModel group;

  const GroupDetailHeroSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 288,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: group.coverImageUrl.isNotEmpty
                ? Image.network(
                    group.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _DefaultCover(),
                  )
                : const _DefaultCover(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.groupBackground.withOpacity(0.3),
                    AppColors.groupBackground,
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -40,
            child: _GroupAvatar(group: group),
          ),
        ],
      ),
    );
  }
}

class _DefaultCover extends StatelessWidget {
  const _DefaultCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: AppColors.groupCoverGradient,
          stops: [0.0, 0.25, 0.55, 0.8, 1.0],
        ),
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  final GroupModel group;

  const _GroupAvatar({required this.group});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.groupBackground, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: group.logoImageUrl.isNotEmpty
                ? Image.network(
                    group.logoImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _DefaultLogo(group: group),
                  )
                : _DefaultLogo(group: group),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.groupBackground, width: 2),
            ),
            child: const Icon(Icons.verified, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _DefaultLogo extends StatelessWidget {
  final GroupModel group;

  const _DefaultLogo({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.buttonColor, AppColors.buttonColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
