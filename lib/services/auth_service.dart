import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  // Register
  Future<bool> register(String username, String email, String password, String phone) async {
    try {
      final response = await _apiService.register(username, email, password, phone);
      return response['ok'] == true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
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
