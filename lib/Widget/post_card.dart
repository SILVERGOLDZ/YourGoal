import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String user;
  final String text;
  final int likeCount;        // Ubah dari 'like' menjadi 'likeCount'
  final bool isLiked;         // Status apakah user sudah like post ini
  final bool isBookmarked; // <-- TAMBAHAN BARU
  final VoidCallback onLikePressed;      // Fungsi ketika tombol like ditekan
  final VoidCallback onBookmarkPressed;  // Fungsi ketika tombol bookmark ditekan
  final String? image;
  final double screenwidth;

  const PostCard({
    super.key,
    required this.user,
    required this.text,
    required this.likeCount,
    required this.isLiked,
    required this.isBookmarked, // <-- WAJIB DIISI
    required this.onLikePressed,
    required this.onBookmarkPressed,
    this.image,
    required this.screenwidth,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenwidth < 768;

    return Card.filled(
      color: const Color(0xFFFFFFFF),
      // elevation: 2, // Uncomment jika ingin ada bayangan
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Profile Row ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  // Ganti dengan NetworkImage jika nanti sudah ada foto profil user
                  backgroundImage: AssetImage('assets/images/default_profile.png'),
                  backgroundColor: Colors.grey, // Warna cadangan
                ),
                const SizedBox(width: 10),
                Text(
                  user,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- 2. Post Text ---
            Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 30),

            // --- 3. Image Section (Logic Mobile vs Web) ---
            if (image != null) ...[
              if (isMobile)
                Image.asset(image!, width: double.infinity)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Image.asset(image!),
                ),
              const SizedBox(height: 30),
            ],

            // --- 4. Bottom Icons (Action Buttons) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Group Tombol Like
                  Row(
                    children: [
                      // Menggunakan IconButton agar bisa diklik
                      InkWell(
                        onTap: onLikePressed,
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                            size: 24,
                            color: isLiked ? Colors.blue : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$likeCount',
                        style: TextStyle(
                          color: isLiked ? Colors.blue : Colors.black,
                          fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  // Tombol Bookmark
                  IconButton(
                      onPressed: onBookmarkPressed,
                      // Jika isBookmarked = true, icon penuh (saved). Jika tidak, border saja.
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 24,
                        color: isBookmarked ? Colors.black : Colors.grey[700],
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}