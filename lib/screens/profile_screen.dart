import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceXL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXXS),
                const Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Settings List
          _buildSettingsSection(context, 'Account', [
            _buildSettingsTile(context, 'Edit Profile', Icons.edit, () {}),
            _buildSettingsTile(context, 'Change Password', Icons.lock, () {}),
            _buildSettingsTile(context, 'Subscription', Icons.card_membership, () {}),
          ]),
          _buildSettingsSection(context, 'Preferences', [
            _buildSettingsTile(context, 'Notifications', Icons.notifications, () {}),
            _buildSettingsTile(context, 'Privacy', Icons.privacy_tip, () {}),
            _buildSettingsTile(context, 'Language', Icons.language, () {}),
          ]),
          _buildSettingsSection(context, 'Support', [
            _buildSettingsTile(context, 'Help Center', Icons.help, () {}),
            _buildSettingsTile(context, 'Report a Problem', Icons.bug_report, () {}),
            _buildSettingsTile(context, 'About', Icons.info, () {}),
          ]),
          const SizedBox(height: AppTheme.spaceMD),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: AppTheme.error),
              label: const Text('Logout', style: TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceMD,
            AppTheme.spaceMD,
            AppTheme.spaceMD,
            AppTheme.spaceXS,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...tiles,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
