class StockTransaction {
  final int? id;
  final int productId;
  final String type; // 'IN' or 'OUT'
  final int quantity;
  final String date;
  final String? note;

  StockTransaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'date': date,
        'note': note,
      };

  factory StockTransaction.fromMap(Map<String, dynamic> map) => StockTransaction(
        id: map['id'],
        productId: map['product_id'],
        type: map['type'],
        quantity: map['quantity'],
        date: map['date'],
        note: map['note'],
      );
}
