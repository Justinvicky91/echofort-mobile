import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://api.echofort.ai';
  final storage = const FlutterSecureStorage();
  
  // Get auth token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  // Save auth token
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }
  
  // Clear auth token
  Future<void> clearToken() async {
    await storage.delete(key: 'auth_token');
  }
  
  // Get headers with auth token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final headers = await getHeaders();
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'API error: ${response.statusCode}');
    }
  }
  
  // Authentication APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await post('/api/auth/login', {
      'username': username,
      'password': password,
    });
  }
  
  Future<Map<String, dynamic>> register(String username, String email, String password, String phone) async {
    return await post('/api/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
    });
  }
  
  Future<Map<String, dynamic>> verify2FA(int userId, String code) async {
    return await post('/api/auth/verify-2fa', {
      'userId': userId,
      'code': code,
    });
  }
  
  // OTP Authentication APIs
  Future<Map<String, dynamic>> requestOTP(String email, String username, String phone, String password) async {
    return await post('/auth/otp/request', {
      'email': email,
      'username': username,
      'phone': phone,
      'password': password,
    });
  }
  
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    return await post('/auth/otp/verify', {
      'email': email,
      'otp': otp,
    });
  }
  
  // GPS Tracking APIs
  Future<Map<String, dynamic>> saveLocation(double latitude, double longitude, double accuracy) async {
    return await post('/gps/location', {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    });
  }
  
  Future<Map<String, dynamic>> getLocationHistory({int limit = 100}) async {
    return await get('/gps/history', queryParams: {'limit': limit.toString()});
  }
  
  Future<Map<String, dynamic>> createGeofence(String name, double latitude, double longitude, int radius) async {
    return await post('/gps/geofence', {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
  }
  
  // Family APIs
  Future<Map<String, dynamic>> createFamily(String familyName) async {
    return await post('/family/create', {
      'family_name': familyName,
    });
  }
  
  Future<Map<String, dynamic>> addFamilyMember(String memberPhone, String memberName, String role) async {
    return await post('/family/add-member', {
      'member_phone': memberPhone,
      'member_name': memberName,
      'role': role,
    });
  }
  
  Future<Map<String, dynamic>> getFamilyMembers() async {
    return await get('/family/members');
  }
  
  Future<Map<String, dynamic>> getFamilyMemberLocation(int memberId) async {
    return await get('/family/member-location/$memberId');
  }
  
  // Screen Time APIs
  Future<Map<String, dynamic>> logScreenTime(String appName, String category, int durationSeconds, String date) async {
    return await post('/screentime/log', {
      'app_name': appName,
      'category': category,
      'duration_seconds': durationSeconds,
      'date': date,
    });
  }
  
  Future<Map<String, dynamic>> getDailyScreenTime({String? date}) async {
    return await get('/screentime/daily', queryParams: date != null ? {'date': date} : null);
  }
  
  Future<Map<String, dynamic>> getWeeklyScreenTime() async {
    return await get('/screentime/weekly');
  }
  
  Future<Map<String, dynamic>> setScreenTimeLimit(String category, int limitMinutes) async {
    return await post('/screentime/set-limit', {
      'category': category,
      'limit_minutes': limitMinutes,
    });
  }
  
  Future<Map<String, dynamic>> getScreenTimeLimits() async {
    return await get('/screentime/limits');
  }
  
  // Subscription APIs
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return await get('/subscription/status');
  }
  
  Future<Map<String, dynamic>> upgradeSubscription(String plan, String razorpayPaymentId) async {
    return await post('/subscription/upgrade', {
      'plan': plan,
      'razorpay_payment_id': razorpayPaymentId,
    });
  }
  
  Future<Map<String, dynamic>> cancelSubscription() async {
    return await post('/subscription/cancel', {});
  }
  
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    return await get('/subscription/plans');
  }
  
  Future<Map<String, dynamic>> requestRefund(String reason) async {
    return await post('/refund/request', {
      'reason': reason,
    });
  }
  
  // Caller ID APIs
  Future<Map<String, dynamic>> lookupNumber(String phoneNumber) async {
    return await post('/api/mobile/caller-id/lookup', {
      'phoneNumber': phoneNumber,
    });
  }
  
  Future<Map<String, dynamic>> reportSpam(String phoneNumber, String category, String description) async {
    return await post('/api/mobile/caller-id/report-spam', {
      'phoneNumber': phoneNumber,
      'category': category,
      'description': description,
    });
  }
  
  Future<Map<String, dynamic>> blockNumber(String phoneNumber, String reason) async {
    return await post('/api/mobile/caller-id/block-number', {
      'phoneNumber': phoneNumber,
      'reason': reason,
    });
  }
  
  Future<Map<String, dynamic>> getBlockedNumbers() async {
    return await get('/api/mobile/caller-id/blocked-numbers');
  }
  
  Future<Map<String, dynamic>> getCallerIdStats() async {
    return await get('/api/mobile/caller-id/statistics');
  }
  
  // SMS Detection APIs
  Future<Map<String, dynamic>> scanSMS(String sender, String message, String language) async {
    return await post('/api/mobile/sms/scan', {
      'sender': sender,
      'message': message,
      'language': language,
    });
  }
  
  Future<Map<String, dynamic>> getSMSThreats({int limit = 20}) async {
    return await get('/api/mobile/sms/threats', queryParams: {'limit': limit.toString()});
  }
  
  // URL Checker APIs
  Future<Map<String, dynamic>> checkURL(String url) async {
    return await post('/api/mobile/url-checker/check-url', {
      'url': url,
    });
  }
  
  Future<Map<String, dynamic>> checkEmail(String email) async {
    return await post('/api/mobile/url-checker/check-email', {
      'email': email,
    });
  }
  
  // User Profile APIs
  Future<Map<String, dynamic>> getProfile() async {
    return await get('/api/mobile/profile');
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await put('/api/mobile/profile', data);
  }
  
  Future<Map<String, dynamic>> getAppPreferences() async {
    return await get('/api/mobile/profile/app-preferences');
  }
  
  Future<Map<String, dynamic>> updateAppPreferences(Map<String, dynamic> preferences) async {
    return await put('/api/mobile/profile/app-preferences', preferences);
  }
  
  // Emergency APIs
  Future<Map<String, dynamic>> getEmergencyContacts() async {
    return await get('/api/mobile/emergency/contacts');
  }
  
  Future<Map<String, dynamic>> addEmergencyContact(Map<String, dynamic> contact) async {
    return await post('/api/mobile/emergency/contacts', contact);
  }
  
  Future<Map<String, dynamic>> triggerSOS(Map<String, dynamic> alertData) async {
    return await post('/api/mobile/emergency/alert', alertData);
  }
  
  // Push Notifications APIs
  Future<Map<String, dynamic>> registerDeviceToken(String deviceToken, String platform) async {
    return await post('/api/mobile/notifications/register-token', {
      'deviceToken': deviceToken,
      'platform': platform,
      'deviceModel': 'Unknown',
      'osVersion': 'Unknown',
      'appVersion': '1.0.0',
    });
  }
  
  Future<Map<String, dynamic>> getNotificationHistory({int limit = 50}) async {
    return await get('/api/mobile/notifications/history', queryParams: {'limit': limit.toString()});
  }
  
  // Real-Time Call APIs
  Future<Map<String, dynamic>> startCallSession(String phoneNumber, String callerName, String callDirection) async {
    return await post('/api/mobile/realtime-call/start', {
      'phoneNumber': phoneNumber,
      'callerName': callerName,
      'callDirection': callDirection,
    });
  }
  
  Future<Map<String, dynamic>> addTranscription(int sessionId, String speaker, String text, String language) async {
    return await post('/api/mobile/realtime-call/transcription', {
      'sessionId': sessionId,
      'speaker': speaker,
      'text': text,
      'language': language,
    });
  }
  
  Future<Map<String, dynamic>> endCallSession(int sessionId, int callDurationSeconds) async {
    return await post('/api/mobile/realtime-call/end', {
      'sessionId': sessionId,
      'callDurationSeconds': callDurationSeconds,
    });
  }
}
