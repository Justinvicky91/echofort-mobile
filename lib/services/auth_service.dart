import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  int? _userId;
  String? _userEmail;
  String? _userName;
  
  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  
  // Initialize auth state from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _userId = prefs.getInt('user_id');
    _userEmail = prefs.getString('user_email');
    _userName = prefs.getString('user_name');
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      
      if (response['ok'] == true) {
        final token = response['token'];
        _userId = response['userId'];
        _userEmail = response['email'];
        _userName = response['username'];
        
        await _apiService.saveToken(token);
        await _saveUserData();
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }
  
  // Register (OLD - Direct registration without OTP)
  Future<bool> register(String username, String email, String password, String phone) async {
    try {
      final response = await _apiService.register(username, email, password, phone);
      return response['ok'] == true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }
  
  // Request OTP (NEW - Step 1 of signup) - Using Make.com webhook
  Future<Map<String, dynamic>> requestOTP(String email, String username, String phone, String password) async {
    try {
      // Generate 6-digit OTP
      final otp = (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor().toString();
      
      // Send OTP via Make.com webhook
      final response = await http.post(
        Uri.parse('https://hook.eu2.make.com/wkm53kk3yjnw10jpqeudvbpapao0y1yd'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'username': username,
        }),
      );

      debugPrint('Make.com webhook response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        // Store OTP and user data temporarily for verification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_otp', otp);
        await prefs.setString('pending_email', email);
        await prefs.setString('pending_username', username);
        await prefs.setString('pending_phone', phone);
        await prefs.setString('pending_password', password);
        await prefs.setInt('otp_timestamp', DateTime.now().millisecondsSinceEpoch);
        
        debugPrint('OTP stored: $otp for email: $email');
        
        return {
          'success': true,
          'message': 'OTP sent to $email. Please check your inbox.',
          'email_sent': true,
        };
      } else {
        debugPrint('Make.com webhook failed: ${response.statusCode}');
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Request OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
      };
    }
  }
  
  // Verify OTP (NEW - Step 2 of signup)
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedOtp = prefs.getString('pending_otp');
      final storedEmail = prefs.getString('pending_email');
      final otpTimestamp = prefs.getInt('otp_timestamp') ?? 0;
      
      // Check if OTP is expired (5 minutes)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - otpTimestamp > 5 * 60 * 1000) {
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }
      
      // Verify OTP matches
      if (storedOtp == otp && storedEmail == email) {
        // Get stored user data
        final username = prefs.getString('pending_username') ?? '';
        final phone = prefs.getString('pending_phone') ?? '';
        final password = prefs.getString('pending_password') ?? '';
        
        // Create account via backend
        final response = await _apiService.register(username, email, password, phone);
        
        // Clear pending data
        await prefs.remove('pending_otp');
        await prefs.remove('pending_email');
        await prefs.remove('pending_username');
        await prefs.remove('pending_phone');
        await prefs.remove('pending_password');
        await prefs.remove('otp_timestamp');
        
        return {
          'success': response['ok'] == true,
          'message': response['message'] ?? 'Account created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid OTP code. Please try again.',
        };
      }
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return {
        'success': false,
        'message': 'Invalid OTP code. Please try again.',
      };
    }
  }
  
  // Verify 2FA
  Future<bool> verify2FA(int userId, String code) async {
    try {
      final response = await _apiService.verify2FA(userId, code);
      
      if (response['ok'] == true) {
        final token = response['token'];
        await _apiService.saveToken(token);
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('2FA verification error: $e');
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _apiService.clearToken();
    await _clearUserData();
    
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
  
  // Save user data to local storage
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    if (_userId != null) await prefs.setInt('user_id', _userId!);
    if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
    if (_userName != null) await prefs.setString('user_name', _userName!);
  }
  
  // Clear user data from local storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_authenticated');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }
}
