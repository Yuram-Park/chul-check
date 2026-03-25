// 백엔드 서버 없이 UI 확인을 위한 Mock 데이터 서비스
import '../models/user_model.dart';
import '../models/member_model.dart';
import '../models/member_story_model.dart';
import '../models/attendance_model.dart';
import '../models/cell_model.dart';
import '../models/village_model.dart';

class MockService {
  static final List<MemberModel> _allMembers = [
    MemberModel(
      id: 101, name: '김민준', phone: '010-1234-5678', gender: Gender.male,
      cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 10, leaderName: '이리더',
      peer: '98년생', birthDate: '1998-03-15', lineOut: false,
      registeredAt: DateTime(2024, 1, 5),
    ),
    MemberModel(
      id: 102, name: '이서연', phone: '010-2345-6789', gender: Gender.female,
      cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 10, leaderName: '이리더',
      peer: '99년생', birthDate: '1999-07-22', lineOut: false,
      registeredAt: DateTime(2024, 1, 10),
    ),
    MemberModel(
      id: 103, name: '박지훈', phone: '010-3456-7890', gender: Gender.male,
      cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 10, leaderName: '이리더',
      peer: '97년생', birthDate: '1997-11-30', lineOut: true,
      registeredAt: DateTime(2024, 2, 3),
    ),
    MemberModel(
      id: 104, name: '최수아', phone: '010-4567-8901', gender: Gender.female,
      cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 10, leaderName: '이리더',
      peer: '00년생', birthDate: '2000-05-18', lineOut: false,
      registeredAt: DateTime(2024, 3, 12),
    ),
    MemberModel(
      id: 105, name: '정현우', phone: '010-5678-9012', gender: Gender.male,
      cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 10, leaderName: '이리더',
      peer: '01년생', birthDate: '2001-09-04', lineOut: false,
      registeredAt: DateTime(2024, 4, 20),
    ),
    MemberModel(
      id: 201, name: '윤지은', phone: '010-6789-0123', gender: Gender.female,
      cellId: 2, cellName: '사랑셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 11, leaderName: '박리더',
      peer: '98년생', birthDate: '1998-12-01', lineOut: false,
      registeredAt: DateTime(2024, 1, 8),
    ),
    MemberModel(
      id: 202, name: '강태양', phone: '010-7890-1234', gender: Gender.male,
      cellId: 2, cellName: '사랑셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 11, leaderName: '박리더',
      peer: '96년생', birthDate: '1996-06-14', lineOut: false,
      registeredAt: DateTime(2024, 2, 15),
    ),
    MemberModel(
      id: 203, name: '임나연', phone: '010-8901-2345', gender: Gender.female,
      cellId: 2, cellName: '사랑셀', villageId: 1, villageName: '다윗마을',
      villageMasterId: 20, villageMasterName: '김마을장',
      leaderId: 11, leaderName: '박리더',
      peer: '00년생', birthDate: '2000-02-28', lineOut: true,
      registeredAt: DateTime(2024, 5, 7),
    ),
    MemberModel(
      id: 301, name: '한동훈', phone: '010-9012-3456', gender: Gender.male,
      cellId: 3, cellName: '믿음셀', villageId: 2, villageName: '솔로몬마을',
      villageMasterId: 21, villageMasterName: '이마을장',
      leaderId: 12, leaderName: '최리더',
      peer: '97년생', birthDate: '1997-04-10', lineOut: false,
      registeredAt: DateTime(2024, 1, 15),
    ),
    MemberModel(
      id: 302, name: '오혜진', phone: '010-0123-4567', gender: Gender.female,
      cellId: 3, cellName: '믿음셀', villageId: 2, villageName: '솔로몬마을',
      villageMasterId: 21, villageMasterName: '이마을장',
      leaderId: 12, leaderName: '최리더',
      peer: '99년생', birthDate: '1999-08-25', lineOut: false,
      registeredAt: DateTime(2024, 3, 1),
    ),
    MemberModel(
      id: 303, name: '신재원', phone: '010-1122-3344', gender: Gender.male,
      cellId: 3, cellName: '믿음셀', villageId: 2, villageName: '솔로몬마을',
      villageMasterId: 21, villageMasterName: '이마을장',
      leaderId: 12, leaderName: '최리더',
      peer: '01년생', birthDate: '2001-01-17', lineOut: false,
      registeredAt: DateTime(2024, 6, 9),
    ),
    MemberModel(
      id: 304, name: '류미소', phone: '010-2233-4455', gender: Gender.female,
      cellId: 3, cellName: '믿음셀', villageId: 2, villageName: '솔로몬마을',
      villageMasterId: 21, villageMasterName: '이마을장',
      leaderId: 12, leaderName: '최리더',
      peer: '98년생', birthDate: '1998-10-03', lineOut: true,
      registeredAt: DateTime(2024, 7, 22),
    ),
  ];

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

