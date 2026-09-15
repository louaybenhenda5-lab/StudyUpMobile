import '../enums/Day.dart';
import '../enums/Subject.dart';

class SessionRequest {
  final Subject? subject;
  final Day? day;
  final String startTime;
  final String endTime;
  final bool eachTwoWeeks;
  final String teacherId;
  final String classNum;

  SessionRequest({
    this.subject,
    this.day,
    required this.startTime,
    required this.endTime,
    this.eachTwoWeeks = false,
    required this.teacherId,
    required this.classNum,
  });

  factory SessionRequest.fromJson(Map<String, dynamic> json) {
    return SessionRequest(
      subject: json['subject'] != null
          ? Subject.fromString(json['subject'].toString())
          : null,
      day: json['day'] != null
          ? Day.fromString(json['day'].toString())
          : null,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      eachTwoWeeks: json['eachTwoWeeks'] == true,
      teacherId: json['teacherId']?.toString() ?? '',
      classNum: json['classNum']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject?.name,
      'day': day?.name,
      'startTime': startTime,
      'endTime': endTime,
      'eachTwoWeeks': eachTwoWeeks,
      'teacherId': teacherId,
      'classNum': classNum,
    };
  }
}
