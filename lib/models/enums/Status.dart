enum Status {
  PRESENT,
  ABSENT;

  static Status? fromString(String value) {
    try {
      return Status.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case Status.PRESENT:
        return 'Present';
      case Status.ABSENT:
        return 'Absent';
    }
  }
}
