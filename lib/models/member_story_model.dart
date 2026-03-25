class MemberStoryModel {
  final int id;
  final int memberId;
  final String memberName;
  final String? peer;
  final String? villageName;
  final String? villageMasterName;
  final String? leaderName;
  final bool lineOut;
  final String? lineOutReason; // 라인아웃 요청 사유
  final String? currentStatus; // 현재 상태
  final String? previousCommunity; // 이전 공동체
  final String? trainingService; // 훈련 및 섬김
  final String? comment1; // 코멘트 1
  final String? comment2; // 코멘트 2
  final DateTime registeredAt;

  MemberStoryModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    this.peer,
    this.villageName,
    this.villageMasterName,
    this.leaderName,
    this.lineOut = false,
    this.lineOutReason,
    this.currentStatus,
    this.previousCommunity,
    this.trainingService,
    this.comment1,
    this.comment2,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  MemberStoryModel copyWith({
    int? id,
    int? memberId,
    String? memberName,
    String? peer,
    String? villageName,
    String? villageMasterName,
    String? leaderName,
    bool? lineOut,
    String? lineOutReason,
    String? currentStatus,
    String? previousCommunity,
    String? trainingService,
    String? comment1,
    String? comment2,
    DateTime? registeredAt,
  }) {
    return MemberStoryModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      peer: peer ?? this.peer,
      villageName: villageName ?? this.villageName,
      villageMasterName: villageMasterName ?? this.villageMasterName,
      leaderName: leaderName ?? this.leaderName,
      lineOut: lineOut ?? this.lineOut,
      lineOutReason: lineOutReason ?? this.lineOutReason,
      currentStatus: currentStatus ?? this.currentStatus,
      previousCommunity: previousCommunity ?? this.previousCommunity,
      trainingService: trainingService ?? this.trainingService,
      comment1: comment1 ?? this.comment1,
      comment2: comment2 ?? this.comment2,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  String get lineOutDisplay => lineOut ? 'Y' : 'N';

  /// CSV 헤더
  static String csvHeader() =>
      '번호,이름,또래,마을장,리더,라인아웃,라인아웃 요청 사유,현재 상태,이전 공동체,훈련/섬김,코멘트1,코멘트2,등록일';

  /// CSV 한 행
  String toCsvRow(int index) {
    String esc(String? v) {
      if (v == null || v.isEmpty) return '';
      if (v.contains(',') || v.contains('"') || v.contains('\n')) {
        return '"${v.replaceAll('"', '""')}"';
      }
      return v;
    }

    return '${index + 1},${esc(memberName)},${esc(peer)},${esc(villageMasterName)},'
        '${esc(leaderName)},${lineOutDisplay},${esc(lineOutReason)},'
        '${esc(currentStatus)},${esc(previousCommunity)},${esc(trainingService)},'
        '${esc(comment1)},${esc(comment2)},${registeredAt.toIso8601String().split('T').first}';
  }
}
