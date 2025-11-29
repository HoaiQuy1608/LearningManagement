import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reply_model.dart';
import '../service/comment_service.dart';

final replyProvider = StreamProvider.family<List<Reply>, Map<String,String>>(
  (ref, params) {
    final service = CommentService();
    return service.replyStream(params['postId']!, params['commentId']!);
  },
);
