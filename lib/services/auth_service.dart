
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalUser {
  final int id;
  final String name;
  final String email;

  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory LocalUser.fromMap(Map<String, Object?> map) {
    return LocalUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _sessionKey = 'cashtrail_logged_in_user';
  static const _iterations = 210000;

  final _hashAlgorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = p.join(
      await getDatabasesPath(),
      'cashtrail_users.db',
    );

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Uint8List _generateSalt() {
    final random = Random.secure();

    return Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
  }

  Future<List<int>> _hashPassword(
      String password,
      List<int> salt,
      ) async {
    final key = await _hashAlgorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    return key.extractBytes();
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    var difference = a.length ^ b.length;

    for (var i = 0; i < a.length && i < b.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }

  Future<LocalUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw Exception('This email is already registered.');
    }

    final salt = _generateSalt();
    final hash = await _hashPassword(password, salt);

    int id;

    try {
      id = await db.insert('users', {
        'name': name.trim(),
        'email': normalizedEmail,
        'password_hash': base64Encode(hash),
        'salt': base64Encode(salt),
        'created_at': DateTime.now().toIso8601String(),
      });
    } on DatabaseException {
      throw Exception('Unable to create account. Email may exist.');
    }

    return LocalUser(
      id: id,
      name: name.trim(),
      email: normalizedEmail,
    );
  }

  Future<LocalUser> login({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    final row = result.first;
    final salt = base64Decode(row['salt'] as String);
    final savedHash =
    base64Decode(row['password_hash'] as String);

    final suppliedHash = await _hashPassword(password, salt);

    if (!_constantTimeEquals(savedHash, suppliedHash)) {
      throw Exception('Invalid email or password.');
    }

    return LocalUser.fromMap(row);
  }

  Future<LocalUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionKey);

    if (id == null) return null;

    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id', 'name', 'email'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      await prefs.remove(_sessionKey);
      return null;
    }

    return LocalUser.fromMap(result.first);
  }

  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
