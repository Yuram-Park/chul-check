import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'attendance_status_button.dart';
import 'member_detail_sheet.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;
  final AttendanceModel attendance;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const MemberCard({
    super.key,
    required this.member,
    required this.attendance,
    required this.onStatusChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 아바타
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: member.gender == Gender.male
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFFCE7F3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.name[0],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: member.gender == Gender.male
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.genderDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (attendance.status == AttendanceStatus.etc &&
                        attendance.memo.isNotEmpty)
                      Text(
                        attendance.memo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 출석 상태 버튼
            AttendanceStatusButton(
              current: attendance.status,
              enabled: enabled,
              onChanged: onStatusChanged,
            ),
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
        member: member,
        attendance: attendance,
        enabled: enabled,
        onStatusChanged: onStatusChanged,
      ),
    );
  }
}
