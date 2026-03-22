import 'package:sqlite3/sqlite3.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/benutzer.dart';

class Datenbank {
  static final Datenbank _instanz = Datenbank._intern();
  late final Database _db;

  factory Datenbank() => _instanz;

  Datenbank._intern() {
    _db = sqlite3.open('benutzer.db');
    _initialisieren();
  }

  void _initialisieren() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS Benutzer (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        benutzername TEXT NOT NULL UNIQUE,
        email        TEXT NOT NULL UNIQUE,
        passwort_hash TEXT NOT NULL,
        erstellt_am  TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
  }

  String passwortHashen(String passwort) {
    final bytes = utf8.encode(passwort);
    return sha256.convert(bytes).toString();
  }

  Benutzer? findeNachEmail(String email) {
    final ergebnis = _db.select(
      'SELECT * FROM Benutzer WHERE email = ? LIMIT 1',
      [email],
    );
    if (ergebnis.isEmpty) return null;
    return Benutzer.fromRow(ergebnis.first);
  }

  String? passwortHashFuerEmail(String email) {
    final ergebnis = _db.select(
      'SELECT passwort_hash FROM Benutzer WHERE email = ? LIMIT 1',
      [email],
    );
    if (ergebnis.isEmpty) return null;
    return ergebnis.first['passwort_hash'] as String;
  }

  bool benutzerErstellen({
    required String benutzername,
    required String email,
    required String passwort,
  }) {
    try {
      _db.execute(
        'INSERT INTO Benutzer (benutzername, email, passwort_hash) VALUES (?, ?, ?)',
        [benutzername, email, passwortHashen(passwort)],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
