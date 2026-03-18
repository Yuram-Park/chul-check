import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cell_model.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/member_card.dart';
import '../../widgets/summary_bar.dart';

class CellAttendanceScreen extends StatefulWidget {
  final CellModel cell;

  const CellAttendanceScreen({super.key, required this.cell});

  @override
  State<CellAttendanceScreen> createState() => _CellAttendanceScreenState();
}

class _CellAttendanceScreenState extends State<CellAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadCellData(widget.cell.id);
    });
  }

  Future<void> _submit() async {
    final provider = context.read<AttendanceProvider>();
    final success = await provider.submit(widget.cell.id);
    if (success && mounted) {
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '제출 실패'),
          backgroundColor: AppTheme.absent,
        ),
      );
    }
  }

  void _cancelEdit() {
    context.read<AttendanceProvider>().cancelEdit();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cell.name} 출석부'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '리더: ${widget.cell.leaderName}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
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
                        enabled: provider.isEditMode,
                        onStatusChanged: (s) =>
                            provider.updateStatus(member.id, s),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: provider.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: provider.isEditMode
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
                    : provider.isSubmitted
                        ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.enterEditMode,
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
                            onPressed: provider.enterEditMode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                            ),
                            child: const Text('작성하기'),
                          ),
              ),
            ),
    );
  }
}
