# Dart Backend + Flutter App mit JWT-Auth und SQLite

Beispielprojekt: Dart-Backend (shelf) mit JWT-Authentifizierung und SQLite-Datenbank,
kombiniert mit einer Flutter-App mit Login- und Startseite.

> **Hinweis zu Serverpod:** Serverpod benötigt `serverpod create` + Code-Generator und läuft
> nur mit PostgreSQL. Dieses Projekt verwendet **shelf** – gleiche Architektur, aber direkt
> lauffähig mit SQLite. Für echtes Serverpod wäre eine PostgreSQL-Datenbank nötig.

---

## Projektstruktur

```
backend/
├── pubspec.yaml
├── bin/server.dart               ← Einstiegspunkt (Port 8080)
└── lib/
    ├── database/database.dart    ← SQLite, Tabelle "Benutzer"
    ├── models/benutzer.dart      ← Datenmodell
    ├── services/jwt_service.dart ← JWT erstellen/prüfen
    └── routes/
        ├── auth_routes.dart      ← /auth/login, /auth/registrieren
        └── protected_routes.dart ← JWT-Middleware + /api/profil

flutter_app/
└── lib/
    ├── main.dart                    ← SplashScreen (Auto-Login)
    ├── models/user.dart
    ├── services/auth_service.dart   ← HTTP + SharedPreferences
    └── screens/
        ├── login_screen.dart        ← Formular, Fehleranzeige
        └── home_screen.dart         ← Begrüßung, Benutzerdetails, Abmelden
```

---

## API-Endpunkte

| Methode | Pfad                  | Beschreibung                        | Auth erforderlich |
|---------|-----------------------|-------------------------------------|-------------------|
| POST    | `/auth/login`         | Anmeldung mit E-Mail + Passwort     | Nein              |
| POST    | `/auth/registrieren`  | Registrierung neuer Benutzer        | Nein              |
| GET     | `/api/profil`         | Geschützte Route (gibt Token-Daten zurück) | Ja (Bearer JWT) |

---

## Starten

### Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Der Server startet auf `http://localhost:8080`.

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

> **Android-Emulator:** In `auth_service.dart` ist `10.0.2.2:8080` als Backend-URL gesetzt
> (localhost vom Emulator). Für iOS-Simulator oder Web → `localhost:8080` verwenden.

---

## Technologien

| Komponente   | Pakete                                              |
|--------------|-----------------------------------------------------|
| Backend      | `shelf`, `shelf_router`, `sqlite3`, `dart_jsonwebtoken`, `crypto` |
| Flutter App  | `http`, `shared_preferences`                        |

---

## SQLite-Tabelle "Benutzer"

```sql
CREATE TABLE Benutzer (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  benutzername  TEXT NOT NULL UNIQUE,
  email         TEXT NOT NULL UNIQUE,
  passwort_hash TEXT NOT NULL,
  erstellt_am   TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);
```

Passwörter werden mit **SHA-256** gehasht. JWT-Token sind **24 Stunden** gültig.
