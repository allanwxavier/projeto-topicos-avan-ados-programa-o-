class User {
  final int id;
  final String name;

  const User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] ?? 0, name: json['name'] ?? 'Sem Nome');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
