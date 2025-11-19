import 'package:flutter/material.dart';
import 'package:tes/Widget/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{



  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    return Scaffold(
      body: SafeArea(
        // Scollable and profesional custom scroll
        child: CustomScrollView(
          //fleksible scroll and animation
          slivers: [
            SliverAppBar(
              pinned: true, // agar selalu di atas
              toolbarHeight: screenHeight * 0.10,
              backgroundColor: Colors.white,
              title: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0x80E3E3E3),
                  hintText: 'Cari...',
                  prefixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                //TODO: Ubah data menjadi dynamic!
                    (context, index) => PostCard(
                      user: 'Username',
                      text: 'MUAHAHAHHHAHAHAHAHAHHAHAHHAHAHAHAHAHAHAHHAA',
                      like: 20,
                      image: 'assets/images/large_rocket_logo.png'),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

