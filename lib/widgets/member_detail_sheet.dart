import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attendance_model.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'attendance_status_button.dart';

class MemberDetailSheet extends StatefulWidget {
  final MemberModel member;
  final AttendanceModel attendance;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const MemberDetailSheet({
    super.key,
    required this.member,
    required this.attendance,
    required this.onStatusChanged,
    this.enabled = true,
  });

  @override
  State<MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<MemberDetailSheet> {
  late AttendanceStatus _status;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _status = widget.attendance.status;
    _memoController = TextEditingController(text: widget.attendance.memo);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:${widget.member.phone.replaceAll('-', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // 아바타 + 이름
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.member.gender == Gender.male
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFBE185D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.member.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.member.genderDisplay} · ${widget.member.cellName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 전화번호
          InkWell(
            onTap: _callPhone,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    widget.member.phone,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 출석 상태
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '출석 상태',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AttendanceStatusButton(
            current: _status,
            enabled: widget.enabled,
            onChanged: (s) {
              setState(() => _status = s);
              widget.onStatusChanged(s);
            },
          ),
          // 기타 메모
          if (_status == AttendanceStatus.etc && widget.enabled) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: '기타 사유',
                hintText: '사유를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}
