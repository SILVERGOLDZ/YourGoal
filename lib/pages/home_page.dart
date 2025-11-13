import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Scollable and profesional custom scroll
        child: CustomScrollView(
          //fleksible scroll and animation
          slivers: [
            SliverAppBar(
              pinned: true, // agar selalu di atas
              backgroundColor: Colors.white,
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(title: Text('Item $index')),
                childCount: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

