import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../utils/app_theme.dart';

class AttendanceStatusButton extends StatelessWidget {
  final AttendanceStatus current;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onChanged;

  const AttendanceStatusButton({
    super.key,
    required this.current,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AttendanceStatus.values.map((status) {
        final isSelected = current == status;
        final color = AppTheme.statusColor(status);
        final bgColor = AppTheme.statusBgColor(status);
        final label = AttendanceModel(
          memberId: 0,
          memberName: '',
          status: status,
        ).statusDisplay;

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: enabled ? () => onChanged(status) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? bgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
