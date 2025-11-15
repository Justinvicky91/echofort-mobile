import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics Service
/// 
/// Wrapper for Firebase Crashlytics to track crashes and errors
class CrashlyticsService {
  static FirebaseCrashlytics? _crashlytics;
  
  /// Initialize Crashlytics
  static Future<void> initialize() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Enable crash collection in release mode
      if (kReleaseMode) {
        await _crashlytics!.setCrashlyticsCollectionEnabled(true);
      }
      
      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = _crashlytics!.recordFlutterError;
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };
      
      print('[CRASHLYTICS] Initialized successfully');
    } catch (e) {
      print('[CRASHLYTICS] Initialization failed: $e');
    }
  }
  
  /// Log a non-fatal error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics?.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
      print('[CRASHLYTICS] Recorded error: $exception');
    } catch (e) {
      print('[CRASHLYTICS] Failed to record error: $e');
    }
  }
  
  /// Log a message
  static Future<void> log(String message) async {
    try {
      await _crashlytics?.log(message);
    } catch (e) {
      print('[CRASHLYTICS] Failed to log message: $e');
    }
  }
  
  /// Set user identifier
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
      print('[CRASHLYTICS] Set user ID: $userId');
    } catch (e) {
      print('[CRASHLYTICS] Failed to set user ID: $e');
    }
  }
  
  /// Set custom key-value pair
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics?.setCustomKey(key, value);
      } else {
        await _crashlytics?.setCustomKey(key, value.toString());
      }
    } catch (e) {
      print('[CRASHLYTICS] Failed to set custom key: $e');
    }
  }
  
  /// Force a test crash (for testing only)
  static void testCrash() {
    if (kDebugMode) {
      print('[CRASHLYTICS] Test crash triggered');
      throw Exception('Test crash from EchoFort');
    }
  }
}
