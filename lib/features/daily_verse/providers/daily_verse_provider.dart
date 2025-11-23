import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';
import 'package:sagebible/features/daily_verse/services/daily_verse_service.dart';

/// Daily Verse Provider
/// 
/// Provides the verse of the day
final dailyVerseServiceProvider = Provider<DailyVerseService>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  return DailyVerseService(repository);
});

/// Provider for current daily verse
final dailyVerseProvider = FutureProvider<DailyVerse?>((ref) async {
  final service = ref.watch(dailyVerseServiceProvider);
  final bibleData = ref.watch(currentBibleDataProvider);
  
  if (bibleData == null) return null;
  
  return await service.getDailyVerse(bibleData);
});
