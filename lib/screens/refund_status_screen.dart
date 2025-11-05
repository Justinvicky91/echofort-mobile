import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/refund_service.dart';
import 'dart:async';

/// Refund Status Screen
/// Shows the status of refund request
class RefundStatusScreen extends StatefulWidget {
  final int refundRequestId;
  
  const RefundStatusScreen({
    Key? key,
    required this.refundRequestId,
  }) : super(key: key);
  
  @override
  State<RefundStatusScreen> createState() => _RefundStatusScreenState();
}

class _RefundStatusScreenState extends State<RefundStatusScreen> {
  final _refundService = RefundService();
  bool _isLoading = true;
  Map<String, dynamic>? _refundData;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadRefundStatus();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadRefundStatus();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadRefundStatus() async {
    try {
      final response = await _refundService.getRefundStatus(widget.refundRequestId);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _refundData = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Status'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRefundStatus,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _refundData == null
                ? _buildErrorView()
                : _buildStatusView(),
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.spaceLG),
          Text(
            'Loading refund status...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          Text(
            'Failed to load refund status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          ElevatedButton(
            onPressed: _loadRefundStatus,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusView() {
    final status = _refundData!['status'] ?? 'pending_approval';
    final amount = _refundData!['amount'] ?? 0.0;
    final requestedAt = _refundData!['requested_at'];
    final processedAt = _refundData!['processed_at'];
    final razorpayRefundId = _refundData!['razorpay_refund_id'];
    final estimatedCreditDate = _refundData!['estimated_credit_date'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status icon
          _buildStatusIcon(status),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Status title
          Text(
            _getStatusTitle(status),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Status description
          Text(
            _getStatusDescription(status),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Refund details card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refund Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildDetailRow('Request ID', '#${widget.refundRequestId}'),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildDetailRow('Amount', '₹${amount.toStringAsFixed(0)}'),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildDetailRow('Status', _getStatusLabel(status)),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildDetailRow('Requested', _formatDate(requestedAt)),
                  if (processedAt != null) ...[
                    const SizedBox(height: AppTheme.spaceSM),
                    _buildDetailRow('Processed', _formatDate(processedAt)),
                  ],
                  if (razorpayRefundId != null) ...[
                    const SizedBox(height: AppTheme.spaceSM),
                    _buildDetailRow('Refund ID', razorpayRefundId),
                  ],
                  if (estimatedCreditDate != null) ...[
                    const SizedBox(height: AppTheme.spaceSM),
                    _buildDetailRow('Est. Credit Date', _formatDate(estimatedCreditDate)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Timeline
          _buildTimeline(status),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Info based on status
          if (status == 'pending_approval')
            _buildInfoCard(
              'Pending Review',
              'Your refund request is being reviewed by our admin team. You will be notified within 24 hours.',
              AppTheme.warningColor,
            ),
          
          if (status == 'approved' || status == 'processed')
            _buildInfoCard(
              'Refund Approved',
              'Your refund has been processed. The amount will be credited to your original payment method within 5-7 business days.',
              AppTheme.successColor,
            ),
          
          if (status == 'rejected')
            _buildInfoCard(
              'Refund Rejected',
              _refundData!['admin_notes'] ?? 'Your refund request was not approved. Please contact support for more information.',
              AppTheme.errorColor,
            ),
          
          const SizedBox(height: AppTheme.spaceXL),
          
          // Action buttons
          if (status == 'pending_approval')
            OutlinedButton(
              onPressed: () {
                // TODO: Cancel refund request
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text('Cancel Request'),
            ),
          
          if (status == 'rejected')
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to support
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text('Contact Support'),
            ),
          
          const SizedBox(height: AppTheme.spaceMD),
          
          // Back to dashboard
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case 'pending_approval':
        icon = Icons.pending_rounded;
        color = AppTheme.warningColor;
        break;
      case 'approved':
      case 'processed':
        icon = Icons.check_circle_rounded;
        color = AppTheme.successColor;
        break;
      case 'rejected':
        icon = Icons.cancel_rounded;
        color = AppTheme.errorColor;
        break;
      default:
        icon = Icons.help_rounded;
        color = AppTheme.textSecondaryLight;
    }
    
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 50,
          color: color,
        ),
      ),
    );
  }
  
  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending_approval':
        return 'Refund Pending';
      case 'approved':
        return 'Refund Approved';
      case 'processed':
        return 'Refund Processed';
      case 'rejected':
        return 'Refund Rejected';
      default:
        return 'Refund Status';
    }
  }
  
  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending_approval':
        return 'Your refund request is being reviewed';
      case 'approved':
        return 'Your refund has been approved and is being processed';
      case 'processed':
        return 'Your refund has been completed';
      case 'rejected':
        return 'Your refund request was not approved';
      default:
        return 'Check the details below';
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending_approval':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'processed':
        return 'Processed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeline(String status) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            _buildTimelineItem('Request Submitted', true),
            _buildTimelineItem('Admin Review', status != 'pending_approval'),
            _buildTimelineItem('Refund Processed', status == 'processed'),
            _buildTimelineItem('Amount Credited', false),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.successColor : AppTheme.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppTheme.successColor : AppTheme.textSecondaryLight,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isCompleted ? AppTheme.textPrimaryLight : AppTheme.textSecondaryLight,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