  // idKey(이름+생일4자리) + lastFour(전화번호 뒤 4자리) → UserModel 매핑 (테스트용)
  static final List<UserModel> _users = [
    UserModel(
      id: 10, name: '이리더', phone: '010-0000-0001', gender: Gender.male,
      role: UserRole.leader, cellId: 1, cellName: '소망셀', villageId: 1, villageName: '다윗마을',
    ),
    UserModel(
      id: 11, name: '박리더', phone: '010-0000-0011', gender: Gender.male,
      role: UserRole.leader, cellId: 2, cellName: '사랑셀', villageId: 1, villageName: '다윗마을',
    ),
    UserModel(
      id: 12, name: '최리더', phone: '010-0000-0012', gender: Gender.male,
      role: UserRole.leader, cellId: 3, cellName: '믿음셀', villageId: 2, villageName: '솔로몬마을',
    ),
    UserModel(
      id: 20, name: '김마을장', phone: '010-0000-0002', gender: Gender.male,
      role: UserRole.villageMaster, villageId: 1, villageName: '다윗마을',
    ),
    UserModel(
      id: 21, name: '이마을장', phone: '010-0000-0021', gender: Gender.male,
      role: UserRole.villageMaster, villageId: 2, villageName: '솔로몬마을',
    ),
    UserModel(
      id: 30, name: '박간사', phone: '010-0000-0003', gender: Gender.female,
      role: UserRole.admin,
    ),
    UserModel(
      id: 31, name: '김수퍼', phone: '010-0000-0031', gender: Gender.male,
      role: UserRole.superAdmin,
    ),
  ];

  static final _loginMap = {
    '이리더0101|0001': 10,
    '김마을장0202|0002': 20,
    '박간사0303|0003': 30,
    '김수퍼0101|0031': 31,
  };

