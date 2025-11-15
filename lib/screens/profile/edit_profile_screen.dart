import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _userEmail = '';
  String _userPhone = '';
  String _avatarUrl = '';
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load from SharedPreferences first (offline support)
      final prefs = await SharedPreferences.getInstance();
      _nameController.text = prefs.getString('user_name') ?? '';
      _bioController.text = prefs.getString('user_bio') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhone = prefs.getString('user_phone') ?? '';
      _avatarUrl = prefs.getString('user_avatar') ?? '';
      
      setState(() {});
      
      // Fetch from backend (sync)
      try {
        final profile = await ApiService.getUserProfile();
        _nameController.text = profile['name'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _userEmail = profile['email'] ?? '';
        _userPhone = profile['phone'] ?? '';
        _avatarUrl = profile['avatar_url'] ?? '';
        
        // Update SharedPreferences
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_bio', _bioController.text);
        await prefs.setString('user_avatar', _avatarUrl);
        
        setState(() {});
      } catch (e) {
        print('[PROFILE] Error fetching profile from backend: $e');
        // Continue with local data
      }
    } catch (e) {
      print('[PROFILE] Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('[PROFILE] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    }
  }
  
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.primarySolid),
              title: Text('Take Photo', style: AppTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primarySolid),
              title: Text('Choose from Gallery', style: AppTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_avatarUrl.isNotEmpty || _selectedImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppTheme.accentDanger),
                title: Text('Remove Photo', style: AppTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _avatarUrl = '';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      String? avatarUrl = _avatarUrl;
      
      // Upload avatar if changed
      if (_selectedImage != null) {
        print('[PROFILE] Uploading avatar...');
        final uploadResult = await ApiService.uploadAvatar(_selectedImage!);
        avatarUrl = uploadResult['avatar_url'];
        print('[PROFILE] Avatar uploaded: $avatarUrl');
      }
      
      // Update profile
      print('[PROFILE] Updating profile...');
      await ApiService.updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: avatarUrl,
      );
      
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_bio', _bioController.text.trim());
      if (avatarUrl != null) {
        await prefs.setString('user_avatar', avatarUrl);
      }
      
      print('[PROFILE] Profile updated successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppTheme.accentSuccess,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print('[PROFILE] Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.accentDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primarySolid),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.primarySolid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primarySolid),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.backgroundSecondary,
                              border: Border.all(
                                color: AppTheme.primarySolid,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : _avatarUrl.isNotEmpty
                                      ? Image.network(
                                          _avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60,
                                              color: AppTheme.textTertiary,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.textTertiary,
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primarySolid,
                                border: Border.all(
                                  color: AppTheme.backgroundPrimary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppTheme.backgroundPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    TextButton(
                      onPressed: _showImageSourceDialog,
                      child: Text(
                        'Change Photo',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primarySolid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primarySolid),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bio Field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: InputDecoration(
                        labelText: 'Bio (Optional)',
                        hintText: 'Tell us about yourself',
                        prefixIcon: Icon(Icons.edit_note, color: AppTheme.primarySolid),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
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
                    
                    const SizedBox(height: 32),
                    
                    // Read-only fields
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyField('Email', _userEmail, Icons.email_outlined),
                          const SizedBox(height: 12),
                          _buildReadOnlyField('Phone', _userPhone, Icons.phone_outlined),
                          const SizedBox(height: 12),
                          Text(
                            'Email and phone cannot be changed for security reasons',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary,
                              fontStyle: FontStyle.italic,
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
  
  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'Not set',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
