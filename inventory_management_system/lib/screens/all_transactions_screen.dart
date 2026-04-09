import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/stock_transaction.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../widgets/app_drawer.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List<StockTransaction> _transactions = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String _typeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    final products     = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _transactions = transactions;
      _products     = products;
      _isLoading    = false;
    });
  }

  String _productName(int productId) {
    try {
      return _products.firstWhere((p) => p.id == productId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  List<StockTransaction> get _filtered {
    if (_typeFilter == 'ALL') return _transactions;
    return _transactions.where((t) => t.type == _typeFilter).toList();
  }

  int get _totalIn  => _filtered
      .where((t) => t.type == 'IN')
      .fold(0, (s, t) => s + t.quantity);
  int get _totalOut => _filtered
      .where((t) => t.type == 'OUT')
      .fold(0, (s, t) => s + t.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      drawer: const AppDrawer(currentRoute: 'transactions'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Summary chips ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      _SummaryChip(
                          label: 'Total In',
                          value: '+$_totalIn',
                          color: AppTheme.success),
                      const SizedBox(width: 8),
                      _SummaryChip(
                          label: 'Total Out',
                          value: '-$_totalOut',
                          color: AppTheme.danger),
                      const SizedBox(width: 8),
                      _SummaryChip(
                          label: 'Records',
                          value: '${_filtered.length}',
                          color: AppTheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Type filter chips ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: ['ALL', 'IN', 'OUT'].map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: _typeFilter == type,
                          onSelected: (_) =>
                              setState(() => _typeFilter = type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Transaction list ──────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text('No transactions yet.',
                              style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (_, i) {
                              final tx   = _filtered[i];
                              final isIn = tx.type == 'IN';
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isIn
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    child: Icon(
                                      isIn
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: isIn
                                          ? AppTheme.success
                                          : AppTheme.danger,
                                      size: 18,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        '${isIn ? '+' : '-'}${tx.quantity} units',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isIn
                                              ? AppTheme.success
                                              : AppTheme.danger,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _productName(tx.productId),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(DateHelper.format(tx.date),
                                          style:
                                              const TextStyle(fontSize: 12)),
                                      if (tx.note != null &&
                                          tx.note!.isNotEmpty)
                                        Text('Note: ${tx.note}',
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 12)),
                                    ],
                                  ),
                                  isThreeLine: tx.note != null &&
                                      tx.note!.isNotEmpty,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ]),
      ),
    );
  }
}
