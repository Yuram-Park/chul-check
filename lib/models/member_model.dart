import 'user_model.dart';

class MemberModel {
  final int id;
  final String name;
  final String phone;
  final Gender gender;
  final int cellId;
  final String cellName;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.cellId,
    required this.cellName,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'] == 'MALE' ? Gender.male : Gender.female,
      cellId: json['cellId'],
      cellName: json['cellName'] ?? '',
    );
  }

  String get genderDisplay => gender == Gender.male ? '남' : '여';
}
