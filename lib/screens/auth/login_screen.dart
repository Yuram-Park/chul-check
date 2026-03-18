import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _lastFourFocusNode = FocusNode();

  @override
  void dispose() {
    _idController.dispose();
    _lastFourController.dispose();
    _lastFourFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final idKey = _idController.text.trim();
    final lastFour = _lastFourController.text.trim();
    final success = await context.read<AuthProvider>().login(idKey, lastFour);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().errorMessage ?? '로그인 실패'),
          backgroundColor: AppTheme.absent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                // 로고
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    '출첵',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '청년부 출석 관리',
                    style: TextStyle(
                        fontSize: 15, color: AppTheme.textSecondary),
                  ),
                ),
                const Spacer(flex: 2),
                // 이름 + 생일 4자리
                const Text(
                  '이름 + 생일 4자리',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_lastFourFocusNode);
                  },
                  decoration: InputDecoration(
                    hintText: '홍길동0112',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '이름과 생일 4자리를 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 휴대전화번호 뒤 4자리
                const Text(
                  '휴대전화번호 뒤 4자리',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastFourController,
                  focusNode: _lastFourFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: '1234',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '전화번호 뒤 4자리를 입력하세요';
                    if (v.length < 4) return '4자리를 모두 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // 테스트 계정 안내
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('테스트 계정',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF15803D))),
                      SizedBox(height: 4),
                      Text('리더: 이리더0101 / 0001',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF166534))),
                      Text('마을장: 김마을장0202 / 0002',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF166534))),
                      Text('간사: 박간사0303 / 0003',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF166534))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('로그인'),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
