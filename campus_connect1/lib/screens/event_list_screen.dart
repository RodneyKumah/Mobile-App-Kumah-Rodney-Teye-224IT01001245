import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'add_event_screen.dart';
import 'comment_screen.dart';


class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}


class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventViewModel>(context, listen: false).listenToEvents();
  }


  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final userId = Provider.of<AuthViewModel>(context, listen: false).user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: eventVm.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : eventVm.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                      const SizedBox(height: 12),
                      Text(eventVm.errorMessage!, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : eventVm.events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 60, color: Color(0xFFBBDEFB)),
                          SizedBox(height: 12),
                          Text('No events yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text('Tap + to add the first event', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: eventVm.events.length,
                      itemBuilder: (context, index) {
                        final event = eventVm.events[index];
                        final isLiked = event.likes.contains(userId);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1565C0),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDate(event.date),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              // Body
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.description,
                                      style: const TextStyle(color: Color(0xFF546E7A), fontSize: 14, height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        // Like button
                                        GestureDetector(
                                          onTap: () => eventVm.toggleLike(event.id, userId),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isLiked ? Colors.red.shade50 : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isLiked ? Colors.red.shade200 : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${event.likes.length}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Comment button
                                        GestureDetector(
                                          onTap: () => Navigator.push(context, MaterialPageRoute(
                                            builder: (_) => CommentScreen(event: event),
                                          )),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: const Color(0xFFBBDEFB)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.comment_outlined, color: Color(0xFF1565C0), size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${event.comments.length}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1565C0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }


  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
