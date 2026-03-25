import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../services/mock_service.dart';
import '../../utils/app_theme.dart';

class AdminMemberRegisterScreen extends StatefulWidget {
  const AdminMemberRegisterScreen({super.key});

  @override
  State<AdminMemberRegisterScreen> createState() => _AdminMemberRegisterScreenState();
}

class _AdminMemberRegisterScreenState extends State<AdminMemberRegisterScreen> {
  static const int _maxRows = 20;
  bool _isLoading = false;

  // 각 행의 컨트롤러
  late final List<TextEditingController> _nameCtrl;
  late final List<TextEditingController> _phoneCtrl;
  late final List<TextEditingController> _peerCtrl;
  late final List<TextEditingController> _birthCtrl;
  late final List<String?> _genderValues;
  late final List<bool> _lineOutValues;
  late final List<String?> _leaderValues;

  // 리더 목록 (셀 목록에서 파생)
  final List<String> _leaderOptions = ['이리더', '박리더', '최리더', '정리더'];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _phoneCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _peerCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _birthCtrl = List.generate(_maxRows, (_) => TextEditingController());
    _genderValues = List.filled(_maxRows, null);
    _lineOutValues = List.filled(_maxRows, false);
    _leaderValues = List.filled(_maxRows, null);
  }

  void _reset() {
    for (int i = 0; i < _maxRows; i++) {
      _nameCtrl[i].clear();
      _phoneCtrl[i].clear();
      _peerCtrl[i].clear();
      _birthCtrl[i].clear();
    }
    setState(() {
      for (int i = 0; i < _maxRows; i++) {
        _genderValues[i] = null;
        _lineOutValues[i] = false;
        _leaderValues[i] = null;
      }
    });
  }

  Future<void> _register() async {
    final newMembers = <MemberModel>[];

    for (int i = 0; i < _maxRows; i++) {
      final name = _nameCtrl[i].text.trim();
      if (name.isEmpty) continue;

      final phone = _phoneCtrl[i].text.trim();
      final gender = _genderValues[i] == '남' ? Gender.male : Gender.female;
      final peer = _peerCtrl[i].text.trim();
      final birth = _birthCtrl[i].text.trim();
      final lineOut = _lineOutValues[i];
      final leaderName = _leaderValues[i];

      // 리더 이름으로 셀 찾기 (mock)
      int cellId = 1;
      String cellName = '소망셀';
      if (leaderName == '박리더') { cellId = 2; cellName = '사랑셀'; }
      else if (leaderName == '최리더') { cellId = 3; cellName = '믿음셀'; }
      else if (leaderName == '정리더') { cellId = 4; cellName = '기쁨셀'; }

      newMembers.add(MemberModel(
        id: DateTime.now().millisecondsSinceEpoch + i,
        name: name,
        phone: phone.isEmpty ? '-' : phone,
        gender: gender,
        cellId: cellId,
        cellName: cellName,
        leaderName: leaderName,
        peer: peer.isEmpty ? null : peer,
        birthDate: birth.isEmpty ? null : birth,
        lineOut: lineOut,
        registeredAt: DateTime.now(),
      ));
    }

    if (newMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록할 셀원 정보를 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await MockService.addMembers(newMembers);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newMembers.length}명이 등록되었습니다')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (final c in _nameCtrl) c.dispose();
    for (final c in _phoneCtrl) c.dispose();
    for (final c in _peerCtrl) c.dispose();
    for (final c in _birthCtrl) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('셀원 등록'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Column(
        children: [
          // 안내 문구
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primaryLight,
            child: const Text(
              '최대 20명까지 동시 입력할 수 있습니다. 이름이 비어있는 행은 무시됩니다.',
              style: TextStyle(fontSize: 13, color: AppTheme.primary),
            ),
          ),
          // 테이블 헤더
          _buildHeader(),
          // 그리드
          Expanded(
            child: SingleChildScrollView(
              child: _buildGrid(),
            ),
          ),
          // 하단 버튼
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
    );
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _hCell('#', 40),
            _hCell('리더', 100, style: headerStyle),
            _hCell('이름 *', 100, style: headerStyle),
            _hCell('성별', 70, style: headerStyle),
            _hCell('또래', 90, style: headerStyle),
            _hCell('생년월일', 120, style: headerStyle),
            _hCell('전화번호', 140, style: headerStyle),
            _hCell('라인아웃', 80, style: headerStyle),
          ],
        ),
      ),
    );
  }

  Widget _hCell(String text, double width, {TextStyle? style}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(text, style: style ?? const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: List.generate(_maxRows, (i) => _buildRow(i)),
      ),
    );
  }

  Widget _buildRow(int i) {
    return Container(
      decoration: BoxDecoration(
        color: i % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // 번호
          SizedBox(
            width: 40,
            child: Center(
              child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ),
          ),
          // 리더
          _dropdownCell(
            width: 100,
            value: _leaderValues[i],
            hint: '선택',
            items: _leaderOptions,
            onChanged: (v) => setState(() => _leaderValues[i] = v),
          ),
          // 이름
          _inputCell(_nameCtrl[i], 100, hint: '이름'),
          // 성별
          _dropdownCell(
            width: 70,
            value: _genderValues[i],
            hint: '성별',
            items: const ['남', '여'],
            onChanged: (v) => setState(() => _genderValues[i] = v),
          ),
          // 또래
          _inputCell(_peerCtrl[i], 90, hint: '예: 98년생'),
          // 생년월일
          _inputCell(_birthCtrl[i], 120, hint: 'yyyy-MM-dd'),
          // 전화번호
          _inputCell(_phoneCtrl[i], 140, hint: '010-0000-0000'),
          // 라인아웃
          SizedBox(
            width: 80,
            child: Center(
              child: Checkbox(
                value: _lineOutValues[i],
                onChanged: (v) => setState(() => _lineOutValues[i] = v ?? false),
                activeColor: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCell(TextEditingController ctrl, double width, {String hint = ''}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: TextFormField(
          controller: ctrl,
          decoration: _inputDecoration(hint: hint),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _dropdownCell({
    required double width,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              items: items.map((v) => DropdownMenuItem(
                value: v,
                child: Text(v, style: const TextStyle(fontSize: 12)),
              )).toList(),
              onChanged: onChanged,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              iconSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.textSecondary),
              ),
              child: const Text('초기화', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('등록하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
