import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/fish_result.dart';

class SQLiteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'atman.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT NOT NULL,
            address TEXT NOT NULL,
            role TEXT NOT NULL,
            last_login TEXT NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE fish_results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_path TEXT NOT NULL,
            species TEXT NOT NULL,
            count INTEGER NOT NULL,
            confidence REAL NOT NULL,
            individual_weight REAL NOT NULL,
            total_weight REAL NOT NULL,
            health_status TEXT NOT NULL,
            analyzed_at TEXT NOT NULL,
            uploaded_to_market INTEGER NOT NULL DEFAULT 0
          )
        ''');
        
        await db.execute('''
          CREATE TABLE market_listings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fish_result_id INTEGER,
            user_name TEXT NOT NULL,
            user_contact TEXT NOT NULL,
            user_address TEXT NOT NULL,
            species TEXT NOT NULL,
            count INTEGER NOT NULL,
            individual_weight REAL NOT NULL,
            total_weight REAL NOT NULL,
            health_status TEXT NOT NULL,
            image_path TEXT NOT NULL,
            listed_at TEXT NOT NULL,
            FOREIGN KEY (fish_result_id) REFERENCES fish_results (id)
          )
        ''');
      },
    );
  }

  // User methods
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('users');
  }

  // Fish Result methods
  Future<int> insertFishResult(FishResult result) async {
    final db = await database;
    return await db.insert('fish_results', result.toMap());
  }

  Future<List<FishResult>> getFishResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fish_results',
      orderBy: 'analyzed_at DESC',
    );
    return List.generate(maps.length, (i) => FishResult.fromMap(maps[i]));
  }

  Future<int> updateFishResult(FishResult result) async {
    final db = await database;
    return await db.update(
      'fish_results',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  // Market methods
  Future<int> insertMarketListing(Map<String, dynamic> listing) async {
    final db = await database;
    return await db.insert('market_listings', listing);
  }

  Future<List<Map<String, dynamic>>> getMarketListings() async {
    final db = await database;
    return await db.query(
      'market_listings',
      orderBy: 'listed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchMarketListings(String query) async {
    final db = await database;
    return await db.query(
      'market_listings',
      where: 'species LIKE ? OR user_name LIKE ? OR user_address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }
}