class User {
  final String id;
  final String name;
  final String email;
  final String password; // Note: In production, handle password securely
  final double? height; // in cm
  final double? weight; // in kg
  final int? dailyCalorieGoal;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.height,
    this.weight,
    this.dailyCalorieGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'height': height,
      'weight': weight,
      'dailyCalorieGoal': dailyCalorieGoal,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      dailyCalorieGoal: map['dailyCalorieGoal'],
    );
  }
}
