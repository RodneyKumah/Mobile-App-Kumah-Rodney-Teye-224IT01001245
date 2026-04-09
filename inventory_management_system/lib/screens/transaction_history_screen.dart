import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Product product;
  const TransactionHistoryScreen({super.key, required this.product});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<StockTransaction> _transactions = [];
  bool _isLoading = true;

  // Filter: 'ALL', 'IN', 'OUT'
  String _typeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance
        .getTransactionsForProduct(widget.product.id!);
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

  List<StockTransaction> get _filtered {
    if (_typeFilter == 'ALL') return _transactions;
    return _transactions.where((t) => t.type == _typeFilter).toList();
  }

  int get _totalIn  => _transactions
      .where((t) => t.type == 'IN')
      .fold(0, (s, t) => s + t.quantity);
  int get _totalOut => _transactions
      .where((t) => t.type == 'OUT')
      .fold(0, (s, t) => s + t.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.product.name} — History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Stats row ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _StatChip(
                          label: 'Total In',
                          value: '+$_totalIn',
                          color: AppTheme.success),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: 'Total Out',
                          value: '-$_totalOut',
                          color: AppTheme.danger),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: 'Current',
                          value: '${widget.product.quantity}',
                          color: AppTheme.primary),
                    ],
                  ),
                ),

                // ── Type filter ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: ['ALL', 'IN', 'OUT'].map((type) {
                      final selected = _typeFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _typeFilter = type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Transaction list ─────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text('No transactions found.',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final tx = _filtered[i];
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
                                title: Text(
                                  '${isIn ? '+' : '-'}${tx.quantity} units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIn
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(DateHelper.format(tx.date),
                                        style: const TextStyle(fontSize: 12)),
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
              ],
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
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
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text(label,
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
