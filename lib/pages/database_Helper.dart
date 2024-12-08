import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thenewsapppartb/pages/article.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookmarks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE ${Article.table} (
        ${ArticleFields.id} $idType,
        ${ArticleFields.title} $textType,
        ${ArticleFields.source} $textType,
        ${ArticleFields.urlToImage} $textType,
        ${ArticleFields.publishedAt} $textType
      )
    ''');
  }

  Future<int> addBookmark(Article article) async {
    final db = await instance.database;
    return await db.insert(Article.table, article.toMap());
  }

  Future<List<Article>> getBookmarks() async {
    final db = await instance.database;
    final maps = await db.query(Article.table);

    if (maps.isEmpty) {
      return [];
    } else {
      return maps.map((map) => Article.fromMap(map)).toList();
    }
  }

  Future<int> removeBookmark(int id) async {
    final db = await instance.database;
    return await db.delete(
      Article.table,
      where: '${ArticleFields.id} = ?',
      whereArgs: [id],
    );
  }
}
