import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SOSEmergencyScreen extends StatefulWidget {
  const SOSEmergencyScreen({Key? key}) : super(key: key);
  @override
  State<SOSEmergencyScreen> createState() => _SOSEmergencyScreenState();
}

class _SOSEmergencyScreenState extends State<SOSEmergencyScreen> {
  bool _isEmergency = false;

  void _triggerSOS() {
    setState(() { _isEmergency = true; });
    // Trigger SOS alert
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Alert Sent!'),
            backgroundColor: AppTheme.success,
          ),
        );
        setState(() { _isEmergency = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency'),
        backgroundColor: AppTheme.error,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            Card(
              color: AppTheme.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceXL),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 80,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Text(
                      'Emergency SOS',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      'Press the button below to alert your emergency contacts',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spaceXL),
                    GestureDetector(
                      onTap: _isEmergency ? null : _triggerSOS,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: _isEmergency ? Colors.grey : AppTheme.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.error.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isEmergency
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            _buildContactCard('Police', '100', Icons.local_police),
            _buildContactCard('Ambulance', '108', Icons.local_hospital),
            _buildContactCard('Fire', '101', Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String name, String number, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceXS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.error.withOpacity(0.2),
          child: Icon(icon, color: AppTheme.error),
        ),
        title: Text(name),
        subtitle: Text(number),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: AppTheme.success),
          onPressed: () {
            // Call number
          },
        ),
      ),
    );
  }
}
