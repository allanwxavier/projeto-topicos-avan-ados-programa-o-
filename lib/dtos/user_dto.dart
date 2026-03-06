class User {
  int? id;
  String name;
  String token;

  User({this.id, required this.name, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'Sem Nome',
      token: json['token'] ?? '',
    );
  }
}