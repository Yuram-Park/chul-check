import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/member_card.dart';
import '../../widgets/summary_bar.dart';
import '../common/calendar_screen.dart';

class LeaderHomeScreen extends StatefulWidget {
  const LeaderHomeScreen({super.key});

  @override
  State<LeaderHomeScreen> createState() => _LeaderHomeScreenState();
}

class _LeaderHomeScreenState extends State<LeaderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user!;
      context.read<AttendanceProvider>().loadCellData(user.cellId!);
    });
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().user!;
    final provider = context.read<AttendanceProvider>();
    final success = await provider.submit(user.cellId!);
    if (success) {
      Fluttertoast.showToast(
        msg: '출석이 제출되었습니다',
        backgroundColor: AppTheme.present,
        textColor: Colors.white,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '제출 실패'),
          backgroundColor: AppTheme.absent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.cellName ?? ''} 출석부'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalendarScreen(cellId: user.cellId!),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _DatePickerBar(
            selectedDate: provider.selectedDate,
            onDateChanged: (date) {
              provider.setDate(date, user.cellId!);
            },
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                SummaryBar(
                  present: provider.presentCount,
                  absent: provider.absentCount,
                  late: provider.lateCount,
                  etc: provider.etcCount,
                ),
                // 제출 완료 배너
                if (provider.isSubmitted && !provider.isEditMode)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.present,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '출석이 제출되었습니다',
                          style: TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: provider.enterEditMode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '수정하기',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.members.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (_, i) {
                      final member = provider.members[i];
                      final attendance = provider.attendances.firstWhere(
                        (a) => a.memberId == member.id,
                        orElse: () => provider.attendances[i],
                      );
                      return MemberCard(
                        member: member,
                        attendance: attendance,
                        enabled: !provider.isSubmitted || provider.isEditMode,
                        onStatusChanged: (s) =>
                            provider.updateStatus(member.id, s),
                      );
                    },
                  ),
                ),
              ],
            ),
      // 하단 제출 버튼
      bottomNavigationBar: provider.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: (provider.isSubmitted && !provider.isEditMode)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isSubmitted && !provider.isEditMode
                        ? Colors.grey
                        : AppTheme.primary,
                  ),
                  child: Text(
                    provider.isEditMode ? '수정 완료' : '제출하기',
                  ),
                ),
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
            onPressed: selectedDate.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)))
                ? () => onDateChanged(selectedDate.add(const Duration(days: 7)))
                : null,
          ),
        ],
      ),
    );
  }
}
