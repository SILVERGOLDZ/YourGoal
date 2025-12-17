import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart';
import 'package:tes/Widget/post_card.dart';
import 'package:tes/Widget/top_bar.dart';
import 'package:tes/models/post_model.dart';
import 'package:tes/models/user_model.dart';
import 'package:tes/services/post_service.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/Widget/stat_card.dart';
import 'package:tes/models/goal_model.dart';

class OtherProfilePage extends StatelessWidget {
  final UserModel user;

  const OtherProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final PostService postService = PostService();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    return Scaffold(
      body: BasePage(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 1. Top Bar with Back Button, NO Settings button
              TopBar(
                title: "${user.firstName}'s Profile",
                showBack: true,
                transparent: true,
                screenSize: screenSize,
                pin: false,
                // actions: [], // Empty actions means no hamburger menu
              ),

              // 2. User Info (Identity Only)
              // 2. User Info (Identity & Stats)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column( // Mulai Column
                    children: [ // Mulai Children
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.active, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: screenSize * 0.15,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(user.profileImageUrl!)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user.firstName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenSize * 0.07)),
                          const SizedBox(width: 8),
                          Text(user.lastName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenSize * 0.07)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Email
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.inactive.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.email,
                          style: TextStyle(fontSize: screenSize * 0.035, color: Colors.grey[700]),
                        ),
                      ),

                      const SizedBox(height: 25), // Jarak sebelum statistik

                      // Statistik Goals
                      StreamBuilder<List<RoadmapModel>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('goals')
                            .snapshots()
                            .map((snapshot) => snapshot.docs
                            .map((d) => RoadmapModel.fromFirestore(d))
                            .toList()),
                        builder: (context, snapshot) {
                          final goals = snapshot.data ?? [];
                          final totalCreated = goals.length;
                          final totalAchieved = goals.where((g) => g.progress == 1.0).length;

                          return Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  label: "Goals\nCreated",
                                  value: "$totalCreated",
                                  icon: Icons.rocket_launch_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  label: "Goals\nAchieved",
                                  value: "$totalAchieved",
                                  icon: Icons.assignment_turned_in_outlined,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Text(
                    "Posts",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ),
              ),

              // 3. User Posts List
              StreamBuilder<QuerySnapshot>(
                stream: postService.getUserPostsStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(child: Text("Error: ${snapshot.error}"));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Center(
                            child: Text("${user.firstName} hasn't posted anything yet.",
                                style: TextStyle(color: Colors.grey[600]))),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = PostModel.fromMap(
                            docs[index].id, docs[index].data() as Map<String, dynamic>);

                        // We assume the viewer is the currently logged-in user
                        final currentUid = postService.currentUserId;
                        bool isLiked = false;
                        bool isBookmarked = false;

                        if (currentUid != null) {
                          isLiked = post.likedBy.contains(currentUid);
                          isBookmarked = post.savedBy.contains(currentUid);
                        }

                        return PostCard(
                          user: post. username,
                          text: post.text,
                          likeCount: post.likeCount,
                          isLiked: isLiked,
                          isBookmarked: isBookmarked,
                          screenwidth: screenWidth,
                          image: null,
                          onLikePressed: () {
                            postService.toggleLike(post.id, post.likedBy);
                          },
                          onBookmarkPressed: () {
                            postService.toggleBookmark(post.id, post.savedBy);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isBookmarked
                                    ? "Removed from collection"
                                    : "Saved to collection"),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          // Disable delete for other people's posts
                          onDeletePressed: null,
                        );
                      },
                      childCount: docs.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}