import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stock_badge.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<Product> _products = [];
  List<Map<String, dynamic>> _categoryStats = [];
  int _todayTxCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final products      = await DatabaseHelper.instance.getAllProducts();
    final categoryStats = await DatabaseHelper.instance.getCategorySummary();
    final todayCount    = await DatabaseHelper.instance
        .getTodayTransactionCount(DateHelper.todayPrefix());

    setState(() {
      _products      = products;
      _categoryStats = categoryStats;
      _todayTxCount  = todayCount;
      _isLoading     = false;
    });
  }

  int    get _totalProducts => _products.length;
  int    get _totalItems    => _products.fold(0, (s, p) => s + p.quantity);
  double get _totalValue    =>
      _products.fold(0.0, (s, p) => s + p.quantity * p.unitPrice);
  int    get _lowStock      =>
      _products.where((p) => p.quantity < AppConstants.lowStockThreshold && p.quantity > 0).length;
  int    get _outOfStock    => _products.where((p) => p.quantity == 0).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Summary')),
      drawer: const AppDrawer(currentRoute: 'summary'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top stats grid ───────────────────────────
                    Row(children: [
                      _StatCard('Products',   '$_totalProducts',
                          Icons.category,      AppTheme.primary),
                      _StatCard('Total Units', '$_totalItems',
                          Icons.inventory,     AppTheme.accent),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _StatCard(
                          'Stock Value',
                          '${AppConstants.currency} ${_totalValue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          AppTheme.success),
                      _StatCard(
                          'Low / Empty',
                          '$_lowStock / $_outOfStock',
                          Icons.warning_amber,
                          AppTheme.danger),
                    ]),
                    const SizedBox(height: 8),
                    // Today's activity card
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.today, color: AppTheme.primary),
                        title: const Text("Today's Transactions"),
                        trailing: Text(
                          '$_todayTxCount',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Category breakdown ───────────────────────
                    if (_categoryStats.isNotEmpty) ...[
                      const Text('By Category',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            // Header row
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100),
                              children: const [
                                _TH('Category'),
                                _TH('Items'),
                                _TH('Units'),
                                _TH('Value'),
                              ],
                            ),
                            ..._categoryStats.map((row) => TableRow(
                              children: [
                                _TD(row['category'] as String),
                                _TD('${row['product_count']}'),
                                _TD('${row['total_units']}'),
                                _TD('${AppConstants.currency} '
                                    '${(row['total_value'] as double).toStringAsFixed(2)}'),
                              ],
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── All products list ────────────────────────
                    const Text('All Products',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_products.isEmpty)
                      const Center(
                          child: Text('No products yet.',
                              style: TextStyle(color: Colors.grey)))
                    else
                      ..._products.map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(p.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(p.name),
                                subtitle: Text(
                                    '${p.category}  •  ${AppConstants.currency}'
                                    ' ${p.unitPrice.toStringAsFixed(2)} / unit'),
                                trailing: StockBadge(quantity: p.quantity),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color),
                textAlign: TextAlign.center),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// Table header & data cell helpers
class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12)),
      );
}

class _TD extends StatelessWidget {
  final String text;
  const _TD(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}
