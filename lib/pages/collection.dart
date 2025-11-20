import 'package:flutter/material.dart';

import '../Widget/post_card.dart';
import '../Widget/top_bar.dart';

class CollectionPage extends StatefulWidget{
  const CollectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _CollectionState();

}

class _CollectionState extends State<CollectionPage> {


  @override
  Widget build(BuildContext context){
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    bool isMobile = false;
    screenWidth < 768 ? isMobile = true : isMobile = false;

    return Scaffold(
      body: SafeArea(
        // Scollable and profesional custom scroll
        child: CustomScrollView(
          //fleksible scroll and animation
          slivers: [
            ScrollableTopBar(title: "My Collection"),

            SliverList(
              delegate: SliverChildBuilderDelegate(

                //TODO: Ubah data menjadi dynamic!
                    (context, index) =>
                    isMobile
                        ? PostCard(
                            user: 'Username',
                            text: 'MUAHAHAHHHAHAHAHAHAHHAHAHHAHAHAHAHAHAHAHHAA',
                            like: 20,
                            image: 'assets/images/large_rocket_logo.png',
                            screenwidth: screenWidth,
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                            child: PostCard(
                              user: 'Username',
                              text: 'MUAHAHAHHHAHAHAHAHAHHAHAHHAHAHAHAHAHAHAHHAA',
                              like: 20,
                              image: 'assets/images/large_rocket_logo.png',
                              screenwidth: screenWidth,
                            ),
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