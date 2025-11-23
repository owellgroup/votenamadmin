import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: elevation!,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }

    return content;
  }
}

