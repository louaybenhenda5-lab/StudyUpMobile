enum Subject {
  INFO,
  SPANISH,
  STI,
  MATH,
  PHYSIC,
  ENGLISH,
  ARABIC,
  SCIENCE,
  PHILOSOPHY,
  SPORT,
  GEOGRAPHY,
  HISTORY,
  ISLAMIC_ED,
  CIVIC_ED,
  ECO,
  GESTION,
  MECHANIC,
  ELECTRIC,
  TECHNIC,
  ITALIC,
  MUSIC,
  ART,
  GERMAN,
  CHINESE,
  CHEMISTRY,
  FRENCH;

  static Subject? fromString(String value) {
    try {
      return Subject.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case Subject.INFO:
        return 'Informatics';
      case Subject.SPANISH:
        return 'Spanish';
      case Subject.STI:
        return 'STI';
      case Subject.MATH:
        return 'Mathematics';
      case Subject.PHYSIC:
        return 'Physics';
      case Subject.ENGLISH:
        return 'English';
      case Subject.ARABIC:
        return 'Arabic';
      case Subject.SCIENCE:
        return 'Science';
      case Subject.PHILOSOPHY:
        return 'Philosophy';
      case Subject.SPORT:
        return 'Sport';
      case Subject.GEOGRAPHY:
        return 'Geography';
      case Subject.HISTORY:
        return 'History';
      case Subject.ISLAMIC_ED:
        return 'Islamic Education';
      case Subject.CIVIC_ED:
        return 'Civic Education';
      case Subject.ECO:
        return 'Economics';
      case Subject.GESTION:
        return 'Management';
      case Subject.MECHANIC:
        return 'Mechanics';
      case Subject.ELECTRIC:
        return 'Electricity';
      case Subject.TECHNIC:
        return 'Technical';
      case Subject.ITALIC:
        return 'Italian';
      case Subject.MUSIC:
        return 'Music';
      case Subject.ART:
        return 'Art';
      case Subject.GERMAN:
        return 'German';
      case Subject.CHINESE:
        return 'Chinese';
      case Subject.CHEMISTRY:
        return 'Chemistry';
      case Subject.FRENCH:
        return 'French';
    }
  }
}
