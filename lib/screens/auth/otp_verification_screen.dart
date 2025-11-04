import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> signupData;

  const OTPVerificationScreen({
    Key? key,
    required this.email,
    required this.signupData,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getOTPCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTPCode();
    
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.verifyOTP(widget.email, otp);
      
      if (result['success']) {
        // OTP verified successfully, account created
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to login
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Invalid OTP code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.requestOTP(
        widget.signupData['email'],
        widget.signupData['username'],
        widget.signupData['phone'],
        widget.signupData['password'],
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to resend OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Widget _buildOTPInput(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppColors.primary
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          // Auto-verify when all 6 digits are entered
          if (index == 5 && value.isNotEmpty) {
            _verifyOTP();
          }
          
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOTPInput(index)),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify & Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resendOTP,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The code expires in 5 minutes. Check your spam folder if you don\'t see it.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
