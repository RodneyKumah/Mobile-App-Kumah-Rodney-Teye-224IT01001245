import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product; // null = add mode, non-null = edit mode

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

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController     = TextEditingController(text: p?.name ?? '');
    _codeController     = TextEditingController(text: p?.code ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _quantityController = TextEditingController(text: p?.quantity.toString() ?? '0');
    _priceController    = TextEditingController(text: p?.unitPrice.toString() ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id:        widget.product?.id,
      name:      _nameController.text.trim(),
      code:      _codeController.text.trim(),
      category:  _categoryController.text.trim(),
      quantity:  int.parse(_quantityController.text.trim()),
      unitPrice: double.parse(_priceController.text.trim()),
    );

    if (_isEditMode) {
      await DatabaseHelper.instance.updateProduct(product);
    } else {
      await DatabaseHelper.instance.insertProduct(product);
    }

    if (mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController,     'Product Name',  Icons.label_outline),
              _buildField(_codeController,     'Product Code',  Icons.qr_code),
              _buildField(_categoryController, 'Category',      Icons.category_outlined),
              _buildField(_quantityController, 'Initial Quantity', Icons.numbers,
                  keyboardType: TextInputType.number),
              _buildField(_priceController,    'Unit Price',    Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(_isEditMode ? Icons.save : Icons.add),
                  label: Text(_isEditMode ? 'Save Changes' : 'Add Product'),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
