import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/service/like_service.dart';
import 'auth_provider.dart';

// State để hiển thị like
class LikeState {
  final int likesCount;
  final bool isLikedByUser;
  LikeState({required this.likesCount, required this.isLikedByUser});
}

// StreamProvider để lắng nghe realtime
final likeProvider = StreamProvider.family<LikeState, String>((ref, postId) {
  final likeService = LikeService();
  final currentUser = ref.watch(authProvider);

  return likeService.streamLikes(postId).map((likesMap) {
    final likesCount = likesMap.length;
    final isLikedByUser = currentUser.userId != null && likesMap.containsKey(currentUser.userId);
    return LikeState(likesCount: likesCount, isLikedByUser: isLikedByUser);
  });
});

// Provider để toggle like
final likeNotifierProvider = Provider.family<LikeNotifier, String>((ref, postId) {
  return LikeNotifier(postId, ref, LikeService());
});

class LikeNotifier {
  final String postId;
  final Ref ref;
  final LikeService service;

  LikeNotifier(this.postId, this.ref, this.service);

  Future<void> toggleLike() async {
    final currentUser = ref.read(authProvider);
    if (currentUser.userId == null) return;

    await service.toggleLike(postId, currentUser.userId!);
  }
}
