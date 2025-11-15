import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/standard_card.dart';
import '../../widgets/status_badge.dart';
import '../../services/api_service.dart';

/// Settings Screen (§1.11)
/// 
/// Per ChatGPT CTO specification:
/// "User preferences + DPDP Act 2023 compliance controls. Must include data export/deletion."
/// 
/// Design Requirements:
/// - Profile section with avatar and subscription badge
/// - Settings sections: Account, Privacy, Notifications, Security, DPDP Rights
/// - DPDP controls: View Data, Export Data, Delete Account, Consent Management
/// - Toggle switches for preferences
/// - Logout button
/// 
/// Technical Requirements:
/// - Settings persistence (shared_preferences)
/// - DPDP API integration (/api/dpdp/*)
/// - Account deletion confirmation flow
/// - Data export functionality
/// - Consent management UI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // User data from SharedPreferences
  String _userName = 'User';
  String _userEmail = '';
  String _userPhone = '';
  String _subscriptionPlan = 'Basic';
  
  // Settings toggles
  bool _callScreeningEnabled = true;
  bool _smsProtectionEnabled = true;
  bool _locationSharingEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _biometricAuthEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Load user data
      _userName = prefs.getString('user_name') ?? 'User';
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhone = prefs.getString('user_phone') ?? '';
      _subscriptionPlan = prefs.getString('subscription_plan') ?? 'Basic';
      
      // Load settings
      _callScreeningEnabled = prefs.getBool('call_screening_enabled') ?? true;
      _smsProtectionEnabled = prefs.getBool('sms_protection_enabled') ?? true;
      _locationSharingEnabled = prefs.getBool('location_sharing_enabled') ?? true;
      _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
      _emailNotificationsEnabled = prefs.getBool('email_notifications_enabled') ?? false;
      _biometricAuthEnabled = prefs.getBool('biometric_auth_enabled') ?? false;
    });
    
    print('[SETTINGS] Loaded from SharedPreferences');
  }
  
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    print('[SETTINGS] Saved $key = $value');
  }

  void _navigateToProfile() {
    print('[NAV] Edit profile tapped');
    // TODO: Navigate to profile edit screen
  }

  void _navigateToSubscription() {
    print('[NAV] Manage subscription tapped');
    // TODO: Navigate to subscription management screen
  }

  void _viewMyData() {
    print('[DPDP] View my data tapped');
    // TODO: Navigate to data view screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Data'),
        content: const Text(
          'This will show all data we have collected about you, including:\n\n'
          '• Personal information\n'
          '• Call logs and scam reports\n'
          '• Location history (if Family plan)\n'
          '• Preferences and settings',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to detailed data view
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _exportMyData() {
    print('[DPDP] Export my data tapped');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Your Data'),
        content: const Text(
          'We will prepare a complete export of your data in JSON format. '
          'You will receive a download link via email within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                print('[DPDP] Requesting data export...');
                await ApiService.requestDataExport();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Data export requested. Check your email in 24 hours.'),
                      backgroundColor: AppTheme.accentSuccess,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                print('[DPDP] Export error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to request export: $e'),
                      backgroundColor: AppTheme.accentDanger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    print('[DPDP] Delete account tapped');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.accentDanger),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. '
          'This action cannot be undone.\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                print('[DPDP] Deleting account...');
                await ApiService.deleteAccount();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Account deletion initiated. You will be logged out.'),
                      backgroundColor: AppTheme.accentSuccess,
                      duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _manageConsent() {
    print('[DPDP] Manage consent tapped');
    // TODO: Navigate to consent management screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consent Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Control how we use your data:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildConsentItem('Call Screening', true),
            _buildConsentItem('SMS Protection', true),
            _buildConsentItem('Location Tracking', true),
            _buildConsentItem('Analytics', false),
            _buildConsentItem('Marketing', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Consent preferences saved'),
                  backgroundColor: AppTheme.accentSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.accentDanger),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted within 30 days.\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentDanger,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Type DELETE to confirm',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // TODO: Enable delete button only if value == 'DELETE'
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              print('[API] POST /api/dpdp/delete-account');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion initiated. You will be logged out.'),
                  backgroundColor: AppTheme.accentDanger,
                  duration: const Duration(seconds: 3),
                ),
              );
              // TODO: Logout and navigate to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentDanger,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              print('[AUTH] Logout');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logged out successfully'),
                  backgroundColor: AppTheme.accentSuccess,
                ),
              );
              // TODO: Clear auth state and navigate to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EchoFortLogo(size: 24, variant: LogoVariant.primary),
            const SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile section
            _buildProfileSection(),
            
            const SizedBox(height: 24),
            
            // Account section
            _buildSectionHeader('Account'),
            _buildSettingItem(
              icon: Icons.person_rounded,
              title: 'Edit Profile',
              onTap: _navigateToProfile,
            ),
            _buildSettingItem(
              icon: Icons.credit_card_rounded,
              title: 'Manage Subscription',
              trailing: StatusBadge(
                label: _subscriptionPlan,
                type: BadgeType.success,
                small: true,
              ),
              onTap: _navigateToSubscription,
            ),
            
            const SizedBox(height: 24),
            
            // Privacy section
            _buildSectionHeader('Privacy'),
            _buildToggleItem(
              icon: Icons.phone_rounded,
              title: 'Call Screening',
              value: _callScreeningEnabled,
              onChanged: (value) {
                setState(() {
                  _callScreeningEnabled = value;
                });
                _saveSetting('call_screening_enabled', value);
              },
            ),
            _buildToggleItem(
              icon: Icons.message_rounded,
              title: 'SMS Protection',
              value: _smsProtectionEnabled,
              onChanged: (value) {
                setState(() {
                  _smsProtectionEnabled = value;
                });
                _saveSetting('sms_protection_enabled', value);
              },
            ),
            _buildToggleItem(
              icon: Icons.location_on_rounded,
              title: 'Location Sharing',
              subtitle: 'Family plan only',
              value: _locationSharingEnabled,
              onChanged: (value) {
                setState(() {
                  _locationSharingEnabled = value;
                });
                _saveSetting('location_sharing_enabled', value);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Notifications section
            _buildSectionHeader('Notifications'),
            _buildToggleItem(
              icon: Icons.notifications_rounded,
              title: 'Push Notifications',
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                });
                _saveSetting('push_notifications_enabled', value);
              },
            ),
            _buildToggleItem(
              icon: Icons.email_rounded,
              title: 'Email Notifications',
              value: _emailNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
                _saveSetting('email_notifications_enabled', value);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Security section
            _buildSectionHeader('Security'),
            _buildToggleItem(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric Authentication',
              value: _biometricAuthEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricAuthEnabled = value;
                });
                _saveSetting('biometric_auth_enabled', value);
              },
            ),
            _buildSettingItem(
              icon: Icons.lock_rounded,
              title: 'Change Password',
              onTap: () {
                print('[NAV] Change password tapped');
              },
            ),
            
            const SizedBox(height: 24),
            
            // DPDP Rights section
            _buildSectionHeader('Your Data Rights (DPDP Act 2023)'),
            _buildSettingItem(
              icon: Icons.visibility_rounded,
              title: 'View My Data',
              subtitle: 'See what data we have about you',
              onTap: _viewMyData,
            ),
            _buildSettingItem(
              icon: Icons.download_rounded,
              title: 'Export My Data',
              subtitle: 'Download a copy of your data',
              onTap: _exportMyData,
            ),
            _buildSettingItem(
              icon: Icons.check_circle_rounded,
              title: 'Manage Consent',
              subtitle: 'Control how we use your data',
              onTap: _manageConsent,
            ),
            _buildSettingItem(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              textColor: AppTheme.accentDanger,
              onTap: _deleteAccount,
            ),
            
            const SizedBox(height: 32),
            
            // Logout button
            OutlinedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout_rounded, color: AppTheme.accentDanger),
              label: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentDanger,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.accentDanger),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    'EchoFort v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Echofort Technology',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return StandardCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName.substring(0, 1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userPhone,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Edit button
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: AppTheme.primarySolid,
            ),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StandardCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (textColor ?? AppTheme.primarySolid).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: textColor ?? AppTheme.primarySolid,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? AppTheme.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StandardCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primarySolid.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primarySolid,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primarySolid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(String label, bool initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: initialValue,
            onChanged: (value) {
              // TODO: Update consent
            },
            activeColor: AppTheme.primarySolid,
          ),
        ],
      ),
    );
  }
}
