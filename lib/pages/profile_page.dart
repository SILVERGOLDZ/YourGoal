import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:tes/Widget/top_bar.dart';
import 'package:tes/services/auth/auth_service.dart';
import 'package:tes/config/routes.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/Widget/base_page.dart';

import '../Widget/gradient_button.dart';
import '../Widget/post_card.dart';
import '../Widget/stat_card.dart';
import '../services/goaldata_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Stream<QuerySnapshot> _userPostsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<List<RoadmapModel>> _userGoalsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((d) => RoadmapModel.fromFirestore(d)).toList(),
    );
  }


  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _email;
  String? _firstName;
  String? _lastName;
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        // Evict the old image from cache before reloading
        if (_photoUrl != null) {
          await PaintingBinding.instance.imageCache.evict(NetworkImage(_photoUrl!));
        }

        await user.reload(); // Reload user to get the latest photoURL
        user = _authService.currentUser;

        _email = user!.email;
        _photoUrl = user.photoURL;

        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
          });
        } else if (mounted) {
          setState(() {
            _firstName = user?.displayName?.split(' ').first ?? "User";
            _lastName = "";
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

    bool isMobile = screenWidth < 768;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: BasePage(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              TopBar(
                title: "Profile",
                showBack: false,
                transparent: true,
                screenSize: screenSize,
                pin: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => context.push(AppRoutes.settings).then((_) => _fetchUserData()),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: _userInfo(context, isMobile, screenWidth, screenHeight, screenSize),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Text("Recent Posts", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                ),
              ),

              _userPost(context, isMobile, screenWidth, screenHeight, screenSize),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfo(
      //TODO: Buat semua variable yang berkaitan dengan firebase nanti
      BuildContext context,
      bool isMobile,
      double screenWidth,
      double screenHeight,
      double screenSize,
      ) {
    String displayFirstName = _firstName ?? "User";
    String displayLastName = _lastName ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.active, width: 2),
                ),
                child: CircleAvatar(
                  radius: screenSize * 0.15,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayFirstName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize * 0.07),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayLastName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize * 0.07),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inactive.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _email ?? 'No Email',
                  style: TextStyle(fontSize: screenSize * 0.035, color: Colors.grey[700]),
                ),
              ),

              const SizedBox(height: 30),

              StreamBuilder<List<RoadmapModel>>(
                stream: _userGoalsStream(),
                builder: (context, snapshot) {
                  final goals = snapshot.data ?? [];

                  final totalCreated = goals.length;
                  final totalAchieved =
                      goals.where((g) => g.progress == 1.0).length;

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


              const SizedBox(height: 25),

              //TODO: Buat page Growth Log dan navigasinya
              GestureDetector(
                onTap: () => context.pushNamed('journey'),
                child: const SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: GradientButton(
                    borderRadius: 16,
                    child: Center(
                      child: Text(
                        "Show Journey",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => context.pushNamed('collection'),
                child: const SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: GradientButton(
                    borderRadius: 16,
                    child: Center(
                      child: Text(
                        "Show My Collection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userPost(
      BuildContext context,
      bool isMobile,
      double screenWidth,
      double screenHeight,
      double screenSize,
      ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _userPostsStream(),
      builder: (context, snapshot) {
        // 1️⃣ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 2️⃣ Error
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text("Error loading posts")),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // 3️⃣ Empty State
        if (docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "You haven't posted anything yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        // 4️⃣ REAL LIST
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final fullName = "$_firstName $_lastName".trim();

              final card = PostCard(
                user: fullName.isEmpty ? 'User' : fullName,
                text: data['text'] ?? '',
                like: data['like'] ?? 0,
                image: data['image'],
                screenwidth: screenWidth,
                photoUrl: _photoUrl,
              );

              return isMobile
                  ? card
                  : Padding(
                padding:
                EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: card,
              );
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }

}
