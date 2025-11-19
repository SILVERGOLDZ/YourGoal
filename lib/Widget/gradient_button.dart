import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;

  const GradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 25.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // 1. FIX: Use Positioned.fill for the gradient
          // This ensures the gradient expands to fill whatever size the TEXT creates.
          Positioned.fill(
            child: Container(
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
          ),

          // 2. FIX: The Material/InkWell is NOT Positioned
          // It sits naturally in the stack, giving the button its size based on the padding/child.
          Material(
            color: Colors.transparent, // Must be transparent to see gradient
            child: InkWell(
              onTap: onPressed,
              splashColor: Colors.white.withValues(alpha: 0.3),
              highlightColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Center(child: child), // The child (Text) gives the button size
              ),
            ),
          ),
        ],
      ),
    );
  }
}