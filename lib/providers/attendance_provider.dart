import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../models/member_model.dart';
import '../services/mock_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _attendances = [];
  List<MemberModel> _members = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isSubmitted = false;
  List<AttendanceModel> _attendancesSnapshot = [];
  String? _errorMessage;

  List<AttendanceModel> get attendances => _attendances;
  List<MemberModel> get members => _members;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isEditMode => _isEditMode;
  bool get isSubmitted => _isSubmitted;
  String? get errorMessage => _errorMessage;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  int get presentCount =>
      _attendances.where((a) => a.status == AttendanceStatus.present).length;
  int get absentCount =>
      _attendances.where((a) => a.status == AttendanceStatus.absent).length;
  int get lateCount =>
      _attendances.where((a) => a.status == AttendanceStatus.late).length;
  int get etcCount =>
      _attendances.where((a) => a.status == AttendanceStatus.etc).length;

  Future<void> loadCellData(int cellId) async {
    _isLoading = true;
    _isSubmitted = false;
    _isEditMode = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await MockService.getCellMembers(cellId);
      final savedAttendances = await MockService.getAttendance(cellId, formattedDate);

      if (savedAttendances.isNotEmpty) {
        _attendances = savedAttendances;
      } else {
        _attendances = _members
            .map((m) => AttendanceModel(
                  memberId: m.id,
                  memberName: m.name,
                  status: AttendanceStatus.absent,
                ))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDate(DateTime date, int cellId) {
    _selectedDate = date;
    loadCellData(cellId);
  }

  void updateStatus(int memberId, AttendanceStatus status) {
    final idx = _attendances.indexWhere((a) => a.memberId == memberId);
    if (idx != -1) {
      _attendances[idx].status = status;
      notifyListeners();
    }
  }

  void updateMemo(int memberId, String memo) {
    final idx = _attendances.indexWhere((a) => a.memberId == memberId);
    if (idx != -1) {
      _attendances[idx].memo = memo;
      notifyListeners();
    }
  }

  void enterEditMode() {
    _attendancesSnapshot = _attendances
        .map((a) => AttendanceModel(
              memberId: a.memberId,
              memberName: a.memberName,
              status: a.status,
              memo: a.memo,
              serviceType: a.serviceType,
            ))
        .toList();
    _isEditMode = true;
    notifyListeners();
  }

  void cancelEdit() {
    _attendances = _attendancesSnapshot;
    _isEditMode = false;
    notifyListeners();
  }

  Future<bool> submit(int cellId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await MockService.submitAttendance(cellId, formattedDate, _attendances);
      _isSubmitted = true;
      _isEditMode = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
