import 'user_model.dart';

class MemberModel {
  final int id;
  final String name;
  final String phone;
  final Gender gender;
  final int cellId;
  final String cellName;
  final int? villageId;
  final String? villageName;
  final int? villageMasterId;
  final String? villageMasterName;
  final int? leaderId;
  final String? leaderName;
  final String? peer; // 또래 (예: 96년생)
  final String? birthDate; // yyyy-MM-dd
  final bool lineOut; // 라인아웃 여부
  final DateTime registeredAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.cellId,
    required this.cellName,
    this.villageId,
    this.villageName,
    this.villageMasterId,
    this.villageMasterName,
    this.leaderId,
    this.leaderName,
    this.peer,
    this.birthDate,
    this.lineOut = false,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'] == 'MALE' ? Gender.male : Gender.female,
      cellId: json['cellId'],
      cellName: json['cellName'] ?? '',
      villageId: json['villageId'],
      villageName: json['villageName'],
      villageMasterId: json['villageMasterId'],
      villageMasterName: json['villageMasterName'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      peer: json['peer'],
      birthDate: json['birthDate'],
      lineOut: json['lineOut'] ?? false,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
    );
  }

  MemberModel copyWith({
    int? id,
    String? name,
    String? phone,
    Gender? gender,
    int? cellId,
    String? cellName,
    int? villageId,
    String? villageName,
    int? villageMasterId,
    String? villageMasterName,
    int? leaderId,
    String? leaderName,
    String? peer,
    String? birthDate,
    bool? lineOut,
    DateTime? registeredAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      cellId: cellId ?? this.cellId,
      cellName: cellName ?? this.cellName,
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      villageMasterId: villageMasterId ?? this.villageMasterId,
      villageMasterName: villageMasterName ?? this.villageMasterName,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      peer: peer ?? this.peer,
      birthDate: birthDate ?? this.birthDate,
      lineOut: lineOut ?? this.lineOut,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  String get genderDisplay => gender == Gender.male ? '남' : '여';
  String get lineOutDisplay => lineOut ? 'Y' : 'N';
}
