import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//Todo: Implement Favorite and History Database Tables (Change this template).
class HistoryDatabase {
  static Database? _database;
  static const String _databaseName = "HistoryDatabase.db";
  static const String _tableName = "history_table", _columnId = "id";

  static const String birdName = "birdName";
  static const String birdDescription = "columnDescription";
  static const String picture = "picture";
  static const String latitude = "latitude", longitude = "longitude";

  HistoryDatabase._privateConstructor();
   static final HistoryDatabase instance = HistoryDatabase._privateConstructor();

  static const int _databaseVersion = 1;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();

    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = "$docDirectory$_databaseName";

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
          $_columnId INTEGER PRIMARY KEY,
          $birdName TEXT NOT NULL,
          $birdDescription TEXT NOT NULL, 
          $picture BLOB NOT NULL,
          $latitude REAL NOT NULL,
          $longitude REAL NOT NULL
          )
          ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> row) async {

    Database? db = await instance.database;

    return await db!.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {

    Database? db = await instance.database;

    return await db!.query(_tableName);
  }

  Future<int> delete(int id) async {

    Database? db = await instance.database;

    return await db!.delete(_tableName, where: "$_columnId = ?", whereArgs: [id]);
  }
}
