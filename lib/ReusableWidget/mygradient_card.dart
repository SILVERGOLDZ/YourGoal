import 'package:flutter/material.dart';

class MyGradientCard extends StatelessWidget {
  const MyGradientCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Example width
      height: 100, // Example height
      decoration: BoxDecoration(
        // Apply the gradient
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5CDFFB), // 0% stop
            Color(0xFF1E89EF), // 100% stop
          ],
          // Horizontal direction
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // Match the rounded corners from your Figma design
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: const Center(
        child: Text(
          "Card Content",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}