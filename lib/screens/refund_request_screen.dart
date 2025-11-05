import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/refund_service.dart';
import 'refund_status_screen.dart';

/// Refund Request Screen
/// Allows users to request refund within 24 hours
class RefundRequestScreen extends StatefulWidget {
  final String paymentId;
  final double amount;
  final String planName;
  
  const RefundRequestScreen({
    Key? key,
    required this.paymentId,
    required this.amount,
    required this.planName,
  }) : super(key: key);
  
  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _refundService = RefundService();
  bool _isLoading = false;
  bool _isEligible = false;
  String? _eligibilityMessage;
  
  final List<String> _refundReasons = [
    'Not satisfied with service',
    'Found a better alternative',
    'Technical issues',
    'Changed my mind',
    'Accidental purchase',
    'Other',
  ];
  
  String _selectedReason = 'Not satisfied with service';
  
  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  Future<void> _checkEligibility() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _refundService.checkRefundEligibility(
        userId: 1, // TODO: Get from auth state
        paymentId: widget.paymentId,
      );
      
      setState(() {
        _isLoading = false;
        _isEligible = response['eligible'] ?? false;
        _eligibilityMessage = response['message'];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isEligible = false;
        _eligibilityMessage = 'Error checking eligibility: $e';
      });
    }
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final reason = _selectedReason == 'Other'
          ? _reasonController.text
          : _selectedReason;
      
      final response = await _refundService.requestRefund(
        userId: 1, // TODO: Get from auth state
        paymentId: widget.paymentId,
        reason: reason,
      );
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Refund requested successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Navigate to refund status screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RefundStatusScreen(
              refundRequestId: response['refund_request_id'],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
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
        title: const Text('Request Refund'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading && _eligibilityMessage == null
            ? _buildLoadingView()
            : !_isEligible
                ? _buildIneligibleView()
                : _buildFormView(),
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
            'Checking eligibility...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildIneligibleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Title
          Text(
            'Refund Not Available',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Message
          Text(
            _eligibilityMessage ?? 'This payment is not eligible for refund.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Info card
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
                    'Refund Policy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildPolicyPoint('Refunds are available within 24 hours of payment'),
                  _buildPolicyPoint('Full amount will be refunded'),
                  _buildPolicyPoint('Processing time: 5-7 business days'),
                  _buildPolicyPoint('Refund will be credited to original payment method'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Contact support button
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to support screen
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
            child: const Text('Contact Support'),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Back button
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment details card
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
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    _buildDetailRow('Plan', widget.planName),
                    const SizedBox(height: AppTheme.spaceSM),
                    _buildDetailRow('Amount', '₹${widget.amount.toStringAsFixed(0)}'),
                    const SizedBox(height: AppTheme.spaceSM),
                    _buildDetailRow('Payment ID', widget.paymentId),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXL),
            
            // Reason selection
            Text(
              'Reason for Refund',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            ..._ refundReasons.map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() => _selectedReason = value!);
                  },
                  activeColor: AppTheme.primaryBlue,
                )),
            
            // Additional details for "Other"
            if (_selectedReason == 'Other') ...[
              const SizedBox(height: AppTheme.spaceMD),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Please specify',
                  hintText: 'Enter your reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (_selectedReason == 'Other' && (value == null || value.isEmpty)) {
                    return 'Please specify your reason';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppTheme.spaceXL),
            
            // 24-hour policy info
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: AppTheme.infoColor,
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24-Hour Refund Policy',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.infoColor,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spaceXS),
                        Text(
                          'Admin will review your request within 24 hours. Full refund will be processed if approved.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceXL),
            
            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Refund Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
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
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
  
  Widget _buildPolicyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
