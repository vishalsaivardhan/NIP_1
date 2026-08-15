import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'nip.sqlite');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE devices (
          id TEXT PRIMARY KEY,
          nodeType TEXT,
          rssi INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE transactions (
          transactionId TEXT PRIMARY KEY,
          senderDeviceId TEXT,
          receiverDeviceId TEXT,
          amount INTEGER,
          createdAt INTEGER,
          status TEXT
        )
      ''');
    });
  }
}
