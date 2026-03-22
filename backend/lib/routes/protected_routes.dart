import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/jwt_service.dart';

/// Middleware: prüft JWT im Authorization-Header
Middleware jwtMiddleware() {
  final jwt = JwtService();

  return (Handler next) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'fehler': 'Kein Token vorhanden'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final verifiziert = jwt.tokenVerifizieren(token);

      if (verifiziert == null) {
        return Response(
          401,
          body: jsonEncode({'fehler': 'Token ungültig oder abgelaufen'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final aktualisiert = request.change(context: {
        'benutzerId': verifiziert.payload['sub'],
        'email': verifiziert.payload['email'],
      });

      return next(aktualisiert);
    };
  };
}

Router protectedRouter() {
  final router = Router();

  // GET /api/profil — nur für eingeloggte Benutzer
  router.get('/profil', (Request request) {
    final benutzerId = request.context['benutzerId'];
    final email = request.context['email'];

    return Response.ok(
      jsonEncode({
        'benutzerId': benutzerId,
        'email': email,
        'nachricht': 'Geschützte Route erfolgreich aufgerufen',
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
