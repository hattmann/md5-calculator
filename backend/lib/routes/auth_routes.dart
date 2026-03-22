import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../services/jwt_service.dart';

Router authRouter() {
  final router = Router();
  final db = Datenbank();
  final jwt = JwtService();

  // POST /auth/login
  router.post('/login', (Request request) async {
    late Map<String, dynamic> body;
    try {
      body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return _json({'fehler': 'Ungültiges JSON'}, 400);
    }

    final email = body['email'] as String?;
    final passwort = body['passwort'] as String?;

    if (email == null || passwort == null || email.isEmpty || passwort.isEmpty) {
      return _json({'fehler': 'Email und Passwort erforderlich'}, 400);
    }

    final gespeicherterHash = db.passwortHashFuerEmail(email);
    if (gespeicherterHash == null) {
      return _json({'fehler': 'Ungültige Anmeldedaten'}, 401);
    }

    if (db.passwortHashen(passwort) != gespeicherterHash) {
      return _json({'fehler': 'Ungültige Anmeldedaten'}, 401);
    }

    final benutzer = db.findeNachEmail(email)!;
    final token = jwt.tokenErstellen(benutzer.id, benutzer.email);

    return _json({'token': token, 'benutzer': benutzer.toJson()}, 200);
  });

  // POST /auth/registrieren
  router.post('/registrieren', (Request request) async {
    late Map<String, dynamic> body;
    try {
      body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return _json({'fehler': 'Ungültiges JSON'}, 400);
    }

    final benutzername = body['benutzername'] as String?;
    final email = body['email'] as String?;
    final passwort = body['passwort'] as String?;

    if (benutzername == null || email == null || passwort == null ||
        benutzername.isEmpty || email.isEmpty || passwort.isEmpty) {
      return _json({'fehler': 'Alle Felder sind erforderlich'}, 400);
    }

    if (passwort.length < 6) {
      return _json({'fehler': 'Passwort muss mindestens 6 Zeichen haben'}, 400);
    }

    final erfolgreich = db.benutzerErstellen(
      benutzername: benutzername,
      email: email,
      passwort: passwort,
    );

    if (!erfolgreich) {
      return _json({'fehler': 'Benutzername oder E-Mail bereits vergeben'}, 409);
    }

    return _json({'nachricht': 'Registrierung erfolgreich'}, 201);
  });

  return router;
}

Response _json(Map<String, dynamic> data, int statusCode) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}
