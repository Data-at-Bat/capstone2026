import 'package:flutter/material.dart';
import 'package:app/shared/logging/logger_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Quality of Life State
  bool _valueBetsAtTop = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6DDF0), // Project Light Blue
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF462255), // Project Dark Purple
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Profile'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            onTap: () => _logAndNavigate('profile_info'),
          ),
          _buildSettingsTile(
            icon: Icons.credit_card,
            title: 'Subscription Settings',
            subtitle: 'Manage active plan via RevenueCat',
            onTap: () => _logAndNavigate('subscription_mgmt'),
          ),
          _buildSettingsTile(
            icon: Icons.star_border,
            title: 'Favorite Teams',
            onTap: () => _logAndNavigate('favorite_teams'),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Quality of Life'),
          
          // Value Bets Toggle
          SwitchListTile(
            activeThumbColor: const Color(0xFF143109), // Project Dark Green
            title: const Text('Value Bets at the Top'),
            subtitle: const Text('Prioritize high-confidence edges'),
            value: _valueBetsAtTop,
            onChanged: (bool value) {
              setState(() => _valueBetsAtTop = value);
              LoggerService.logEvent(
                fileName: 'settings_screen.dart',
                functionName: 'toggle_value_bets($value)',
                outcome: 'Success',
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Account & Security'),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => _logAndNavigate('change_password'),
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            textColor: Colors.redAccent,
            onTap: () => _logAndNavigate('sign_out'),
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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF462255),
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.7),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF462255)),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _logAndNavigate(String feature) {
    LoggerService.logEvent(
      fileName: 'settings_screen.dart',
      functionName: 'navigate_to_$feature',
      outcome: 'Success',
    );
    /* TODO: Implement actual navigation logging */
  }
}