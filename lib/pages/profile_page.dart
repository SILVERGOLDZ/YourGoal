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
import '../models/goal_model.dart';
import '../services/goaldata_service.dart';
import '../models/post_model.dart'; // Import Model
import '../services/post_service.dart'; // Import Service
import '../pages/explore_page.dart';

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
  final PostService _postService = PostService(); // Instance PostService

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
        await user.reload();
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
  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Postingan?"),
          content: const Text("Postingan ini akan dihapus secara permanen dari profil Anda."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog dulu
                try {
                  await _postService.deletePost(postId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Postingan berhasil dihapus")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal menghapus: $e")),
                    );
                  }
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Bagian build TETAP SAMA sampai _userPost) ...
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
                  backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)                      ? NetworkImage(_photoUrl!)
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayFirstName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenSize * 0.07)),
                  const SizedBox(width: 8),
                  Text(displayLastName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenSize * 0.07)),
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
                child: const SizedBox(width: double.infinity, height: 55, child: GradientButton(borderRadius: 16, child: Center(child: Text("Show My Collection", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BAGIAN YANG DIUBAH ---
  Widget _userPost(BuildContext context, bool isMobile, double screenWidth, double screenHeight, double screenSize) {
    final user = _authService.currentUser;
    // Jika user entah kenapa null, return kosong
    if (user == null) return const SliverToBoxAdapter(child: SizedBox());

    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getUserPostsStream(user.uid),
      builder: (context, snapshot) {

        // 1. LOGIKA ERROR (Penting: Cek ini dulu!)
        // Jika Firestore butuh Index, errornya akan muncul di sini.
        if (snapshot.hasError) {
          debugPrint("🔥 FIRESTORE ERROR: ${snapshot.error}");
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText( // Pakai SelectableText agar bisa copy error
                "Terjadi Error Database:\n${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // 2. LOGIKA LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 3. LOGIKA DATA KOSONG
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                        "You haven't posted anything yet.",
                        style: TextStyle(color: Colors.grey[600])
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tampilkan UID User yang sedang login untuk debug
                  Text("Login UID: ${user.uid}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const Text("Pastikan field 'userId' di database cocok dengan UID di atas.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // 4. LOGIKA SUKSES (Tampilkan Data)
        final docs = snapshot.data!.docs;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final post = PostModel.fromMap(
                  docs[index].id,
                  docs[index].data() as Map<String, dynamic>
              );

              bool isLiked = post.likedBy.contains(user.uid);
              bool isBookmarked = post.savedBy.contains(user.uid);
              bool isOwner = true;

              return PostCard(
                user: post.username,
                text: post.text,
                likeCount: post.likeCount,
                isLiked: isLiked,
                isBookmarked: isBookmarked, // <-- Pass ke widget
                image: null,
                screenwidth: screenWidth,
                onLikePressed: () => _postService.toggleLike(post.id, post.likedBy),
                onBookmarkPressed: () {
                  _postService.toggleBookmark(post.id, post.savedBy);

                  // Opsional: Tampilkan snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBookmarked ? "Removed from Collection" : "Saved to Collection"),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                onDeletePressed: isOwner ? () => _confirmDelete(post.id) : null,
              );
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }
}