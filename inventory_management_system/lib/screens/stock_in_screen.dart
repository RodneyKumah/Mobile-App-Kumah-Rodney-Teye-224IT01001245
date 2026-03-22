import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class StockInScreen extends StatefulWidget {
  final Product product;
  const StockInScreen({super.key, required this.product});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController     = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.parse(_quantityController.text.trim());

    // New Quantity = Current Quantity + Added Quantity
    await DatabaseHelper.instance.recordStockIn(
      widget.product.id!,
      qty,
      _noteController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$qty units added to ${widget.product.name}'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info card
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: AppTheme.success),
                  title: Text(widget.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Current Stock: ${widget.product.quantity}'),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity field
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Add',
                  prefixIcon: Icon(Icons.add_box_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Note field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Confirm Stock In'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
