import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Kill Switch Service
/// 
/// Allows remote control of features for legal/regulatory compliance
/// Backend can disable features immediately without app update
class KillSwitchService {
  // Feature flags (default values)
  static const Map<String, bool> DEFAULT_FLAGS = {
    'call_recording_enabled': true,
    'gps_tracking_enabled': true,
    'scam_detection_enabled': true,
    'legal_assistance_enabled': true,
    'evidence_vault_enabled': true,
    'qr_scanning_enabled': true,
    'ai_chat_enabled': true,
    'family_sharing_enabled': true,
    'sms_protection_enabled': true,
    'payment_enabled': true,
  };
  
  // Cache duration (5 minutes)
  static const int CACHE_DURATION_SECONDS = 300;
  
  static Map<String, bool> _cachedFlags = {};
  static DateTime? _lastFetchTime;
  
  /// Fetch feature flags from backend
  static Future<Map<String, bool>> fetchFlags() async {
    try {
      print('[KILL_SWITCH] Fetching feature flags from backend...');
      
      final response = await ApiService.get('/api/features', requiresAuth: false);
      
      if (response is Map<String, dynamic>) {
        // Convert dynamic map to Map<String, bool>
        final flags = <String, bool>{};
        response.forEach((key, value) {
          if (value is bool) {
            flags[key] = value;
          }
        });
        
        // Cache flags
        _cachedFlags = flags;
        _lastFetchTime = DateTime.now();
        
        // Save to SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('feature_flags', jsonEncode(flags));
        await prefs.setString('feature_flags_timestamp', DateTime.now().toIso8601String());
        
        print('[KILL_SWITCH] Fetched ${flags.length} feature flags');
        return flags;
      }
      
      return DEFAULT_FLAGS;
    } catch (e) {
      print('[KILL_SWITCH] Error fetching flags: $e');
      
      // Load from cache if available
      final cachedFlags = await _loadCachedFlags();
      if (cachedFlags.isNotEmpty) {
        print('[KILL_SWITCH] Using cached flags');
        return cachedFlags;
      }
      
      // Fallback to defaults
      print('[KILL_SWITCH] Using default flags');
      return DEFAULT_FLAGS;
    }
  }
  
  /// Load cached flags from SharedPreferences
  static Future<Map<String, bool>> _loadCachedFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flagsJson = prefs.getString('feature_flags');
      
      if (flagsJson != null) {
        final decoded = jsonDecode(flagsJson) as Map<String, dynamic>;
        final flags = <String, bool>{};
        decoded.forEach((key, value) {
          if (value is bool) {
            flags[key] = value;
          }
        });
        return flags;
      }
    } catch (e) {
      print('[KILL_SWITCH] Error loading cached flags: $e');
    }
    
    return {};
  }
  
  /// Check if a feature is enabled
  static Future<bool> isFeatureEnabled(String featureKey) async {
    // Check if cache is fresh
    if (_cachedFlags.isNotEmpty && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!).inSeconds;
      if (age < CACHE_DURATION_SECONDS) {
        return _cachedFlags[featureKey] ?? DEFAULT_FLAGS[featureKey] ?? true;
      }
    }
    
    // Fetch fresh flags
    final flags = await fetchFlags();
    return flags[featureKey] ?? DEFAULT_FLAGS[featureKey] ?? true;
  }
  
  /// Get all feature flags
  static Future<Map<String, bool>> getAllFlags() async {
    // Check if cache is fresh
    if (_cachedFlags.isNotEmpty && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!).inSeconds;
      if (age < CACHE_DURATION_SECONDS) {
        return _cachedFlags;
      }
    }
    
    // Fetch fresh flags
    return await fetchFlags();
  }
  
  /// Force refresh flags (bypass cache)
  static Future<Map<String, bool>> refreshFlags() async {
    _cachedFlags = {};
    _lastFetchTime = null;
    return await fetchFlags();
  }
  
  /// Get disabled message for a feature
  static String getDisabledMessage(String featureKey) {
    switch (featureKey) {
      case 'call_recording_enabled':
        return 'Call recording is temporarily unavailable. Please try again later.';
      case 'gps_tracking_enabled':
        return 'GPS tracking is temporarily unavailable. Please try again later.';
      case 'scam_detection_enabled':
        return 'Scam detection is temporarily unavailable. Please try again later.';
      case 'legal_assistance_enabled':
        return 'Legal assistance is temporarily unavailable. Please try again later.';
      case 'evidence_vault_enabled':
        return 'Evidence vault is temporarily unavailable. Please try again later.';
      case 'qr_scanning_enabled':
        return 'QR scanning is temporarily unavailable. Please try again later.';
      case 'ai_chat_enabled':
        return 'AI chat is temporarily unavailable. Please try again later.';
      case 'family_sharing_enabled':
        return 'Family sharing is temporarily unavailable. Please try again later.';
      case 'sms_protection_enabled':
        return 'SMS protection is temporarily unavailable. Please try again later.';
      case 'payment_enabled':
        return 'Payments are temporarily unavailable. Please try again later.';
      default:
        return 'This feature is temporarily unavailable. Please try again later.';
    }
  }
  
  /// Initialize kill switch (fetch flags on app start)
  static Future<void> initialize() async {
    print('[KILL_SWITCH] Initializing...');
    await fetchFlags();
  }
}
