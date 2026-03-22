class User {
  final int id;
  final String benutzername;
  final String email;
  final String erstelltAm;

  User({
    required this.id,
    required this.benutzername,
    required this.email,
    required this.erstelltAm,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        benutzername: json['benutzername'] as String,
        email: json['email'] as String,
        erstelltAm: json['erstelltAm'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'benutzername': benutzername,
        'email': email,
        'erstelltAm': erstelltAm,
      };
}
