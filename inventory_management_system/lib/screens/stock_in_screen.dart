import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class StockInScreen extends StatelessWidget {
  final String id;
  StockInScreen(this.id);

  final qty = TextEditingController();
  final db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock In")),
      body: Column(
        children: [
          TextField(controller: qty),
          ElevatedButton(
            onPressed: () {
              db.stockIn(id, int.parse(qty.text));
              Navigator.pop(context);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }
}