import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dashboard Screen - Main hub after login
/// Features: Card-based layout, bottom navigation, quick actions
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<DashboardFeature> _features = [
    DashboardFeature(
      title: 'GPS Tracking',
      subtitle: 'Track family in real-time',
      icon: Icons.location_on_rounded,
      color: AppTheme.success,
      route: '/gps',
    ),
    DashboardFeature(
      title: 'Screen Time',
      subtitle: 'Monitor app usage',
      icon: Icons.timer_rounded,
      color: AppTheme.warning,
      route: '/screentime',
    ),
    DashboardFeature(
      title: 'Scam Protection',
      subtitle: 'Block spam calls & SMS',
      icon: Icons.shield_rounded,
      color: AppTheme.error,
      route: '/protection',
    ),
    DashboardFeature(
      title: 'Evidence Vault',
      subtitle: 'Secure storage',
      icon: Icons.folder_rounded,
      color: AppTheme.primaryPurple,
      route: '/vault',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppTheme.spaceMD),
              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: AppTheme.spaceXL),
              // Features grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                child: Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              _buildFeaturesGrid(),
              const SizedBox(height: AppTheme.spaceXL),
              // Recent activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                child: Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              _buildRecentActivity(),
              const SizedBox(height: AppTheme.spaceXXL),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS Emergency activated!')),
          );
        },
        child: const Icon(Icons.emergency_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryPurple,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXLarge),
          bottomRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryPurple,
                        ],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 200, 70),
                      ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Morning',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification bell
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_rounded),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '24',
              'Calls Blocked',
              Icons.phone_disabled_rounded,
              AppTheme.error,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: _buildStatCard(
              '12',
              'SMS Scanned',
              Icons.message_rounded,
              AppTheme.warning,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: _buildStatCard(
              '98%',
              'Protection',
              Icons.shield_rounded,
              AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceXXS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spaceMD,
        mainAxisSpacing: AppTheme.spaceMD,
        childAspectRatio: 1.2,
      ),
      itemCount: _features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(_features[index]);
      },
    );
  }

  Widget _buildFeatureCard(DashboardFeature feature) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${feature.title} coming soon!')),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  feature.icon,
                  color: feature.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceXXS),
              Text(
                feature.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _buildActivityItem(
          'Blocked spam call',
          '+91 9876543210',
          '2 minutes ago',
          Icons.phone_disabled_rounded,
          AppTheme.error,
        ),
        _buildActivityItem(
          'Scanned SMS message',
          'Suspicious link detected',
          '15 minutes ago',
          Icons.message_rounded,
          AppTheme.warning,
        ),
        _buildActivityItem(
          'Family member arrived',
          'John arrived at School',
          '1 hour ago',
          Icons.location_on_rounded,
          AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spaceXS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom_rounded),
          label: 'Family',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shield_rounded),
          label: 'Protection',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}

class DashboardFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  DashboardFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
