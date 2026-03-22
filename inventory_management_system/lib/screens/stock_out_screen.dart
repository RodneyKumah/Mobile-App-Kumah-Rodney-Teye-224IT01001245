import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class StockOutScreen extends StatefulWidget {
  final Product product;
  const StockOutScreen({super.key, required this.product});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController     = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.parse(_quantityController.text.trim());

    // New Quantity = Current Quantity – Issued Quantity
    final success = await DatabaseHelper.instance.recordStockOut(
      widget.product.id!,
      qty,
      _noteController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('-$qty units issued from ${widget.product.name}'),
          backgroundColor: AppTheme.danger,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough stock to issue that quantity.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Out')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info card
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.outbox, color: AppTheme.danger),
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
                  labelText: 'Quantity to Issue',
                  prefixIcon: Icon(Icons.remove_circle_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  final qty = int.tryParse(v);
                  if (qty == null || qty <= 0) return 'Enter a valid quantity';
                  if (qty > widget.product.quantity) {
                    return 'Cannot issue more than current stock (${widget.product.quantity})';
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Confirm Stock Out'),
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
