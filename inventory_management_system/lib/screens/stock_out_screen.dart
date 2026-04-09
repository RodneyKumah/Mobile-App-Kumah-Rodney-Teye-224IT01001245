import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';

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
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.parse(_quantityController.text.trim());
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Confirm Stock Out',
      message: 'Issue $qty unit(s) of "${widget.product.name}"?',
      confirmLabel: 'Issue',
      confirmColor: AppTheme.danger,
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    final success = await DatabaseHelper.instance.recordStockOut(
        widget.product.id!, qty, _noteController.text.trim());

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('-$qty units issued from ${widget.product.name}'),
        backgroundColor: AppTheme.danger,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Not enough stock to issue that quantity.'),
        backgroundColor: Colors.orange,
      ));
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
            children: [
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.outbox, color: AppTheme.danger),
                  title: Text(widget.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Current Stock: ${widget.product.quantity} units'),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Issue',
                  prefixIcon: Icon(Icons.remove_circle_outline),
                ),
                validator: (v) =>
                    Validators.notExceedStock(v, widget.product.quantity),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_upward, color: Colors.white),
                  label: const Text('Confirm Stock Out',
                      style: TextStyle(color: Colors.white)),
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
