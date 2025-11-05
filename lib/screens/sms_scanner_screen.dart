import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// SMS Scanner & Phishing Detection Screen
/// AI-powered SMS analysis for scam detection
class SMSScannerScreen extends StatefulWidget {
  const SMSScannerScreen({Key? key}) : super(key: key);

  @override
  State<SMSScannerScreen> createState() => _SMSScannerScreenState();
}

class _SMSScannerScreenState extends State<SMSScannerScreen> {
  bool _isScanning = false;
  List<Map<String, dynamic>> _scamMessages = [];
  int _totalScanned = 0;
  int _threatsDetected = 0;

  @override
  void initState() {
    super.initState();
    _loadScamMessages();
  }

  Future<void> _loadScamMessages() async {
    try {
      final response = await ApiService.get('/api/mobile/sms/scam-list');
      setState(() {
        _scamMessages = List<Map<String, dynamic>>.from(response['messages'] ?? []);
        _totalScanned = response['total_scanned'] ?? 0;
        _threatsDetected = response['threats_detected'] ?? 0;
      });
    } catch (e) {
      print('Error loading scam messages: $e');
    }
  }

  Future<void> _scanMessages() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final response = await ApiService.post('/api/mobile/sms/scan', {});
      setState(() {
        _totalScanned = response['total_scanned'] ?? 0;
        _threatsDetected = response['threats_detected'] ?? 0;
        _isScanning = false;
      });
      await _loadScamMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan complete! Found $_threatsDetected threats'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to SMS scanner settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadScamMessages,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Scanned',
                      _totalScanned.toString(),
                      Icons.message,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSM),
                  Expanded(
                    child: _buildStatCard(
                      'Threats Blocked',
                      _threatsDetected.toString(),
                      Icons.shield,
                      AppTheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spaceMD),

              // Scan Button
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        size: 64,
                        color: AppTheme.primaryBlue.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppTheme.spaceMD),
                      Text(
                        'Scan Your Messages',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spaceXS),
                      Text(
                        'AI-powered analysis to detect phishing and scam messages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spaceMD),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isScanning ? null : _scanMessages,
                          icon: _isScanning
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isScanning ? 'Scanning...' : 'Scan Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scam Messages List
              const SizedBox(height: AppTheme.spaceXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detected Threats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_scamMessages.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Clear all
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSM),
              
              if (_scamMessages.isEmpty)
                _buildEmptyState()
              else
                ..._scamMessages.map((message) => _buildMessageCard(message)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
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

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final riskLevel = message['risk_level'] ?? 'medium';
    final isHighRisk = riskLevel == 'high' || riskLevel == 'critical';

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceXS),
      color: isHighRisk ? AppTheme.error.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceXS,
                    vertical: AppTheme.spaceXXS,
                  ),
                  decoration: BoxDecoration(
                    color: isHighRisk ? AppTheme.error : AppTheme.warning,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    riskLevel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  message['time'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              message['sender'] ?? 'Unknown Sender',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              message['content'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (message['scam_type'] != null) ...[
              const SizedBox(height: AppTheme.spaceXS),
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: AppTheme.error),
                  const SizedBox(width: AppTheme.spaceXXS),
                  Text(
                    message['scam_type'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.spaceSM),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View details
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Delete message
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.success.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'All Clear!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              'No scam messages detected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
