enum Day {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY;

  static Day? fromString(String value) {
    try {
      return Day.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  int get dayNumber {
    switch (this) {
      case Day.MONDAY:
        return 1;
      case Day.TUESDAY:
        return 2;
      case Day.WEDNESDAY:
        return 3;
      case Day.THURSDAY:
        return 4;
      case Day.FRIDAY:
        return 5;
      case Day.SATURDAY:
        return 6;
      case Day.SUNDAY:
        return 7;
    }
  }

  String get displayName {
    switch (this) {
      case Day.MONDAY:
        return 'Monday';
      case Day.TUESDAY:
        return 'Tuesday';
      case Day.WEDNESDAY:
        return 'Wednesday';
      case Day.THURSDAY:
        return 'Thursday';
      case Day.FRIDAY:
        return 'Friday';
      case Day.SATURDAY:
        return 'Saturday';
      case Day.SUNDAY:
        return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case Day.MONDAY:
        return 'Mon';
      case Day.TUESDAY:
        return 'Tue';
      case Day.WEDNESDAY:
        return 'Wed';
      case Day.THURSDAY:
        return 'Thu';
      case Day.FRIDAY:
        return 'Fri';
      case Day.SATURDAY:
        return 'Sat';
      case Day.SUNDAY:
        return 'Sun';
    }
  }
}
