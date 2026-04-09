import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../models/user.dart';
import '../utils/constants.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

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

    // Seed default admin
    await db.insert('users', {
      'username': AppConstants.defaultUsername,
      'password': AppConstants.defaultPassword,
    });
  }

  // ── Auth ──────────────────────────────────────────────────────

  Future<User?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'username = ? AND password = ?',
        whereArgs: [username.trim(), password.trim()]);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // ── Products ──────────────────────────────────────────────────

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Search products by name or code, optionally filtered by category.
  Future<List<Product>> searchProducts({
    String query = '',
    String category = 'All',
  }) async {
    final db = await database;
    String where = '';
    List<dynamic> args = [];

    if (query.isNotEmpty && category != 'All') {
      where = '(name LIKE ? OR code LIKE ?) AND category = ?';
      args = ['%$query%', '%$query%', category];
    } else if (query.isNotEmpty) {
      where = 'name LIKE ? OR code LIKE ?';
      args = ['%$query%', '%$query%'];
    } else if (category != 'All') {
      where = 'category = ?';
      args = [category];
    }

    final maps = await db.query('products',
        where: where.isEmpty ? null : where,
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Returns a sorted list of all distinct category names.
  Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.rawQuery(
        'SELECT DISTINCT category FROM products ORDER BY category ASC');
    return maps.map((m) => m['category'] as String).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ── Stock Movements ───────────────────────────────────────────

  Future<void> recordStockIn(int productId, int quantity, String note) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE products SET quantity = quantity + ? WHERE id = ?',
        [quantity, productId]);
    await db.insert(
        'stock_transactions',
        StockTransaction(
          productId: productId,
          type: 'IN',
          quantity: quantity,
          date: DateTime.now().toIso8601String(),
          note: note,
        ).toMap());
  }

  Future<bool> recordStockOut(int productId, int quantity, String note) async {
    final db = await database;
    final result =
        await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isEmpty) return false;
    final current = result.first['quantity'] as int;
    if (current < quantity) return false;
    await db.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ?',
        [quantity, productId]);
    await db.insert(
        'stock_transactions',
        StockTransaction(
          productId: productId,
          type: 'OUT',
          quantity: quantity,
          date: DateTime.now().toIso8601String(),
          note: note,
        ).toMap());
    return true;
  }

  /// All transactions for a single product, newest first.
  Future<List<StockTransaction>> getTransactionsForProduct(int productId) async {
    final db = await database;
    final maps = await db.query('stock_transactions',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'date DESC');
    return maps.map((m) => StockTransaction.fromMap(m)).toList();
  }

  /// All transactions across all products, newest first.
  Future<List<StockTransaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('stock_transactions', orderBy: 'date DESC');
    return maps.map((m) => StockTransaction.fromMap(m)).toList();
  }

  /// Summary stats: totals by category.
  Future<List<Map<String, dynamic>>> getCategorySummary() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
        category,
        COUNT(*) AS product_count,
        SUM(quantity) AS total_units,
        SUM(quantity * unit_price) AS total_value
      FROM products
      GROUP BY category
      ORDER BY category ASC
    ''');
  }

  /// Count of today's transactions.
  Future<int> getTodayTransactionCount(String todayPrefix) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM stock_transactions WHERE date LIKE ?',
        ['$todayPrefix%']);
    return result.first['cnt'] as int;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
