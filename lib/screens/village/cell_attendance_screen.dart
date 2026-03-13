import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                if (provider.isSubmitted && !provider.isEditMode)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppTheme.present, size: 16),
                        const SizedBox(width: 8),
                        const Text('출석이 제출되었습니다',
                            style: TextStyle(
                                color: Color(0xFF15803D), fontSize: 13)),
                        const Spacer(),
                        TextButton(
                          onPressed: provider.enterEditMode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text('수정하기',
                              style: TextStyle(
                                  color: AppTheme.primary, fontSize: 13)),
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
      bottomNavigationBar: provider.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed:
                      (provider.isSubmitted && !provider.isEditMode)
                          ? null
                          : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        provider.isSubmitted && !provider.isEditMode
                            ? Colors.grey
                            : AppTheme.primary,
                  ),
                  child: Text(provider.isEditMode ? '수정 완료' : '제출하기'),
                ),
              ),
            ),
    );
  }
}
