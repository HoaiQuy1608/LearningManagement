import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@immutable
class Post {
  final String title;
  final String author;
  final int replyCount;
  final int likeCount;

  const Post({
    required this.title,
    required this.author,
    this.replyCount = 0,
    this.likeCount = 0,
  });
}

@immutable
class ForumState {
  final List<Post> posts;
  final bool isLoading;

  const ForumState({this.posts = const [], this.isLoading = false});

  ForumState copyWith({List<Post>? posts, bool? isLoading}) {
    return ForumState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ForumProvider extends Notifier<ForumState> {
  @override
  ForumState build() {
    return const ForumState(
      posts: [
        Post(
          title: 'Hỏi về cách tính điểm Giá trị thặng dư?',
          author: 'SinhVienA',
          replyCount: 5,
          likeCount: 10,
        ),
        Post(
          title: 'Cần xin tài liệu Triết học (Bản full)',
          author: 'SinhVienB',
          replyCount: 2,
          likeCount: 8,
        ),
        Post(
          title: 'Flutter Riverpod 3.0 khó quá :(',
          author: 'SinhVienC',
          replyCount: 15,
          likeCount: 20,
        ),
      ],
    );
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String author,
  }) async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(seconds: 1));

    final newPost = Post(
      title: title,
      author: author,
      replyCount: 0,
      likeCount: 0,
    );

    state = state.copyWith(isLoading: false, posts: [newPost, ...state.posts]);
  }
}

final forumProvider = NotifierProvider<ForumProvider, ForumState>(() {
  return ForumProvider();
});
