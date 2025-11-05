import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScreenTimeScreen extends StatelessWidget {
  const ScreenTimeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Time')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                child: Column(
                  children: [
                    Text(
                      'Today',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Text(
                      '4h 32m',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      'Daily average: 5h 12m',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'Most Used Apps',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            _buildAppUsageCard('WhatsApp', '1h 45m', Icons.chat, Colors.green),
            _buildAppUsageCard('Instagram', '1h 12m', Icons.photo_camera, Colors.pink),
            _buildAppUsageCard('YouTube', '58m', Icons.play_circle, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageCard(String name, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceXS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        trailing: Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
