import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart';
import 'package:tes/Widget/gradient_button.dart';
import 'package:tes/Widget/mygradient_card.dart'; //bg color + transparent status bar with safe area

class MyGoalPage extends StatelessWidget {
  const MyGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage( //background blending
        child: Center(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              MyGradientCard(),
              GradientButton(
                onPressed: () {
                  print("Button tapped!");
                },
                borderRadius: 25.0, // Match your Figma radius
                child: const Text(
                  "Click Me",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
