import 'package:flutter/material.dart';
import '../../models/member_story_model.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/web_file_utils.dart';

class AdminLeaderStoryRegisterScreen extends StatefulWidget {
  final String mode; // 'direct' | 'upload'
  const AdminLeaderStoryRegisterScreen({super.key, required this.mode});

  @override
  State<AdminLeaderStoryRegisterScreen> createState() =>
      _AdminLeaderStoryRegisterScreenState();
}

class _AdminLeaderStoryRegisterScreenState
    extends State<AdminLeaderStoryRegisterScreen> {
  // ── 직접 등록 컨트롤러 ──
  static const int _maxRows = 20;
  late final List<TextEditingController> _nameCtrl;
  late final List<TextEditingController> _peerCtrl;
  late final List<TextEditingController> _leaderCtrl;
  late final List<TextEditingController> _reasonCtrl;
  late final List<TextEditingController> _statusCtrl;
  late final List<TextEditingController> _prevCommCtrl;
  late final List<TextEditingController> _trainingCtrl;
  late final List<TextEditingController> _comment1Ctrl;
  late final List<TextEditingController> _comment2Ctrl;
  late final List<bool> _lineOutValues;

  // ── 업로드 모드 ──
  String _uploadStatus = ''; // 파일 선택 전
  List<Map<String, String>> _previewRows = [];
  bool _isParsed = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _peerCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _leaderCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _reasonCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _statusCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _prevCommCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _trainingCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _comment1Ctrl = List.generate(_maxRows, (_) => TextEditingController());
    _comment2Ctrl = List.generate(_maxRows, (_) => TextEditingController());
    _lineOutValues = List.filled(_maxRows, false);
  }

  @override
  void dispose() {
    for (final c in [..._nameCtrl, ..._peerCtrl, ..._leaderCtrl, ..._reasonCtrl,
      ..._statusCtrl, ..._prevCommCtrl, ..._trainingCtrl, ..._comment1Ctrl, ..._comment2Ctrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _reset() {
    for (int i = 0; i < _maxRows; i++) {
      _nameCtrl[i].clear(); _peerCtrl[i].clear(); _leaderCtrl[i].clear();
      _reasonCtrl[i].clear(); _statusCtrl[i].clear(); _prevCommCtrl[i].clear();
      _trainingCtrl[i].clear(); _comment1Ctrl[i].clear(); _comment2Ctrl[i].clear();
    }
    setState(() {
      for (int i = 0; i < _maxRows; i++) _lineOutValues[i] = false;
      _previewRows = [];
      _isParsed = false;
      _uploadStatus = '';
    });
  }

  Future<void> _registerDirect() async {
    final stories = <MemberStoryModel>[];
    for (int i = 0; i < _maxRows; i++) {
      final name = _nameCtrl[i].text.trim();
      if (name.isEmpty) continue;
      stories.add(MemberStoryModel(
        id: DateTime.now().millisecondsSinceEpoch + i,
        memberId: 0,
        memberName: name,
        peer: _peerCtrl[i].text.trim().isNotEmpty ? _peerCtrl[i].text.trim() : null,
        leaderName: _leaderCtrl[i].text.trim().isNotEmpty ? _leaderCtrl[i].text.trim() : null,
        lineOut: _lineOutValues[i],
        lineOutReason: _reasonCtrl[i].text.trim().isNotEmpty ? _reasonCtrl[i].text.trim() : null,
        currentStatus: _statusCtrl[i].text.trim().isNotEmpty ? _statusCtrl[i].text.trim() : null,
        previousCommunity: _prevCommCtrl[i].text.trim().isNotEmpty ? _prevCommCtrl[i].text.trim() : null,
        trainingService: _trainingCtrl[i].text.trim().isNotEmpty ? _trainingCtrl[i].text.trim() : null,
        comment1: _comment1Ctrl[i].text.trim().isNotEmpty ? _comment1Ctrl[i].text.trim() : null,
        comment2: _comment2Ctrl[i].text.trim().isNotEmpty ? _comment2Ctrl[i].text.trim() : null,
        registeredAt: DateTime.now(),
      ));
    }
    if (stories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('등록할 데이터를 입력해주세요')));
      return;
    }
    setState(() => _isLoading = true);
    await MockService.addStories(stories);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${stories.length}건 등록 완료')));
      Navigator.pop(context);
    }
  }

  Future<void> _registerFromPreview() async {
    if (_previewRows.isEmpty) return;
    setState(() => _isLoading = true);
    final stories = _previewRows.asMap().entries.map((e) {
      final r = e.value;
      return MemberStoryModel(
        id: DateTime.now().millisecondsSinceEpoch + e.key,
        memberId: 0,
        memberName: r['이름'] ?? '',
        peer: r['또래'],
        leaderName: r['리더'],
        lineOut: r['라인아웃'] == 'Y',
        lineOutReason: r['라인아웃 요청 사유'],
        currentStatus: r['현재 상태'],
        previousCommunity: r['이전 공동체'],
        trainingService: r['훈련/섬김'],
        comment1: r['코멘트1'],
        comment2: r['코멘트2'],
        registeredAt: DateTime.now(),
      );
    }).where((s) => s.memberName.isNotEmpty).toList();

    await MockService.addStories(stories);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${stories.length}건 등록 완료')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'direct' ? '리더 스토리 직접 등록' : '리더 스토리 엑셀 업로드'),
      ),
      body: widget.mode == 'direct' ? _buildDirectMode() : _buildUploadMode(),
    );
  }

  // ── 직접 등록 모드 ──────────────────────────────────────────────

  Widget _buildDirectMode() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.primaryLight,
          child: const Text(
            '최대 20행까지 입력 가능합니다. 이름이 빈 행은 무시됩니다.',
            style: TextStyle(fontSize: 12, color: AppTheme.primary),
          ),
        ),
        _buildDirectHeader(),
        Expanded(
          child: SingleChildScrollView(child: _buildDirectGrid()),
        ),
        _buildDirectBottomBar(),
      ],
    );
  }

  Widget _buildDirectHeader() {
    const s = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _hCell('#', 36),
          _hCell('이름 *', 90, style: s),
          _hCell('또래', 80, style: s),
          _hCell('리더', 90, style: s),
          _hCell('라인아웃', 72, style: s),
          _hCell('라인아웃 사유', 130, style: s),
          _hCell('현재 상태', 110, style: s),
          _hCell('이전 공동체', 120, style: s),
          _hCell('훈련/섬김', 120, style: s),
          _hCell('코멘트1', 150, style: s),
          _hCell('코멘트2', 150, style: s),
        ]),
      ),
    );
  }

  Widget _hCell(String text, double w, {TextStyle? style}) => SizedBox(
    width: w,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      child: Text(text, style: style ?? const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ),
  );

  Widget _buildDirectGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: List.generate(_maxRows, (i) {
          final isEven = i % 2 == 0;
          return Container(
            color: isEven ? Colors.white : const Color(0xFFF8FAFC),
            child: Row(children: [
              SizedBox(width: 36, child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)))),
              _ic(_nameCtrl[i], 90),
              _ic(_peerCtrl[i], 80, hint: '예: 98년생'),
              _ic(_leaderCtrl[i], 90, hint: '리더명'),
              SizedBox(width: 72, child: Center(child: Checkbox(value: _lineOutValues[i], onChanged: (v) => setState(() => _lineOutValues[i] = v ?? false), activeColor: AppTheme.primary))),
              _ic(_reasonCtrl[i], 130, hint: '사유'),
              _ic(_statusCtrl[i], 110, hint: '활동중/라인아웃'),
              _ic(_prevCommCtrl[i], 120, hint: '이전 공동체'),
              _ic(_trainingCtrl[i], 120, hint: 'DT, 새가족팀'),
              _ic(_comment1Ctrl[i], 150),
              _ic(_comment2Ctrl[i], 150),
            ]),
          );
        }),
      ),
    );
  }

  Widget _ic(TextEditingController ctrl, double w, {String hint = ''}) => SizedBox(
    width: w,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.primary)),
        ),
      ),
    ),
  );

  Widget _buildDirectBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppTheme.textSecondary)),
              child: const Text('초기화', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerDirect,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('등록하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 업로드 모드 ──────────────────────────────────────────────────

  Widget _buildUploadMode() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateSection(),
                const SizedBox(height: 24),
                _buildUploadSection(),
                if (_isParsed && _previewRows.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildPreviewSection(),
                ],
              ],
            ),
          ),
        ),
        if (_isParsed && _previewRows.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppTheme.textSecondary)),
                    child: const Text('초기화', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerFromPreview,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('${_previewRows.length}건 등록하기', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTemplateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
            SizedBox(width: 6),
            Text('업로드 양식 안내', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 8),
          const Text(
            'CSV 파일 형식으로 업로드하세요.\n첫 번째 행은 헤더이며, 아래 컬럼 순서를 따라야 합니다.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            '이름, 또래, 리더, 라인아웃(Y/N), 라인아웃 요청 사유, 현재 상태, 이전 공동체, 훈련/섬김, 코멘트1, 코멘트2',
            style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _downloadTemplate,
            icon: const Icon(Icons.download, size: 14, color: AppTheme.primary),
            label: const Text('템플릿 다운로드', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadTemplate() {
    const header = '이름,또래,리더,라인아웃(Y/N),라인아웃 요청 사유,현재 상태,이전 공동체,훈련/섬김,코멘트1,코멘트2';
    const example = '홍길동,98년생,이리더,N,,활동중,청소년부,DT수료,성실함,';
    downloadText('\uFEFF$header\n$example\n', '리더스토리_업로드양식.csv');
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('파일 업로드', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primaryLight,
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_file_outlined, size: 40, color: AppTheme.primary),
                const SizedBox(height: 8),
                const Text('CSV 파일을 선택하세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text(
                  _uploadStatus.isEmpty ? '.csv 파일만 지원됩니다' : _uploadStatus,
                  style: TextStyle(fontSize: 12, color: _uploadStatus.startsWith('오류') ? AppTheme.absent : AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickFile() {
    pickCsvFile(
      onParsed: (rows) {
        setState(() {
          _previewRows = rows;
          _isParsed = true;
          _uploadStatus = '${rows.length}행 파싱 완료';
        });
      },
      onError: (msg) => setState(() => _uploadStatus = '오류: $msg'),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('미리보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Text('${_previewRows.length}건', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: (_previewRows.isNotEmpty ? _previewRows.first.keys : <String>[])
                  .map((k) => DataColumn(label: Text(k, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))))
                  .toList(),
              rows: _previewRows.take(5).map((row) => DataRow(
                cells: row.values.map((v) => DataCell(Text(v, style: const TextStyle(fontSize: 11)))).toList(),
              )).toList(),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 36,
              headingRowHeight: 36,
              columnSpacing: 12,
            ),
          ),
        ),
        if (_previewRows.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('외 ${_previewRows.length - 5}건 더...', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
      ],
    );
  }
}

