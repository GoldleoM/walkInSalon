import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/models/post_model.dart';
import 'package:walkinsalonapp/services/post_service.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService();
});

final explorePostsProvider = StreamProvider<List<PostModel>>((ref) {
  final postService = ref.read(postServiceProvider);
  return postService.getPosts();
});
