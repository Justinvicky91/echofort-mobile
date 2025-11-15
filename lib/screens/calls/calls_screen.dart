import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/standard_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/scam_report_dialog.dart';
import '../../services/api_service.dart'; Calls Screen (§1.8)
/// 
/// Per ChatGPT CTO specification:
/// "Full call history with scam detection results. Must show AI analysis for each call."
/// 
/// Design Requirements:
/// - Tabbed interface (All / Scam / Blocked / Safe)
/// - Call list with phone number, name, time, duration
/// - Risk level indicator and badge
/// - AI confidence score (e.g., "95% Scam Confidence")
/// - Search functionality
/// - Filter by date range
/// - Tap call to see detailed analysis
/// 
/// Technical Requirements:
/// - Tab controller for filtering
/// - Search bar with debounce
/// - Infinite scroll / pagination
/// - Pull-to-refresh
/// - Backend integration with /api/calls endpoint
class CallsScreen extends StatefulWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  
  // Mock data (TODO: Replace with real API calls)
  final List<Map<String, dynamic>> _allCalls = [
    {
      'id': '1',
      'number': '+91 98765 43210',
      'name': 'Unknown',
      'time': '2 hours ago',
      'duration': '0:23',
      'riskLevel': 'high',
      'type': 'Scam',
      'confidence': 95,
      'category': 'scam',
    },
    {
      'id': '2',
      'number': '+91 87654 32109',
      'name': 'Bank Fraud',
      'time': '5 hours ago',
      'duration': '1:45',
      'riskLevel': 'critical',
      'type': 'Phishing',
      'confidence': 98,
      'category': 'scam',
    },
    {
      'id': '3',
      'number': '+91 76543 21098',
      'name': 'Unknown',
      'time': 'Yesterday',
      'duration': '0:15',
      'riskLevel': 'medium',
      'type': 'Spam',
      'confidence': 72,
      'category': 'blocked',
    },
    {
      'id': '4',
      'number': '+91 65432 10987',
      'name': 'Telemarketing',
      'time': 'Yesterday',
      'duration': '2:10',
      'riskLevel': 'low',
      'type': 'Marketing',
      'confidence': 45,
      'category': 'blocked',
    },
    {
      'id': '5',
      'number': '+91 98123 45678',
      'name': 'Mom',
      'time': '2 days ago',
      'duration': '5:32',
      'riskLevel': 'safe',
      'type': 'Safe',
      'confidence': 5,
      'category': 'safe',
    },
    {
      'id': '6',
      'number': '+91 87123 45679',
      'name': 'Work',
      'time': '2 days ago',
      'duration': '12:45',
      'riskLevel': 'safe',
      'type': 'Safe',
      'confidence': 3,
      'category': 'safe',
    },
    {
      'id': '7',
      'number': '+91 54321 09876',
      'name': 'Unknown',
      'time': '3 days ago',
      'duration': '0:08',
      'riskLevel': 'medium',
      'type': 'Spam',
      'confidence': 68,
      'category': 'scam',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshCalls() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement real API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Call history refreshed'),
        backgroundColor: AppTheme.accentSuccess,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCalls() {
    final currentTab = _tabController.index;
    List<Map<String, dynamic>> filtered = _allCalls;

    // Filter by tab
    switch (currentTab) {
      case 1: // Scam
        filtered = _allCalls.where((call) => call['category'] == 'scam').toList();
        break;
      case 2: // Blocked
        filtered = _allCalls.where((call) => call['category'] == 'blocked').toList();
        break;
      case 3: // Safe
        filtered = _allCalls.where((call) => call['category'] == 'safe').toList();
        break;
      default: // All
        break;
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((call) {
        return call['number'].toLowerCase().contains(query) ||
               call['name'].toLowerCase().contains(query) ||
               call['type'].toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
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
      case 'safe':
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
      case 'safe':
        return BadgeType.success;
      default:
        return BadgeType.neutral;
    }
  }

  void _viewCallDetails(Map<String, dynamic> call) {
    // TODO: Navigate to call details screen
    print('[NAV] View call details: ${call['id']}');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (context) => _buildCallDetailsSheet(call),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search calls...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                ),
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EchoFortLogo(size: 24, variant: LogoVariant.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Call History',
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
              _isSearching ? Icons.close : Icons.search,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primarySolid,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primarySolid,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Scam'),
            Tab(text: 'Blocked'),
            Tab(text: 'Safe'),
          ],
          onTap: (index) {
            setState(() {});
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCalls,
        color: AppTheme.primarySolid,
        child: TabBarView(
          controller: _tabController,
          children: List.generate(4, (index) => _buildCallList()),
        ),
      ),
    );
  }

  Widget _buildCallList() {
    final calls = _getFilteredCalls();

    if (calls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_disabled_rounded,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No calls found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCallCard(call),
        );
      },
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
    return GestureDetector(
      onTap: () => _viewCallDetails(call),
      child: StandardCard(
        child: Row(
          children: [
            // Risk indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getRiskLevelColor(call['riskLevel']),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Call icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRiskLevelColor(call['riskLevel']).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_rounded,
                color: _getRiskLevelColor(call['riskLevel']),
                size: 22,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Call details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        call['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      StatusBadge(
                        label: call['type'],
                        type: _getRiskBadgeType(call['riskLevel']),
                        small: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    call['number'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${call['time']} • ${call['duration']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (call['confidence'] > 50) ...[
                        Icon(
                          Icons.psychology_rounded,
                          size: 14,
                          color: AppTheme.primarySolid,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${call['confidence']}% AI Confidence',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primarySolid,
                          ),
                        ),
                      ],
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

  Widget _buildCallDetailsSheet(Map<String, dynamic> call) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Call Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Call info
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getRiskLevelColor(call['riskLevel']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_rounded,
                  color: _getRiskLevelColor(call['riskLevel']),
                  size: 40,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              call['name'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              call['number'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // AI Analysis
            StandardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        color: AppTheme.primarySolid,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Risk Level:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      StatusBadge(
                        label: call['type'],
                        type: _getRiskBadgeType(call['riskLevel']),
                        small: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confidence:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${call['confidence']}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await ScamReportDialog.show(
                        context,
                        type: 'phone',
                        value: call['number'],
                      );
                      if (result == true) {
                        print('[ACTION] Scam reported: ${call['number']}');
                      }
                    },
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Report Scam'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentDanger,
                      side: BorderSide(color: AppTheme.accentDanger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('[ACTION] Report scam: ${call['number']}');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.report_rounded),
                    label: const Text('Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primarySolid,
                      side: BorderSide(color: AppTheme.primarySolid),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
