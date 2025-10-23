import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // 1. Buat "slot" untuk menerima data counter
  final int counterValue;

  // 2. Buat constructor untuk mewajibkan data counter
  const HomePage({super.key, required this.counterValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Text(
            '$counterValue', // 4. Tampilkan data yang diterima
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}