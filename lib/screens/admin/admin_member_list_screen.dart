import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member_model.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/csv_download.dart';
import 'admin_member_register_screen.dart';

class AdminMemberListScreen extends StatefulWidget {
  const AdminMemberListScreen({super.key});

  @override
  State<AdminMemberListScreen> createState() => _AdminMemberListScreenState();
}

class _AdminMemberListScreenState extends State<AdminMemberListScreen> {
  List<MemberModel> _allMembers = [];
  List<MemberModel> _filtered = [];
  Map<int, double> _attendanceRates = {};
  bool _isLoading = true;

  // 필터
  String _filterName = '';
  String _filterVillageMaster = '';
  String _filterLeader = '';
  String _filterGender = '전체';
  String _filterPeer = '';

  // 정렬
  String _sortColumn = 'registeredAt';
  bool _sortAsc = false;

  // 페이지네이션
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool resetPage = false}) async {
    setState(() => _isLoading = true);
    final members = await MockService.getAllMembers();
    final ids = members.map((m) => m.id).toList();
    final rates = await MockService.getMemberAttendanceRates(ids);
    setState(() {
      _allMembers = members;
      _attendanceRates = rates;
      _isLoading = false;
      if (resetPage) _currentPage = 0;
    });
    _applyFilter();
  }

  void _applyFilter() {
    var list = List<MemberModel>.from(_allMembers);

    if (_filterName.isNotEmpty) {
      list = list.where((m) => m.name.contains(_filterName)).toList();
    }
    if (_filterVillageMaster.isNotEmpty) {
      list = list.where((m) =>
          (m.villageMasterName ?? '').contains(_filterVillageMaster)).toList();
    }
    if (_filterLeader.isNotEmpty) {
      list = list.where((m) =>
          (m.leaderName ?? '').contains(_filterLeader)).toList();
    }
    if (_filterGender != '전체') {
      list = list.where((m) => m.genderDisplay == _filterGender).toList();
    }
    if (_filterPeer.isNotEmpty) {
      list = list.where((m) => (m.peer ?? '').contains(_filterPeer)).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'villageMasterName':
          cmp = (a.villageMasterName ?? '').compareTo(b.villageMasterName ?? '');
          break;
        case 'leaderName':
          cmp = (a.leaderName ?? '').compareTo(b.leaderName ?? '');
          break;
        case 'peer':
          cmp = (a.peer ?? '').compareTo(b.peer ?? '');
          break;
        case 'attendanceRate':
          cmp = (_attendanceRates[a.id] ?? 0)
              .compareTo(_attendanceRates[b.id] ?? 0);
          break;
        default:
          cmp = a.registeredAt.compareTo(b.registeredAt);
      }
      return _sortAsc ? cmp : -cmp;
    });

    setState(() {
      _filtered = list;
    });
  }

  void _setSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortColumn = column;
        _sortAsc = true;
      }
    });
    _applyFilter();
  }

  List<MemberModel> get _paginated {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int get _totalPages => (_filtered.length / _pageSize).ceil();

  void _exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln('번호,마을장,리더,이름,성별,또래,생년월일,전화번호,라인아웃,출석률(%),등록일');
    for (int i = 0; i < _filtered.length; i++) {
      final m = _filtered[i];
      final rate = _attendanceRates[m.id]?.toStringAsFixed(1) ?? '-';
      final regDate = DateFormat('yyyy-MM-dd').format(m.registeredAt);
      buffer.writeln(
        '${i + 1},${m.villageMasterName ?? ''},${m.leaderName ?? ''},'
        '${m.name},${m.genderDisplay},${m.peer ?? ''},${m.birthDate ?? ''},'
        '${m.phone},${m.lineOutDisplay},$rate,$regDate',
      );
    }
    final filename = '셀원명단_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    downloadCsv(buffer.toString(), filename);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$filename 다운로드 완료')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                _buildTableHeader(),
                Expanded(child: _buildTable()),
                _buildPagination(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminMemberRegisterScreen()),
          );
          _loadData(resetPage: true);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('등록하기'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterField(
            label: '이름',
            onChanged: (v) {
              _filterName = v;
              _currentPage = 0;
              _applyFilter();
            },
          ),
          _FilterField(
            label: '마을장',
            onChanged: (v) {
              _filterVillageMaster = v;
              _currentPage = 0;
              _applyFilter();
            },
          ),
          _FilterField(
            label: '리더',
            onChanged: (v) {
              _filterLeader = v;
              _currentPage = 0;
              _applyFilter();
            },
          ),
          _FilterField(
            label: '또래',
            onChanged: (v) {
              _filterPeer = v;
              _currentPage = 0;
              _applyFilter();
            },
          ),
          _GenderFilter(
            value: _filterGender,
            onChanged: (v) {
              setState(() => _filterGender = v);
              _currentPage = 0;
              _applyFilter();
            },
          ),
          TextButton.icon(
            onPressed: _exportCsv,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('CSV 내보내기'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          Text(
            '총 ${_filtered.length}명',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _TableRow(
          isHeader: true,
          cells: [
            _HeaderCell('번호', width: 50),
            _HeaderCell('마을장', width: 80, sortKey: 'villageMasterName', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
            _HeaderCell('리더', width: 80, sortKey: 'leaderName', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
            _HeaderCell('이름', width: 80, sortKey: 'name', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
            _HeaderCell('성별', width: 50),
            _HeaderCell('또래', width: 70, sortKey: 'peer', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
            _HeaderCell('생년월일', width: 100),
            _HeaderCell('전화번호', width: 130),
            _HeaderCell('라인아웃', width: 70),
            _HeaderCell('출석률', width: 70, sortKey: 'attendanceRate', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
            _HeaderCell('등록일', width: 100, sortKey: 'registeredAt', currentSort: _sortColumn, asc: _sortAsc, onSort: _setSort),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = _paginated;
    if (rows.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    final startIdx = _currentPage * _pageSize;
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            final rate = _attendanceRates[m.id];
            final regDate = DateFormat('yyyy-MM-dd').format(m.registeredAt);
            final isEven = idx % 2 == 0;
            return _TableRow(
              backgroundColor: isEven ? Colors.white : const Color(0xFFF8FAFC),
              cells: [
                _DataCell('${startIdx + idx + 1}', width: 50),
                _DataCell(m.villageMasterName ?? '-', width: 80),
                _DataCell(m.leaderName ?? '-', width: 80),
                _DataCell(m.name, width: 80, bold: true),
                _DataCell(m.genderDisplay, width: 50),
                _DataCell(m.peer ?? '-', width: 70),
                _DataCell(m.birthDate ?? '-', width: 100),
                _DataCell(m.phone, width: 130),
                _DataCell(
                  m.lineOutDisplay,
                  width: 70,
                  color: m.lineOut ? AppTheme.absent : AppTheme.present,
                ),
                _DataCell(
                  rate != null ? '${rate.toStringAsFixed(1)}%' : '-',
                  width: 70,
                  color: rate != null
                      ? (rate >= 80
                          ? AppTheme.present
                          : rate >= 60
                              ? AppTheme.late
                              : AppTheme.absent)
                      : AppTheme.textSecondary,
                ),
                _DataCell(regDate, width: 100),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            '${_currentPage + 1} / ${_totalPages == 0 ? 1 : _totalPages}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}

// 테이블 행 위젯
class _TableRow extends StatelessWidget {
  final List<Widget> cells;
  final bool isHeader;
  final Color? backgroundColor;

  const _TableRow({
    required this.cells,
    this.isHeader = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      decoration: isHeader
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
            )
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
      child: Row(children: cells),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final String? sortKey;
  final String? currentSort;
  final bool asc;
  final void Function(String)? onSort;

  const _HeaderCell(
    this.label, {
    required this.width,
    this.sortKey,
    this.currentSort,
    this.asc = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isSorted = sortKey != null && currentSort == sortKey;
    return GestureDetector(
      onTap: sortKey != null ? () => onSort?.call(sortKey!) : null,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (isSorted)
                Icon(
                  asc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: AppTheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final double width;
  final bool bold;
  final Color? color;

  const _DataCell(this.text, {required this.width, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? AppTheme.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;

  const _FilterField({required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 36,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _GenderFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: ['전체', '남', '여']
              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) => onChanged(v!),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        ),
      ),
    );
  }
}

