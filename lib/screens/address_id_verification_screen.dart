import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'pricing_screen.dart';
import '../theme/app_theme.dart';
import '../services/verification_service.dart';

/// Address & ID Verification Screen
/// Final step before dashboard access
class AddressIDVerificationScreen extends StatefulWidget {
  final PricingPlan selectedPlan;

  const AddressIDVerificationScreen({
    Key? key,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  State<AddressIDVerificationScreen> createState() =>
      _AddressIDVerificationScreenState();
}

class _AddressIDVerificationScreenState
    extends State<AddressIDVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _idNumberController = TextEditingController();
  String _selectedIDType = 'Aadhaar';
  bool _isLoading = false;
  final _verificationService = VerificationService();

  final List<String> _idTypes = [
    'Aadhaar',
    'PAN Card',
    'Voter ID',
    'Driving License',
    'Passport',
  ];

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call verification API
      final response = await _verificationService.completeVerification(
        userId: 1, // TODO: Get from auth state
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        idType: _selectedIDType,
        idNumber: _idNumberController.text,
      );

      setState(() => _isLoading = false);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Verification completed!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                _buildProgressIndicator(3, 3),
                const SizedBox(height: AppTheme.spaceXL),
                // Step title
                Text(
                  'Step 3: Verification',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  'Complete your profile to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXL),
                // Address section
                _buildSectionHeader('Address Details', Icons.home_rounded),
                const SizedBox(height: AppTheme.spaceMD),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                    hintText: 'House/Flat No., Building Name',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address line 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceMD),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 2',
                    hintText: 'Street, Area, Landmark',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address line 2';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceMD),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          hintText: 'Enter city',
                          prefixIcon: Icon(Icons.location_city_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          hintText: 'Enter state',
                          prefixIcon: Icon(Icons.map_rounded),
                        ),
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
                const SizedBox(height: AppTheme.spaceMD),
                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Pincode',
                    hintText: 'Enter 6-digit pincode',
                    prefixIcon: Icon(Icons.pin_drop_rounded),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceXXL),
                // ID section
                _buildSectionHeader('ID Verification', Icons.badge_rounded),
                const SizedBox(height: AppTheme.spaceMD),
                DropdownButtonFormField<String>(
                  value: _selectedIDType,
                  decoration: const InputDecoration(
                    labelText: 'ID Type',
                    prefixIcon: Icon(Icons.credit_card_rounded),
                  ),
                  items: _idTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedIDType = value!);
                  },
                ),
                const SizedBox(height: AppTheme.spaceMD),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    labelText: '$_selectedIDType Number',
                    hintText: 'Enter $_selectedIDType number',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ID number';
                    }
                    // Basic validation for Aadhaar
                    if (_selectedIDType == 'Aadhaar' && value.length != 12) {
                      return 'Aadhaar must be 12 digits';
                    }
                    // Basic validation for PAN
                    if (_selectedIDType == 'PAN Card' && value.length != 10) {
                      return 'PAN must be 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceMD),
                // Upload ID button
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID upload feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Upload ID Photo (Optional)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXL),
                // Info card
                Card(
                  color: AppTheme.info.withOpacity(0.1),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: AppTheme.info,
                          size: 24,
                        ),
                        const SizedBox(width: AppTheme.spaceMD),
                        Expanded(
                          child: Text(
                            'Your information is encrypted and secure. We use it only for verification purposes.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.info,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXL),
                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Complete Setup'),
                ),
              ],
            ),
          ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceXS),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
