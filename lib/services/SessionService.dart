import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/Session.dart';
import '../models/User.dart';
import '../services/AuthService.dart';

class SessionService {
  final http.Client _client = http.Client();

  /// Gets today's session for the logged-in teacher.
  /// The backend expects the teacher's user id in the path, and the JWT in the header.
  Future<Session> getSession(String token, String userId) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.sessionGetWithId(userId)),
      headers: _headers(token),
    );
    debugPrint('[SessionService] GET ${NetworkConstants.sessionGetWithId(userId)}');
    debugPrint('[SessionService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  /// Gets all sessions assigned to the logged-in teacher (from the JWT).
  Future<List<Session>> getMySessions(String token) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.sessionMyUrl),
      headers: _headers(token),
    );
    debugPrint('[SessionService] GET ${NetworkConstants.sessionMyUrl}');
    debugPrint('[SessionService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  /// Gets the students of a classroom (TEACHER-only endpoint).
  Future<List<User>> getStudentsByClass(String token, String classroomId) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.sessionStudentByClassWithId(classroomId)),
      headers: _headers(token),
    );
    debugPrint(
        '[SessionService] GET ${NetworkConstants.sessionStudentByClassWithId(classroomId)}');
    debugPrint('[SessionService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> deleteSession(String token, String id) async {
    final response = await _client.delete(
      Uri.parse(NetworkConstants.sessionDeleteWithId(id)),
      headers: _headers(token),
    );
    debugPrint('[SessionService] DELETE ${NetworkConstants.sessionDeleteWithId(id)}');
    debugPrint('[SessionService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message']?.toString() ?? '';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return 'Something went wrong';
  }
}
