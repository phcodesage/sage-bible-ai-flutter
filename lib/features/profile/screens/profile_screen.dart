import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/providers/theme_provider.dart';
import 'package:sagebible/core/router/app_router.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// Profile Screen
/// 
/// Shows user profile if authenticated, or sign in prompt if guest.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isAuthenticated
          ? _buildAuthenticatedProfile(context, ref, user)
          : _buildGuestProfile(context, ref),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, WidgetRef ref, user) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      children: [
        // Profile header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Settings sections
        _buildSection(
          context,
          'Reading',
          [
            _buildListTile(
              context,
              Icons.history,
              'Reading History',
              'View your reading progress',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading History feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildListTile(
              context,
              Icons.calendar_today,
              'Reading Plans',
              'Follow structured reading plans',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading Plans feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildSection(
          context,
          'Preferences',
          [
            _buildListTile(
              context,
              Icons.text_fields,
              'Font Size',
              'Adjust reading font size',
              () {
                showDialog(
                  context: context,
                  builder: (context) => _FontSizeDialog(),
                );
              },
            ),
            _buildThemeToggle(context, ref),
          ],
        ),

        const SizedBox(height: 16),

        _buildSection(
          context,
          'Account',
          [
            _buildListTile(
              context,
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              textColor: AppTheme.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestProfile(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      children: [
        // Guest mode info
        Center(
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 100,
                color: AppTheme.textLight,
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re using Guest Mode',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to unlock AI Assistant, sync your bookmarks, and join the community',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRouter.login);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.push(AppRouter.register);
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Preferences section (available for guests)
        _buildSection(
          context,
          'Preferences',
          [
            _buildThemeToggle(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return ListTile(
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          key: ValueKey(isDarkMode),
          color: AppTheme.primaryColor,
        ),
      ),
      title: const Text('Dark Mode'),
      subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDarkMode ? 26 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  size: 16,
                  color: isDarkMode ? AppTheme.primaryColor : Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
    );
  }
}

/// Font Size Dialog
class _FontSizeDialog extends StatefulWidget {
  @override
  State<_FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<_FontSizeDialog> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Font Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(fontSize: _fontSize),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Small'),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ),
              const Text('Large'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save font size preference
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Font size set to ${_fontSize.round()}'),
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
