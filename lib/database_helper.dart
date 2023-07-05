import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initializeDatabase();
    return _database!;
  }

  DatabaseHelper._internal();

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'favorites.db');

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    return database;
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, temperature REAL)',
    );
  }

  Future<int> insertFavorite(String name, double temperature) async {
    Database db = await database;
    var row = {
      'name': name,
      'temperature': temperature,
    };
    int id = await db.insert('favorites', row);
    return id;
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    Database db = await database;
    List<Map<String, dynamic>> favorites = await db.query('favorites');
    return favorites;
  }

  Future<int> deleteFavorite(int id) async {
    Database db = await database;
    int result = await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
