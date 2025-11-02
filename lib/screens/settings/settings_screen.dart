import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoCallRecording = false;
  bool _autoSMSScanning = true;
  bool _locationTracking = true;
  String _language = 'English';
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Protection Settings
          _buildSectionHeader('Protection'),
          _buildSwitchTile(
            'Auto Call Recording',
            'Automatically record suspicious calls',
            Icons.call_end,
            _autoCallRecording,
            (value) => setState(() => _autoCallRecording = value),
          ),
          _buildSwitchTile(
            'Auto SMS Scanning',
            'Scan all incoming messages',
            Icons.message,
            _autoSMSScanning,
            (value) => setState(() => _autoSMSScanning = value),
          ),
          _buildSwitchTile(
            'Location Tracking',
            'Share location with family members',
            Icons.location_on,
            _locationTracking,
            (value) => setState(() => _locationTracking = value),
          ),

          const Divider(),

          // Notifications
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            'Push Notifications',
            'Receive alerts and updates',
            Icons.notifications,
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildNavigationTile(
            'Notification Preferences',
            'Customize notification types',
            Icons.tune,
            () {
              // TODO: Navigate to notification preferences
            },
          ),

          const Divider(),

          // Appearance
          _buildSectionHeader('Appearance'),
          _buildSelectionTile(
            'Language',
            _language,
            Icons.language,
            () => _showLanguageDialog(),
          ),
          _buildSelectionTile(
            'Theme',
            _theme,
            Icons.palette,
            () => _showThemeDialog(),
          ),

          const Divider(),

          // Privacy & Security
          _buildSectionHeader('Privacy & Security'),
          _buildNavigationTile(
            'Privacy Settings',
            'Manage your privacy',
            Icons.privacy_tip,
            () {
              // TODO: Navigate to privacy settings
            },
          ),
          _buildNavigationTile(
            'Two-Factor Authentication',
            'Add extra security',
            Icons.security,
            () {
              // TODO: Navigate to 2FA setup
            },
          ),
          _buildNavigationTile(
            'Blocked Numbers',
            'Manage blocked contacts',
            Icons.block,
            () {
              // TODO: Navigate to blocked numbers
            },
          ),

          const Divider(),

          // Data & Storage
          _buildSectionHeader('Data & Storage'),
          _buildNavigationTile(
            'Storage Usage',
            'Manage app storage',
            Icons.storage,
            () {
              // TODO: Navigate to storage management
            },
          ),
          _buildNavigationTile(
            'Clear Cache',
            'Free up space',
            Icons.cleaning_services,
            () => _showClearCacheDialog(),
          ),
          _buildNavigationTile(
            'Export Data',
            'Download your data',
            Icons.download,
            () {
              // TODO: Export user data
            },
          ),

          const Divider(),

          // About
          _buildSectionHeader('About'),
          _buildNavigationTile(
            'Help & Support',
            'Get help with the app',
            Icons.help,
            () {
              // TODO: Navigate to help
            },
          ),
          _buildNavigationTile(
            'Terms of Service',
            'Read our terms',
            Icons.description,
            () {
              // TODO: Navigate to terms
            },
          ),
          _buildNavigationTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.policy,
            () {
              // TODO: Navigate to privacy policy
            },
          ),
          _buildNavigationTile(
            'About EchoFort',
            'Version 1.0.0',
            Icons.info,
            () => _showAboutDialog(),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _showDeleteAccountDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSelectionTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Spanish', 'French', 'German'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themes = ['System', 'Light', 'Dark'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _theme,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear temporary files and free up space. Your data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'EchoFort',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shield, size: 48),
      children: [
        const Text(
          'EchoFort is a comprehensive scam protection platform that helps you stay safe from fraud, scams, and cyber threats.',
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete account
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
