import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'admin_leader_story_screen.dart';
import 'admin_role_screen.dart';

class AdminStoryLandingScreen extends StatelessWidget {
  const AdminStoryLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Super Admin 메뉴',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '아래 메뉴는 Super Admin 전용 기능입니다.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          _MenuCard(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories,
            title: '리더 스토리',
            description: '셀원들의 상세 이력, 라인아웃 사유, 이전 공동체, 훈련/섬김 현황, 코멘트 관리',
            color: const Color(0xFF7C3AED),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLeaderStoryScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            icon: Icons.security_outlined,
            activeIcon: Icons.security,
            title: '권한 관리',
            description: '간사 승인 및 Super Admin 권한 부여, 사용자 역할 변경',
            color: AppTheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminRoleScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(activeIcon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
