class Benutzer {
  final int id;
  final String benutzername;
  final String email;
  final String erstelltAm;

  Benutzer({
    required this.id,
    required this.benutzername,
    required this.email,
    required this.erstelltAm,
  });

  factory Benutzer.fromRow(Map<String, Object?> row) {
    return Benutzer(
      id: row['id'] as int,
      benutzername: row['benutzername'] as String,
      email: row['email'] as String,
      erstelltAm: row['erstellt_am'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'benutzername': benutzername,
        'email': email,
        'erstelltAm': erstelltAm,
      };
}
