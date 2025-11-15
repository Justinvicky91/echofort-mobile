import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/standard_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/alert_card.dart';
import '../../models/subscription_plan.dart';
import '../../services/api_service.dart';

/// Paywall/Subscription Screen (§1.5)
/// 
/// Per ChatGPT CTO specification:
/// "This must be the most premium screen in the app. EchoFort's revenue depends on it."
/// 
/// Design Requirements:
/// - Three plan cards (Basic / Personal / Family)
/// - MUST match website pricing (₹399 / ₹799 / ₹1499)
/// - Family card has "Most Protection" badge
/// - Use spacing, card styling, typography, and icons from Brand Guidelines
/// - Features shown in clean bullet style
/// - Gradient "Continue with Razorpay" bottom CTA always visible
/// - Subtle entrance animation for each plan card
/// 
/// Technical Requirements:
/// - Subscription selection state
/// - Track button taps for analytics (stub)
/// - Leave payment execution for Razorpay screen (later step)
class PaywallScreen extends StatefulWidget {
  final bool isOnboarding;

  const PaywallScreen({
    Key? key,
    this.isOnboarding = false,
  }) : super(key: key);

  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> with TickerProviderStateMixin {
  String? _selectedPlanId;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  
  late Razorpay _razorpay;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Initialize animations for each plan card
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      for (var i = 0; i < _animationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _animationControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _razorpay.clear();
    super.dispose();
  }

  void _selectPlan(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
    
    // Analytics stub
    print('[ANALYTICS] Plan selected: $planId');
  }

  Future<void> _continueToPurchase() async {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a plan to continue'),
          backgroundColor: AppTheme.accentWarning,
        ),
      );
      return;
    }

    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      print('[PAYMENT] Creating Razorpay order for plan: $_selectedPlanId');
      
      // Create order on backend
      final orderResponse = await ApiService.createRazorpayOrder(
        plan: _selectedPlanId!,
        isTrial: false,
      );
      
      if (orderResponse['order_id'] == null) {
        throw Exception('Failed to create order');
      }
      
      final orderId = orderResponse['order_id'];
      final amount = orderResponse['amount']; // Amount in paise
      
      print('[PAYMENT] Order created: $orderId, amount: $amount');
      
      // Get plan details for display
      final plan = SubscriptionPlan.plans.firstWhere(
        (p) => p.id == _selectedPlanId,
      );
      
      // Open Razorpay checkout
      var options = {
        'key': 'rzp_test_YOUR_KEY_HERE', // TODO: Get from backend or env
        'amount': amount,
        'name': 'EchoFort',
        'description': '${plan.name} Plan Subscription',
        'order_id': orderId,
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {
          'color': '#3A7BFF',
        },
      };
      
      _razorpay.open(options);
      
    } catch (e) {
      print('[PAYMENT] Error: $e');
      
      setState(() {
        _isProcessingPayment = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate payment: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('[PAYMENT] Success: ${response.paymentId}');
    print('[PAYMENT] Order ID: ${response.orderId}');
    print('[PAYMENT] Signature: ${response.signature}');
    
    try {
      // Verify payment on backend
      final verifyResponse = await ApiService.verifyRazorpayPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        plan: _selectedPlanId!,
        isTrial: false,
      );
      
      if (verifyResponse['ok'] == true) {
        print('[PAYMENT] Payment verified successfully');
        
        setState(() {
          _isProcessingPayment = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payment successful! Subscription activated.'),
              backgroundColor: AppTheme.accentSuccess,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      print('[PAYMENT] Verification error: $e');
      
      setState(() {
        _isProcessingPayment = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    print('[PAYMENT] Error: ${response.code} - ${response.message}');
    
    setState(() {
      _isProcessingPayment = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: AppTheme.accentDanger,
        ),
      );
    }
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('[PAYMENT] External wallet: ${response.walletName}');
    
    setState(() {
      _isProcessingPayment = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: AppTheme.accentInfo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isOnboarding
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EchoFortLogo(size: 24, variant: LogoVariant.primary),
            const SizedBox(width: 8),
            Text(
              'EchoFort',
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
          if (widget.isOnboarding)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Choose Your Protection',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Select the plan that best fits your needs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Plan cards with animations
                ...SubscriptionPlans.all.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;
                  
                  return FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: SlideTransition(
                      position: _slideAnimations[index],
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlanCard(plan),
                      ),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Trust indicators
                _buildTrustIndicators(),
              ],
            ),
          ),
          
          // Fixed bottom CTA (gradient button always visible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _selectedPlanId != null
                      ? AppTheme.primaryGradient
                      : null,
                  color: _selectedPlanId == null
                      ? AppTheme.borderLight
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: _selectedPlanId != null
                      ? [
                          BoxShadow(
                            color: AppTheme.primarySolid.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: _selectedPlanId == null ? null : _continueToPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue with Razorpay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: _selectedPlanId != null ? Colors.white : AppTheme.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    
    return GestureDetector(
      onTap: () => _selectPlan(plan.id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border.all(
            color: isSelected ? AppTheme.primarySolid : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primarySolid.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (plan.isPopular)
                  StatusBadge(
                    label: plan.badge,
                    type: BadgeType.success,
                    small: false,
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceDisplayINR,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '/${plan.period}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Features (clean bullet style)
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.accentSuccess.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppTheme.accentSuccess,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustItem(Icons.lock_rounded, 'Secure\nPayment'),
              _buildTrustItem(Icons.cancel_rounded, 'Cancel\nAnytime'),
              _buildTrustItem(Icons.support_agent_rounded, '24/7\nSupport'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'All plans include 7-day money-back guarantee',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
