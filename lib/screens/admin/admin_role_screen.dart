import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';

class AdminRoleScreen extends StatefulWidget {
  const AdminRoleScreen({super.key});

  @override
  State<AdminRoleScreen> createState() => _AdminRoleScreenState();
}

class _AdminRoleScreenState extends State<AdminRoleScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await MockService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _changeRole(UserModel user, UserRole newRole) async {
    if (user.role == newRole) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('권한 변경'),
        content: Text(
          '${user.name}님의 권한을\n'
          '${user.roleDisplayName} → ${_roleLabel(newRole)}\n'
          '으로 변경하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('변경', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MockService.updateUserRole(user.id, newRole);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name}님 권한이 ${_roleLabel(newRole)}으로 변경되었습니다')),
        );
      }
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return '간사/교역자';
      case UserRole.villageMaster:
        return '마을장';
      case UserRole.leader:
        return '리더';
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return const Color(0xFF7C3AED);
      case UserRole.admin:
        return AppTheme.primary;
      case UserRole.villageMaster:
        return AppTheme.late;
      case UserRole.leader:
        return AppTheme.present;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('권한 관리')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  const Text(
                    '사용자 목록',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._users.map((u) => _buildUserCard(u)),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, size: 16, color: Color(0xFF7C3AED)),
              SizedBox(width: 6),
              Text(
                '권한 관리 (Super Admin 전용)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _roleRow('Super Admin', '시스템 전체 관리, 권한 부여 가능', const Color(0xFF7C3AED)),
          _roleRow('간사/교역자', '셀원 리스트 조회, 등록, 수정, 엑셀 내보내기', AppTheme.primary),
          _roleRow('마을장', '마을 내 리더 및 셀원 출석 관리', AppTheme.late),
          _roleRow('리더', '본인 셀원 출석 체크 및 조회', AppTheme.present),
        ],
      ),
    );
  }

  Widget _roleRow(String role, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$role  ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 20,
              backgroundColor: _roleColor(user.role).withOpacity(0.1),
              child: Text(
                user.name[0],
                style: TextStyle(
                  color: _roleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 이름 & 부가정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    user.phone,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            // 현재 권한 뱃지
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _roleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.roleDisplayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _roleColor(user.role),
                ),
              ),
            ),
            // 권한 변경 드롭다운
            PopupMenuButton<UserRole>(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
              tooltip: '권한 변경',
              itemBuilder: (_) => UserRole.values
                  .map((r) => PopupMenuItem(
                        value: r,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _roleColor(r),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _roleLabel(r),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: user.role == r ? FontWeight.w700 : FontWeight.normal,
                                color: user.role == r ? AppTheme.primary : AppTheme.textPrimary,
                              ),
                            ),
                            if (user.role == r) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check, size: 14, color: AppTheme.primary),
                            ],
                          ],
                        ),
                      ))
                  .toList(),
              onSelected: (newRole) => _changeRole(user, newRole),
            ),
          ],
        ),
      ),
    );
  }
}
