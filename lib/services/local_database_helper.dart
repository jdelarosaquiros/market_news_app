import 'package:market_news_app/models/article_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/*
 * This class is contains the local database logic. It opens or creates the
 * tables to save the articles in the history and favorite lists.
 */

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = "ArticlesDatabase.db";
  static const String historyTableName = "history_table";
  static const String favoritesTableName = "favorites_table";

  static const String idFieldName = "id";
  static const String dateUnixFieldName = "dateUnix";
  static const String dateFieldName = "date";
  static const String categoryFieldName = "category";
  static const String titleFieldName = "title";
  static const String imageFieldName = "image";
  static const String sourceFieldName = "source";
  static const String summaryFieldName = "summary";
  static const String urlFieldName = "url";
  static const String dateVisitedFieldName = "dateVisited";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const int _databaseVersion = 1;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();

    return _database;
  }

  // Create singleton
  Future<Database> _initDatabase() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = "$docDirectory$_databaseName";

    // Open or create database with tables for history and favorite articles
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $historyTableName (
          $idFieldName INTEGER PRIMARY KEY,
          $dateUnixFieldName INTEGER NOT NULL, 
          $dateFieldName TEXT NOT NULL,
          $categoryFieldName TEXT NOT NULL, 
          $titleFieldName TEXT NOT NULL,
          $imageFieldName TEXT NOT NULL,
          $sourceFieldName TEXT NOT NULL,
          $summaryFieldName TEXT NOT NULL,
          $urlFieldName TEXT NOT NULL,
          $dateVisitedFieldName TEXT NOT NULL
          );
          ''');
        await db.execute(''' 
          CREATE TABLE $favoritesTableName (
          $idFieldName INTEGER PRIMARY KEY,
          $dateUnixFieldName INTEGER NOT NULL, 
          $dateFieldName TEXT NOT NULL,
          $categoryFieldName TEXT NOT NULL, 
          $titleFieldName TEXT NOT NULL,
          $imageFieldName TEXT NOT NULL,
          $sourceFieldName TEXT NOT NULL,
          $summaryFieldName TEXT NOT NULL,
          $urlFieldName TEXT NOT NULL
          );
          ''');
      },
    );
  }

  // Inserts an article in the table with the passed name. Returns index
  Future<int> insert(Article article, String tableName) async {
    Database? db = await instance.database;

    Map<String, dynamic> row = {
      idFieldName: article.id,
      dateUnixFieldName: article.dateUnix,
      dateFieldName: article.date,
      categoryFieldName: article.category,
      titleFieldName: article.title,
      imageFieldName: article.image,
      sourceFieldName: article.source,
      summaryFieldName: article.summary,
      urlFieldName: article.url,
    };

    if(tableName == historyTableName) {
      row[dateVisitedFieldName] = article.dateVisited.toString();
    }

    return await db!.insert(tableName, row);
  }

  // Queries and returns all articles from a table
  Future<List<Article>> queryAllArticles(tableName) async {
    List<Article> articles = [];
    Article article;
    Database? db = await instance.database;

    List<Map<String, dynamic>> rows = await db!.query(tableName);

    for (Map<String, dynamic> row in rows) {
      article = Article(
        id: row[idFieldName],
        dateUnix: row[dateUnixFieldName],
        category: row[categoryFieldName],
        date: row[dateFieldName],
        title: row[titleFieldName],
        image: row[imageFieldName],
        source: row[sourceFieldName],
        summary: row[summaryFieldName],
        url: row[urlFieldName],
      );

      if(tableName == historyTableName) {
         article.dateVisited = int.parse(row[dateVisitedFieldName]);
      }

      articles.add(article);
    }
    return articles;
  }

  // Deletes article with the passed id from a table. Returns index of article
  Future<int> delete(int id, tableName) async {
    Database? db = await instance.database;
    return await db!
        .delete(tableName, where: "$idFieldName = ?", whereArgs: [id]);
  }
}
