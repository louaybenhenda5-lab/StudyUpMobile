import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/Schedule.dart';
import '../models/enums/Subject.dart';
import '../models/dto/CreateScheduleRequest.dart';
import '../services/AuthService.dart';

class ScheduleService {
  final http.Client _client = http.Client();

  Future<List<Schedule>> getSchedules(String token) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.scheduleGetAllUrl),
      headers: _headers(token),
    );
    debugPrint('[ScheduleService] GET ${NetworkConstants.scheduleGetAllUrl}');
    debugPrint('[ScheduleService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<Schedule> getSchedule(String token, String classroomId) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.scheduleGetWithId(classroomId)),
      headers: _headers(token),
    );
    debugPrint('[ScheduleService] GET ${NetworkConstants.scheduleGetWithId(classroomId)}');
    debugPrint('[ScheduleService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> updateSchedule(String token, String scheduleId, CreateScheduleRequest request) async {
    final response = await _client.put(
      Uri.parse(NetworkConstants.scheduleUpdateWithId(scheduleId)),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );
    debugPrint('[ScheduleService] PUT ${NetworkConstants.scheduleUpdateWithId(scheduleId)}');
    debugPrint('[ScheduleService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return 'Schedule updated successfully';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> deleteSchedule(String token, String id) async {
    final response = await _client.delete(
      Uri.parse(NetworkConstants.scheduleDeleteWithId(id)),
      headers: _headers(token),
    );
    debugPrint('[ScheduleService] DELETE ${NetworkConstants.scheduleDeleteWithId(id)}');
    debugPrint('[ScheduleService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message']?.toString() ?? '';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<List<Subject>> getSubjects(String token) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.scheduleSubjectsUrl),
      headers: _headers(token),
    );
    debugPrint('[ScheduleService] GET ${NetworkConstants.scheduleSubjectsUrl}');
    debugPrint('[ScheduleService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Subject.fromString(e.toString()))
          .whereType<Subject>()
          .toList();
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
