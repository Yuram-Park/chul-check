import 'cell_model.dart';

class VillageModel {
  final int id;
  final String name;
  final int masterId;
  final String masterName;
  final List<CellModel> cells;

  VillageModel({
    required this.id,
    required this.name,
    required this.masterId,
    required this.masterName,
    this.cells = const [],
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'],
      name: json['name'],
      masterId: json['masterId'],
      masterName: json['masterName'] ?? '',
      cells:
          (json['cells'] as List<dynamic>?)
              ?.map((c) => CellModel.fromJson(c))
              .toList() ??
          [],
    );
  }
}
