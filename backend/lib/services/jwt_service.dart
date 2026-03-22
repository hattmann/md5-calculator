import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  // In Produktion: aus Umgebungsvariable laden!
  static const String _geheimnis = 'GEHEIMES_SCHLUESSEL_BITTE_IN_ENV_SPEICHERN';
  static const Duration _gueltigkeitsdauer = Duration(hours: 24);

  String tokenErstellen(int benutzerId, String email) {
    final jwt = JWT({
      'sub': benutzerId,
      'email': email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    return jwt.sign(
      SecretKey(_geheimnis),
      expiresIn: _gueltigkeitsdauer,
    );
  }

  JWT? tokenVerifizieren(String token) {
    try {
      return JWT.verify(token, SecretKey(_geheimnis));
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }
}
