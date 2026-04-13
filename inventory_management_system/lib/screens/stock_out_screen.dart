import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class StockOutScreen extends StatelessWidget {
  final String id;
  StockOutScreen(this.id);

  final qty = TextEditingController();
  final db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock Out")),
      body: Column(
        children: [
          TextField(controller: qty),
          ElevatedButton(
            onPressed: () async {
              try {
                await db.stockOut(id, int.parse(qty.text));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Remove"),
          )
        ],
      ),
    );
  }
}