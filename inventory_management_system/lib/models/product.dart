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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'code': code,
        'category': category,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        code: map['code'],
        category: map['category'],
        quantity: map['quantity'],
        unitPrice: map['unit_price'],
      );
}
