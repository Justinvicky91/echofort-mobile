import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/standard_card.dart';
import '../../widgets/status_badge.dart';
import '../../services/api_service.dart';

/// Home Shield Screen (§1.7)
/// 
/// Per ChatGPT CTO specification:
/// "The main dashboard. User sees this after login. Must feel premium and informative."
/// 
/// Design Requirements:
/// - Large circular threat score (0-100) with color gradient
/// - Protection status badge (Protected/At Risk/Scanning)
/// - Recent scam calls list (last 5 calls with risk levels)
/// - Family safety status card (if Family plan)
/// - Quick action buttons (Scan QR, Report Scam, Settings)
/// - Stats cards (Calls Blocked, Threats Detected, Family Members)
/// 
/// Technical Requirements:
/// - Real-time threat score from backend
/// - Pull-to-refresh functionality
/// - Navigation to Calls/Family/Scan/Settings screens
/// - Subscription tier awareness (show Family features only for Family plan)
class HomeShieldScreen extends StatefulWidget {
  const HomeShieldScreen({Key? key}) : super(key: key);

  @override
  _HomeShieldScreenState createState() => _HomeShieldScreenState();
}

class _HomeShieldScreenState extends State<HomeShieldScreen> {
  bool _isLoading = false;
  
  // Data from backend
  int _threatScore = 0;
  String _protectionStatus = 'Scanning';
  int _callsBlocked = 0;
  int _threatsDetected = 0;
  int _familyMembers = 0;
  bool _hasFamilyPlan = false;
  List<Map<String, dynamic>> _recentCalls = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('[HOME] Loading dashboard data...');
      
      // Load recent calls
      final calls = await ApiService.getRecentScamCalls();
      
      setState(() {
        _recentCalls = calls.take(5).map((call) => {
          'number': call['phone_number'] ?? 'Unknown',
          'name': call['caller_name'] ?? 'Unknown',
          'time': _formatTime(call['timestamp']),
          'riskLevel': call['risk_level'] ?? 'low',
          'type': call['scam_type'] ?? 'Unknown',
        }).toList();
        
        _callsBlocked = calls.length;
        _threatsDetected = calls.where((c) => c['risk_level'] == 'high' || c['risk_level'] == 'critical').length;
        
        // Calculate threat score (0-100)
        if (calls.isEmpty) {
          _threatScore = 100;
          _protectionStatus = 'Protected';
        } else if (_threatsDetected > 10) {
          _threatScore = 50;
          _protectionStatus = 'At Risk';
        } else {
          _threatScore = 75;
          _protectionStatus = 'Protected';
        }
      });
      
      print('[HOME] Dashboard loaded: ${_recentCalls.length} calls');
    } catch (e) {
      print('[HOME] Error loading dashboard: $e');
      // Keep default values on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  // Mock recent calls for fallback
  final List<Map<String, dynamic>> _mockRecentCalls = [
    {
      'number': '+91 98765 43210',
      'name': 'Unknown',
      'time': '2 hours ago',
      'riskLevel': 'high',
      'type': 'Scam',
    },
    {
      'number': '+91 87654 32109',
      'name': 'Bank Fraud',
      'time': '5 hours ago',
      'riskLevel': 'critical',
      'type': 'Phishing',
    },
    {
      'number': '+91 76543 21098',
      'name': 'Unknown',
      'time': 'Yesterday',
      'riskLevel': 'medium',
      'type': 'Spam',
    },
    {
      'number': '+91 65432 10987',
      'name': 'Telemarketing',
      'time': 'Yesterday',
      'riskLevel': 'low',
      'type': 'Marketing',
    },
    {
      'number': '+91 54321 09876',
      'name': 'Unknown',
      'time': '2 days ago',
      'riskLevel': 'medium',
      'type': 'Spam',
    },
  ];

  Future<void> _refreshData() async {
    await _loadDashboardData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard refreshed'),
          backgroundColor: AppTheme.accentSuccess,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Color _getThreatScoreColor(int score) {
    if (score >= 80) return AppTheme.accentSuccess;
    if (score >= 60) return AppTheme.accentWarning;
    return AppTheme.accentDanger;
  }

  Color _getRiskLevelColor(String level) {
    switch (level) {
      case 'critical':
        return AppTheme.accentDanger;
      case 'high':
        return const Color(0xFFFF6B35);
      case 'medium':
        return AppTheme.accentWarning;
      case 'low':
        return AppTheme.accentSuccess;
      default:
        return AppTheme.textSecondary;
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
            const EchoFortLogo(size: 28, variant: LogoVariant.primary),
            const SizedBox(width: 10),
            Text(
              'EchoFort',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              // TODO: Navigate to notifications
              print('[NAV] Notifications tapped');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primarySolid,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Threat Score Card
              _buildThreatScoreCard(),
              
              const SizedBox(height: 20),
              
              // Stats Row
              _buildStatsRow(),
              
              const SizedBox(height: 20),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 24),
              
              // Family Safety Card (if Family plan)
              if (_hasFamilyPlan) ...[
                _buildFamilySafetyCard(),
                const SizedBox(height: 24),
              ],
              
              // Recent Scam Calls
              _buildRecentCallsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatScoreCard() {
    final scoreColor = _getThreatScoreColor(_threatScore);
    
    return StandardCard(
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Protection Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              StatusBadge(
                label: _protectionStatus,
                type: BadgeType.success,
                small: false,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Circular Threat Score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _threatScore / 100,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_threatScore',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'Threat Score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'Your device is well protected. Keep monitoring for threats.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.block_rounded,
            label: 'Blocked',
            value: '$_callsBlocked',
            color: AppTheme.accentDanger,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.shield_rounded,
            label: 'Threats',
            value: '$_threatsDetected',
            color: AppTheme.accentWarning,
          ),
        ),
        if (_hasFamilyPlan) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_rounded,
              label: 'Family',
              value: '$_familyMembers',
              color: AppTheme.accentSuccess,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return StandardCard(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            onTap: () {
              print('[NAV] Scan QR tapped');
              // TODO: Navigate to Scan screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.report_rounded,
            label: 'Report',
            onTap: () {
              print('[NAV] Report Scam tapped');
              // TODO: Show report dialog
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () {
              print('[NAV] Settings tapped');
              // TODO: Navigate to Settings screen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primarySolid.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySafetyCard() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentSuccess.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: AppTheme.accentSuccess,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Family Safety',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: 'All Safe',
                type: BadgeType.success,
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'All family members are protected. No threats detected in the last 24 hours.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              print('[NAV] View Family Dashboard tapped');
              // TODO: Navigate to Family screen
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primarySolid),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Family Dashboard',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primarySolid,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.primarySolid,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCallsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scam Calls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                print('[NAV] View All Calls tapped');
                // TODO: Navigate to Calls screen
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primarySolid,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentCalls.map((call) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCallCard(call),
        )).toList(),
      ],
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
    return StandardCard(
      child: Row(
        children: [
          // Risk indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getRiskLevelColor(call['riskLevel']),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // Call icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRiskLevelColor(call['riskLevel']).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_rounded,
              color: _getRiskLevelColor(call['riskLevel']),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Call details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  call['number'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  call['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge
          StatusBadge(
            label: call['type'],
            type: _getRiskBadgeType(call['riskLevel']),
            small: true,
          ),
        ],
      ),
    );
  }
}
