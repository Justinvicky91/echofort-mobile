import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../utils/country_data.dart';
import '../../services/auth_service.dart';
import '../../services/id_verification_service.dart';
import 'otp_verification_screen.dart';

class AddressIDVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const AddressIDVerificationScreen({
    Key? key,
    required this.signupData,
  }) : super(key: key);

  @override
  _AddressIDVerificationScreenState createState() =>
      _AddressIDVerificationScreenState();
}

class _AddressIDVerificationScreenState
    extends State<AddressIDVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _idNumberController = TextEditingController();

  String _selectedCountry = 'India';
  String? _selectedState;
  String _selectedIDType = 'Aadhaar';
  File? _idPhoto;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _isLoading = false;
  bool _isVerifyingID = false;
  Map<String, dynamic>? _idVerificationResult;
  final IDVerificationService _idVerificationService = IDVerificationService();

  final List<String> _countries = ['India', 'USA', 'UK', 'Canada', 'Australia'];
  final List<String> _idTypes = [
    'Aadhaar',
    'Passport',
    'Driving License',
    'Voter ID',
    'PAN Card'
  ];

  @override
  void initState() {
    super.initState();
    // Set initial state based on country
    final states = CountryData.getStatesForCountry(_selectedCountry);
    if (states.isNotEmpty) {
      _selectedState = states.first;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  Future<void> _pickIDPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _idPhoto = File(image.path);
      });
      _verifyIDAutomatically();
    }
  }

  Future<void> _takeIDPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _idPhoto = File(image.path);
      });
      _verifyIDAutomatically();
    }
  }

  Future<void> _verifyIDAutomatically() async {
    if (_idPhoto == null || _idNumberController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isVerifyingID = true);

    final result = await _idVerificationService.verifyID(
      idType: _selectedIDType,
      idNumber: _idNumberController.text.trim(),
      idPhoto: _idPhoto!,
      country: _selectedCountry,
    );

    setState(() {
      _isVerifyingID = false;
      _idVerificationResult = result;
    });

    if (!mounted) return;

    // Show verification result
    final color = result['verified'] ? Colors.green : Colors.red;
    final icon = result['verified'] ? Icons.check_circle : Icons.error;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(result['message']),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takeIDPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickIDPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your ID photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_termsAccepted || !_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate pincode format
    if (!CountryData.validatePincode(_selectedCountry, _pincodeController.text.trim())) {
      final format = CountryData.getPincodeFormat(_selectedCountry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(format['errorMessage'] as String),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add address and ID data to signup data
    final completeSignupData = {
      ...widget.signupData,
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _selectedState ?? '',
      'country': _selectedCountry,
      'pincode': _pincodeController.text.trim(),
      'idType': _selectedIDType,
      'idNumber': _idNumberController.text.trim(),
      'idPhotoPath': _idPhoto!.path,
    };

    setState(() => _isLoading = true);

    // Request OTP
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.requestOTP(
      widget.signupData['email'],
      widget.signupData['username'],
      widget.signupData['phone'],
      widget.signupData['password'],
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Navigate to OTP verification
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            email: widget.signupData['email'],
            signupData: completeSignupData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: const Text(
          'Step 2 of 3',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address & ID Verification',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Required for account verification and compliance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Address Section
                      const Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _streetController,
                        decoration: InputDecoration(
                          labelText: 'Street Address',
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: 'City',
                                prefixIcon: const Icon(Icons.location_city),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedState,
                              decoration: InputDecoration(
                                labelText: 'State',
                                prefixIcon: const Icon(Icons.map_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: CountryData.getStatesForCountry(_selectedCountry)
                                  .map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedState = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              decoration: InputDecoration(
                                labelText: 'Country',
                                prefixIcon: const Icon(Icons.public),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _countries.map((country) {
                                return DropdownMenuItem(
                                  value: country,
                                  child: Text(country),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountry = value!;
                                  // Update state dropdown when country changes
                                  final states = CountryData.getStatesForCountry(_selectedCountry);
                                  _selectedState = states.isNotEmpty ? states.first : null;
                                  // Clear pincode when country changes
                                  _pincodeController.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final pincodeFormat = CountryData.getPincodeFormat(_selectedCountry);
                                return TextFormField(
                                  controller: _pincodeController,
                                  decoration: InputDecoration(
                                    labelText: pincodeFormat['label'] as String,
                                    hintText: pincodeFormat['placeholder'] as String,
                                    prefixIcon: const Icon(Icons.pin_drop),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: _selectedCountry == 'UK' || _selectedCountry == 'Canada'
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  maxLength: pincodeFormat['maxLength'] as int,
                                  textCapitalization: _selectedCountry == 'UK' || _selectedCountry == 'Canada'
                                      ? TextCapitalization.characters
                                      : TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ID Verification Section
                      const Text(
                        'ID Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedIDType,
                        decoration: InputDecoration(
                          labelText: 'ID Type',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _idTypes.map((idType) {
                          return DropdownMenuItem(
                            value: idType,
                            child: Text(idType),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedIDType = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _idNumberController,
                        decoration: InputDecoration(
                          labelText: 'ID Number',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ID number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ID Photo Upload
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _idPhoto == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Upload ID Photo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to take photo or choose from gallery',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _idPhoto!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _idPhoto = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms and Privacy
                      CheckboxListTile(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _termsAccepted = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: GestureDetector(
                          onTap: () {
                            // Open Terms and Conditions URL
                            _launchURL('https://echofort.ai/terms');
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF2196F3),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      CheckboxListTile(
                        value: _privacyAccepted,
                        onChanged: (value) {
                          setState(() {
                            _privacyAccepted = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: GestureDetector(
                          onTap: () {
                            // Open Privacy Policy URL
                            _launchURL('https://echofort.ai/privacy');
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF2196F3),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
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
                                  'Continue to Verification',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
