import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class PermissionsService {
  final ApiService _apiService = ApiService();

  Future<void> requestAllPermissions() async {
    // Request all necessary permissions
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.sms,
      Permission.phone,
      Permission.storage,
      Permission.notification,
      Permission.contacts,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Track permissions in backend
    await trackPermissions(statuses);
  }

  Future<void> trackPermissions(Map<Permission, PermissionStatus> statuses) async {
    final permissionData = {
      'camera_permission': _getPermissionStatus(statuses[Permission.camera]),
      'microphone_permission': _getPermissionStatus(statuses[Permission.microphone]),
      'location_permission': _getPermissionStatus(statuses[Permission.location]),
      'sms_permission': _getPermissionStatus(statuses[Permission.sms]),
      'contacts_permission': _getPermissionStatus(statuses[Permission.contacts]),
      'phone_permission': _getPermissionStatus(statuses[Permission.phone]),
      'storage_permission': _getPermissionStatus(statuses[Permission.storage]),
      'notification_permission': _getPermissionStatus(statuses[Permission.notification]),
      'location_accuracy': 'high',
      'location_background': statuses[Permission.locationAlways]?.isGranted ?? false,
    };

    try {
      await _apiService.post('/api/mobile/profile/update-permissions', permissionData);
    } catch (e) {
      print('Error tracking permissions: $e');
    }
  }

  String _getPermissionStatus(PermissionStatus? status) {
    if (status == null) return 'not_requested';
    if (status.isGranted) return 'granted';
    if (status.isDenied) return 'denied';
    if (status.isPermanentlyDenied) return 'permanently_denied';
    return 'not_requested';
  }

  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    
    // Track individual permission change
    await trackPermissions({permission: status});
    
    return status.isGranted;
  }
}
