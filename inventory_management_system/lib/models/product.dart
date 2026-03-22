// Model representing a product in the inventory

class Product {
  final int? id;
  final String name;
  final String code;
  final String category;
  int quantity;
  final double unitPrice;

  Product({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.quantity,
    required this.unitPrice,
  });

  // Convert a Product into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  // Create a Product from a database Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      category: map['category'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
    );
  }
}
