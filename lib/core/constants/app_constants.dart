class NetworkConstants {
  static const url = "https://studyup-2p58.onrender.com";

  static const loginUrl = '$url/api/auth/login';
  static const registerUrl = '$url/api/auth/register';
  static const addUserUrl = '$url/api/auth/add-user';
  static const meUrl = '$url/api/auth/me';
  static const teachersUrl = '$url/api/auth/teachers';
  static const studentsUrl = '$url/api/auth/students';

  static const classroomCreateUrl = '$url/api/level/create';
  static const classroomGetUrl = '$url/api/level/get';
  static const classroomDeleteUrl = '$url/api/level/delete';

  static const scheduleGetAllUrl = '$url/api/schedule/get/all';
  static const scheduleGetUrl = '$url/api/schedule/get';
  static const scheduleDeleteUrl = '$url/api/schedule/delete';
  static const scheduleUpdateUrl = '$url/api/schedule/update';
  static const scheduleSubjectsUrl = '$url/api/schedule/subjects';

  static const sessionGetUrl = '$url/api/session/get';
  static const sessionMyUrl = '$url/api/session/my';
  static const sessionDeleteUrl = '$url/api/session/delete';
  static const sessionStudentByClassUrl = '$url/api/session/student-by-class';

  static String classroomGetUrlWithId(String id) => '$classroomGetUrl/$id';
  static String classroomDeleteUrlWithId(String id) => '$classroomDeleteUrl/$id';
  static String scheduleGetWithId(String classroomId) => '$scheduleGetUrl/$classroomId';
  static String scheduleDeleteWithId(String id) => '$scheduleDeleteUrl/$id';
  static String scheduleUpdateWithId(String scheduleId) => '$scheduleUpdateUrl/$scheduleId';
  static String sessionGetWithId(String id) => '$sessionGetUrl/$id';
  static String sessionDeleteWithId(String id) => '$sessionDeleteUrl/$id';
  static String sessionStudentByClassWithId(String classroomId) =>
      '$sessionStudentByClassUrl/$classroomId';
}
