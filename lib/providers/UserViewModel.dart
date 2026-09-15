import 'package:flutter/foundation.dart';
import '../models/User.dart';
import '../models/enums/Role.dart';
import '../services/AuthService.dart';
import '../Utils/SharedPreferencesUtils.dart';

class UserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  String? _token;
  Roles? _role;
  String? _rawRole;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  Roles? get role => _role;
  String? get rawRole => _rawRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _currentUser != null;
  bool get isTeacher => _role == Roles.TEACHER || _rawRole == 'TEACHER';
  bool get isStudent => _role == Roles.STUDENT || _rawRole == 'STUDENT';
  bool get isAdmin => _rawRole == 'ADMIN' || _rawRole == 'SUPER_ADMIN';

  Future<void> loadFromStorage() async {
    final savedToken = await SharedPreferencesUtils.getToken();
    if (savedToken == null) return;

    _token = savedToken;
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getMe(savedToken);
      _role = _currentUser?.role;
      _rawRole = _currentUser?.rawRole;
    } catch (e) {
      debugPrint('[UserViewModel] loadFromStorage error: $e');
      _token = null;
      await SharedPreferencesUtils.removeToken();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(email, password);
      _token = authResponse.token;
      _role = authResponse.role;
      _rawRole = authResponse.rawRole;

      if (_token != null) {
        await SharedPreferencesUtils.saveToken(_token!);
        _currentUser = await _authService.getMe(_token!);
        _role = _currentUser?.role;
        _rawRole = _currentUser?.rawRole;
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      debugPrint('[UserViewModel] login error: $e');
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Login failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthday,
    List<int>? logoBytes,
    String? logoFilename,
    String? code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        birthday: birthday,
        logoBytes: logoBytes,
        logoFilename: logoFilename,
        code: code,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[UserViewModel] register error: $e');
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Registration failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> getMe() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getMe(_token!);
      _role = _currentUser?.role;
      _rawRole = _currentUser?.rawRole;
    } catch (e) {
      debugPrint('[UserViewModel] getMe error: $e');
      _error = e is ApiException ? e.message : 'Could not load user';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await SharedPreferencesUtils.removeToken();
    _currentUser = null;
    _token = null;
    _role = null;
    _rawRole = null;
    _error = null;
    notifyListeners();
  }
}
