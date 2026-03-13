class CellModel {
  final int id;
  final String name;
  final int leaderId;
  final String leaderName;
  final int villageId;

  CellModel({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.leaderName,
    required this.villageId,
  });

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(
      id: json['id'],
      name: json['name'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'] ?? '',
      villageId: json['villageId'],
    );
  }
}
