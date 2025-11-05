import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';
import 'pricing_screen.dart';
import 'address_id_verification_screen.dart';

/// Auto-Debit Verification Screen
/// Handles ₹1 auto-debit setup for subscription
class AutoDebitScreen extends StatefulWidget {
  final PricingPlan selectedPlan;
  final String billingPeriod;
  
  const AutoDebitScreen({
    Key? key,
    required this.selectedPlan,
    required this.billingPeriod,
  }) : super(key: key);
  
  @override
  State<AutoDebitScreen> createState() => _AutoDebitScreenState();
}

class _AutoDebitScreenState extends State<AutoDebitScreen> {
  final _paymentService = PaymentService();
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _subscriptionId;
  String? _shortUrl;
  
  @override
  void initState() {
    super.initState();
    _createSubscription();
  }
  
  Future<void> _createSubscription() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _paymentService.createSubscription(
        userId: 1, // TODO: Get from auth state
        planName: widget.selectedPlan.name,
        amount: widget.billingPeriod == 'yearly'
            ? widget.selectedPlan.yearlyPrice
            : widget.selectedPlan.monthlyPrice,
        billingPeriod: widget.billingPeriod,
      );
      
      setState(() {
        _isLoading = false;
        _subscriptionId = response['subscription_id'];
        _shortUrl = response['short_url'];
      });
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
  
  Future<void> _verifyAutoDebit() async {
    if (_subscriptionId == null) return;
    
    setState(() => _isVerifying = true);
    
    try {
      final response = await _paymentService.verifyAutoDebit(
        userId: 1, // TODO: Get from auth state
        subscriptionId: _subscriptionId!,
      );
      
      setState(() => _isVerifying = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Navigate to address/ID verification
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddressIDVerificationScreen(
              selectedPlan: widget.selectedPlan,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
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
        title: const Text('Auto-Debit Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _buildContentView(),
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
            'Setting up subscription...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentView() {
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
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              size: 50,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Title
          Text(
            'Auto-Debit Verification',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Description
          Text(
            'To activate your subscription, we need to verify your payment method with a ₹1 charge. This amount will be refunded within 5-7 business days.',
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
                    'How it works',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildStep(
                    1,
                    'Authorize Auto-Debit',
                    'Complete the ₹1 verification payment',
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildStep(
                    2,
                    'Verification Complete',
                    'Your payment method is verified',
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildStep(
                    3,
                    'Refund Initiated',
                    '₹1 will be refunded within 5-7 days',
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildStep(
                    4,
                    'Subscription Active',
                    'Your plan will be activated',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Benefits
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spaceSM),
                    Text(
                      'Why Auto-Debit?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.successColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSM),
                _buildBenefit('Never miss a payment'),
                _buildBenefit('Automatic renewal'),
                _buildBenefit('Cancel anytime'),
                _buildBenefit('Full refund within 24 hours'),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Authorize button
          ElevatedButton(
            onPressed: _subscriptionId != null && !_isVerifying
                ? () {
                    // TODO: Open Razorpay checkout for ₹1
                    // For now, simulate verification
                    _verifyAutoDebit();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
            child: _isVerifying
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Authorize ₹1 Auto-Debit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Skip button
          TextButton(
            onPressed: () {
              // Navigate to address/ID verification without auto-debit
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AddressIDVerificationScreen(
                    selectedPlan: widget.selectedPlan,
                  ),
                ),
              );
            },
            child: const Text('Skip for now'),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Secure info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 16,
                color: AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: AppTheme.spaceXS),
              Text(
                'Secure payment powered by Razorpay',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXS),
      child: Row(
        children: [
          const Icon(
            Icons.check_rounded,
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
