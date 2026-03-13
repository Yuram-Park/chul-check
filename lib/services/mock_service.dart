// 백엔드 서버 없이 UI 확인을 위한 Mock 데이터 서비스
import '../models/user_model.dart';
import '../models/member_model.dart';
import '../models/attendance_model.dart';
import '../models/cell_model.dart';
import '../models/village_model.dart';

class MockService {
  static final _members = <int, List<MemberModel>>{
    1: [
      MemberModel(id: 101, name: '김민준', phone: '010-1234-5678', gender: Gender.male, cellId: 1, cellName: '소망셀'),
      MemberModel(id: 102, name: '이서연', phone: '010-2345-6789', gender: Gender.female, cellId: 1, cellName: '소망셀'),
      MemberModel(id: 103, name: '박지훈', phone: '010-3456-7890', gender: Gender.male, cellId: 1, cellName: '소망셀'),
      MemberModel(id: 104, name: '최수아', phone: '010-4567-8901', gender: Gender.female, cellId: 1, cellName: '소망셀'),
      MemberModel(id: 105, name: '정현우', phone: '010-5678-9012', gender: Gender.male, cellId: 1, cellName: '소망셀'),
    ],
    2: [
      MemberModel(id: 201, name: '윤지은', phone: '010-6789-0123', gender: Gender.female, cellId: 2, cellName: '사랑셀'),
      MemberModel(id: 202, name: '강태양', phone: '010-7890-1234', gender: Gender.male, cellId: 2, cellName: '사랑셀'),
      MemberModel(id: 203, name: '임나연', phone: '010-8901-2345', gender: Gender.female, cellId: 2, cellName: '사랑셀'),
    ],
    3: [
      MemberModel(id: 301, name: '한동훈', phone: '010-9012-3456', gender: Gender.male, cellId: 3, cellName: '믿음셀'),
      MemberModel(id: 302, name: '오혜진', phone: '010-0123-4567', gender: Gender.female, cellId: 3, cellName: '믿음셀'),
      MemberModel(id: 303, name: '신재원', phone: '010-1122-3344', gender: Gender.male, cellId: 3, cellName: '믿음셀'),
      MemberModel(id: 304, name: '류미소', phone: '010-2233-4455', gender: Gender.female, cellId: 3, cellName: '믿음셀'),
    ],
  };

  static final _cells = [
    CellModel(id: 1, name: '소망셀', leaderId: 10, leaderName: '이리더', villageId: 1),
    CellModel(id: 2, name: '사랑셀', leaderId: 11, leaderName: '박리더', villageId: 1),
    CellModel(id: 3, name: '믿음셀', leaderId: 12, leaderName: '최리더', villageId: 2),
    CellModel(id: 4, name: '기쁨셀', leaderId: 13, leaderName: '정리더', villageId: 2),
  ];

  static final _villages = [
    VillageModel(
      id: 1,
      name: '다윗마을',
      masterId: 20,
      masterName: '김마을장',
      cells: [
        CellModel(id: 1, name: '소망셀', leaderId: 10, leaderName: '이리더', villageId: 1),
        CellModel(id: 2, name: '사랑셀', leaderId: 11, leaderName: '박리더', villageId: 1),
      ],
    ),
    VillageModel(
      id: 2,
      name: '솔로몬마을',
      masterId: 21,
      masterName: '이마을장',
      cells: [
        CellModel(id: 3, name: '믿음셀', leaderId: 12, leaderName: '최리더', villageId: 2),
        CellModel(id: 4, name: '기쁨셀', leaderId: 13, leaderName: '정리더', villageId: 2),
      ],
    ),
  ];

  // phone → UserModel 매핑 (테스트용)
  static final _users = {
    '010-0000-0001': UserModel(
      id: 10, name: '이리더', phone: '010-0000-0001', gender: Gender.male,
      role: UserRole.leader, cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
    ),
    '010-0000-0002': UserModel(
      id: 20, name: '김마을장', phone: '010-0000-0002', gender: Gender.male,
      role: UserRole.villageMaster, villageId: 1, villageName: '다윗마을',
    ),
    '010-0000-0003': UserModel(
      id: 30, name: '박간사', phone: '010-0000-0003', gender: Gender.female,
      role: UserRole.admin,
    ),
  };

  static Future<UserModel> login(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _users[phone];
    if (user == null) throw Exception('등록되지 않은 전화번호입니다');
    return user;
  }

  static Future<List<MemberModel>> getCellMembers(int cellId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _members[cellId] ?? [];
  }

  static Future<List<AttendanceModel>> getAttendance(int cellId, String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final members = _members[cellId] ?? [];
    return members.map((m) => AttendanceModel(
      memberId: m.id,
      memberName: m.name,
      status: AttendanceStatus.absent,
    )).toList();
  }

  static Future<void> submitAttendance(
    int cellId, String date, List<AttendanceModel> attendances) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<List<CellModel>> getVillageCells(int villageId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cells.where((c) => c.villageId == villageId).toList();
  }

  static Future<List<VillageModel>> getAllVillages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _villages;
  }

  static Future<Map<String, dynamic>> getStats({int? villageId, int? cellId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'totalMembers': 15,
      'presentCount': 10,
      'absentCount': 3,
      'lateCount': 1,
      'etcCount': 1,
      'attendanceRate': 73.3,
    };
  }
}
