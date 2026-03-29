import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';

class StockBadge extends StatelessWidget {
  final int quantity;

  const StockBadge({super.key, required this.quantity});

  bool get _isLow => quantity < AppConstants.lowStockThreshold;
  bool get _isEmpty => quantity == 0;

  Color get _bgColor {
    if (_isEmpty) return Colors.red.shade200;
    if (_isLow) return Colors.orange.shade100;
    return Colors.green.shade100;
  }

  Color get _textColor {
    if (_isEmpty) return AppTheme.danger;
    if (_isLow) return Colors.orange.shade800;
    return AppTheme.success;
  }

  String get _label {
    if (_isEmpty) return 'Out of stock';
    return '$quantity units';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
