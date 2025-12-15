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
                      return JourneyTile(
                          journey: journeys[index]
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


class JourneyTile extends StatefulWidget {
  final JourneyItem journey;
  const JourneyTile({super.key, required this.journey});

  @override
  State<JourneyTile> createState() => _JourneyTileState();
}

class _JourneyTileState extends State<JourneyTile> {
  bool _showComment = false;

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final hasComment = journey.comment != null && journey.comment!.trim().isNotEmpty;

    return GestureDetector(
      onTap: hasComment ? () {
        setState(() => _showComment = !_showComment);
      } : null,
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(journey.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        "From goal: ${journey.goalTitle}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Show dropdown indicator only if comment exists
                if (hasComment)
                  Icon(
                    _showComment ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
              ],
            ),

            // Animated comment section
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showComment && hasComment
                  ? Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        journey.comment!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}