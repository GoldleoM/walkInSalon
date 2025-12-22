import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/providers/explore_provider.dart';
import 'package:walkinsalonapp/screens/customer/explore/feed_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  String _searchQuery = '';
  // "For You" is the default logical category, but we show chips
  String _selectedCategory = 'For You';
  final List<String> _categories = [
    'For You',
    'IGTV',
    'Shop',
    'Games',
    'Style',
    'Barber',
  ];

  @override
  Widget build(BuildContext context) {
    // Get posts
    final postsAsync = ref.watch(explorePostsProvider);

    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        toolbarHeight: 0, // Hide default toolbar
        elevation: 0,
        backgroundColor: AppConfig.adaptiveSurface(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: AppConfig.adaptiveSurface(context),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText:
                            'Suchen', // Matching screenshot language just for flavor or use 'Search'
                        hintStyle: TextStyle(
                          color: AppConfig.adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppConfig.adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.1),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.crop_free,
                    color: AppConfig.adaptiveTextColor(context),
                  ),
                ],
              ),
            ),

            // 2. Categories
            Container(
              height: 50,
              padding: const EdgeInsets.only(bottom: 8),
              color: AppConfig.adaptiveSurface(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  // In screenshot, chips are white/outlined.
                  // 'IGTV' has icon. 'Shop' has icon.
                  IconData? icon;
                  if (cat == 'IGTV') icon = Icons.tv;
                  if (cat == 'Shop') icon = Icons.shopping_bag;

                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors
                                  .black // Selected style
                            : Colors.transparent, // Unselected
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppConfig.adaptiveTextColor(context),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppConfig.adaptiveTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Grid
            Expanded(
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(child: Text("No posts found"));
                  }

                  // Use GridView.custom for advanced pattern or Quilted
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: GridView.custom(
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 3, // 3 columns
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: const [
                            // Pattern 1: Large item 2x2, two small items 1x1 stacked
                            QuiltedGridTile(2, 2),
                            QuiltedGridTile(1, 1),
                            QuiltedGridTile(1, 1),
                            // Pattern 2: Three small items row
                            QuiltedGridTile(1, 1),
                            QuiltedGridTile(1, 1),
                            QuiltedGridTile(1, 1),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          // Loop posts if not enough
                          final post = posts[index % posts.length];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedScreen(
                                    initialIndex:
                                        index %
                                        posts
                                            .length, // Ensure index is valid for list
                                    posts: posts,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  post.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                                ),
                                // Optional: Icon overlay for video/carousel?
                                if (index % 5 == 0) // Dummy logic
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.collections,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }, childCount: posts.isEmpty ? 0 : posts.length),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, s) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
