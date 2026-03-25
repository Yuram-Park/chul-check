import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member_story_model.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/csv_download.dart';
import 'admin_leader_story_register_screen.dart';

class AdminLeaderStoryScreen extends StatefulWidget {
  const AdminLeaderStoryScreen({super.key});

  @override
  State<AdminLeaderStoryScreen> createState() => _AdminLeaderStoryScreenState();
}

class _AdminLeaderStoryScreenState extends State<AdminLeaderStoryScreen> {
  List<MemberStoryModel> _all = [];
  List<MemberStoryModel> _filtered = [];
  bool _isLoading = true;

  // 필터
  String _filterName = '';
  String _filterLeader = '';
  String _filterStatus = '';
  String _filterLineOut = '전체';

  // 헤더·데이터 가로 스크롤 동기화
  final ScrollController _headerScrollCtrl = ScrollController();
  final ScrollController _bodyScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _bodyScrollCtrl.addListener(() {
      if (_headerScrollCtrl.hasClients) {
        _headerScrollCtrl.jumpTo(_bodyScrollCtrl.offset);
      }
    });
    _loadData();
  }

  Future<void> _loadData({bool resetPage = false}) async {
    setState(() => _isLoading = true);
    final stories = await MockService.getAllStories();
    setState(() {
      _all = stories;
      _isLoading = false;
    });
    _applyFilter();
  }

  @override
  void dispose() {
    _headerScrollCtrl.dispose();
    _bodyScrollCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    var list = List<MemberStoryModel>.from(_all);
    if (_filterName.isNotEmpty) {
      list = list.where((s) => s.memberName.contains(_filterName)).toList();
    }
    if (_filterLeader.isNotEmpty) {
      list = list.where((s) => (s.leaderName ?? '').contains(_filterLeader)).toList();
    }
    if (_filterStatus.isNotEmpty) {
      list = list.where((s) => (s.currentStatus ?? '').contains(_filterStatus)).toList();
    }
    if (_filterLineOut == 'Y') {
      list = list.where((s) => s.lineOut).toList();
    } else if (_filterLineOut == 'N') {
      list = list.where((s) => !s.lineOut).toList();
    }
    setState(() => _filtered = list);
  }

  void _exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln(MemberStoryModel.csvHeader());
    for (int i = 0; i < _filtered.length; i++) {
      buffer.writeln(_filtered[i].toCsvRow(i));
    }
    final filename = '리더스토리_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    downloadCsv(buffer.toString(), filename);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$filename 다운로드 완료')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리더 스토리'),
        actions: [
          TextButton.icon(
            onPressed: _exportCsv,
            icon: const Icon(Icons.download, size: 16, color: AppTheme.primary),
            label: const Text('CSV', style: TextStyle(color: AppTheme.primary)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: '등록하기',
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'direct', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('직접 등록하기')])),
              const PopupMenuItem(value: 'upload', child: Row(children: [Icon(Icons.upload_file_outlined, size: 18), SizedBox(width: 8), Text('엑셀 업로드')])),
            ],
            onSelected: (mode) async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLeaderStoryRegisterScreen(mode: mode)),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                _buildHeader(),
                Expanded(child: _buildTable()),
                _buildStatusBar(),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _FilterChip(label: '이름', onChanged: (v) { _filterName = v; _applyFilter(); }),
          _FilterChip(label: '리더', onChanged: (v) { _filterLeader = v; _applyFilter(); }),
          _FilterChip(label: '현재 상태', onChanged: (v) { _filterStatus = v; _applyFilter(); }),
          _DropdownChip(
            value: _filterLineOut,
            items: const ['전체', 'Y', 'N'],
            label: '라인아웃',
            onChanged: (v) { setState(() => _filterLineOut = v); _applyFilter(); },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const style = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2)),
      ),
      child: SingleChildScrollView(
        controller: _headerScrollCtrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: [
          _H('#', 44),
          _H('이름', 80, style: style),
          _H('또래', 70),
          _H('마을장', 80),
          _H('리더', 80),
          _H('라인아웃', 70),
          _H('라인아웃 사유', 130),
          _H('현재 상태', 90),
          _H('이전 공동체', 110),
          _H('훈련/섬김', 120),
          _H('코멘트1', 150),
          _H('코멘트2', 150),
          _H('등록일', 95),
        ]),
      ),
    );
  }

  Widget _H(String text, double w, {TextStyle? style}) => SizedBox(
    width: w,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Text(text, style: style ?? const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ),
  );

  Widget _buildTable() {
    if (_filtered.isEmpty) {
      return const Center(child: Text('데이터가 없습니다', style: TextStyle(color: AppTheme.textSecondary)));
    }
    return SingleChildScrollView(
      child: SingleChildScrollView(
        controller: _bodyScrollCtrl,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: _filtered.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final isEven = i % 2 == 0;
            return _StoryRow(story: s, index: i, isEven: isEven);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Text('총 ${_filtered.length}건', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(width: 16),
          _StatusBadge('활동중', _filtered.where((s) => s.currentStatus == '활동중').length, AppTheme.present),
          const SizedBox(width: 8),
          _StatusBadge('라인아웃', _filtered.where((s) => s.lineOut).length, AppTheme.absent),
          const SizedBox(width: 8),
          _StatusBadge('등록대기', _filtered.where((s) => s.currentStatus == '등록대기').length, AppTheme.late),
        ],
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  final MemberStoryModel story;
  final int index;
  final bool isEven;

  const _StoryRow({required this.story, required this.index, required this.isEven});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FAFC),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(children: [
        _C('${index + 1}', 44, color: AppTheme.textSecondary),
        _C(story.memberName, 80, bold: true),
        _C(story.peer ?? '-', 70),
        _C(story.villageMasterName ?? '-', 80),
        _C(story.leaderName ?? '-', 80),
        _C(story.lineOutDisplay, 70,
          color: story.lineOut ? AppTheme.absent : AppTheme.present),
        _C(story.lineOutReason ?? '-', 130),
        _StatusCell(story.currentStatus, 90),
        _C(story.previousCommunity ?? '-', 110),
        _C(story.trainingService ?? '-', 120),
        _C(story.comment1 ?? '-', 150),
        _C(story.comment2 ?? '-', 150),
        _C(DateFormat('yyyy-MM-dd').format(story.registeredAt), 95),
      ]),
    );
  }

  Widget _C(String text, double w, {bool bold = false, Color? color}) => SizedBox(
    width: w,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? AppTheme.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

class _StatusCell extends StatelessWidget {
  final String? status;
  final double width;
  const _StatusCell(this.status, this.width);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case '활동중': color = AppTheme.present; break;
      case '라인아웃': color = AppTheme.absent; break;
      case '등록대기': color = AppTheme.late; break;
      default: color = AppTheme.textSecondary;
    }
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: status == null
            ? const Text('-', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status!,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  const _FilterChip({required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 34,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary)),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String> onChanged;
  const _DropdownChip({required this.value, required this.items, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((v) => DropdownMenuItem(value: v, child: Text('$label: $v', style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (v) => onChanged(v!),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusBadge(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text('$label $count', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
