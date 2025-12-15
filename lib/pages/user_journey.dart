import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/journey_model.dart';
import '../services/goaldata_service.dart';

class UserJourneyPage extends StatefulWidget{
  const UserJourneyPage({super.key});

  @override
  State<UserJourneyPage> createState() => _UserJourneyPageState();
}

class _UserJourneyPageState extends State<UserJourneyPage>{

  final GoalDataService _dataService = GoalDataService();


  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    bool isMobile = false;
    screenWidth < 768 ? isMobile = true : isMobile = false;

    return StreamBuilder<List<JourneyItem>>(
      stream: _dataService.getCompletedJourneyStream(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final journeys = snapshot.data ?? [];

        if (journeys.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("No journey yet")),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Scrollbar(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _header(context),
                  ),

                  SliverList.builder(
                    itemCount: journeys.length,
                    itemBuilder: (context, index) {
                      return _textHolder(
                        journeys[index],
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );


  }

  // Card template untuk tiap log
  Widget _textHolder(
      JourneyItem journey,
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            journey.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            "From goal: ${journey.goalTitle}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
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
    );
  }
}