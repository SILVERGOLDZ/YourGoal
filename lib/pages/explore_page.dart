import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tes/Widget/post_card.dart';
import 'package:tes/models/post_model.dart';
import 'package:tes/services/post_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();

  // Controller untuk input text di dalam dialog
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false; // Status loading saat posting

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isPosting, // Cegah tutup dialog jika sedang loading
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder agar kita bisa update UI di dalam dialog (loading)
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Buat Postingan Baru"),
              content: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Apa yang sedang kamu pikirkan?",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 4,
                enabled: !_isPosting, // Disable input saat loading
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
                      Navigator.pop(context);
                      _textController.clear();
                    },
                    child: const Text("Batal",
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final text = _textController.text.trim();

                      if (text.isNotEmpty) {
                        // 1. Ubah state menjadi loading
                        setStateDialog(() => _isPosting = true);

                        try {
                          // 2. Kirim ke Firebase via Service
                          await _postService.addPost(text);

                          // 3. Reset & Tutup Dialog jika sukses
                          _textController.clear();
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          // Handle error jika perlu
                          debugPrint("Error posting: $e");
                        } finally {
                          // Matikan loading (jika dialog belum tertutup karena error)
                          if (context.mounted) {
                            setStateDialog(() => _isPosting = false);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Posting"),
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
          title: const Text("Hapus Postingan?"),
          content: const Text("Postingan ini akan dihapus secara permanen."),
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
    // Ambil User ID saat ini untuk pengecekan like & bookmark
    final currentUid = _postService.currentUserId;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // --- HEADER SEARCH ---
            SliverAppBar(
              floating: true,
              pinned: false,
              toolbarHeight: screenHeight * 0.10,
              backgroundColor: Colors.white,
              title: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0x80E3E3E3),
                  hintText: 'Cari...',
                  prefixIcon: const Icon(Icons.search),
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

            // --- LIST POSTINGAN ---
            StreamBuilder<QuerySnapshot>(
              stream: _postService.getPostsStream(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }

                // 2. Error / Empty State
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: Text("Error: ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Text("Belum ada postingan.")));
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = PostModel.fromMap(
                          docs[index].id,
                          docs[index].data() as Map<String, dynamic>
                      );

                      // --- LOGIKA UTAMA PERUBAHAN DI SINI ---
                      bool isLiked = false;
                      bool isBookmarked = false; // Default false
                      bool isOwner = false;
                      // Cek jika user login, update status based on ID
                      if (currentUid != null) {
                        isLiked = post.likedBy.contains(currentUid);
                        isBookmarked = post.savedBy.contains(currentUid); // <-- Pakai currentUid, bukan user.uid
                        isOwner = post.userId == currentUid; // <--- Cek Ownership
                      }

                      return PostCard(
                        user: post.username,
                        text: post.text,
                        likeCount: post.likeCount,
                        isLiked: isLiked,
                        isBookmarked: isBookmarked, // <-- Pass ke widget
                        screenwidth: screenWidth,
                        image: null,

                        // AKSI KETIKA TOMBOL LIKE DITEKAN
                        onLikePressed: () {
                          _postService.toggleLike(post.id, post.likedBy);
                        },

                        // AKSI KETIKA TOMBOL BOOKMARK DITEKAN
                        onBookmarkPressed: () {
                          _postService.toggleBookmark(post.id, post.savedBy);

                          // Tampilkan snackbar (feedback visual)
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isBookmarked
                                  ? "Dihapus dari koleksi"
                                  : "Disimpan ke koleksi"),
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
            ),
          ],
        ),
      ),

      // --- TOMBOL TAMBAH POSTINGAN ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
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
      ),
    );
  }
}