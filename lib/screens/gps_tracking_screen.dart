import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GPSTrackingScreen extends StatefulWidget {
  const GPSTrackingScreen({Key? key}) : super(key: key);
  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  bool _isTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Tracking')),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 400,
            color: Colors.grey[300],
            child: const Center(
              child: Text('Map View\n(Google Maps Integration)'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Location Tracking'),
                    subtitle: const Text('Share your location with family'),
                    value: _isTracking,
                    onChanged: (value) {
                      setState(() { _isTracking = value; });
                    },
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: const Text('Family Member 1'),
                      subtitle: const Text('Last seen: 2 mins ago'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
