import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance_model.dart';
import '../../models/cell_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';
import 'cell_attendance_screen.dart';

class VillageHomeScreen extends StatefulWidget {
  const VillageHomeScreen({super.key});

  @override
  State<VillageHomeScreen> createState() => _VillageHomeScreenState();
}

class _VillageHomeScreenState extends State<VillageHomeScreen> {
  List<CellModel> _cells = [];
  bool _isLoading = true;

  // 리더 출석 상태 (cellId → AttendanceStatus)
  final Map<int, AttendanceStatus> _leaderStatus = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user!;
    try {
      final cells = await MockService.getVillageCells(user.villageId!);
      setState(() {
        _cells = cells;
        for (final c in cells) {
          _leaderStatus[c.id] = AttendanceStatus.absent;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.villageName ?? ''} 마을'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cells.isEmpty
              ? const Center(child: Text('소속 셀이 없습니다'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 통계 요약
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    const Text(
                      '리더 & 셀 출석부',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._cells.map((cell) => _buildCellCard(cell)),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard() {
    final present = _leaderStatus.values
        .where((s) => s == AttendanceStatus.present)
        .length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF6D8EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘 마을 현황',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '리더 $present / ${_cells.length}명 출석',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCellCard(CellModel cell) {
    final leaderStatus = _leaderStatus[cell.id] ?? AttendanceStatus.absent;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // 리더 아바타
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      cell.leaderName[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cell.leaderName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        cell.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 리더 출석 상태
                _LeaderStatusPicker(
                  status: leaderStatus,
                  onChanged: (s) {
                    setState(() => _leaderStatus[cell.id] = s);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CellAttendanceScreen(cell: cell),
                  ),
                ),
                icon: const Icon(Icons.list_alt, size: 16),
                label: Text('${cell.name} 출석부'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('로그아웃', style: TextStyle(color: AppTheme.absent)),
          ),
        ],
      ),
    );
  }
}

class _LeaderStatusPicker extends StatelessWidget {
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onChanged;

  const _LeaderStatusPicker({
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AttendanceStatus>(
      initialValue: status,
      onSelected: onChanged,
      itemBuilder: (_) => AttendanceStatus.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.statusColor(s),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(AttendanceModel(memberId: 0, memberName: '', status: s)
                      .statusDisplay),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.statusBgColor(status),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.statusColor(status)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AttendanceModel(memberId: 0, memberName: '', status: status)
                  .statusDisplay,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.statusColor(status),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppTheme.statusColor(status),
            ),
          ],
        ),
      ),
    );
  }
}
