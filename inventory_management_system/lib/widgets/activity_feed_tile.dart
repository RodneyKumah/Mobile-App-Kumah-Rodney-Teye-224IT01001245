import 'package:flutter/material.dart';
import '../models/stock_transaction.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';

/// A single row in the recent activity feed shown on the Dashboard.
class ActivityFeedTile extends StatelessWidget {
  final StockTransaction transaction;
  final List<Product> products;

  const ActivityFeedTile({
    super.key,
    required this.transaction,
    required this.products,
  });

  String get _productName {
    try {
      return products.firstWhere((p) => p.id == transaction.productId).name;
    } catch (_) {
      return 'Unknown product';
    }
  }

  bool get _isIn => transaction.type == 'IN';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor:
            _isIn ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          _isIn ? Icons.arrow_downward : Icons.arrow_upward,
          size: 14,
          color: _isIn ? AppTheme.success : AppTheme.danger,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
          children: [
            TextSpan(
              text: '${_isIn ? '+' : '-'}${transaction.quantity} units ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isIn ? AppTheme.success : AppTheme.danger,
              ),
            ),
            TextSpan(text: _productName),
          ],
        ),
      ),
      trailing: Text(
        DateHelper.shortDate(transaction.date),
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
