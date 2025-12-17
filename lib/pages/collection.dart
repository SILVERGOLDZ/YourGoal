import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tes/Widget/post_card.dart';
import 'package:tes/Widget/top_bar.dart';
import 'package:tes/models/post_model.dart';
import 'package:tes/services/post_service.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _CollectionState();
}

class _CollectionState extends State<CollectionPage> {
  final PostService _postService = PostService();

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Post?"),
          content: const Text(
              "This post will be permanently deleted from your profile."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog dulu
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize =
    (screenWidth < screenHeight ? screenWidth : screenHeight);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            TopBar(title: "My Collection", screenSize: screenSize),

            // StreamBuilder untuk mengambil daftar ID bookmarks
            StreamBuilder<QuerySnapshot>(
              stream: _postService.getBookmarksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Text("No collections yet.")),
                    ),
                  );
                }

                final bookmarkDocs = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Ambil ID Post dari dokumen bookmark
                      final postId = bookmarkDocs[index].id;

                      // Panggil Widget Helper
                      return _BookmarkedPostItem(
                        postId: postId,
                        screenWidth: screenWidth,
                        postService: _postService,
                        onDelete: _confirmDelete, // Kirim fungsi ke sini
                      );
                    },
                    childCount: bookmarkDocs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget: Mengambil data Post asli berdasarkan ID
class _BookmarkedPostItem extends StatelessWidget {
  final String postId;
  final double screenWidth;
  final PostService postService;
  final Function(String) onDelete; // Parameter penampung fungsi

  const _BookmarkedPostItem({
    super.key,
    required this.postId,
    required this.screenWidth,
    required this.postService,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = postService.currentUserId;

    return StreamBuilder<DocumentSnapshot>(
      stream: postService.getSinglePostStream(postId),
      builder: (context, snapshot) {
        // Jika data masih loading atau post sudah dihapus ownernya
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        // Konversi data ke PostModel
        final post = PostModel.fromMap(
          snapshot.data!.id,
          snapshot.data!.data() as Map<String, dynamic>,
        );

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
          image: null,
          screenwidth: screenWidth,

          onLikePressed: () => postService.toggleLike(post.id, post.likedBy),
          onBookmarkPressed: () {
            postService.toggleBookmark(post.id, post.savedBy);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isBookmarked
                    ? "Removed from Collection"
                    : "Saved to Collection"),
                duration: const Duration(milliseconds: 500),
              ),
            );
          },
          // PERBAIKAN UTAMA DI SINI:
          // Gunakan 'onDelete' (parameter), BUKAN '_confirmDelete' (fungsi parent)
          onDeletePressed: isOwner ? () => onDelete(post.id) : null,
        );
      },
    );
  }
}