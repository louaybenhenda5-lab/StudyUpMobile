import 'enums/Day.dart';
import 'enums/Subject.dart';
import 'User.dart';

class Session {
  final String id;
  final Subject? subject;
  final Day? day;
  final String startTime;
  final String endTime;
  final bool eachTwoWeeks;
  final User? teacher;
  final String classNum;
  final String? scheduleId;
  final String? classroomId;
  final String createdAt;

  Session({
    required this.id,
    this.subject,
    this.day,
    required this.startTime,
    required this.endTime,
    this.eachTwoWeeks = false,
    this.teacher,
    this.classNum = '',
    this.scheduleId,
    this.classroomId,
    this.createdAt = '',
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] != null
          ? Subject.fromString(json['subject'].toString())
          : null,
      day: json['day'] != null
          ? Day.fromString(json['day'].toString())
          : null,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      eachTwoWeeks: json['eachTwoWeeks'] == true || json['isEachTwoWeeks'] == true,
      teacher: json['teacher'] != null
          ? User.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      classNum: json['classNum']?.toString() ?? '',
      scheduleId: json['schedule']?['id']?.toString(),
      classroomId: json['classroomId']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject?.name,
      'day': day?.name,
      'startTime': startTime,
      'endTime': endTime,
      'eachTwoWeeks': eachTwoWeeks,
      'teacherId': teacher?.id,
      'classNum': classNum,
    };
  }

  String get startTimeFormatted {
    try {
      final dt = DateTime.parse(startTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return startTime;
    }
  }

  String get endTimeFormatted {
    try {
      final dt = DateTime.parse(endTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return endTime;
    }
  }
}
