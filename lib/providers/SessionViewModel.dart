import 'package:flutter/foundation.dart';
import '../models/Session.dart';
import '../models/User.dart';
import '../services/SessionService.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionService _service = SessionService();

  Session? _todaySession;
  List<Session> _mySessions = [];
  bool _isLoading = false;
  String? _error;

  Session? get todaySession => _todaySession;
  List<Session> get mySessions => _mySessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodaySession(String token, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaySession = await _service.getSession(token, userId);
    } catch (e) {
      _error = e.toString();
      _todaySession = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMySessions(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mySessions = await _service.getMySessions(token);
    } catch (e) {
      _error = e.toString();
      _mySessions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<User>> loadStudentsByClass(String token, String classroomId) async {
    try {
      return await _service.getStudentsByClass(token, classroomId);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<bool> deleteSession(String token, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteSession(token, sessionId);
      _todaySession = null;
      _mySessions = _mySessions.where((s) => s.id != sessionId).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _todaySession = null;
    _mySessions = [];
    notifyListeners();
  }
}
