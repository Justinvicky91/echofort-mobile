import 'package:flutter/material.dart';
import 'signup_screen.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String _selectedPlan = 'monthly'; // monthly, quarterly, yearly

  final Map<String, Map<String, dynamic>> _plans = {
    'monthly': {
      'name': 'Monthly Plan',
      'price': 499,
      'duration': '1 Month',
      'savings': null,
    },
    'quarterly': {
      'name': 'Quarterly Plan',
      'price': 1299,
      'duration': '3 Months',
      'savings': '13% OFF',
    },
    'yearly': {
      'name': 'Yearly Plan',
      'price': 4999,
      'duration': '12 Months',
      'savings': '17% OFF',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/echofort_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start with ₹1 auto-debit verification',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Plans
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Monthly Plan
                      _buildPlanCard('monthly'),
                      const SizedBox(height: 16),

                      // Quarterly Plan (Recommended)
                      _buildPlanCard('quarterly', recommended: true),
                      const SizedBox(height: 16),

                      // Yearly Plan
                      _buildPlanCard('yearly'),
                      const SizedBox(height: 32),

                      // Features List
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Plans Include:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeature('📍 Real-time GPS Tracking'),
                            _buildFeature('📱 Screen Time Monitoring'),
                            _buildFeature('🚫 App Blocking & Whitelisting'),
                            _buildFeature('🎤 Voice Call Transcription'),
                            _buildFeature('🔔 Instant Scam Alerts'),
                            _buildFeature('💰 24-Hour Money-Back Guarantee'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(
                                  selectedPlan: _selectedPlan,
                                  planPrice: _plans[_selectedPlan]!['price'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Continue to Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Text
                      Text(
                        'You\'ll be charged ₹1 now for verification.\nFull amount will be charged after 24 hours.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildPlanCard(String planKey, {bool recommended = false}) {
    final plan = _plans[planKey]!;
    final isSelected = _selectedPlan == planKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),

                // Plan name
                Expanded(
                  child: Text(
                    plan['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                // Recommended badge
                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                Text(
                  '${plan['price']}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '/ ${plan['duration']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            // Savings badge
            if (plan['savings'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Save ${plan['savings']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
