import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';


class CommentScreen extends StatefulWidget {
  final Event event;
  CommentScreen({required this.event});


  @override
  _CommentScreenState createState() => _CommentScreenState();
}


class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final user = Provider.of<AuthViewModel>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          // Comment count banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE3F2FD),
            child: Text(
              '${widget.event.comments.length} Comment${widget.event.comments.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          // Comments list
          Expanded(
            child: widget.event.comments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 50, color: Color(0xFFBBDEFB)),
                        SizedBox(height: 10),
                        Text('No comments yet', style: TextStyle(color: Colors.grey, fontSize: 15)),
                        Text('Be the first to comment!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.event.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.event.comments[index];
                      final isMe = comment.userId == user?.uid;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF1565C0) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'You' : comment.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isMe ? Colors.white70 : const Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isMe ? Colors.white : const Color(0xFF37474F),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(comment.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE3F2FD), width: 1.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF0F4FF),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      if (user == null || _commentController.text.trim().isEmpty) return;
                      final comment = Comment(
                        userId: user.uid,
                        userName: user.email ?? 'User',
                        text: _commentController.text.trim(),
                        timestamp: DateTime.now(),
                      );
                      await eventVm.addComment(widget.event.id, comment);
                      _commentController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1565C0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
