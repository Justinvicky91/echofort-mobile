import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';
import 'pricing_screen.dart';
import 'otp_verification_screen.dart';

/// Payment Screen
/// Handles Razorpay payment integration
class PaymentScreen extends StatefulWidget {
  final PricingPlan selectedPlan;
  final String billingPeriod; // 'monthly' or 'yearly'
  
  const PaymentScreen({
    Key? key,
    required this.selectedPlan,
    required this.billingPeriod,
  }) : super(key: key);
  
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  bool _isLoading = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initializePayment();
  }
  
  void _initializePayment() {
    _paymentService.initializeRazorpay(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }
  
  double get _amount {
    if (widget.billingPeriod == 'yearly') {
      return widget.selectedPlan.yearlyPrice;
    }
    return widget.selectedPlan.monthlyPrice;
  }
  
  Future<void> _handlePayNow() async {
    setState(() => _isLoading = true);
    
    try {
      // Create order on backend
      final orderResponse = await _paymentService.createOrder(
        userId: 1, // TODO: Get from auth state
        planName: widget.selectedPlan.name,
        amount: _amount,
        billingPeriod: widget.billingPeriod,
      );
      
      setState(() => _isLoading = false);
      
      // Open Razorpay checkout
      _paymentService.openCheckout(
        orderId: orderResponse['order_id'],
        amount: _amount,
        planName: widget.selectedPlan.name,
        userName: 'John Doe', // TODO: Get from auth state
        userEmail: 'john@example.com', // TODO: Get from auth state
        userPhone: '+919876543210', // TODO: Get from auth state
      );
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
  
  void _handlePaymentSuccess(Map<String, dynamic> response) async {
    setState(() => _isProcessing = true);
    
    try {
      // Verify payment on backend
      final verifyResponse = await _paymentService.verifyPayment(
        paymentId: response['razorpay_payment_id'],
        orderId: response['razorpay_order_id'],
        signature: response['razorpay_signature'],
        userId: 1, // TODO: Get from auth state
      );
      
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! 🎉'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Navigate to OTP verification
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: '+919876543210', // TODO: Get from auth state
              selectedPlan: widget.selectedPlan,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  void _handlePaymentError(Map<String, dynamic> response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response['description']}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isProcessing
            ? _buildProcessingView()
            : _buildPaymentView(),
      ),
    );
  }
  
  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.spaceLG),
          Text(
            'Processing payment...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            'Please wait',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Plan summary card
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
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  _buildSummaryRow('Plan', widget.selectedPlan.name),
                  const SizedBox(height: AppTheme.spaceSM),
                  _buildSummaryRow(
                    'Billing Period',
                    widget.billingPeriod == 'yearly' ? 'Yearly' : 'Monthly',
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  if (widget.billingPeriod == 'yearly')
                    _buildSummaryRow(
                      'Discount',
                      'Save 20%',
                      valueColor: AppTheme.successColor,
                    ),
                  const Divider(height: AppTheme.spaceLG),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹${_amount.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          
          // Features included
          Text(
            'What\'s Included',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          ...widget.selectedPlan.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spaceSM),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppTheme.spaceXL),
          
          // 24-hour free trial info
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
                        '24-Hour Free Trial',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.infoColor,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spaceXS),
                      Text(
                        'Full refund available if you cancel within 24 hours',
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
          
          // Pay now button
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePayNow,
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
                : Text(
                    'Pay ₹${_amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          
          // Secure payment info
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
  
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                fontSize: isTotal ? 18 : 14,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
