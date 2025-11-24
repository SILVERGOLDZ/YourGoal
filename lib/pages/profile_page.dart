import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes/Widget/top_bar.dart';
import 'package:tes/auth_service.dart';
import 'package:tes/config/routes.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/Widget/base_page.dart';

import '../Widget/gradient_button.dart';
import '../Widget/post_card.dart';
import '../Widget/stat_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        _email = user.email;
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
            _firstName = user.displayName?.split(' ').first ?? "User";
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
                    onPressed: () => context.push(AppRoutes.settings),
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
                      : const AssetImage('assets/profile.jpg') as ImageProvider,
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

              Row(
                children: const [
                  //TODO: Dynamic Data
                  Expanded(
                    child: StatCard(
                      label: "Goals",
                      value: "1",
                      icon: Icons.rocket_launch_outlined,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: "Days Active",
                      value: "14",
                      icon: Icons.bar_chart_rounded,
                      isBlue: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              //TODO: Buat page Growth Log dan navigasinya
              GestureDetector(
                onTap: () => context.pushNamed('collection'),
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

  SliverList _userPost(
      BuildContext context,
      bool isMobile,
      double screenWidth,
      double screenHeight,
      double screenSize,
      ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final fullName = "$_firstName $_lastName";

          return isMobile
              ? PostCard(
            user: fullName.trim().isEmpty ? 'User' : fullName,
            text: 'Look at my achievement!',
            like: 20 + index,
            image: 'assets/images/large_rocket_logo.png',
            screenwidth: screenWidth,
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: PostCard(
              user: fullName.trim().isEmpty ? 'User' : fullName,
              text: 'Look at my achievement!',
              like: 20 + index,
              image: 'assets/images/large_rocket_logo.png',
              screenwidth: screenWidth,
            ),
          );
        },
        childCount: 3,
      ),
    );
  }
}
