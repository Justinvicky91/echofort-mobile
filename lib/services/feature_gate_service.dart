import 'package:shared_preferences/shared_preferences.dart';

/// Feature Gating Service
/// 
/// Controls access to features based on subscription plan
/// Prevents free users from accessing paid features
class FeatureGateService {
  // Subscription plans
  static const String PLAN_FREE = 'free';
  static const String PLAN_BASIC = 'basic';
  static const String PLAN_PERSONAL = 'personal';
  static const String PLAN_FAMILY = 'family';
  
  // Features
  static const String FEATURE_CALL_SCREENING = 'call_screening';
  static const String FEATURE_SMS_PROTECTION = 'sms_protection';
  static const String FEATURE_FAMILY_GPS = 'family_gps';
  static const String FEATURE_LEGAL_ASSISTANCE = 'legal_assistance';
  static const String FEATURE_EVIDENCE_VAULT = 'evidence_vault';
  static const String FEATURE_SCAM_REPORTING = 'scam_reporting';
  static const String FEATURE_QR_SCANNING = 'qr_scanning';
  static const String FEATURE_AI_CHAT = 'ai_chat';
  
  /// Feature availability matrix
  static const Map<String, List<String>> FEATURE_MATRIX = {
    FEATURE_CALL_SCREENING: [PLAN_BASIC, PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_SMS_PROTECTION: [PLAN_BASIC, PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_FAMILY_GPS: [PLAN_FAMILY], // Family plan only
    FEATURE_LEGAL_ASSISTANCE: [PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_EVIDENCE_VAULT: [PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_SCAM_REPORTING: [PLAN_BASIC, PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_QR_SCANNING: [PLAN_BASIC, PLAN_PERSONAL, PLAN_FAMILY],
    FEATURE_AI_CHAT: [PLAN_PERSONAL, PLAN_FAMILY],
  };
  
  /// Get current user's subscription plan
  static Future<String> getCurrentPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('subscription_plan')?.toLowerCase() ?? PLAN_FREE;
    } catch (e) {
      print('[FEATURE_GATE] Error getting plan: $e');
      return PLAN_FREE;
    }
  }
  
  /// Check if user has access to a feature
  static Future<bool> hasAccess(String feature) async {
    final plan = await getCurrentPlan();
    final allowedPlans = FEATURE_MATRIX[feature] ?? [];
    return allowedPlans.contains(plan);
  }
  
  /// Get required plan for a feature
  static String getRequiredPlan(String feature) {
    final allowedPlans = FEATURE_MATRIX[feature] ?? [];
    if (allowedPlans.isEmpty) return PLAN_FREE;
    
    // Return the lowest tier that has access
    if (allowedPlans.contains(PLAN_BASIC)) return PLAN_BASIC;
    if (allowedPlans.contains(PLAN_PERSONAL)) return PLAN_PERSONAL;
    if (allowedPlans.contains(PLAN_FAMILY)) return PLAN_FAMILY;
    
    return PLAN_FREE;
  }
  
  /// Get plan display name
  static String getPlanDisplayName(String plan) {
    switch (plan.toLowerCase()) {
      case PLAN_FREE:
        return 'Free';
      case PLAN_BASIC:
        return 'Basic';
      case PLAN_PERSONAL:
        return 'Personal';
      case PLAN_FAMILY:
        return 'Family';
      default:
        return 'Unknown';
    }
  }
  
  /// Get plan price (for upgrade prompts)
  static String getPlanPrice(String plan) {
    switch (plan.toLowerCase()) {
      case PLAN_BASIC:
        return '₹399/month';
      case PLAN_PERSONAL:
        return '₹799/month';
      case PLAN_FAMILY:
        return '₹1499/month';
      default:
        return 'Free';
    }
  }
  
  /// Check if user needs to upgrade for a feature
  static Future<bool> needsUpgrade(String feature) async {
    return !(await hasAccess(feature));
  }
  
  /// Get upgrade message for a feature
  static String getUpgradeMessage(String feature) {
    final requiredPlan = getRequiredPlan(feature);
    final planName = getPlanDisplayName(requiredPlan);
    final price = getPlanPrice(requiredPlan);
    
    return 'This feature requires $planName plan ($price). Upgrade now to unlock!';
  }
  
  /// Get list of features for a plan
  static List<String> getFeaturesForPlan(String plan) {
    final features = <String>[];
    
    FEATURE_MATRIX.forEach((feature, allowedPlans) {
      if (allowedPlans.contains(plan.toLowerCase())) {
        features.add(feature);
      }
    });
    
    return features;
  }
  
  /// Get feature display name
  static String getFeatureDisplayName(String feature) {
    switch (feature) {
      case FEATURE_CALL_SCREENING:
        return 'Call Screening';
      case FEATURE_SMS_PROTECTION:
        return 'SMS Protection';
      case FEATURE_FAMILY_GPS:
        return 'Family GPS Tracking';
      case FEATURE_LEGAL_ASSISTANCE:
        return 'Legal Assistance';
      case FEATURE_EVIDENCE_VAULT:
        return 'Evidence Vault';
      case FEATURE_SCAM_REPORTING:
        return 'Scam Reporting';
      case FEATURE_QR_SCANNING:
        return 'QR/Link Scanning';
      case FEATURE_AI_CHAT:
        return 'AI Chat Assistant';
      default:
        return feature;
    }
  }
}
