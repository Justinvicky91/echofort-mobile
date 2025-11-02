import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'api_service.dart';

class ActivityLogger {
  final ApiService _apiService = ApiService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> logActivity(String activityType, String description) async {
    try {
      final deviceData = await _getDeviceInfo();
      
      final activityData = {
        'activity_type': activityType,
        'activity_description': description,
        'device_type': deviceData['device_type'],
        'user_agent': deviceData['user_agent'],
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'app_version': '1.0.0', // TODO: Get from package_info
      };

      await _apiService.post('/api/mobile/profile/log-activity', activityData);
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'device_type': '${androidInfo.manufacturer} ${androidInfo.model}',
        'user_agent': 'Android ${androidInfo.version.release}',
        'os_version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'device_type': '${iosInfo.name} ${iosInfo.model}',
        'user_agent': 'iOS ${iosInfo.systemVersion}',
        'os_version': iosInfo.systemVersion,
      };
    }
    
    return {
      'device_type': 'Unknown',
      'user_agent': 'Unknown',
      'os_version': 'Unknown',
    };
  }

  // Common activity types
  Future<void> logLogin() => logActivity('login', 'User logged in');
  Future<void> logLogout() => logActivity('logout', 'User logged out');
  Future<void> logProfileUpdate() => logActivity('profile_update', 'User updated profile');
  Future<void> logSettingsChange(String setting) => logActivity('settings_change', 'Changed setting: $setting');
  Future<void> logFeatureUsed(String feature) => logActivity('feature_used', 'Used feature: $feature');
  Future<void> logSubscriptionChange(String plan) => logActivity('subscription_change', 'Changed subscription to: $plan');
  Future<void> logPayment(double amount) => logActivity('payment', 'Payment of ₹$amount');
}
