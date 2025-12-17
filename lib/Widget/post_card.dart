import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String user;
  final String text;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLikePressed;
  final VoidCallback? onUserTap;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onTap; // <--- Tambahkan ini
  final Widget? sharedContent; // <--- Tambahkan ini untuk UI Roadmap
  final String? image;
  final double screenwidth;
  final VoidCallback onBookmarkPressed;

  const PostCard({
    super.key,
    required this.user,
    required this.text,
    required this.likeCount,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLikePressed,
    required this.onBookmarkPressed,
    this.onUserTap,
    this.onTap, // <--- Masukkan ke constructor
    this.sharedContent, // <--- Masukkan ke constructor
    this.image,
    this.onDeletePressed,
    required this.screenwidth,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenwidth < 768;

    return Card.filled(
      color: const Color(0xFFFFFFFF),
      clipBehavior: Clip.antiAlias, // Agar efek splash InkWell rapi
      child: InkWell( // <--- Bungkus dengan InkWell agar kartu bisa diklik
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Profile Row ---
              GestureDetector(
                onTap: onUserTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/default_profile.png'),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    if (onDeletePressed != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        onPressed: onDeletePressed,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // --- 2. Post Text ---
              Text(text, style: const TextStyle(fontSize: 15)),

              // --- TAMBAHAN: Shared Roadmap UI ---
              if (sharedContent != null) ...[
                const SizedBox(height: 12),
                sharedContent!,
              ],

              const SizedBox(height: 20),

              // --- 3. Image Section ---
              if (image != null) ...[
                // ... (tetap sama seperti kode lama Anda)
                const SizedBox(height: 30),
              ],

              // --- 4. Bottom Icons ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
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
                        Text('$likeCount', style: TextStyle(color: isLiked ? Colors.blue : Colors.black)),
                      ],
                    ),
                    IconButton(
                      onPressed: onBookmarkPressed,
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
      ),
    );
  }
}