class Product {
  String id;
  String name;
  String code;
  String category;
  int quantity;
  double price;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.quantity,
    required this.price,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      category: data['category'] ?? '',
      quantity: (data['quantity'] ?? 0) as int,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'category': category,
      'quantity': quantity,
      'price': price,
    };
  }
}