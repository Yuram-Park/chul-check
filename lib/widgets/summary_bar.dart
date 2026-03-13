import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SummaryBar extends StatelessWidget {
  final int present;
  final int absent;
  final int late;
  final int etc;

  const SummaryBar({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
    required this.etc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '출석', count: present, color: AppTheme.present),
          _Divider(),
          _StatItem(label: '결석', count: absent, color: AppTheme.absent),
          _Divider(),
          _StatItem(label: '지각', count: late, color: AppTheme.late),
          _Divider(),
          _StatItem(label: '기타', count: etc, color: AppTheme.etc),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}
