import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/Widget/post_card.dart';
import 'package:tes/models/post_model.dart';
import 'package:tes/models/user_model.dart';
import 'package:tes/services/auth/user_service.dart';
import 'package:tes/services/post_service.dart';
import 'package:tes/theme/colors.dart';

import '../models/goal_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Future<List<UserModel>>? _searchResults;
  String _query = "";
  Timer? _debounce;

  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();

    // 1. Listen for Focus changes (to update UI when keyboard opens/closes)
    _searchFocusNode.addListener(() {
      setState(() {});
    });

    // 2. Unified Search Logic
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  void _navigateToUserProfile(String userId) async {
    try {
      // Ambil data user lengkap dari Firestore menggunakan userId dari post
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && mounted) {
        // Gunakan factory constructor sesuai template model Anda
        final user = UserModel.fromFirestore(userDoc);

        // Navigasi ke halaman profil orang lain menggunakan GoRouter
        context.pushNamed(
          'otherProfile',
          extra: user,
        );
      }
    } catch (e) {
      debugPrint("Error fetching user for profile: $e");
    }
  }
  void _onSearchChanged() {
    final newQuery = _searchController.text;

    // CRITICAL FIX: Always cancel the previous timer immediately.
    // This prevents an old search from firing after you have cleared the text.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _query = newQuery;
    });

    if (newQuery.trim().isEmpty) {
      // If empty, clear results immediately (no delay needed)
      setState(() {
        _searchResults = null;
      });
      return;
    }

    // Start a new timer for the search (Debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted && newQuery.trim().isNotEmpty) {
        setState(() {
          _searchResults = _userService.searchUsers(newQuery.trim());
        });
      }
    });
  }

  void _exitSearchMode() {
    // Cancel any pending search timers
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _searchController.clear(); // This triggers the listener to clear results too
      _query = "";
      _searchResults = null;
      _searchFocusNode.unfocus(); // Close keyboard
    });
  }

  void _showCreatePostDialog() {
    setState(() {
      _isPosting = false;
    });
    showDialog(
      context: context,
      barrierDismissible: !_isPosting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Create New Post"),
              content: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 4,
                enabled: !_isPosting,
              ),
              actions: [
                if (_isPosting)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else ...[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _textController.clear();
                    },
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final text = _textController.text.trim();
                      if (text.isEmpty) return;

                      setStateDialog(() => _isPosting = true);

                      try {
                        await _postService.addPost(text);
                        _textController.clear();

                        // FIX: Async Gap Warning
                        // Check if the dialog is still mounted before using context
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                      } catch (e) {
                        debugPrint("Error posting: $e");
                        if (dialogContext.mounted) {
                          setStateDialog(() => _isPosting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Post"),
                  ),
                ]
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Post?"),
          content: const Text("This post will be permanently deleted."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _postService.deletePost(postId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post deleted successfully")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete: $e")),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Logic: We are in "Search Mode" if we have text OR the keyboard is open
    final bool isSearchMode = _query.trim().isNotEmpty || _searchFocusNode.hasFocus;

    return PopScope(
      canPop: !isSearchMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSearchMode();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                toolbarHeight: screenHeight * 0.10,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    if (isSearchMode)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: _exitSearchMode,
                      ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0x80E3E3E3),
                          hintText: 'Search users...',
                          prefixIcon: isSearchMode ? null : const Icon(Icons.search),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSearchMode)
                _buildSearchResults()
              else
                _buildPostsList(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: !isSearchMode
            ? Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset(
                'assets/images/+ btn.png',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E89EF),
                  ),
                  child: const Icon(Icons.add, size: 40, color: Colors.white),
                ),
              ),
            ),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildSearchResults() {
    // Case 1: Search bar is active, but text is empty
    if (_query.trim().isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Text(
              "Start typing to search...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // Case 2: Searching...
    return FutureBuilder<List<UserModel>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("User not found.")),
            ),
          );
        }

        final users = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final user = users[index];
              final hasImage = user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;


              return Card(
                color: Colors.transparent,
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: hasImage ? NetworkImage(user.profileImageUrl!) : null,
                    child: !hasImage ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(color: AppColors.active, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.email),
                  onTap: () {
                    context.pushNamed(
                      'otherProfile', // Must match the name in routes.dart
                      extra: user,    // Pass the user object
                    );
                  },
                ),
              );
            },
            childCount: users.length,
          ),
        );
      },
    );
  }

  Widget _buildPostsList() {
    final currentUid = _postService.currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getPostsStream(),
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
          return const SliverToBoxAdapter(child: Center(child: Text("No posts yet.")));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final post = PostModel.fromMap(
                  docs[index].id, docs[index].data() as Map<String, dynamic>);

              bool isLiked = false;
              bool isBookmarked = false;
              bool isOwner = false;

              if (currentUid != null) {
                isLiked = post.likedBy.contains(currentUid);
                isBookmarked = post.savedBy.contains(currentUid);
                isOwner = post.userId == currentUid;
              }

              return PostCard(
                user: post.username,
                text: post.text,
                likeCount: post.likeCount,
                isLiked: isLiked,
                isBookmarked: isBookmarked,
                screenwidth: screenWidth,
                image: null,
                onLikePressed: () {
                  _postService.toggleLike(post.id, post.likedBy);
                },
                onBookmarkPressed: () {
                  _postService.toggleBookmark(post.id, post.savedBy);
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
                onDeletePressed: isOwner ? () => _confirmDelete(post.id) : null,
                onUserTap: () => _navigateToUserProfile(post.userId),
                // LOGIKA BARU: Jika postingan berisi roadmap
                onTap: post.sharedRoadmap != null ? () {
                  final roadmap = RoadmapModel.fromFirestoreData(post.sharedRoadmap!);
                  context.pushNamed('goalDetail', extra: roadmap);
                } : null,

                sharedContent: post.sharedRoadmap != null ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.sharedRoadmap!['title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Tap to view this roadmap journey",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.blue),
                    ],
                  ),
                ) : null,
              );
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }
}