import 'enums/Status.dart';

class StudentStatus {
  final String sessionId;
  final String studentId;
  final Status? status;

  StudentStatus({
    required this.sessionId,
    required this.studentId,
    this.status,
  });

  factory StudentStatus.fromJson(Map<String, dynamic> json) {
    return StudentStatus(
      sessionId: json['sessionId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      status: json['status'] != null
          ? Status.fromString(json['status'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status?.name,
    };
  }
}
