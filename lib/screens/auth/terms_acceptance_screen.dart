import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../subscription/paywall_screen.dart';

class TermsAcceptanceScreen extends StatefulWidget {
  const TermsAcceptanceScreen({Key? key}) : super(key: key);

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _termsAccepted = false;
  bool _isLoading = false;

  Future<void> _openTerms() async {
    final url = Uri.parse('https://echofort.ai/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open Terms & Conditions'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }

  Future<void> _openPrivacy() async {
    final url = Uri.parse('https://echofort.ai/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open Privacy Policy'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }

  Future<void> _acceptTerms() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms & Conditions and Privacy Policy'),
          backgroundColor: AppTheme.accentWarning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('[TERMS] Accepting terms...');
      await ApiService.acceptTerms(
        termsVersion: 'v1.0',
        privacyVersion: 'v1.0',
      );
      
      print('[TERMS] Terms accepted successfully');
      
      if (mounted) {
        // Navigate to Paywall screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaywallScreen()),
        );
      }
    } catch (e) {
      print('[TERMS] Error accepting terms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept terms: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Terms & Privacy',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'To use EchoFort, you must agree to our Terms & Conditions and Privacy Policy.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Legal Documents Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Terms Link
                    InkWell(
                      onTap: _openTerms,
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_rounded,
                            color: AppTheme.primarySolid,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Terms & Conditions',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version 1.0',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: AppTheme.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Divider(color: AppTheme.borderColor, height: 1),
                    
                    const SizedBox(height: 20),
                    
                    // Privacy Link
                    InkWell(
                      onTap: _openPrivacy,
                      child: Row(
                        children: [
                          Icon(
                            Icons.privacy_tip_rounded,
                            color: AppTheme.primarySolid,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Privacy Policy',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version 1.0',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: AppTheme.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _termsAccepted ? AppTheme.primarySolid : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primarySolid,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text: 'I have read and agree to the ',
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: AppTheme.primarySolid,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _openTerms,
                            ),
                            const TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.primarySolid,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _openPrivacy,
                            ),
                            const TextSpan(
                              text: '.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Accept Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _termsAccepted && !_isLoading ? _acceptTerms : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primarySolid,
                    disabledBackgroundColor: AppTheme.textTertiary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.backgroundPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Accept & Continue',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.backgroundPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Text
              Center(
                child: Text(
                  'By continuing, you confirm that you are 18+ years old',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
