import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/standard_card.dart';
import '../../widgets/status_badge.dart';

/// Scan Screen (§1.10)
/// 
/// Per ChatGPT CTO specification:
/// "QR/barcode scanner for verifying URLs, phone numbers, and products against scam database."
/// 
/// Design Requirements:
/// - Camera viewfinder with scanning overlay
/// - Scan history list
/// - Manual input option
/// - Scan result with risk assessment
/// - Share/report functionality
/// 
/// Technical Requirements:
/// - QR code scanner plugin (qr_code_scanner or mobile_scanner)
/// - Barcode scanner support
/// - URL/phone number extraction
/// - Backend verification via /api/scan/verify
/// - Scan history persistence
class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  bool _showHistory = false;
  
  // Mock scan history (TODO: Replace with local storage + API)
  final List<Map<String, dynamic>> _scanHistory = [
    {
      'id': '1',
      'type': 'url',
      'content': 'https://secure-bank-login.com',
      'time': '2 hours ago',
      'riskLevel': 'critical',
      'verdict': 'Phishing Site',
      'confidence': 98,
    },
    {
      'id': '2',
      'type': 'phone',
      'content': '+91 98765 43210',
      'time': 'Yesterday',
      'riskLevel': 'high',
      'verdict': 'Known Scammer',
      'confidence': 92,
    },
    {
      'id': '3',
      'type': 'url',
      'content': 'https://amazon.in/product/xyz',
      'time': '2 days ago',
      'riskLevel': 'safe',
      'verdict': 'Verified Safe',
      'confidence': 5,
    },
    {
      'id': '4',
      'type': 'barcode',
      'content': '8901234567890',
      'time': '3 days ago',
      'riskLevel': 'safe',
      'verdict': 'Genuine Product',
      'confidence': 3,
    },
  ];

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    
    // TODO: Implement actual camera scanning
    // Simulate scan after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isScanning) {
        _handleScanResult('https://fake-payment-gateway.com', 'url');
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _handleScanResult(String content, String type) async {
    _stopScanning();
    
    // TODO: Call backend API for verification
    print('[SCAN] Verifying: $content (type: $type)');
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock result
    final result = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'content': content,
      'time': 'Just now',
      'riskLevel': 'critical',
      'verdict': 'Phishing Site',
      'confidence': 95,
    };
    
    // Show result dialog
    if (mounted) {
      _showScanResultDialog(result);
    }
  }

  void _showScanResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getRiskIcon(result['riskLevel']),
              color: _getRiskColor(result['riskLevel']),
            ),
            const SizedBox(width: 8),
            const Text('Scan Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(
              label: result['verdict'],
              type: _getRiskBadgeType(result['riskLevel']),
              small: false,
            ),
            const SizedBox(height: 12),
            Text(
              result['content'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  size: 16,
                  color: AppTheme.primarySolid,
                ),
                const SizedBox(width: 6),
                Text(
                  '${result['confidence']}% AI Confidence',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primarySolid,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (result['riskLevel'] != 'safe')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                print('[ACTION] Report scam: ${result['content']}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Reported to scam database'),
                    backgroundColor: AppTheme.accentSuccess,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentDanger,
              ),
              child: const Text('Report'),
            ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter URL, phone number, or code',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              Navigator.pop(context);
              if (input.isNotEmpty) {
                // Determine type
                String type = 'text';
                if (input.startsWith('http')) {
                  type = 'url';
                } else if (input.startsWith('+') || RegExp(r'^\d+$').hasMatch(input)) {
                  type = 'phone';
                }
                _handleScanResult(input, type);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySolid,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'critical':
        return AppTheme.accentDanger;
      case 'high':
        return const Color(0xFFFF6B35);
      case 'medium':
        return AppTheme.accentWarning;
      case 'low':
        return AppTheme.accentSuccess;
      case 'safe':
        return AppTheme.accentSuccess;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRiskIcon(String level) {
    switch (level) {
      case 'critical':
      case 'high':
        return Icons.dangerous_rounded;
      case 'medium':
        return Icons.warning_rounded;
      case 'low':
      case 'safe':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  BadgeType _getRiskBadgeType(String level) {
    switch (level) {
      case 'critical':
      case 'high':
        return BadgeType.danger;
      case 'medium':
        return BadgeType.warning;
      case 'low':
      case 'safe':
        return BadgeType.success;
      default:
        return BadgeType.neutral;
    }
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
              'Scan & Verify',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showHistory ? Icons.qr_code_scanner : Icons.history,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body: _showHistory ? _buildHistoryView() : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        // Camera viewfinder
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowLg,
            ),
            child: Stack(
              children: [
                // Camera placeholder
                Center(
                  child: _isScanning
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Scanning animation
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Stack(
                                children: [
                                  // Corner brackets
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Icon(
                                      Icons.crop_free,
                                      size: 200,
                                      color: AppTheme.primarySolid,
                                    ),
                                  ),
                                  // Scanning line (animated)
                                  Center(
                                    child: Container(
                                      width: 180,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppTheme.primarySolid,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Scanning...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Point camera at QR code or barcode',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Ready to Scan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the button below to start',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // Controls
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Start/Stop scan button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _isScanning ? null : AppTheme.primaryGradient,
                  color: _isScanning ? AppTheme.accentDanger : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: (_isScanning ? AppTheme.accentDanger : AppTheme.primarySolid)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScanning : _startScanning,
                  icon: Icon(
                    _isScanning ? Icons.stop_rounded : Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isScanning ? 'Stop Scanning' : 'Start Scanning',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Manual input button
              OutlinedButton.icon(
                onPressed: _showManualInputDialog,
                icon: Icon(Icons.edit_rounded, color: AppTheme.primarySolid),
                label: Text(
                  'Enter Manually',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primarySolid,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primarySolid),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _scanHistory.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Scan History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          );
        }
        
        final scan = _scanHistory[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryCard(scan),
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> scan) {
    return GestureDetector(
      onTap: () => _showScanResultDialog(scan),
      child: StandardCard(
        child: Row(
          children: [
            // Risk indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRiskColor(scan['riskLevel']).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRiskIcon(scan['riskLevel']),
                color: _getRiskColor(scan['riskLevel']),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Scan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        scan['verdict'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      StatusBadge(
                        label: scan['type'].toUpperCase(),
                        type: BadgeType.neutral,
                        small: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan['content'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scan['time'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.psychology_rounded,
                        size: 12,
                        color: AppTheme.primarySolid,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${scan['confidence']}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primarySolid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
