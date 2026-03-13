enum AttendanceStatus { present, absent, late, etc }

enum ServiceType { main, youth }

class AttendanceModel {
  final int memberId;
  final String memberName;
  AttendanceStatus status;
  String memo;
  final ServiceType serviceType;

  AttendanceModel({
    required this.memberId,
    required this.memberName,
    this.status = AttendanceStatus.absent,
    this.memo = '',
    this.serviceType = ServiceType.youth,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      memberId: json['memberId'],
      memberName: json['memberName'] ?? '',
      status: _parseStatus(json['status']),
      memo: json['memo'] ?? '',
      serviceType:
          json['serviceType'] == 'MAIN' ? ServiceType.main : ServiceType.youth,
    );
  }

  static AttendanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'LATE':
        return AttendanceStatus.late;
      case 'ETC':
        return AttendanceStatus.etc;
      default:
        return AttendanceStatus.absent;
    }
  }

  String get statusCode {
    switch (status) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.absent:
        return 'ABSENT';
      case AttendanceStatus.late:
        return 'LATE';
      case AttendanceStatus.etc:
        return 'ETC';
    }
  }

  String get statusDisplay {
    switch (status) {
      case AttendanceStatus.present:
        return '출석';
      case AttendanceStatus.absent:
        return '결석';
      case AttendanceStatus.late:
        return '지각';
      case AttendanceStatus.etc:
        return '기타';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'status': statusCode,
      'memo': memo,
      'serviceType': serviceType == ServiceType.main ? 'MAIN' : 'YOUTH',
    };
  }
}
