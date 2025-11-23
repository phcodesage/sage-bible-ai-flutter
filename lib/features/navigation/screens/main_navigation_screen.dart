import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';
import 'package:sagebible/features/bible/screens/bible_books_screen.dart';
import 'package:sagebible/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:sagebible/features/search/screens/search_screen.dart';
import 'package:sagebible/features/ai/screens/ai_assistant_screen.dart';
import 'package:sagebible/features/profile/screens/profile_screen.dart';

/// Main Navigation Screen
/// 
/// Bottom navigation with 5 tabs:
/// - Read Bible
/// - Search
/// - Bookmarks
/// - AI Assistant (requires login)
/// - Profile
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  // Navigation screens
  final List<Widget> _screens = const [
    BibleBooksScreen(),
    SearchScreen(),
    BookmarksScreen(),
    AIAssistantScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // Check if trying to access AI without login (AI is now at index 3)
          if (index == 3 && !isAuthenticated) {
            _showLoginRequiredDialog();
            return;
          }
          
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Read',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.psychology_outlined),
                if (!isAuthenticated)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            selectedIcon: const Icon(Icons.psychology_rounded),
            label: 'AI',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Show dialog when user tries to access AI without login
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'AI Assistant requires a free account. Sign in to unlock this feature and join the community.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login - will be handled by profile screen
              setState(() {
                _currentIndex = 3; // Go to profile tab
              });
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
