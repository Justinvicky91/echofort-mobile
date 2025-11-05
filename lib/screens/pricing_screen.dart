import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import '../theme/app_theme.dart';

/// Pricing Screen with card-based plans
/// Shows 3 subscription tiers matching website pricing
class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _selectedPlanIndex = 1; // Default to Personal plan
  bool _isYearly = false;

  final List<PricingPlan> _plans = [
    PricingPlan(
      name: 'Basic',
      monthlyPrice: 399,
      yearlyPrice: 3830,
      features: [
        'AI Call Screening',
        'Trust Factor (0-10)',
        'Scam Database (125K+)',
        'Basic Protection',
        '1 Device',
      ],
      color: AppTheme.primaryBlue,
      icon: Icons.shield_rounded,
    ),
    PricingPlan(
      name: 'Personal',
      monthlyPrice: 799,
      yearlyPrice: 7670,
      features: [
        'Everything in Basic',
        'Call Recording',
        'Image Scanning',
        'WhatsApp/SMS Protection',
        'Evidence Vault',
        '1 Device',
      ],
      color: AppTheme.primaryPurple,
      icon: Icons.person_rounded,
      isBestValue: true,
    ),
    PricingPlan(
      name: 'Family',
      monthlyPrice: 1499,
      yearlyPrice: 14390,
      features: [
        'Everything in Personal',
        'GPS Tracking',
        'Child Protection',
        'Screen Time Monitoring',
        'Family Dashboard',
        '4 Devices',
      ],
      color: AppTheme.success,
      icon: Icons.family_restroom_rounded,
    ),
  ];

  void _handleSelectPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          phoneNumber: '+91 9876543210', // From signup
          selectedPlan: _plans[_selectedPlanIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceXL),
              child: _buildProgressIndicator(2, 3),
            ),
            // Billing toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                padding: const EdgeInsets.all(AppTheme.spaceXXS),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBillingToggle('Monthly', !_isYearly),
                    ),
                    Expanded(
                      child: _buildBillingToggle('Yearly (Save 20%)', _isYearly),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            // Free trial badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
              ),
              child: const Text(
                '🎉 Try Free for 24 Hours - Full Refund Available',
                style: TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            // Plans list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(_plans[index], index);
                },
              ),
            ),
            // Select button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceXL),
              child: ElevatedButton(
                onPressed: _handleSelectPlan,
                child: Text(
                  'Continue with ${_plans[_selectedPlanIndex].name}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep, int totalSteps) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? AppTheme.spaceXS : 0,
            ),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppTheme.primaryBlue
                  : AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _isYearly = label.contains('Yearly'));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.textSecondaryLight,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(PricingPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final period = _isYearly ? 'year' : 'month';

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(
            color: isSelected ? plan.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceSM),
                    decoration: BoxDecoration(
                      color: plan.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(plan.icon, color: plan.color, size: 24),
                  ),
                  const SizedBox(width: AppTheme.spaceMD),
                  // Plan name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (plan.isBestValue) ...[
                              const SizedBox(width: AppTheme.spaceXS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceXS,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: const Text(
                                  'BEST VALUE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹$price/$period',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: plan.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Radio button
                  Radio<int>(
                    value: index,
                    groupValue: _selectedPlanIndex,
                    onChanged: (value) {
                      setState(() => _selectedPlanIndex = value!);
                    },
                    activeColor: plan.color,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMD),
              const Divider(),
              const SizedBox(height: AppTheme.spaceSM),
              // Features
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceXS),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: plan.color,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spaceXS),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingPlan {
  final String name;
  final int monthlyPrice;
  final int yearlyPrice;
  final List<String> features;
  final Color color;
  final IconData icon;
  final bool isBestValue;

  PricingPlan({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.color,
    required this.icon,
    this.isBestValue = false,
  });
}
