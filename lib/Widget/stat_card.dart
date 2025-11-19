import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isBlue;
  final bool fullWidth;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isBlue = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isBlue ? Colors.white : Colors.black87;
    final subTextColor =
    isBlue ? Colors.white.withOpacity(0.9) : Colors.grey[600];

    final decoration = BoxDecoration(
      color: isBlue ? null : Colors.white,
      gradient: isBlue
          ? const LinearGradient(
        colors: [Color(0xFF5CDFFB), Color(0xFF1E89EF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : null,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBlue ? Colors.white.withOpacity(0.2) : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isBlue ? Colors.white : const Color(0xFF1E89EF),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}