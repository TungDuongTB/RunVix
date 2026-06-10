import 'package:runvix/export.dart';

class EliteRunnersDnCard extends StatelessWidget {
  const EliteRunnersDnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1486218119243-13883505764c?q=80&w=200&auto=format&fit=crop',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Elite Runners DN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Hanken Grotesk',
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.people_outline, size: 16, color: Colors.black54),
                              SizedBox(width: 4),
                              Text(
                                '420 thành viên',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontFamily: 'Hanken Grotesk',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.buttonColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        'Tham gia',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 72,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildOverlapAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=60'),
                    ),
                    Positioned(
                      left: 16,
                      child: _buildOverlapAvatar('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&auto=format&fit=crop&q=60'),
                    ),
                    Positioned(
                      left: 32,
                      child: _buildOverlapAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&auto=format&fit=crop&q=60'),
                    ),
                    Positioned(
                      left: 48,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            '+12',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '6,120 km tuần này',
                style: TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlapAvatar(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
