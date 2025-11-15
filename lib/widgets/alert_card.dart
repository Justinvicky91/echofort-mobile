import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Alert Card Component
/// 
/// Reusable alert card following EchoFort brand guidelines (§6)
/// Used for errors, warnings, info messages, and success confirmations
enum AlertType {
  success,  // Green - Success messages
  warning,  // Orange - Warnings, action needed
  danger,   // Red - Errors, critical alerts
  info,     // Blue - Information, tips
}

class AlertCard extends StatelessWidget {
  final String title;
  final String? message;
  final AlertType type;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final Widget? action;

  const AlertCard({
    Key? key,
    required this.title,
    this.message,
    required this.type,
    this.icon,
    this.onDismiss,
    this.action,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case AlertType.success:
        return AppTheme.accentSuccess.withOpacity(0.1);
      case AlertType.warning:
        return AppTheme.accentWarning.withOpacity(0.1);
      case AlertType.danger:
        return AppTheme.accentDanger.withOpacity(0.1);
      case AlertType.info:
        return AppTheme.primarySolid.withOpacity(0.1);
    }
  }

  Color get borderColor {
    switch (type) {
      case AlertType.success:
        return AppTheme.accentSuccess;
      case AlertType.warning:
        return AppTheme.accentWarning;
      case AlertType.danger:
        return AppTheme.accentDanger;
      case AlertType.info:
        return AppTheme.primarySolid;
    }
  }

  Color get iconColor {
    return borderColor;
  }

  IconData get defaultIcon {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_rounded;
      case AlertType.warning:
        return Icons.warning_rounded;
      case AlertType.danger:
        return Icons.error_rounded;
      case AlertType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            icon ?? defaultIcon,
            color: iconColor,
            size: 24,
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action!,
                ],
              ],
            ),
          ),
          
          // Dismiss button
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
