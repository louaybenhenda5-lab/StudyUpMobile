/// The type of illustration rendered on each onboarding slide.
enum OnboardingIllustration { books, rocket, career }

/// Immutable data backing a single onboarding slide.
class OnboardingItem {
  const OnboardingItem({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.illustration,
  });

  /// Small category / intro label shown above the title.
  final String label;
  final String title;
  final String subtitle;
  final OnboardingIllustration illustration;
}

/// The three slides used by the onboarding flow.
const List<OnboardingItem> kOnboardingItems = [
  OnboardingItem(
    label: 'LEARN',
    title: 'Learn with Expert Trainers',
    subtitle: 'Study with vetted mentors and well-structured '
        'lessons built to help you truly understand each topic.',
    illustration: OnboardingIllustration.books,
  ),
  OnboardingItem(
    label: 'EXPLORE',
    title: 'Browse Curated Courses',
    subtitle: 'Discover courses across subjects and levels, '
        'organised so you can focus on what matters most.',
    illustration: OnboardingIllustration.rocket,
  ),
  OnboardingItem(
    label: 'GROW',
    title: 'Track & Grow Your Career',
    subtitle: 'Follow your progress, build consistent study '
        'habits, and move closer to your academic goals.',
    illustration: OnboardingIllustration.career,
  ),
];
