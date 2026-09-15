import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/app_constants.dart';
import '../models/User.dart';
import '../models/enums/Role.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthResponse {
  final String? token;
  final Roles? role;
  final String? rawRole;

  AuthResponse({this.token, this.role, this.rawRole});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString();
    return AuthResponse(
      token: json['token']?.toString(),
      role: Roles.fromString(rawRole ?? ''),
      rawRole: rawRole,
    );
  }
}

class AuthService {
  final http.Client _client = http.Client();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse(NetworkConstants.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    debugPrint('[AuthService] POST ${NetworkConstants.loginUrl}');
    debugPrint('[AuthService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  /// Registers an invited user.
  /// The backend consumes `multipart/form-data` with a JSON part named
  /// `registerRequest` and an optional `logo` file part.
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthday,
    List<int>? logoBytes,
    String? logoFilename,
    String? code,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(NetworkConstants.registerUrl),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'registerRequest',
        utf8.encode(jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'birthday': birthday,
          'code': code,
        })),
        filename: 'registerRequest.json',
        contentType: MediaType('application', 'json'),
      ),
    );
    if (logoBytes != null && logoBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'logo',
          logoBytes,
          filename: logoFilename ?? 'logo.jpg',
        ),
      );
    }
    debugPrint('[AuthService] POST ${NetworkConstants.registerUrl}');
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    debugPrint('[AuthService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message']?.toString() ?? '';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<User> getMe(String token) async {
    final response = await _client.get(
      Uri.parse(NetworkConstants.meUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('[AuthService] GET ${NetworkConstants.meUrl}');
    debugPrint('[AuthService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<String> addUser({
    required String token,
    String? email,
    required String role,
    String? firstName,
    String? lastName,
    String? classroomId,
  }) async {
    final response = await _client.post(
      Uri.parse(NetworkConstants.addUserUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'classroomId': classroomId,
      }),
    );
    debugPrint('[AuthService] POST ${NetworkConstants.addUserUrl}');
    debugPrint('[AuthService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message']?.toString() ?? '';
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  Future<List<User>> getTeachers(String token) async {
    return _getUsers(NetworkConstants.teachersUrl, token);
  }

  Future<List<User>> getStudents(String token) async {
    return _getUsers(NetworkConstants.studentsUrl, token);
  }

  Future<List<User>> _getUsers(String url, String token) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('[AuthService] GET $url');
    debugPrint('[AuthService] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw ApiException(_extractErrorMessage(response));
    }
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return _capitalize(body['message'].toString());
      }
    } catch (_) {
      // Not JSON; fall through to status-based message below.
    }

    switch (response.statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 404:
        return 'User not found';
      case 500:
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
