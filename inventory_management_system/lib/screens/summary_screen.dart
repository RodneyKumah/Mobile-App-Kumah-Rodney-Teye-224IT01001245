import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

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
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  int get _totalProducts => _products.length;
  int get _totalItems    => _products.fold(0, (sum, p) => sum + p.quantity);
  double get _totalValue =>
      _products.fold(0, (sum, p) => sum + (p.quantity * p.unitPrice));
  int get _lowStockCount => _products.where((p) => p.quantity < 5).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Summary')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary cards row
                  Row(
                    children: [
                      _SummaryCard('Products',    '$_totalProducts', Icons.category,        AppTheme.primary),
                      _SummaryCard('Total Items', '$_totalItems',    Icons.inventory,        AppTheme.accent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SummaryCard('Total Value',      'GHS ${_totalValue.toStringAsFixed(2)}',
                          Icons.attach_money, AppTheme.success),
                      _SummaryCard('Low Stock', '$_lowStockCount products',
                          Icons.warning_amber,  AppTheme.danger),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stock level table
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Stock Levels',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  ..._products.map((p) => _StockRow(product: p)),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final Product product;
  const _StockRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final isLow = product.quantity < 5;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.category),
        trailing: Chip(
          label: Text('${product.quantity} units'),
          backgroundColor: isLow ? Colors.red.shade100 : Colors.green.shade100,
          labelStyle: TextStyle(
            color: isLow ? AppTheme.danger : AppTheme.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
