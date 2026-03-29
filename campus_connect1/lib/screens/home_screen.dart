import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quoteVm = Provider.of<QuoteViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final email = authVm.user?.email ?? '';
    final firstName = email.isNotEmpty ? email.split('@')[0] : 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $firstName 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'What\'s happening on campus today?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quote card
            const Text(
              '💡 Quote of the Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (quoteVm.isLoading)
                      const CircularProgressIndicator(color: Color(0xFF1565C0))
                    else if (quoteVm.errorMessage != null)
                      const Text('Failed to load quote', style: TextStyle(color: Colors.grey))
                    else ...[
                      const Icon(Icons.format_quote, color: Color(0xFF42A5F5), size: 30),
                      const SizedBox(height: 8),
                      Text(
                        quoteVm.currentQuote?.text ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF37474F),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${quoteVm.currentQuote?.author ?? ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => quoteVm.loadRandomQuote(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('New Quote'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          side: const BorderSide(color: Color(0xFF1565C0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              '🚀 Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.event,
                    label: 'View Events',
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventListScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.person,
                    label: 'My Profile',
                    color: const Color(0xFF42A5F5),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
