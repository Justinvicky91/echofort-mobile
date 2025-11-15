import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status Badge Component
/// 
/// Reusable badge following EchoFort brand guidelines (§7)
/// Used for call status, threat levels, subscription status, etc.
enum BadgeType {
  success,  // Green - Protected, Safe, Active
  warning,  // Orange - Action needed, Unknown
  danger,   // Red - Scam detected, Blocked, Critical
  info,     // Blue - Info, Pending
  neutral,  // Gray - Inactive, None
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool small;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.type,
    this.small = false,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case BadgeType.success:
        return AppTheme.accentSuccess.withOpacity(0.1);
      case BadgeType.warning:
        return AppTheme.accentWarning.withOpacity(0.1);
      case BadgeType.danger:
        return AppTheme.accentDanger.withOpacity(0.1);
      case BadgeType.info:
        return AppTheme.primarySolid.withOpacity(0.1);
      case BadgeType.neutral:
        return AppTheme.borderLight;
    }
  }

  Color get textColor {
    switch (type) {
      case BadgeType.success:
        return AppTheme.accentSuccess;
      case BadgeType.warning:
        return AppTheme.accentWarning;
      case BadgeType.danger:
        return AppTheme.accentDanger;
      case BadgeType.info:
        return AppTheme.primarySolid;
      case BadgeType.neutral:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Shield Status Badge
/// 
/// Special badge for home screen shield status
class ShieldStatusBadge extends StatelessWidget {
  final bool isProtected;
  final String label;

  const ShieldStatusBadge({
    Key? key,
    required this.isProtected,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isProtected
            ? LinearGradient(
                colors: [AppTheme.accentSuccess, AppTheme.accentSuccess.withOpacity(0.8)],
              )
            : LinearGradient(
                colors: [AppTheme.accentWarning, AppTheme.accentWarning.withOpacity(0.8)],
              ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: (isProtected ? AppTheme.accentSuccess : AppTheme.accentWarning).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProtected ? Icons.shield_rounded : Icons.warning_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
