import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  User get user => FirebaseAuth.instance.currentUser!;

  
  Future<void> addProduct({
    required String name,
    required String code,
    required String category,
    required int qty,
    required double price,
  }) async {
    await db.collection('products').add({
      'name': name,
      'code': code,
      'category': category,
      'quantity': qty,
      'price': price,
      'userId': user.uid,
    });
  }

  
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await db.collection('products').doc(id).update(data);
  }

  
  Future<void> deleteProduct(String id) async {
    await db.collection('products').doc(id).delete();
  }

  
  Future<void> stockIn(String id, int qty) async {
    final doc = await db.collection('products').doc(id).get();
    final data = doc.data() as Map<String, dynamic>;

    int current = data['quantity'] ?? 0;

    await db.collection('products').doc(id).update({
      'quantity': current + qty,
    });
  }

  
  Future<void> stockOut(String id, int qty) async {
    final doc = await db.collection('products').doc(id).get();
    final data = doc.data() as Map<String, dynamic>;

    int current = data['quantity'] ?? 0;

    if (qty > current) {
      throw Exception("Not enough stock");
    }

    await db.collection('products').doc(id).update({
      'quantity': current - qty,
    });
  }

  
  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return db
        .collection('products')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }
}