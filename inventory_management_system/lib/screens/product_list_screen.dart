import 'package:flutter/material.dart';
import 'add_edit_product_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'summary_screen.dart';
import 'transaction_history_screen.dart';
import 'product_detail_screen.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stock_badge.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/low_stock_banner.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  bool _showBanner = true;

  // Search & filter state
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => _load();

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final products = await DatabaseHelper.instance.searchProducts(
      query: _searchController.text,
      category: _selectedCategory,
    );

    final rawCategories = await DatabaseHelper.instance.getCategories();
    final categories = ['All', ...rawCategories];

    setState(() {
      _products = products;
      _categories = categories;
      _isLoading = false;
    });
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
      _load();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _selectedCategory = 'All');
    _load();
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()))
                .then((_) => _load()),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'products'),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or product code…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Category filter chips ──────────────────────────────
          if (_categories.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _load();
                    },
                  );
                },
              ),
            ),

          // ── Low stock banner ──────────────────────────────────
          if (_showBanner)
            LowStockBanner(
              products: _products,
              onDismiss: () => setState(() => _showBanner = false),
            ),

          // ── Product list ──────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isNotEmpty ||
                                      _selectedCategory != 'All'
                                  ? 'No products match your search.'
                                  : 'No products yet. Tap + to add one.',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchController.text.isNotEmpty ||
                                _selectedCategory != 'All') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                  onPressed: _clearSearch,
                                  child: const Text('Clear filters')),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final p = _products[index];
                            return _ProductCard(
                              product: p,
                              onEdit: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditProductScreen(product: p)))
                                  .then((_) => _load()),
                              onDelete: () => _deleteProduct(p),
                              onStockIn: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              StockInScreen(product: p)))
                                  .then((_) => _load()),
                              onStockOut: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              StockOutScreen(product: p)))
                                  .then((_) => _load()),
                              onHistory: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TransactionHistoryScreen(product: p))),
                              onDetail: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailScreen(product: p)))
                                  .then((_) => _load()),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()))
            .then((_) => _load()),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onHistory;
  final VoidCallback onDetail;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onStockIn,
    required this.onStockOut,
    required this.onHistory,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onDetail, // tap card to open detail screen
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(product.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${product.code}  •  ${product.category}  •  GHS ${product.unitPrice.toStringAsFixed(2)}'),
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
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'in',
                    child: ListTile(
                        leading: Icon(Icons.arrow_downward, color: Colors.green),
                        title: Text('Stock In'))),
                const PopupMenuItem(
                    value: 'out',
                    child: ListTile(
                        leading: Icon(Icons.arrow_upward, color: Colors.red),
                        title: Text('Stock Out'))),
                const PopupMenuItem(
                    value: 'history',
                    child: ListTile(
                        leading: Icon(Icons.history),
                        title: Text('History'))),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                        leading: Icon(Icons.edit), title: Text('Edit'))),
                const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
