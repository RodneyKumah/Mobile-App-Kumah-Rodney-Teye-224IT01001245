import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/validators.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  bool _isSaving = false;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController     = TextEditingController(text: p?.name ?? '');
    _codeController     = TextEditingController(text: p?.code ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _quantityController = TextEditingController(text: p != null ? p.quantity.toString() : '0');
    _priceController    = TextEditingController(text: p != null ? p.unitPrice.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = Product(
      id:        widget.product?.id,
      name:      _nameController.text.trim(),
      code:      _codeController.text.trim(),
      category:  _categoryController.text.trim(),
      quantity:  int.parse(_quantityController.text.trim()),
      unitPrice: double.parse(_priceController.text.trim()),
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateProduct(product);
      } else {
        await DatabaseHelper.instance.insertProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: product code may already exist.'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameController,     'Product Name',     Icons.label_outline),
              _field(_codeController,     'Product Code',     Icons.qr_code),
              _field(_categoryController, 'Category',         Icons.category_outlined),
              _field(_quantityController, 'Initial Quantity', Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: Validators.positiveInt),
              _field(_priceController,    'Unit Price (GHS)', Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.positiveDouble),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(_isEditMode ? Icons.save : Icons.add),
                  label: Text(_isEditMode ? 'Save Changes' : 'Add Product'),
                  onPressed: _isSaving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator ?? (v) => Validators.required(v, label),
      ),
    );
  }
}
