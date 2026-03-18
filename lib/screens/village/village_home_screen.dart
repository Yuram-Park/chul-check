import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/attendance_model.dart';
import '../../models/cell_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/attendance_status_button.dart';
import 'cell_attendance_screen.dart';

class VillageHomeScreen extends StatefulWidget {
  const VillageHomeScreen({super.key});

  @override
  State<VillageHomeScreen> createState() => _VillageHomeScreenState();
}

class _VillageHomeScreenState extends State<VillageHomeScreen> {
  List<CellModel> _cells = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isSubmitted = false;
  DateTime _selectedDate = DateTime.now();

  final Map<int, AttendanceStatus> _leaderStatus = {};
  Map<int, AttendanceStatus> _leaderStatusSnapshot = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user!;
    setState(() {
      _isLoading = true;
      _isEditMode = false;
      _isSubmitted = false;
    });
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

  void _setDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  void _enterEditMode() {
    setState(() {
      _leaderStatusSnapshot = Map.from(_leaderStatus);
      _isEditMode = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _leaderStatus.addAll(_leaderStatusSnapshot);
      _isEditMode = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _isSubmitted = true;
      _isEditMode = false;
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '출석이 제출되었습니다',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Color(0xFF0EA5E9),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
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
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('ko', 'KR'),
              );
              if (picked != null) _setDate(picked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _DatePickerBar(
            selectedDate: _selectedDate,
            onDateChanged: _setDate,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cells.isEmpty
              ? const Center(child: Text('소속 셀이 없습니다'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
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
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _isEditMode
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _cancelEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.grey.shade600,
                              ),
                              child: const Text('작성취소'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                              ),
                              child: const Text('제출하기'),
                            ),
                          ),
                        ],
                      )
                    : _isSubmitted
                        ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _enterEditMode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                  ),
                                  child: const Text('수정하기'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.grey.shade500,
                                  ),
                                  child: const Text('제출완료'),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: _enterEditMode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                            ),
                            child: const Text('작성하기'),
                          ),
              ),
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
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildCellCard(CellModel cell) {
    final leaderStatus = _leaderStatus[cell.id] ?? AttendanceStatus.absent;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                AttendanceStatusButton(
                  current: leaderStatus,
                  enabled: _isEditMode,
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
            child:
                const Text('로그아웃', style: TextStyle(color: AppTheme.absent)),
          ),
        ],
      ),
    );
  }
}

class _DatePickerBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DatePickerBar({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () =>
                onDateChanged(selectedDate.subtract(const Duration(days: 7))),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  locale: const Locale('ko', 'KR'),
                );
                if (picked != null) onDateChanged(picked);
              },
              child: Center(
                child: Text(
                  DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: selectedDate
                    .isBefore(DateTime.now().subtract(const Duration(days: 1)))
                ? () => onDateChanged(selectedDate.add(const Duration(days: 7)))
                : null,
          ),
        ],
      ),
    );
  }
}
