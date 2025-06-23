import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel Users
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Tabel Notes dengan kolom color (integer)
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            color INTEGER NOT NULL DEFAULT 4280391411
          )
        ''');

        // Dummy User (opsional)
        await db.insert('users', {
          'email': 'randi123@gmail.com',
          'password': '123456',
        });
      },
      // Kalau nanti mau upgrade schema, tambahkan onUpgrade di sini
    );
  }

  // Login User
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // Insert note dengan warna
  Future<void> insertNoteWithColor(String title, String content, int color) async {
    final db = await database;
    await db.insert(
      'notes',
      {'title': title, 'content': content, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil semua catatan
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  // Ambil catatan berdasar id
  Future<Map<String, dynamic>?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update catatan dengan warna
  Future<int> updateNoteWithColor(int id, String title, String content, int color) async {
    final db = await database;
    return await db.update(
      'notes',
      {'title': title, 'content': content, 'color': color},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus catatan
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tutup database
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
