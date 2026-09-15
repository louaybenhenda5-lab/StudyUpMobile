import 'package:flutter/foundation.dart';
import '../models/Classroom.dart';
import '../services/ClassroomService.dart';

class ClassroomViewModel extends ChangeNotifier {
  final ClassroomService _service = ClassroomService();

  List<Classroom>? _classrooms;
  bool _isLoading = false;
  String? _error;

  List<Classroom>? get classrooms => _classrooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClassrooms(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classrooms = await _service.getClassrooms(token);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
