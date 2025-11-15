import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/feature_gate_service.dart';
import '../screens/subscription/paywall_screen.dart';

/// Upgrade Prompt Dialog
/// 
/// Shows when user tries to access a paid feature without subscription
class UpgradePromptDialog extends StatelessWidget {
  final String feature;
  final String? customMessage;
  
  const UpgradePromptDialog({
    Key? key,
    required this.feature,
    this.customMessage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final requiredPlan = FeatureGateService.getRequiredPlan(feature);
    final planName = FeatureGateService.getPlanDisplayName(requiredPlan);
    final price = FeatureGateService.getPlanPrice(requiredPlan);
    final featureName = FeatureGateService.getFeatureDisplayName(feature);
    
    return Dialog(
      backgroundColor: AppTheme.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primarySolid.withOpacity(0.2),
                    AppTheme.primarySolid.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppTheme.primarySolid,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Upgrade Required',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              customMessage ?? 
              '$featureName requires $planName plan ($price).',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Upgrade Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaywallScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primarySolid,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Upgrade Now',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Maybe Later',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show upgrade prompt dialog
  static Future<void> show(BuildContext context, String feature, {String? customMessage}) {
    return showDialog(
      context: context,
      builder: (context) => UpgradePromptDialog(
        feature: feature,
        customMessage: customMessage,
      ),
    );
  }
}
