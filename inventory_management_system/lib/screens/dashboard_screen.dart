import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_feed_tile.dart';
import '../widgets/low_stock_banner.dart';
import 'product_list_screen.dart';
import 'summary_screen.dart';
import 'all_transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<StockTransaction> _recentTx = [];
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final stats    = await DatabaseHelper.instance.getDashboardStats();
    final recent   = await DatabaseHelper.instance.getRecentTransactions(8);
    final products = await DatabaseHelper.instance.getAllProducts();
    final lowStock = products
        .where((p) => p.quantity < AppConstants.lowStockThreshold)
        .toList();

    setState(() {
      _stats            = stats;
      _recentTx         = recent;
      _products         = products;
      _lowStockProducts = lowStock;
      _isLoading        = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: AppDrawer(currentRoute: 'dashboard', username: widget.username),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Welcome banner ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${widget.username} 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateHelper.format(DateTime.now().toIso8601String()),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // ── Low stock banner ──────────────────────────
                    if (_showBanner && _lowStockProducts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: LowStockBanner(
                          products: _lowStockProducts,
                          onDismiss: () =>
                              setState(() => _showBanner = false),
                        ),
                      ),

                    // ── Stat cards ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                      child: Column(
                        children: [
                          Row(children: [
                            StatCard(
                              label: 'Products',
                              value: '${_stats['total_products'] ?? 0}',
                              icon: Icons.category_outlined,
                              color: AppTheme.primary,
                              onTap: () => _goTo(context, const ProductListScreen()),
                            ),
                            StatCard(
                              label: 'Total Units',
                              value: '${_stats['total_units'] ?? 0}',
                              icon: Icons.inventory_2_outlined,
                              color: AppTheme.accent,
                              onTap: () => _goTo(context, const SummaryScreen()),
                            ),
                          ]),
                          const SizedBox(height: 0),
                          Row(children: [
                            StatCard(
                              label: 'Stock Value',
                              value:
                                  '${AppConstants.currency} ${((_stats['total_value'] ?? 0.0) as double).toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              color: AppTheme.success,
                              onTap: () => _goTo(context, const SummaryScreen()),
                            ),
                            StatCard(
                              label: "Today's Moves",
                              value: '${_stats['today_tx'] ?? 0}',
                              icon: Icons.swap_vert,
                              color: Colors.purple,
                              onTap: () => _goTo(context, const AllTransactionsScreen()),
                            ),
                          ]),
                          const SizedBox(height: 0),
                          Row(children: [
                            StatCard(
                              label: 'Low Stock',
                              value: '${_stats['low_stock'] ?? 0}',
                              icon: Icons.warning_amber_outlined,
                              color: AppTheme.warning,
                            ),
                            StatCard(
                              label: 'Out of Stock',
                              value: '${_stats['out_of_stock'] ?? 0}',
                              icon: Icons.remove_shopping_cart_outlined,
                              color: AppTheme.danger,
                            ),
                          ]),
                        ],
                      ),
                    ),

                    // ── Quick actions ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Actions',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(children: [
                            _QuickAction(
                              icon: Icons.list_alt,
                              label: 'Products',
                              color: AppTheme.primary,
                              onTap: () => _goTo(context, const ProductListScreen()),
                            ),
                            _QuickAction(
                              icon: Icons.bar_chart,
                              label: 'Summary',
                              color: AppTheme.success,
                              onTap: () => _goTo(context, const SummaryScreen()),
                            ),
                            _QuickAction(
                              icon: Icons.history,
                              label: 'Transactions',
                              color: Colors.purple,
                              onTap: () => _goTo(context, const AllTransactionsScreen()),
                            ),
                          ]),
                        ],
                      ),
                    ),

                    // ── Recent activity ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Activity',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () =>
                                _goTo(context, const AllTransactionsScreen()),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                    if (_recentTx.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No transactions yet.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Card(
                          child: Column(
                            children: _recentTx
                                .map((tx) => ActivityFeedTile(
                                      transaction: tx,
                                      products: _products,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }
}

// ── Quick action button ───────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style:
                      TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
