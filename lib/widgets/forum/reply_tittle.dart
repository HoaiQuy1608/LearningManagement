import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reply_model.dart';
import '../../providers/auth_provider.dart';
import '../../service/comment_service.dart';

class ReplyTile extends ConsumerStatefulWidget {
  final Reply reply;
  final String postId;

  const ReplyTile({required this.reply, required this.postId, super.key});

  @override
  ConsumerState<ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends ConsumerState<ReplyTile> {
  late Reply reply;

  @override
  void initState() {
    super.initState();
    reply = widget.reply;
  }

  bool _isLiked(String userId) => reply.likes.contains(userId);

  void _toggleLike() async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;

    await CommentService().toggleLikeReply(
      widget.postId,
      reply.commentId,
      reply.replyId,
      authState.userId!,
    );

    setState(() {
      if (_isLiked(authState.userId!)) {
        reply.likes.remove(authState.userId);
      } else {
        reply.likes.add(authState.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      child: Card(
        color: Colors.grey[200],
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: reply.avatarUrl != null ? NetworkImage(reply.avatarUrl!) : null,
            child: reply.avatarUrl == null
                ? Text(reply.authorName.isNotEmpty ? reply.authorName[0] : "U")
                : null,
          ),
          title: Text(reply.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reply.content),
              const SizedBox(height: 4),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      _isLiked(authState.userId ?? "") ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: _isLiked(authState.userId ?? "") ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text("${reply.likes.length}", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Text("${reply.createdAt.hour}:${reply.createdAt.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
