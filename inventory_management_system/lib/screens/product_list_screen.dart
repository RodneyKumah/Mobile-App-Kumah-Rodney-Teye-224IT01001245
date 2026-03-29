import 'package:flutter/material.dart';
import 'add_edit_product_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'summary_screen.dart';
import 'transaction_history_screen.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stock_badge.dart';
import '../widgets/confirm_dialog.dart';

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
    setState(() { _products = products; _isLoading = false; });
  }

  Future<void> _deleteProduct(Product p) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Product',
      message: 'Delete "${p.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await DatabaseHelper.instance.deleteProduct(p.id!);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Summary',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            ).then((_) => _loadProducts()),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'products'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No products yet.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                        ).then((_) => _loadProducts()),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final p = _products[index];
                      return _ProductCard(
                        product: p,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddEditProductScreen(product: p)),
                        ).then((_) => _loadProducts()),
                        onDelete: () => _deleteProduct(p),
                        onStockIn: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StockInScreen(product: p)),
                        ).then((_) => _loadProducts()),
                        onStockOut: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StockOutScreen(product: p)),
                        ).then((_) => _loadProducts()),
                        onHistory: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TransactionHistoryScreen(product: p)),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ).then((_) => _loadProducts()),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onHistory;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onStockIn,
    required this.onStockOut,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(product.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${product.code}  •  ${product.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StockBadge(quantity: product.quantity),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'in':      onStockIn();  break;
                  case 'out':     onStockOut(); break;
                  case 'history': onHistory();  break;
                  case 'edit':    onEdit();     break;
                  case 'delete':  onDelete();   break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'in',      child: ListTile(leading: Icon(Icons.arrow_downward, color: Colors.green), title: Text('Stock In'))),
                PopupMenuItem(value: 'out',     child: ListTile(leading: Icon(Icons.arrow_upward,   color: Colors.red),   title: Text('Stock Out'))),
                PopupMenuItem(value: 'history', child: ListTile(leading: Icon(Icons.history),        title: Text('History'))),
                PopupMenuDivider(),
                PopupMenuItem(value: 'edit',    child: ListTile(leading: Icon(Icons.edit),           title: Text('Edit'))),
                PopupMenuItem(value: 'delete',  child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
