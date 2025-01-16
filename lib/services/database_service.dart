import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('word_quiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE words (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      english TEXT NOT NULL,
      chinese TEXT NOT NULL,
      category TEXT,
      createTime TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE quiz_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      wordId INTEGER,
      correct INTEGER,
      attempts INTEGER,
      lastAttempt TEXT,
      FOREIGN KEY (wordId) REFERENCES words (id)
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE words ADD COLUMN category TEXT');
      await db.execute('''
      CREATE TABLE quiz_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wordId INTEGER,
        correct INTEGER,
        attempts INTEGER,
        lastAttempt TEXT,
        FOREIGN KEY (wordId) REFERENCES words (id)
      )
      ''');
    }
  }

  Future<Word> create(Word word) async {
    final db = await instance.database;
    final id = await db.insert('words', word.toMap());
    return word.copyWith(id: id);
  }

  Future<Word> update(Word word) async {
    final db = await instance.database;
    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
    return word;
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<String>> getAllCategories() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      distinct: true,
      columns: ['category'],
      where: 'category IS NOT NULL',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<List<Word>> getWordsByCategory(String category) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<void> updateQuizStats(int wordId, bool correct) async {
    final db = await instance.database;
    final stats = await db.query(
      'quiz_stats',
      where: 'wordId = ?',
      whereArgs: [wordId],
    );

    if (stats.isEmpty) {
      await db.insert('quiz_stats', {
        'wordId': wordId,
        'correct': correct ? 1 : 0,
        'attempts': 1,
        'lastAttempt': DateTime.now().toIso8601String(),
      });
    } else {
      final currentCorrect = stats.first['correct'] as int? ?? 0;
      final currentAttempts = stats.first['attempts'] as int? ?? 0;

      await db.update(
        'quiz_stats',
        {
          'correct': correct ? currentCorrect + 1 : currentCorrect,
          'attempts': currentAttempts + 1,
          'lastAttempt': DateTime.now().toIso8601String(),
        },
        where: 'wordId = ?',
        whereArgs: [wordId],
      );
    }
  }

  Future<Map<String, dynamic>> getWordStats(int wordId) async {
    final db = await instance.database;
    final stats = await db.query(
      'quiz_stats',
      where: 'wordId = ?',
      whereArgs: [wordId],
    );

    if (stats.isEmpty) {
      return {
        'correct': 0,
        'attempts': 0,
        'accuracy': 0.0,
      };
    }

    final correct = stats[0]['correct'] as int;
    final attempts = stats[0]['attempts'] as int;

    return {
      'correct': correct,
      'attempts': attempts,
      'accuracy': attempts > 0 ? correct / attempts : 0.0,
    };
  }

  Future<String> exportToJson() async {
    final words = await getAllWords();
    return json.encode(words.map((word) => word.toJson()).toList());
  }

  Future<void> importFromJson(String jsonStr) async {
    final db = await instance.database;
    final batch = db.batch();

    final List<dynamic> wordsList = json.decode(jsonStr);
    for (var wordMap in wordsList) {
      final word = Word.fromJson(wordMap as Map<String, dynamic>);
      batch.insert('words', word.toMap());
    }

    await batch.commit();
  }
}