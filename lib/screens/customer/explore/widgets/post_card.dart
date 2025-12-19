import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/post_model.dart';
import 'package:walkinsalonapp/services/post_service.dart';
import 'package:walkinsalonapp/widgets/dialogs/comments_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onSalonTap;

  const PostCard({super.key, required this.post, required this.onSalonTap});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLiked = user != null && post.likes.contains(user.uid);
    // Background should be black for immersive media

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // 1. Full Screen Image
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: () => PostService().likePost(post.id),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withValues(alpha: 0.5),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Gradient Overlay (Bottom) for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Right Side Actions
          Positioned(
            right: 16,
            bottom: 100, // Above bottom nav height approx
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  context,
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  label: '${post.likes.length}',
                  onTap: () => PostService().likePost(post.id),
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  context,
                  icon: Icons.mode_comment_outlined,
                  color: Colors.white,
                  label: 'Comment',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: CommentsSheet(postId: post.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  color: Colors.white,
                  label: 'Share',
                  onTap: () => PostService().sharePost(post),
                ),
              ],
            ),
          ),

          // 4. Bottom Information (Salon & Description)
          Positioned(
            left: 16,
            right: 80, // Leave space for action buttons
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onSalonTap,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Text(
                          post.salonName.isNotEmpty
                              ? post.salonName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          post.salonName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Checkmark or similar?
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (post.description.isNotEmpty)
                  Text(
                    post.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (post.salonLocation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.salonLocation,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Back Button / App Bar overlay is handled by Scaffold in ExploreScreen?
          // ExploreScreen has an AppBar, we might want to extendBodyBehindAppBar there too
          // but for now this fits _under_ the app bar.
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(
                alpha: 0.2,
              ), // Slight background for contrast
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
