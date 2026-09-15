import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/Classroom.dart';
import '../models/dto/CreateClassroomRequest.dart';
import '../services/AuthService.dart';

class ClassroomService {
  final http.Client _client = http.Client();

  Future<List<Classroom>> getClassrooms(String token) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.classroomGetUrl),
      headers: _headers(token),
    );
    debugPrint('[ClassroomService] GET ${NetworkConstants.classroomGetUrl}');
    debugPrint('[ClassroomService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Classroom.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> createClassroom(String token, CreateClassroomRequest request) async {
    final response = await _client.post(
      Uri.parse(NetworkConstants.classroomCreateUrl),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );
    debugPrint('[ClassroomService] POST ${NetworkConstants.classroomCreateUrl}');
    debugPrint('[ClassroomService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message']?.toString() ?? '';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> deleteClassroom(String token, String id) async {
    final response = await _client.delete(
      Uri.parse(NetworkConstants.classroomDeleteUrlWithId(id)),
      headers: _headers(token),
    );
    debugPrint('[ClassroomService] DELETE ${NetworkConstants.classroomDeleteUrlWithId(id)}');
    debugPrint('[ClassroomService] Status: ${response.statusCode}');
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
