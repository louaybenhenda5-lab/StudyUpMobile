import 'package:flutter/foundation.dart';
import '../models/Schedule.dart';
import '../services/ScheduleService.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  List<Schedule>? _schedules;
  Schedule? _currentSchedule;
  bool _isLoading = false;
  String? _error;

  List<Schedule>? get schedules => _schedules;
  Schedule? get currentSchedule => _currentSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSchedules(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _service.getSchedules(token);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSchedule(String token, String classroomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSchedule = await _service.getSchedule(token, classroomId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _currentSchedule = null;
    _schedules = null;
    notifyListeners();
  }
}
