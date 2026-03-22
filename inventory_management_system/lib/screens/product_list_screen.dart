import 'package:flutter/material.dart';
import 'add_edit_product_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'summary_screen.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Summary button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Summary',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text('No products yet.\nTap + to add one.',
                      textAlign: TextAlign.center),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final p = _products[index];
                    return _ProductCard(
                      product: p,
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditProductScreen(product: p),
                          ),
                        );
                        _loadProducts();
                      },
                      onDelete: () => _deleteProduct(p.id!),
                      onStockIn: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockInScreen(product: p),
                          ),
                        );
                        _loadProducts();
                      },
                      onStockOut: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockOutScreen(product: p),
                          ),
                        );
                        _loadProducts();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
          _loadProducts();
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Product Card Widget ───────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onStockIn,
    required this.onStockOut,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(product.name[0].toUpperCase()),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Code: ${product.code}  •  Category: ${product.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stock quantity chip
            Chip(
              label: Text('${product.quantity}'),
              backgroundColor: product.quantity > 0
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
                if (value == 'in') onStockIn();
                if (value == 'out') onStockOut();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'in',     child: Text('Stock In')),
                PopupMenuItem(value: 'out',    child: Text('Stock Out')),
                PopupMenuItem(value: 'edit',   child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
