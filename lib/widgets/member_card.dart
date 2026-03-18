import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'attendance_status_button.dart';
import 'member_detail_sheet.dart';

class MemberCard extends StatefulWidget {
  final MemberModel member;
  final AttendanceModel attendance;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final ValueChanged<String>? onMemoChanged;

  const MemberCard({
    super.key,
    required this.member,
    required this.attendance,
    required this.onStatusChanged,
    this.onMemoChanged,
    this.enabled = true,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.attendance.memo);
  }

  @override
  void didUpdateWidget(MemberCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attendance.memo != widget.attendance.memo &&
        _memoController.text != widget.attendance.memo) {
      _memoController.text = widget.attendance.memo;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEtc = widget.attendance.status == AttendanceStatus.etc;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 아바타
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.member.gender == Gender.male
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFFCE7F3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.member.name[0],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.member.gender == Gender.male
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFFBE185D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 이름
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMemberDetail(context),
                    child: Row(
                      children: [
                        Text(
                          widget.member.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.member.genderDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 출석 상태 버튼
                AttendanceStatusButton(
                  current: widget.attendance.status,
                  enabled: widget.enabled,
                  onChanged: widget.onStatusChanged,
                ),
              ],
            ),
            // 기타 사유 입력/표시
            if (isEtc) ...[
              const SizedBox(height: 8),
              widget.enabled
                  ? TextField(
                      controller: _memoController,
                      onChanged: widget.onMemoChanged,
                      decoration: InputDecoration(
                        hintText: '사유를 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                    )
                  : widget.attendance.memo.isNotEmpty
                      ? Text(
                          widget.attendance.memo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : const SizedBox.shrink(),
            ],
          ],
        ),
      ),
    );
  }

  void _showMemberDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemberDetailSheet(
        member: widget.member,
        attendance: widget.attendance,
        enabled: widget.enabled,
        onStatusChanged: widget.onStatusChanged,
      ),
    );
  }
}
