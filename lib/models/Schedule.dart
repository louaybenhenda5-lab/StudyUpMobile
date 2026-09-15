import 'Classroom.dart';
import 'Session.dart';

class Schedule {
  final String id;
  final Classroom? classroom;
  final List<Session> sessions;

  Schedule({
    required this.id,
    this.classroom,
    this.sessions = const [],
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'] as Map<String, dynamic>)
          : null,
      sessions: json['sessions'] != null
          ? (json['sessions'] as List)
              .map((e) => Session.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classroom': classroom?.toJson(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}
