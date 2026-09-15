import 'Classroom.dart';
import 'enums/Role.dart';
import 'enums/Status.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String profilePictureURL;
  final String birthday;
  final String createdAt;
  final Roles? role;
  final String? rawRole;
  final Status? status;
  final bool hasJoinRequest;
  final Classroom? classroom;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    required this.profilePictureURL,
    required this.birthday,
    this.createdAt = '',
    this.role,
    this.rawRole,
    this.status,
    required this.hasJoinRequest,
    this.classroom,
  });

  bool get isAdmin => rawRole == 'ADMIN' || rawRole == 'SUPER_ADMIN';
  bool get isTeacher => role == Roles.TEACHER || rawRole == 'TEACHER';
  bool get isStudent => role == Roles.STUDENT || rawRole == 'STUDENT';

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString();
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      profilePictureURL: json['profilePictureURL']?.toString() ?? '',
      birthday: json['birthday']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      role: Roles.fromString(rawRole ?? ''),
      rawRole: rawRole,
      status: json['status'] != null
          ? Status.fromString(json['status'].toString())
          : null,
      hasJoinRequest: json['hasJoinRequest'] == true,
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profilePictureURL': profilePictureURL,
      'birthday': birthday,
      'createdAt': createdAt,
      'role': rawRole ?? role?.name,
      'status': status?.name,
      'hasJoinRequest': hasJoinRequest,
      'classroom': classroom?.toJson(),
    };
  }

  String get displayName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}
