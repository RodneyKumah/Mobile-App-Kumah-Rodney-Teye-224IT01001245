import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stock_badge.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() { _products = products; _isLoading = false; });
  }

  int get _totalProducts => _products.length;
  int get _totalItems    => _products.fold(0, (sum, p) => sum + p.quantity);
  double get _totalValue => _products.fold(0.0, (sum, p) => sum + p.quantity * p.unitPrice);
  int get _lowStockCount => _products.where((p) => p.quantity < AppConstants.lowStockThreshold).length;
  int get _outOfStock    => _products.where((p) => p.quantity == 0).length;

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
                    // Stats grid
                    Row(children: [
                      _StatCard('Total Products', '$_totalProducts', Icons.category,        AppTheme.primary),
                      _StatCard('Total Units',    '$_totalItems',    Icons.inventory,        AppTheme.accent),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _StatCard('Stock Value',  '${AppConstants.currency} ${_totalValue.toStringAsFixed(2)}',
                          Icons.attach_money, AppTheme.success),
                      _StatCard('Low / Empty',  '$_lowStockCount / $_outOfStock',
                          Icons.warning_amber, AppTheme.danger),
                    ]),
                    const SizedBox(height: 24),

                    // Product stock table
                    const Text('All Products',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    if (_products.isEmpty)
                      const Center(child: Text('No products yet.', style: TextStyle(color: Colors.grey)))
                    else
                      ..._products.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(p.name[0].toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(p.name),
                            subtitle: Text(
                                '${p.category}  •  ${AppConstants.currency} ${p.unitPrice.toStringAsFixed(2)} / unit'),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
