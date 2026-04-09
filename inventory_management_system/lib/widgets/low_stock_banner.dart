import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Shows a dismissible warning banner when products are low or out of stock.
class LowStockBanner extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onDismiss;

  const LowStockBanner({
    super.key,
    required this.products,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = products.where((p) => p.quantity == 0).toList();
    final lowStock   = products
        .where((p) => p.quantity > 0 && p.quantity < AppConstants.lowStockThreshold)
        .toList();

    if (outOfStock.isEmpty && lowStock.isEmpty) return const SizedBox.shrink();

    final lines = <String>[];
    if (outOfStock.isNotEmpty) {
      lines.add('Out of stock: ${outOfStock.map((p) => p.name).join(', ')}');
    }
    if (lowStock.isNotEmpty) {
      lines.add('Low stock: ${lowStock.map((p) => '${p.name} (${p.quantity})').join(', ')}');
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stock Alert',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.warning)),
                const SizedBox(height: 2),
                ...lines.map((l) => Text(l,
                    style: TextStyle(
                        fontSize: 12, color: Colors.orange.shade900))),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 18, color: Colors.orange.shade600),
          ),
        ],
      ),
    );
  }
}
