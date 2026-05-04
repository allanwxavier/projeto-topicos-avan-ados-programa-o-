class User {
  final int id;
  final String name;
  final String? token;

  const User({required this.id, required this.name, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sem Nome',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (token != null) 'token': token};
  }
}
