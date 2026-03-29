import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../utils/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Product product;

  const TransactionHistoryScreen({super.key, required this.product});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<StockTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getTransactionsForProduct(widget.product.id!);
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.product.name} — History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(
                  child: Text('No transactions recorded yet.',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final tx = _transactions[index];
                    final isIn = tx.type == 'IN';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isIn ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIn ? AppTheme.success : AppTheme.danger,
                          ),
                        ),
                        title: Text(
                          '${isIn ? '+' : '-'}${tx.quantity} units  (${tx.type})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIn ? AppTheme.success : AppTheme.danger,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(tx.date)),
                            if (tx.note != null && tx.note!.isNotEmpty)
                              Text('Note: ${tx.note}',
                                  style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        isThreeLine: tx.note != null && tx.note!.isNotEmpty,
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
