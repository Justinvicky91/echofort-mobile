import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

/// Onboarding Screen with swipeable pages
/// Shows key features before login
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'AI Call Screening',
      description:
          'Get real-time Trust Factor (0-10) for every call. Block scammers automatically.',
      icon: Icons.phone_in_talk_rounded,
      color: AppTheme.primaryBlue,
    ),
    OnboardingPage(
      title: 'WhatsApp & SMS Protection',
      description:
          'Scan messages before opening. Detect phishing links and scam messages instantly.',
      icon: Icons.message_rounded,
      color: AppTheme.primaryPurple,
    ),
    OnboardingPage(
      title: 'Family GPS Tracking',
      description:
          'Track your family in real-time. Get alerts for arrivals, departures, and emergencies.',
      icon: Icons.location_on_rounded,
      color: AppTheme.success,
    ),
    OnboardingPage(
      title: 'Screen Time Monitoring',
      description:
          'Monitor app usage and set limits. Keep your family safe from digital addiction.',
      icon: Icons.timer_rounded,
      color: AppTheme.warning,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: const Text('Skip'),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXL),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _navigateToLogin();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXXL),
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXXS),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryBlue
            : AppTheme.dividerLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
