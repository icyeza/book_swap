import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _bg = Color(0xFF0B1026);
  static const Color _accent = Color(0xFFF1C64A);
  static const Color _cardBg = Color(0xFF1A1F3A);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _accent.withOpacity(0.2),
                          radius: 40,
                          child: user.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.photoUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  user.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: _accent,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    user.emailVerified
                                        ? Icons.verified
                                        : Icons.warning,
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.emailVerified
                                        ? 'Email Verified'
                                        : 'Email Not Verified',
                                    style: TextStyle(
                                      color: user.emailVerified
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notification Settings
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _NotificationToggle(
                    title: 'Swap Requests',
                    subtitle: 'Get notified when someone wants to swap',
                    value: user.notificationSettings['swapRequests'] ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, bool>.from(
                        user.notificationSettings,
                      );
                      newSettings['swapRequests'] = value;
                      authProvider.updateNotificationSettings(newSettings);
                    },
                  ),

                  _NotificationToggle(
                    title: 'Messages',
                    subtitle: 'Get notified when you receive a message',
                    value: user.notificationSettings['messages'] ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, bool>.from(
                        user.notificationSettings,
                      );
                      newSettings['messages'] = value;
                      authProvider.updateNotificationSettings(newSettings);
                    },
                  ),

                  _NotificationToggle(
                    title: 'Updates',
                    subtitle: 'Get notified about app updates',
                    value: user.notificationSettings['updates'] ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, bool>.from(
                        user.notificationSettings,
                      );
                      newSettings['updates'] = value;
                      authProvider.updateNotificationSettings(newSettings);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Account Actions
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (!user.emailVerified)
                    _SettingsButton(
                      icon: Icons.email,
                      title: 'Resend Verification Email',
                      onTap: () async {
                        final success = await authProvider
                            .resendEmailVerification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Verification email sent!'
                                    : 'Failed to send email',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                    ),

                  _SettingsButton(
                    icon: Icons.refresh,
                    title: 'Reload Account',
                    onTap: () async {
                      await authProvider.reloadUser();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account reloaded'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),

                  _SettingsButton(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    isDestructive: true,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: _cardBg,
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/welcome',
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  static const Color _cardBg = Color(0xFF1A1F3A);
  static const Color _accent = Color(0xFFF1C64A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _accent),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  static const Color _cardBg = Color(0xFF1A1F3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
