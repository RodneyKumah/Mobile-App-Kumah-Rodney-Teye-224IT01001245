import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL
      )
    ''');

    // Stock transactions table
    await db.execute('''
      CREATE TABLE stock_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
  }

  // ── Product CRUD ──────────────────────────────────────────────

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ── Stock Transaction Logic ───────────────────────────────────

  Future<void> recordStockIn(int productId, int quantity, String note) async {
    final db = await database;

    // New Quantity = Current Quantity + Added Quantity
    await db.rawUpdate(
      'UPDATE products SET quantity = quantity + ? WHERE id = ?',
      [quantity, productId],
    );

    await db.insert('stock_transactions', StockTransaction(
      productId: productId,
      type: 'IN',
      quantity: quantity,
      date: DateTime.now().toIso8601String(),
      note: note,
    ).toMap());
  }

  Future<bool> recordStockOut(int productId, int quantity, String note) async {
    final db = await database;

    // Validate: prevent stock going below zero
    final result = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isEmpty) return false;

    final current = result.first['quantity'] as int;
    if (current < quantity) return false; // Not enough stock

    // New Quantity = Current Quantity – Issued Quantity
    await db.rawUpdate(
      'UPDATE products SET quantity = quantity - ? WHERE id = ?',
      [quantity, productId],
    );

    await db.insert('stock_transactions', StockTransaction(
      productId: productId,
      type: 'OUT',
      quantity: quantity,
      date: DateTime.now().toIso8601String(),
      note: note,
    ).toMap());

    return true;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
