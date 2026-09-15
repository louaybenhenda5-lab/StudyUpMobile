import 'User.dart';

enum SessionType {
  INFO,
  ECO,
  TECHNIC,
  SCIENCE,
  MATH,
  LETTER,
  SPORT,
  S;

  static SessionType? fromString(String value) {
    try {
      return SessionType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case SessionType.INFO:
        return 'Informatics';
      case SessionType.ECO:
        return 'Economics';
      case SessionType.TECHNIC:
        return 'Technical';
      case SessionType.SCIENCE:
        return 'Science';
      case SessionType.MATH:
        return 'Mathematics';
      case SessionType.LETTER:
        return 'Letters';
      case SessionType.SPORT:
        return 'Sport';
      case SessionType.S:
        return 'Single';
    }
  }
}

class Classroom {
  final String id;
  final int level;
  final int levelId;
  final String name;
  final SessionType? sessionType;
  final User? teacher;
  final List<User> students;

  Classroom({
    required this.id,
    required this.level,
    required this.levelId,
    required this.name,
    this.sessionType,
    this.teacher,
    this.students = const [],
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id']?.toString() ?? '',
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '0') ?? 0,
      levelId: json['levelId'] is int ? json['levelId'] : int.tryParse(json['levelId']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      sessionType: json['sessionType'] != null
          ? SessionType.fromString(json['sessionType'].toString())
          : null,
      teacher: json['teacher'] != null
          ? User.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      students: json['students'] != null
          ? (json['students'] as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'levelId': levelId,
      'name': name,
      'sessionType': sessionType?.name,
      'teacher': teacher?.toJson(),
      'students': students.map((e) => e.toJson()).toList(),
    };
  }
}
