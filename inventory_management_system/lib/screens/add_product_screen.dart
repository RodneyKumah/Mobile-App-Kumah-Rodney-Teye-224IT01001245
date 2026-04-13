import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'barcode_scanner_screen.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final name = TextEditingController();
  final code = TextEditingController();
  final category = TextEditingController();
  final qty = TextEditingController();
  final price = TextEditingController();

  final db = FirestoreService();

  bool loading = false;

  void save() async {
    setState(() => loading = true);

    try {
      
      if (name.text.trim().isEmpty ||
          category.text.trim().isEmpty ||
          qty.text.trim().isEmpty ||
          price.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        setState(() => loading = false);
        return;
      }

      await db.addProduct(
        name: name.text.trim(),
        code: code.text.trim(), 
        category: category.text.trim(),
        qty: int.parse(qty.text.trim()),
        price: double.parse(price.text.trim()),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  void scanBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeScannerScreen(
          onScan: (value) {
            setState(() {
              code.text = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(name, "Product Name"),
            const SizedBox(height: 10),

            buildField(category, "Category"),
            const SizedBox(height: 10),

            buildField(qty, "Quantity", number: true),
            const SizedBox(height: 10),

            buildField(price, "Price", number: true),
            const SizedBox(height: 10),

            // BARCODE (OPTIONAL)
            TextField(
              controller: code,
              decoration: InputDecoration(
                labelText: "Barcode (Optional)",
                prefixIcon: const Icon(Icons.qr_code),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan Barcode"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE PRODUCT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}