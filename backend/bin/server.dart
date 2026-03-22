import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:login_backend/routes/auth_routes.dart';
import 'package:login_backend/routes/protected_routes.dart';

void main() async {
  final app = Router();

  // Öffentliche Routen
  app.mount('/auth', authRouter());

  // Geschützte Routen (JWT erforderlich)
  app.mount(
    '/api',
    Pipeline().addMiddleware(jwtMiddleware()).addHandler(protectedRouter()),
  );

  // 404-Fallback
  app.all('/<_|.*>', (Request req) => Response.notFound('Route nicht gefunden'));

  final pipeline = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(app);

  final server = await io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    8080,
  );

  print('✅ Server läuft auf http://${server.address.host}:${server.port}');
  print('   POST /auth/login       — Anmelden');
  print('   POST /auth/registrieren — Registrieren');
  print('   GET  /api/profil       — Geschützte Route (Bearer Token)');
}

Middleware _corsMiddleware() {
  const headers = {
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'access-control-allow-headers': 'content-type, authorization',
  };

  return (Handler next) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await next(request);
      return response.change(headers: headers);
    };
  };
}
