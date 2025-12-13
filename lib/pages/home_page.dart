import 'package:flutter/material.dart';
import 'package:tes/Widget/post_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
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
                    (context, index) => PostCard(
                  user: 'Username',
                  text: 'MUAHAHAHHHAHAHAHAHAHHAHAHHAHAHAHAHAHAHAHHAA',
                  like: 20,
                  image: 'assets/images/large_rocket_logo.png',
                  screenwidth: screenWidth,
                ),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}