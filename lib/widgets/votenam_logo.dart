import 'package:flutter/material.dart';

class VotenamLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;

  const VotenamLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      decoration: backgroundColor == null ? null : BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/logovotenam.png',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Return empty container instead of crashing
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

