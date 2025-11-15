import 'package:flutter/material.dart';

/// Logo variant types
enum LogoVariant {
  /// Primary logo with gradient (for light backgrounds)
  primary,
  
  /// White monochrome logo (for dark backgrounds)
  white,
  
  /// Watermark logo with 15% opacity (for empty states)
  watermark,
}

/// EchoFort Logo Widget
/// 
/// A reusable component for displaying the EchoFort logo
/// with consistent sizing and variants across the app.
/// 
/// Example usage:
/// ```dart
/// // Primary logo at 48dp
/// EchoFortLogo(size: 48)
/// 
/// // White logo for dark backgrounds
/// EchoFortLogo(size: 32, variant: LogoVariant.white)
/// 
/// // Watermark for empty states
/// EchoFortLogo(size: 160, variant: LogoVariant.watermark)
/// ```
class EchoFortLogo extends StatelessWidget {
  /// Size of the logo in dp (width and height are equal)
  final double size;
  
  /// Logo variant to display
  final LogoVariant variant;
  
  /// Optional custom fit
  final BoxFit fit;
  
  const EchoFortLogo({
    Key? key,
    this.size = 48.0,
    this.variant = LogoVariant.primary,
    this.fit = BoxFit.contain,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    String assetPath;
    
    switch (variant) {
      case LogoVariant.white:
        assetPath = 'assets/logo_echofort_white.png';
        break;
      case LogoVariant.watermark:
        assetPath = 'assets/logo_echofort_watermark.png';
        break;
      case LogoVariant.primary:
      default:
        assetPath = 'assets/logo_echofort_primary.png';
    }
    
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
    );
  }
}

/// EchoFort Logo with Text
/// 
/// Displays the logo alongside "EchoFort" text
/// Used in AppBar and headers
class EchoFortLogoWithText extends StatelessWidget {
  /// Size of the logo
  final double logoSize;
  
  /// Logo variant
  final LogoVariant variant;
  
  /// Text color (defaults to theme text color)
  final Color? textColor;
  
  /// Font size for the text
  final double fontSize;
  
  const EchoFortLogoWithText({
    Key? key,
    this.logoSize = 32.0,
    this.variant = LogoVariant.primary,
    this.textColor,
    this.fontSize = 18.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EchoFortLogo(
          size: logoSize,
          variant: variant,
        ),
        const SizedBox(width: 8),
        Text(
          'EchoFort',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
