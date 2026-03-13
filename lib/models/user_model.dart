enum UserRole { leader, villageMaster, admin }

enum Gender { male, female }

class UserModel {
  final int id;
  final String name;
  final String phone;
  final Gender gender;
  final UserRole role;
  final int? cellId;
  final String? cellName;
  final int? villageId;
  final String? villageName;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.role,
    this.cellId,
    this.cellName,
    this.villageId,
    this.villageName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'] == 'MALE' ? Gender.male : Gender.female,
      role: _parseRole(json['role']),
      cellId: json['cellId'],
      cellName: json['cellName'],
      villageId: json['villageId'],
      villageName: json['villageName'],
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'ADMIN':
        return UserRole.admin;
      case 'VILLAGE_MASTER':
        return UserRole.villageMaster;
      default:
        return UserRole.leader;
    }
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return '간사/교역자';
      case UserRole.villageMaster:
        return '마을장';
      case UserRole.leader:
        return '리더';
    }
  }
}
