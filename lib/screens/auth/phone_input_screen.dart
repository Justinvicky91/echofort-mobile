import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/echofort_logo.dart';
import '../../widgets/alert_card.dart';
import 'otp_verification_screen.dart';

/// Phone Number Input Screen (§1.3)
/// 
/// Per ChatGPT's CTO-level specification:
/// - Country selector defaults to "India (+91)"
/// - Support future multi-country numbers (not hard-coded +91)
/// - Monospace font for number input
/// - Live validation
/// - "Invalid number" → AlertCard
/// - "Send OTP" button uses gradient + disabled state
/// - Wire directly to /auth/otp/request
/// - Show loading state correctly
/// - Follow spacing + typography from branding doc
class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({Key? key}) : super(key: key);

  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedCountryCode = '+91'; // Default to India
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptedTerms = false;

  // Country codes (expandable for future)
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'country': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
    {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String phone) {
    // Live validation based on country code
    if (_selectedCountryCode == '+91') {
      // India: 10 digits
      return phone.length == 10 && RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone);
    } else if (_selectedCountryCode == '+1') {
      // USA: 10 digits
      return phone.length == 10 && RegExp(r'^[2-9][0-9]{9}$').hasMatch(phone);
    } else if (_selectedCountryCode == '+44') {
      // UK: 10 digits
      return phone.length == 10 && RegExp(r'^[1-9][0-9]{9}$').hasMatch(phone);
    } else {
      // Generic: 7-15 digits
      return phone.length >= 7 && phone.length <= 15;
    }
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    
    // Validation
    if (!_isValidPhoneNumber(phone)) {
      setState(() {
        _errorMessage = 'Invalid phone number for ${_selectedCountryCode}';
      });
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Please accept Terms & Privacy Policy to continue';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Wire directly to /auth/otp/request
      final fullPhone = '$_selectedCountryCode$phone';
      final result = await _authService.requestOTP(
        _emailController.text.trim().isEmpty 
            ? '$phone@echofort.temp' // Temp email if not provided
            : _emailController.text.trim(),
        _usernameController.text.trim().isEmpty 
            ? 'user_$phone' // Auto-generate username
            : _usernameController.text.trim(),
        fullPhone,
        _passwordController.text.trim().isEmpty 
            ? 'temp_pass_$phone' // Temp password
            : _passwordController.text.trim(),
      );

      if (result['success']) {
        if (mounted) {
          // Navigate to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: _emailController.text.trim().isEmpty 
                    ? '$phone@echofort.temp'
                    : _emailController.text.trim(),
                signupData: {
                  'phone': fullPhone,
                  'email': _emailController.text.trim(),
                  'username': _usernameController.text.trim(),
                  'password': _passwordController.text.trim(),
                },
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
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
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Get Started',
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
                'Enter your phone number to receive a verification code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Country code selector + Phone input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code dropdown
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      border: Border.all(color: AppTheme.borderLight, width: 1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                      items: _countryCodes.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            children: [
                              Text(
                                country['flag']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                country['code']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Courier', // Monospace
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value!;
                          _errorMessage = null;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Phone number input
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        border: Border.all(color: AppTheme.borderLight, width: 1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Courier', // Monospace font
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: _selectedCountryCode == '+91' ? '9876543210' : 'Phone number',
                          hintStyle: TextStyle(
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          // Live validation
                          setState(() {
                            if (value.isNotEmpty && !_isValidPhoneNumber(value)) {
                              _errorMessage = 'Invalid phone number';
                            } else {
                              _errorMessage = null;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error alert card
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AlertCard(
                    title: 'Invalid Input',
                    message: _errorMessage,
                    type: AlertType.danger,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                ),
              
              // Terms & Privacy checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primarySolid,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to EchoFort\'s '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppTheme.primarySolid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.primarySolid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Send OTP button (gradient + disabled state)
              Container(
                decoration: BoxDecoration(
                  gradient: _isLoading || !_acceptedTerms || _phoneController.text.isEmpty
                      ? null
                      : AppTheme.primaryGradient,
                  color: _isLoading || !_acceptedTerms || _phoneController.text.isEmpty
                      ? AppTheme.borderLight
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading || !_acceptedTerms || _phoneController.text.isEmpty
                      ? null
                      : _sendOTP,
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
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Helper text
              Text(
                'We\'ll send you a 6-digit verification code via SMS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
