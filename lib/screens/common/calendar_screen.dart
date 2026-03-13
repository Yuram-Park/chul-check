import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/member_card.dart';
import '../../widgets/summary_bar.dart';

class CalendarScreen extends StatefulWidget {
  final int cellId;
  final String? title;

  const CalendarScreen({super.key, required this.cellId, this.title});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadCellData(widget.cellId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '출석 조회'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime(2020),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              provider.setDate(selected, widget.cellId);
            },
            onPageChanged: (focused) {
              setState(() => _focusedDay = focused);
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  DateFormat('yyyy년 M월 d일 출석', 'ko_KR').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (provider.isSubmitted && !provider.isEditMode)
                  TextButton(
                    onPressed: provider.enterEditMode,
                    child: const Text('수정하기'),
                  ),
              ],
            ),
          ),
          if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            SummaryBar(
              present: provider.presentCount,
              absent: provider.absentCount,
              late: provider.lateCount,
              etc: provider.etcCount,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.members.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (_, i) {
                  final member = provider.members[i];
                  final attendance = provider.attendances.firstWhere(
                    (a) => a.memberId == member.id,
                    orElse: () => provider.attendances[i],
                  );
                  return MemberCard(
                    member: member,
                    attendance: attendance,
                    enabled: provider.isEditMode || !provider.isSubmitted,
                    onStatusChanged: (s) =>
                        provider.updateStatus(member.id, s),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: provider.isEditMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: () => provider.submit(widget.cellId),
                  child: const Text('수정 완료'),
                ),
              ),
            )
          : null,
    );
  }
}
