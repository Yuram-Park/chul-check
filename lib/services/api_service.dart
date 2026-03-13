import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/member_model.dart';
import '../models/attendance_model.dart';
import '../models/cell_model.dart';
import '../models/village_model.dart';

class ApiService {
  // 실제 서버 주소로 변경하세요
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── 인증 ──────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('로그인 실패: ${response.statusCode}');
  }

  static Future<UserModel> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('사용자 정보 조회 실패');
  }

  // ── 셀원 ──────────────────────────────────────────
  static Future<List<MemberModel>> getCellMembers(int cellId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cells/$cellId/members'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((m) => MemberModel.fromJson(m)).toList();
    }
    throw Exception('셀원 조회 실패');
  }

  // ── 출석 ──────────────────────────────────────────
  static Future<List<AttendanceModel>> getAttendance(
    int cellId,
    String date,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/$date?cellId=$cellId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((a) => AttendanceModel.fromJson(a)).toList();
    }
    throw Exception('출석 조회 실패');
  }

  static Future<void> submitAttendance(
    int cellId,
    String date,
    List<AttendanceModel> attendances,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance'),
      headers: await _headers(),
      body: jsonEncode({
        'cellId': cellId,
        'date': date,
        'attendances': attendances.map((a) => a.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('출석 제출 실패: ${response.statusCode}');
    }
  }

  static Future<void> updateAttendance(
    int cellId,
    String date,
    List<AttendanceModel> attendances,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/attendance'),
      headers: await _headers(),
      body: jsonEncode({
        'cellId': cellId,
        'date': date,
        'attendances': attendances.map((a) => a.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('출석 수정 실패: ${response.statusCode}');
    }
  }

  // ── 마을 ──────────────────────────────────────────
  static Future<List<CellModel>> getVillageCells(int villageId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/villages/$villageId/cells'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((c) => CellModel.fromJson(c)).toList();
    }
    throw Exception('마을 셀 조회 실패');
  }

  static Future<List<VillageModel>> getAllVillages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/villages'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((v) => VillageModel.fromJson(v)).toList();
    }
    throw Exception('마을 목록 조회 실패');
  }

  // ── 통계 ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getStats({
    int? villageId,
    int? cellId,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (villageId != null) params['villageId'] = villageId.toString();
    if (cellId != null) params['cellId'] = cellId.toString();
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final uri = Uri.parse(
      '$baseUrl/attendance/stats',
    ).replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('통계 조회 실패');
  }
}
