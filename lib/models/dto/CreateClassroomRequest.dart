class CreateClassroomRequest {
  final int level;
  final String sessionType;

  CreateClassroomRequest({
    required this.level,
    required this.sessionType,
  });

  factory CreateClassroomRequest.fromJson(Map<String, dynamic> json) {
    return CreateClassroomRequest(
      level: json['level'] ?? 0,
      sessionType: json['sessionType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'sessionType': sessionType,
    };
  }
}
