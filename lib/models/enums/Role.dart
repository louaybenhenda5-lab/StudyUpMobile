enum Roles {
  TEACHER,
  STUDENT;

  static Roles? fromString(String value) {
    switch (value) {
      case 'TEACHER':
        return Roles.TEACHER;
      case 'STUDENT':
        return Roles.STUDENT;
      case 'SUPER_ADMIN':
      case 'ADMIN':
        return null;
      default:
        return null;
    }
  }
}
