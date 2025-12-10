import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserJourneyPage extends StatefulWidget{
  const UserJourneyPage({super.key});

  @override
  State<UserJourneyPage> createState() => _UserJourneyPageState();
}

class _UserJourneyPageState extends State<UserJourneyPage>{

  // dummy data
  final List<String> userJourney = [
    "User membuka halaman Home",
    "User klik tombol Login",
    "User berhasil login",
    "User membuka halaman Product",
    "User menambah item ke cart",
    "User melakukan checkout",
    "User membuka halaman Home",
    "User klik tombol Login",
    "User berhasil login",
    "User membuka halaman Product",
    "User menambah item ke cart",
    "User melakukan checkout",
  ];

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    bool isMobile = false;
    screenWidth < 768 ? isMobile = true : isMobile = false;

    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.1,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Text(
                      'What Have I Achieved?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? screenWidth * 0.12 : screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              SliverList.builder(
                itemCount: userJourney.length,
                itemBuilder: (context, index) {
                  return _textHolder(
                    userJourney[index],
                    context,
                    isMobile,
                    screenWidth,
                    screenHeight,
                    screenSize,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

  }

  // Card template untuk tiap log
  Widget _textHolder(
      String text,
      BuildContext context,
      bool isMobile,
      double screenWidth,
      double screenHeight,
      double screenSize,
      ){

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(text, style: TextStyle(fontSize: screenSize*0.05, fontWeight: FontWeight.w700),), flex: 8),
              Expanded(child: Text('20 January 2025, 15:00', style: TextStyle(fontSize: 7),), flex: 2),
            ],
          ),

          SizedBox(height: 10),
          Row(
            children: [
              Text('Comment'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                //TODO: Add Gesture Detector
                child: Icon(Icons.arrow_forward_ios, size: 10, weight: 20),
              ),
            ],
          )
        ],
      ),
    );
  }

}