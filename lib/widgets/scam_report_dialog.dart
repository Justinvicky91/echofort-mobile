import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Scam Report Dialog
/// 
/// Allows users to report scams (phone numbers, URLs, QR codes)
class ScamReportDialog extends StatefulWidget {
  final String type; // 'phone', 'url', 'qr'
  final String value; // Phone number, URL, or QR content
  
  const ScamReportDialog({
    Key? key,
    required this.type,
    required this.value,
  }) : super(key: key);
  
  @override
  State<ScamReportDialog> createState() => _ScamReportDialogState();
}

class _ScamReportDialogState extends State<ScamReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;
  
  final List<Map<String, String>> _categories = [
    {'value': 'financial', 'label': 'Financial Fraud'},
    {'value': 'phishing', 'label': 'Phishing'},
    {'value': 'impersonation', 'label': 'Impersonation'},
    {'value': 'lottery', 'label': 'Lottery/Prize Scam'},
    {'value': 'job', 'label': 'Job Scam'},
    {'value': 'romance', 'label': 'Romance Scam'},
    {'value': 'tech_support', 'label': 'Tech Support Scam'},
    {'value': 'other', 'label': 'Other'},
  ];
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  String get _typeLabel {
    switch (widget.type) {
      case 'phone':
        return 'Phone Number';
      case 'url':
        return 'URL/Link';
      case 'qr':
        return 'QR Code';
      default:
        return 'Item';
    }
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: AppTheme.accentWarning,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await ApiService.reportScam(
        type: widget.type,
        value: widget.value,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you! Your report has been submitted.'),
            backgroundColor: AppTheme.accentSuccess,
          ),
        );
      }
    } catch (e) {
      print('[SCAM_REPORT] Error: $e');
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.report_outlined,
                      color: AppTheme.accentDanger,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report Scam',
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.textTertiary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Reported Item
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundPrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.value,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Category Dropdown
                Text(
                  'Category',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select scam type',
                    filled: true,
                    fillColor: AppTheme.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primarySolid, width: 2),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category['value'],
                      child: Text(category['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Description
                Text(
                  'Description (Optional)',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Describe what happened...',
                    filled: true,
                    fillColor: AppTheme.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primarySolid, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentDanger,
                      disabledBackgroundColor: AppTheme.textTertiary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
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
                            'Submit Report',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.backgroundPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Info Text
                Text(
                  'Your report will be reviewed by our team within 24 hours. Thank you for helping keep EchoFort safe.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Show scam report dialog
  static Future<bool?> show(
    BuildContext context, {
    required String type,
    required String value,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ScamReportDialog(
        type: type,
        value: value,
      ),
    );
  }
}
