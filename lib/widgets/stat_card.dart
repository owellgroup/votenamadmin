import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.primaryBlue,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 900;
    final isSmall = screenWidth < 600;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available space
        final cardWidth = constraints.maxWidth;
        final isVerySmall = cardWidth < 150;
        final isSmallCard = cardWidth < 200;
        
        final padding = isVerySmall ? 8.0 : (isSmallCard ? 12.0 : (isTablet ? 16.0 : 24.0));
        final iconSize = isVerySmall ? 18.0 : (isSmallCard ? 20.0 : (isTablet ? 24.0 : 28.0));
        final iconPadding = isVerySmall ? 6.0 : (isSmallCard ? 8.0 : (isTablet ? 8.0 : 12.0));
        final valueFontSize = isVerySmall ? 20.0 : (isSmallCard ? 24.0 : (isTablet ? 28.0 : 32.0));
        final titleFontSize = isVerySmall ? 10.0 : (isSmallCard ? 11.0 : (isTablet ? 12.0 : 14.0));
        final spacing1 = isVerySmall ? 6.0 : (isSmallCard ? 8.0 : (isTablet ? 12.0 : 16.0));
        final spacing2 = isVerySmall ? 2.0 : (isSmallCard ? 3.0 : (isTablet ? 2.0 : 4.0));
        
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: backgroundColor != null
                  ? null
                  : AppTheme.cardGradient,
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: iconSize,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: isVerySmall ? 12.0 : (isSmallCard ? 13.0 : (isTablet ? 14.0 : 16.0)),
                        color: Colors.grey[400],
                      ),
                  ],
                ),
                SizedBox(height: spacing1),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(height: spacing2),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

