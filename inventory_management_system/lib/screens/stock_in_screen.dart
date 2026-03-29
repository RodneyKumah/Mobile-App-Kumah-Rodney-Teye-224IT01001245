import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';

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
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final qty = int.parse(_quantityController.text.trim());
    await DatabaseHelper.instance.recordStockIn(
      widget.product.id!,
      qty,
      _noteController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('+$qty units added to ${widget.product.name}'),
        backgroundColor: AppTheme.success,
      ));
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
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: AppTheme.success),
                  title: Text(widget.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Current Stock: ${widget.product.quantity} units'),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Add',
                  prefixIcon: Icon(Icons.add_box_outlined),
                ),
                validator: Validators.positiveInt,
              ),
              const SizedBox(height: 14),

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
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_downward, color: Colors.white),
                  label: const Text('Confirm Stock In', style: TextStyle(color: Colors.white)),
                  onPressed: _isSaving ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
