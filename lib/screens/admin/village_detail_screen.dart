import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/village_model.dart';
import '../../models/cell_model.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/app_theme.dart';
import '../village/cell_attendance_screen.dart';

class VillageDetailScreen extends StatelessWidget {
  final VillageModel village;

  const VillageDetailScreen({super.key, required this.village});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(village.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 마을 정보 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city,
                    color: AppTheme.primary, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      village.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      '마을장: ${village.masterName} · ${village.cells.length}개 셀',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '셀 목록',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...village.cells.map((cell) => _buildCellCard(context, cell)),
        ],
      ),
    );
  }

  Widget _buildCellCard(BuildContext context, CellModel cell) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
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
        title: Text(
          cell.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '리더: ${cell.leaderName}',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => AttendanceProvider(),
                child: CellAttendanceScreen(cell: cell),
              ),
            ),
          );
        },
      ),
    );
  }
}
