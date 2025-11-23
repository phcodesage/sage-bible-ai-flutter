import 'package:flutter/material.dart';

/// Onboarding Page Model
/// 
/// Represents a single page in the onboarding flow.
class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Onboarding Pages Data
class OnboardingData {
  static List<OnboardingPageModel> get pages => [
    OnboardingPageModel(
      title: 'Read the Bible',
      description: 'Access the complete Bible offline. Read, search, and explore God\'s Word anytime, anywhere.',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF5B7C99), // Primary color
    ),
    OnboardingPageModel(
      title: 'Bookmark & Highlight',
      description: 'Save your favorite verses, add highlights, and create personal notes for deeper study.',
      icon: Icons.bookmark_rounded,
      color: const Color(0xFF8B9D83), // Secondary color
    ),
    OnboardingPageModel(
      title: 'Daily Devotions',
      description: 'Start each day with inspiring verses and devotional content to strengthen your faith.',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFD4A574), // Accent color
    ),
    OnboardingPageModel(
      title: 'AI Bible Assistant',
      description: 'Get instant answers to your biblical questions with our AI-powered assistant. (Requires sign in)',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF9B7C99), // Purple variant
    ),
    OnboardingPageModel(
      title: 'Join the Community',
      description: 'Connect with fellow believers, share insights, and grow together in faith. (Optional sign in)',
      icon: Icons.people_rounded,
      color: const Color(0xFF7C9B83), // Green variant
    ),
  ];
}
