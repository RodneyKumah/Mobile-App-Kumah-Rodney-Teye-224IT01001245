import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  final dynamic product;
  EditProductScreen(this.product);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final db = FirestoreService();

  late TextEditingController name;
  late TextEditingController price;

  @override
  void initState() {
    super.initState();
    final data = widget.product.data();

    name = TextEditingController(text: data['name']);
    price = TextEditingController(text: data['price'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Column(
        children: [
          TextField(controller: name),
          TextField(controller: price),
          ElevatedButton(
            onPressed: () {
              db.updateProduct(widget.product.id, {
                'name': name.text,
                'price': double.parse(price.text),
              });

              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
}