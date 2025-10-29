import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;

  const GradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 25.0, // Default radius, you can change this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // 1. The Gradient Container
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5CDFFB),
                  Color(0xFF1E89EF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // 2. The Material/InkWell for tap effects
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withValues(alpha: 0.3),
                highlightColor: Colors.white.withValues(alpha: 0.2), // Hold color
                child: Padding(
                  // Default button padding
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}