import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/logging/logger_service.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6DDF0),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF462255),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Profile'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            onTap: () {
              LoggerService.logEvent(fileName: 'settings_screen.dart', functionName: 'nav_profile', outcome: 'Success');
              context.push('/profile');
            },
          ),
          _buildSettingsTile(
            icon: Icons.star_border,
            title: 'Favorite Teams',
            onTap: () {
              LoggerService.logEvent(fileName: 'settings_screen.dart', functionName: 'nav_favorites', outcome: 'Success');
              context.push('/favorites');
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Account & Security'),

          // Change password moved to profile screen!

          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            textColor: Colors.redAccent,
            onTap: () async {
              LoggerService.logEvent(fileName: 'settings_screen.dart', functionName: 'sign_out_clicked', outcome: 'Prompted');

              // NEW: Show Confirmation Dialog
              final bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to sign out of your account?'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false), // Returns false
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), // Returns true
                      child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              // Only sign out if they hit "Sign Out"
              if (confirmLogout == true) {
                LoggerService.logEvent(fileName: 'settings_screen.dart', functionName: 'sign_out_confirmed', outcome: 'Success');
                await ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF462255), letterSpacing: 1.2, fontSize: 12),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color? textColor}) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.7),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF462255)),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}