import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Caller ID & Scam Detection Screen
/// Real-time call screening with AI-powered scam detection
class CallerIDScreen extends StatefulWidget {
  const CallerIDScreen({Key? key}) : super(key: key);

  @override
  State<CallerIDScreen> createState() => _CallerIDScreenState();
}

class _CallerIDScreenState extends State<CallerIDScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _callerInfo;

  Future<void> _checkNumber() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _callerInfo = null;
    });

    try {
      final response = await ApiService.post('/api/mobile/caller-id/check', {
        'phone_number': _phoneController.text,
      });

      setState(() {
        _callerInfo = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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
        title: const Text('Caller ID'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to call history
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Phone Number',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+91 XXXXX XXXXX',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _checkNumber,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isLoading ? 'Checking...' : 'Check Number'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Results Section
            if (_callerInfo != null) ...[
              const SizedBox(height: AppTheme.spaceMD),
              _buildCallerInfoCard(),
            ],

            // Recent Calls Section
            const SizedBox(height: AppTheme.spaceXL),
            Text(
              'Recent Scam Calls Blocked',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            _buildRecentCallsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallerInfoCard() {
    final riskLevel = _callerInfo!['risk_level'] ?? 'unknown';
    final isScam = riskLevel == 'high' || riskLevel == 'critical';

    Color riskColor;
    IconData riskIcon;
    String riskText;

    switch (riskLevel) {
      case 'critical':
        riskColor = AppTheme.error;
        riskIcon = Icons.dangerous;
        riskText = 'CRITICAL THREAT';
        break;
      case 'high':
        riskColor = AppTheme.error;
        riskIcon = Icons.warning;
        riskText = 'HIGH RISK';
        break;
      case 'medium':
        riskColor = AppTheme.warning;
        riskIcon = Icons.error_outline;
        riskText = 'MEDIUM RISK';
        break;
      case 'low':
        riskColor = AppTheme.success;
        riskIcon = Icons.check_circle;
        riskText = 'LOW RISK';
        break;
      default:
        riskColor = Colors.grey;
        riskIcon = Icons.help_outline;
        riskText = 'UNKNOWN';
    }

    return Card(
      color: isScam ? AppTheme.error.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSM,
                vertical: AppTheme.spaceXXS,
              ),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(riskIcon, color: Colors.white, size: 16),
                  const SizedBox(width: AppTheme.spaceXXS),
                  Text(
                    riskText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),

            // Caller Name
            if (_callerInfo!['name'] != null) ...[
              Text(
                _callerInfo!['name'],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spaceXS),
            ],

            // Phone Number
            Text(
              _phoneController.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),

            // Scam Type
            if (_callerInfo!['scam_type'] != null) ...[
              const SizedBox(height: AppTheme.spaceMD),
              const Divider(),
              const SizedBox(height: AppTheme.spaceMD),
              Text(
                'Scam Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                _callerInfo!['scam_type'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],

            // Reports Count
            if (_callerInfo!['reports_count'] != null) ...[
              const SizedBox(height: AppTheme.spaceMD),
              Row(
                children: [
                  const Icon(Icons.report, size: 20, color: AppTheme.error),
                  const SizedBox(width: AppTheme.spaceXS),
                  Text(
                    '${_callerInfo!['reports_count']} reports',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],

            // Action Buttons
            const SizedBox(height: AppTheme.spaceMD),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Block number
                    },
                    icon: const Icon(Icons.block),
                    label: const Text('Block'),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Report scam
                    },
                    icon: const Icon(Icons.flag),
                    label: const Text('Report'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCallsList() {
    // Mock data - replace with actual API call
    final recentCalls = [
      {
        'phone': '+91 98765 43210',
        'name': 'Fake Bank',
        'time': '2 hours ago',
        'risk': 'high',
      },
      {
        'phone': '+91 87654 32109',
        'name': 'Lottery Scam',
        'time': '5 hours ago',
        'risk': 'critical',
      },
      {
        'phone': '+91 76543 21098',
        'name': 'Unknown',
        'time': 'Yesterday',
        'risk': 'medium',
      },
    ];

    return Column(
      children: recentCalls.map((call) {
        final isHighRisk = call['risk'] == 'high' || call['risk'] == 'critical';
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spaceXS),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isHighRisk ? AppTheme.error : AppTheme.warning,
              child: Icon(
                isHighRisk ? Icons.dangerous : Icons.warning,
                color: Colors.white,
              ),
            ),
            title: Text(call['name'] as String),
            subtitle: Text(call['phone'] as String),
            trailing: Text(
              call['time'] as String,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
