import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  final db = FirestoreService();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: db.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int totalQty = 0;
          int lowStock = 0;

          for (var d in docs) {
            final data = d.data();
            int qty = data['quantity'] ?? 0;

            totalQty += qty;

            if (qty <= 5) {
              lowStock++;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Inventory Overview",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text("Total Stock: $totalQty",
                          style: const TextStyle(fontSize: 18)),
                      Text("Low Stock Items: $lowStock",
                          style: const TextStyle(fontSize: 18, color: Colors.red)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalQty.toDouble(),
                          title: "Stock",
                          color: Colors.green,
                        ),
                        PieChartSectionData(
                          value: lowStock.toDouble(),
                          title: "Low",
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}