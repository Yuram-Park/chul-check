enum UserRole { leader, villageMaster, admin, superAdmin }

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
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'VILLAGE_MASTER':
        return UserRole.villageMaster;
      default:
        return UserRole.leader;
    }
  }

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isSuperAdmin => role == UserRole.superAdmin;

  String get roleDisplayName {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return '간사/교역자';
      case UserRole.villageMaster:
        return '마을장';
      case UserRole.leader:
        return '리더';
    }
  }
}
