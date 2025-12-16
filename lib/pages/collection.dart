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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = (screenWidth < screenHeight ? screenWidth : screenHeight);

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
                      // (Asumsi di PostService: toggleBookmark menyimpan doc dengan ID = postId)
                      final postId = bookmarkDocs[index].id;

                      // Panggil Widget Helper untuk fetch detail post
                      return _BookmarkedPostItem(
                        postId: postId,
                        screenWidth: screenWidth,
                        postService: _postService,
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

  const _BookmarkedPostItem({
    required this.postId,
    required this.screenWidth,
    required this.postService,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = postService.currentUserId;

    return StreamBuilder<DocumentSnapshot>(
      stream: postService.getSinglePostStream(postId),
      builder: (context, snapshot) {
        // Jika data masih loading atau post sudah dihapus ownernya
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Opsional: Bisa return SizedBox() agar tidak terlihat
          return const SizedBox();
        }

        // Konversi data ke PostModel
        final post = PostModel.fromMap(
          snapshot.data!.id,
          snapshot.data!.data() as Map<String, dynamic>,
        );

        bool isLiked = false;
        bool isBookmarked = false; // <-- Variabel baru
        if (currentUid != null) {
          isLiked = post.likedBy.contains(currentUid);
          isBookmarked = post.savedBy.contains(currentUid); // <-- Cek array savedBy
        }

        return PostCard(
          user: post.username,
          text: post.text,
          likeCount: post.likeCount,
          isLiked: isLiked,
          isBookmarked: isBookmarked, // <-- Pass ke widget
          image: null,
          screenwidth: screenWidth,

          onLikePressed: () => postService.toggleLike(post.id, post.likedBy),
          onBookmarkPressed: () {
            postService.toggleBookmark(post.id, post.savedBy);

            // Opsional: Tampilkan snackbar
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isBookmarked ? "Removed from Collection" : "Saved to Collection"),
                duration: const Duration(milliseconds: 500),
              ),
            );
          },
        );
        },
    );
  }
}