class UserModel {
  int? id;
  String name;
  String contact;
  String address;
  String role;
  DateTime lastLogin;

  UserModel({
    this.id,
    required this.name,
    required this.contact,
    required this.address,
    required this.role,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'role': role,
      'last_login': lastLogin.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      address: map['address'],
      role: map['role'],
      lastLogin: DateTime.parse(map['last_login']),
    );
  }
}