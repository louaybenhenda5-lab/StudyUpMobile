import 'SessionRequest.dart';

class CreateScheduleRequest {
  final String classroomId;
  final List<SessionRequest> sessionRequests;

  CreateScheduleRequest({
    required this.classroomId,
    required this.sessionRequests,
  });

  factory CreateScheduleRequest.fromJson(Map<String, dynamic> json) {
    return CreateScheduleRequest(
      classroomId: json['classroomId']?.toString() ?? '',
      sessionRequests: json['sessionRequests'] != null
          ? (json['sessionRequests'] as List)
              .map((e) => SessionRequest.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classroomId': classroomId,
      'sessionRequests': sessionRequests.map((e) => e.toJson()).toList(),
    };
  }
}