  static Future<UserModel> login(String idKey, String lastFour) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final key = '$idKey|$lastFour';
    final userId = _loginMap[key];
    if (userId == null) throw Exception('등록되지 않은 계정입니다');
    return _users.firstWhere((u) => u.id == userId);
  }

  static Future<List<MemberModel>> getCellMembers(int cellId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allMembers.where((m) => m.cellId == cellId).toList();
  }

  static Future<List<MemberModel>> getAllMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = List<MemberModel>.from(_allMembers);
    list.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return list;
  }

  static Future<void> addMembers(List<MemberModel> newMembers) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _allMembers.addAll(newMembers);
  }

  static Future<List<AttendanceModel>> getAttendance(int cellId, String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final members = _allMembers.where((m) => m.cellId == cellId).toList();
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

  static Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<UserModel>.from(_users);
  }

  static Future<void> updateUserRole(int userId, UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = UserModel(
        id: _users[idx].id,
        name: _users[idx].name,
        phone: _users[idx].phone,
        gender: _users[idx].gender,
        role: newRole,
        cellId: _users[idx].cellId,
        cellName: _users[idx].cellName,
        villageId: _users[idx].villageId,
        villageName: _users[idx].villageName,
      );
    }
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

  static Future<Map<int, double>> getMemberAttendanceRates(List<int> memberIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final Map<int, double> rates = {};
    for (final id in memberIds) {
      rates[id] = (50 + (id % 50)).toDouble();
    }
    return rates;
  }

  // ─── 리더 스토리 ───────────────────────────────────────────────

  static final List<MemberStoryModel> _stories = [
    MemberStoryModel(
      id: 1, memberId: 101, memberName: '김민준', peer: '98년생',
      villageName: '다윗마을', villageMasterName: '김마을장', leaderName: '이리더',
      lineOut: false, lineOutReason: null,
      currentStatus: '활동중', previousCommunity: '청소년부',
      trainingService: '새가족팀', comment1: '성실히 출석 중', comment2: null,
      registeredAt: DateTime(2024, 3, 10),
    ),
    MemberStoryModel(
      id: 2, memberId: 102, memberName: '이서연', peer: '99년생',
      villageName: '다윗마을', villageMasterName: '김마을장', leaderName: '이리더',
      lineOut: false, lineOutReason: null,
      currentStatus: '활동중', previousCommunity: null,
      trainingService: 'DT수료', comment1: '리더십 관심 있음', comment2: null,
      registeredAt: DateTime(2024, 3, 12),
    ),
    MemberStoryModel(
      id: 3, memberId: 103, memberName: '박지훈', peer: '97년생',
      villageName: '다윗마을', villageMasterName: '김마을장', leaderName: '이리더',
      lineOut: true, lineOutReason: '타지역 이사',
      currentStatus: '라인아웃', previousCommunity: '직장부',
      trainingService: null, comment1: '연락 두절', comment2: '재등록 가능성 있음',
      registeredAt: DateTime(2024, 4, 1),
    ),
    MemberStoryModel(
      id: 4, memberId: 201, memberName: '윤지은', peer: '98년생',
      villageName: '다윗마을', villageMasterName: '김마을장', leaderName: '박리더',
      lineOut: false, lineOutReason: null,
      currentStatus: '활동중', previousCommunity: '찬양팀',
      trainingService: '팀장', comment1: '찬양 은사', comment2: null,
      registeredAt: DateTime(2024, 2, 20),
    ),
    MemberStoryModel(
      id: 5, memberId: 203, memberName: '임나연', peer: '00년생',
      villageName: '다윗마을', villageMasterName: '김마을장', leaderName: '박리더',
      lineOut: true, lineOutReason: '학업',
      currentStatus: '등록대기', previousCommunity: null,
      trainingService: null, comment1: '복학 후 재연결 예정', comment2: null,
      registeredAt: DateTime(2024, 5, 15),
    ),
    MemberStoryModel(
      id: 6, memberId: 301, memberName: '한동훈', peer: '97년생',
      villageName: '솔로몬마을', villageMasterName: '이마을장', leaderName: '최리더',
      lineOut: false, lineOutReason: null,
      currentStatus: '활동중', previousCommunity: '중등부',
      trainingService: 'DT수료, 새가족팀', comment1: null, comment2: null,
      registeredAt: DateTime(2024, 1, 30),
    ),
    MemberStoryModel(
      id: 7, memberId: 304, memberName: '류미소', peer: '98년생',
      villageName: '솔로몬마을', villageMasterName: '이마을장', leaderName: '최리더',
      lineOut: true, lineOutReason: '군입대',
      currentStatus: '라인아웃', previousCommunity: null,
      trainingService: null, comment1: '전역 후 복귀 예정 24.12', comment2: null,
      registeredAt: DateTime(2024, 7, 22),
    ),
  ];

  static Future<List<MemberStoryModel>> getAllStories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = List<MemberStoryModel>.from(_stories);
    list.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return list;
  }

  static Future<void> addStories(List<MemberStoryModel> newStories) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _stories.addAll(newStories);
  }
}
