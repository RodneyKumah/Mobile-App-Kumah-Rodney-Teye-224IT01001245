import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../database/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../widgets/stock_badge.dart';
import 'add_edit_product_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'transaction_history_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  List<StockTransaction> _recentTx = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    // Reload product to get latest quantity
    final all = await DatabaseHelper.instance.getAllProducts();
    final updated = all.firstWhere((p) => p.id == _product.id,
        orElse: () => _product);
    final txList =
        await DatabaseHelper.instance.getTransactionsForProduct(_product.id!);
    setState(() {
      _product  = updated;
      _recentTx = txList.take(5).toList(); // show last 5
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(product: _product)),
            ).then((_) => _load()),
          ),
        ],
      ),
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
                    // ── Product info card ─────────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    _product.name[0].toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_product.name,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text(_product.category,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                StockBadge(quantity: _product.quantity),
                              ],
                            ),
                            const Divider(height: 24),
                            _InfoRow('Product Code', _product.code),
                            _InfoRow('Category',     _product.category),
                            _InfoRow('Unit Price',
                                '${AppConstants.currency} ${_product.unitPrice.toStringAsFixed(2)}'),
                            _InfoRow('In Stock',     '${_product.quantity} units'),
                            _InfoRow('Stock Value',
                                '${AppConstants.currency} '
                                '${(_product.quantity * _product.unitPrice).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Action buttons ────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success),
                            icon: const Icon(Icons.arrow_downward,
                                color: Colors.white),
                            label: const Text('Stock In',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      StockInScreen(product: _product)),
                            ).then((_) => _load()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.danger),
                            icon: const Icon(Icons.arrow_upward,
                                color: Colors.white),
                            label: const Text('Stock Out',
                                style: TextStyle(color: Colors.white)),
                            onPressed: _product.quantity == 0
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              StockOutScreen(product: _product)),
                                    ).then((_) => _load()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Recent transactions ───────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Transactions',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TransactionHistoryScreen(product: _product)),
                          ),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (_recentTx.isEmpty)
                      const Text('No transactions yet.',
                          style: TextStyle(color: Colors.grey))
                    else
                      ..._recentTx.map((tx) {
                        final isIn = tx.type == 'IN';
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIn ? AppTheme.success : AppTheme.danger,
                            size: 18,
                          ),
                          title: Text(
                            '${isIn ? '+' : '-'}${tx.quantity} units',
                            style: TextStyle(
                                color:
                                    isIn ? AppTheme.success : AppTheme.danger,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(DateHelper.shortDate(tx.date),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
