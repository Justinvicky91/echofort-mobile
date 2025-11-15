import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive API Service for EchoFort Mobile App
/// Handles all backend API communication with authentication
class ApiService {
  // Base URL - Update based on environment
  static const String baseUrl = 'https://api.echofort.ai';
  
  // Token management
  static String? _authToken;
  static String? _userId;
  
  /// Initialize API service and load saved token
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
  }
  
  /// Save authentication token
  static Future<void> saveToken(String token, String userId) async {
    _authToken = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
  }
  
  /// Clear authentication token (logout)
  static Future<void> clearToken() async {
    _authToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }
  
  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;
  
  /// Get current user ID
  static String? get userId => _userId;
  
  /// Get headers with authentication
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Generic GET request
  static Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Generic POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Generic PUT request
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Generic DELETE request
  static Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized - clear token
      clearToken();
      throw ApiException('Session expired. Please login again.', 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access forbidden', 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found', 404);
    } else if (response.statusCode == 422) {
      // Validation error
      final body = jsonDecode(response.body);
      final message = body['detail'] ?? 'Validation error';
      throw ApiException(message.toString(), 422);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', response.statusCode);
    } else {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? body['detail'] ?? 'Request failed';
      throw ApiException(message.toString(), response.statusCode);
    }
  }
  
  /// Handle errors
  static String _handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }
  
  // ============================================================================
  // AUTHENTICATION APIs
  // ============================================================================
  
  /// Request OTP for login
  static Future<Map<String, dynamic>> requestOTP(String email) async {
    return await post('/auth/otp/request', {'email': email}, requiresAuth: false);
  }
  
  /// Verify OTP and login
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
    required String deviceId,
    String deviceName = 'Mobile Device',
    String name = 'User',
  }) async {
    final response = await post(
      '/auth/otp/verify',
      {
        'email': email,
        'otp': otp,
        'device_id': deviceId,
        'device_name': deviceName,
        'name': name,
      },
      requiresAuth: false,
    );
    
    // Save token
    if (response['token'] != null && response['user_id'] != null) {
      await saveToken(response['token'], response['user_id'].toString());
    }
    
    return response;
  }
  
  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? idType,
    String? idNumber,
  }) async {
    final response = await post(
      '/api/auth/register',
      {
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (pincode != null) 'pincode': pincode,
        if (idType != null) 'id_type': idType,
        if (idNumber != null) 'id_number': idNumber,
      },
      requiresAuth: false,
    );
    
    // Save token
    if (response['token'] != null && response['userId'] != null) {
      await saveToken(response['token'], response['userId'].toString());
    }
    
    return response;
  }
  
  /// Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post(
      '/api/auth/login',
      {'email': email, 'password': password},
      requiresAuth: false,
    );
    
    // Save token
    if (response['token'] != null && response['userId'] != null) {
      await saveToken(response['token'], response['userId'].toString());
    }
    
    return response;
  }
  
  // ============================================================================
  // RAZORPAY PAYMENT APIs
  // ============================================================================
  
  /// Create Razorpay order
  static Future<Map<String, dynamic>> createRazorpayOrder({
    required String plan,
    bool isTrial = true,
  }) async {
    return await post('/api/razorpay/create-order', {
      'plan': plan,
      'is_trial': isTrial,
    });
  }
  
  /// Verify Razorpay payment
  static Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String plan,
    bool isTrial = true,
  }) async {
    return await post('/api/razorpay/verify-payment', {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
      'plan': plan,
      'is_trial': isTrial,
    });
  }
  
  /// Get subscription status
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return await get('/api/razorpay/subscription-status');
  }
  
  /// Cancel subscription
  static Future<Map<String, dynamic>> cancelSubscription() async {
    return await post('/api/razorpay/cancel-subscription', {});
  }
  
  // ============================================================================
  // REFUND APIs
  // ============================================================================
  
  /// Check refund eligibility
  static Future<Map<String, dynamic>> checkRefundEligibility() async {
    return await get('/api/billing/refund/check-eligibility');
  }
  
  /// Request refund
  static Future<Map<String, dynamic>> requestRefund(String reason) async {
    return await post('/api/billing/refund/request', {'reason': reason});
  }
  
  /// Get refund status
  static Future<Map<String, dynamic>> getRefundStatus() async {
    return await get('/api/billing/refund/status');
  }
  
  // ============================================================================
  // CALLER ID APIs
  // ============================================================================
  
  /// Check phone number for scam
  static Future<Map<String, dynamic>> checkCallerID(String phoneNumber) async {
    return await post('/api/mobile/caller-id/check', {'phone_number': phoneNumber});
  }
  
  /// Get recent scam calls
  static Future<List<dynamic>> getRecentScamCalls() async {
    final response = await get('/api/mobile/caller-id/recent');
    return response['calls'] ?? [];
  }
  
  // ============================================================================
  // SMS SCANNER APIs
  // ============================================================================
  
  /// Scan messages for scams
  static Future<Map<String, dynamic>> scanMessages() async {
    return await post('/api/mobile/sms/scan', {});
  }
  
  /// Get scam messages list
  static Future<Map<String, dynamic>> getScamMessages() async {
    return await get('/api/mobile/sms/scam-list');
  }
  
  // ============================================================================
  // URL CHECKER APIs
  // ============================================================================
  
  /// Check URL for phishing
  static Future<Map<String, dynamic>> checkURL(String url) async {
    return await post('/api/mobile/url/check', {'url': url});
  }
  
  // ============================================================================
  // GPS TRACKING APIs
  // ============================================================================
  
  /// Update location
  static Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    return await post('/api/gps/update', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
  
  /// Get family locations
  static Future<List<dynamic>> getFamilyLocations() async {
    final response = await get('/api/gps/family');
    return response['locations'] ?? [];
  }
  
  // ============================================================================
  // SCREEN TIME APIs
  // ============================================================================
  
  /// Get screen time stats
  static Future<Map<String, dynamic>> getScreenTimeStats() async {
    return await get('/api/screentime/stats');
  }
  
  /// Update app usage
  static Future<Map<String, dynamic>> updateAppUsage({
    required String appName,
    required int duration,
  }) async {
    return await post('/api/screentime/update', {
      'app_name': appName,
      'duration': duration,
    });
  }
  
  // ============================================================================
  // FAMILY MEMBERS APIs
  // ============================================================================
  
  /// Get family members list
  static Future<List<dynamic>> getFamilyMembers() async {
    final response = await get('/api/family/members');
    return response['members'] ?? [];
  }
  
  /// Add family member
  static Future<Map<String, dynamic>> addFamilyMember({
    required String name,
    required String email,
    required String relation,
  }) async {
    return await post('/api/family/add', {
      'name': name,
      'email': email,
      'relation': relation,
    });
  }
  
  /// Get family member location
  static Future<Map<String, dynamic>> getFamilyMemberLocation(int userId) async {
    final response = await get('/api/gps/member/$userId/location');
    return response;
  }
  
  /// Save current GPS location
  static Future<Map<String, dynamic>> saveLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    return await post('/api/gps/location', {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    });
  }
  
  /// Get location history
  static Future<List<dynamic>> getLocationHistory({int limit = 100}) async {
    final response = await get('/api/gps/history?limit=$limit');
    return response['locations'] ?? [];
  }
  
  /// Create geofence
  static Future<Map<String, dynamic>> createGeofence({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    return await post('/api/gps/geofence', {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
  }
  
  /// Get geofences
  static Future<List<dynamic>> getGeofences() async {
    final response = await get('/api/gps/geofences');
    return response['geofences'] ?? [];
  }
  
  // ============================================================================
  // USER SETTINGS APIs
  // ============================================================================
  
  /// Get user settings
  static Future<Map<String, dynamic>> getUserSettings() async {
    return await get('/api/user/settings');
  }
  
  /// Update user settings
  static Future<Map<String, dynamic>> updateUserSettings({
    required bool callScreeningEnabled,
    required bool smsProtectionEnabled,
    required bool locationSharingEnabled,
    required bool pushNotificationsEnabled,
    required bool emailNotificationsEnabled,
    required bool biometricAuthEnabled,
  }) async {
    return await put('/api/user/settings', {
      'call_screening_enabled': callScreeningEnabled,
      'sms_protection_enabled': smsProtectionEnabled,
      'location_sharing_enabled': locationSharingEnabled,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'biometric_auth_enabled': biometricAuthEnabled,
    });
  }
  
  // ============================================================================
  // USER PROFILE APIs
  // ============================================================================
  
  /// Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/api/user/profile');
  }
  
  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    String? bio,
    String? avatarUrl,
  }) async {
    return await put('/api/user/profile', {
      'name': name,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }
  
  /// Upload avatar image
  static Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/avatar');
      final request = http.MultipartRequest('POST', uri);
      
      // Add auth header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============================================================================
  // LEGAL & TERMS APIs
  // ============================================================================
  
  /// Accept Terms & Conditions and Privacy Policy
  static Future<Map<String, dynamic>> acceptTerms({
    required String termsVersion,
    required String privacyVersion,
  }) async {
    return await post('/auth/accept-terms', {
      'terms_version': termsVersion,
      'privacy_version': privacyVersion,
      'accepted_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Get Terms & Conditions document
  static Future<Map<String, dynamic>> getTerms({String version = 'latest'}) async {
    return await get('/legal/terms?version=$version', requiresAuth: false);
  }
  
  /// Get Privacy Policy document
  static Future<Map<String, dynamic>> getPrivacy({String version = 'latest'}) async {
    return await get('/legal/privacy?version=$version', requiresAuth: false);
  }
  
  // ============================================================================
  // SCAM REPORTING APIs
  // ============================================================================
  
  /// Report a scam (phone number, URL, or QR code)
  static Future<Map<String, dynamic>> reportScam({
    required String type, // 'phone', 'url', 'qr'
    required String value, // Phone number, URL, or QR content
    String? description,
    String? category, // 'financial', 'phishing', 'impersonation', etc.
  }) async {
    return await post('/api/report/scam', {
      'type': type,
      'value': value,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      'reported_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Get user's scam reports
  static Future<List<dynamic>> getMyReports() async {
    final response = await get('/api/report/my-reports');
    return response['reports'] ?? [];
  }
  
  // ============================================================================
  // EVIDENCE VAULT APIs
  // ============================================================================
  
  /// Get evidence list
  static Future<List<dynamic>> getEvidenceList() async {
    final response = await get('/api/vault/list');
    return response['evidence'] ?? [];
  }
  
  /// Upload evidence
  static Future<Map<String, dynamic>> uploadEvidence({
    required String title,
    required String type,
    required String content,
  }) async {
    return await post('/api/vault/upload', {
      'title': title,
      'type': type,
      'content': content,
    });
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}
