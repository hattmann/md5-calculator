import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  // Android-Emulator: 10.0.2.2 | iOS-Simulator / Web: localhost
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static const String _tokenKey = 'jwt_token';
  static const String _benutzerKey = 'benutzer_daten';

  Future<({bool erfolg, User? benutzer, String? fehler})> login(
    String email,
    String passwort,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'email': email, 'passwort': passwort}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final benutzer = User.fromJson(data['benutzer'] as Map<String, dynamic>);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token'] as String);
        await prefs.setString(_benutzerKey, jsonEncode(benutzer.toJson()));
        return (erfolg: true, benutzer: benutzer, fehler: null);
      }

      return (
        erfolg: false,
        benutzer: null,
        fehler: data['fehler'] as String? ?? 'Anmeldung fehlgeschlagen',
      );
    } catch (e) {
      return (
        erfolg: false,
        benutzer: null,
        fehler: 'Verbindungsfehler. Server erreichbar?',
      );
    }
  }

  Future<void> abmelden() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_benutzerKey);
  }

  Future<User?> gespeicherterBenutzer() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_benutzerKey);
    if (json == null) return null;
    try {
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
