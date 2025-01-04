class User {
  final String id;
  final String name;
  final String email;
  final String password;
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

  // Convert User to a Map (for storing in Firestore)
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

  // Create a User from a Map (for retrieving from Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      height: (map['height'] is num) ? map['height'].toDouble() : null,
      weight: (map['weight'] is num) ? map['weight'].toDouble() : null,
      dailyCalorieGoal: map['dailyCalorieGoal'],
    );
  }

  // Create a User from Firestore document (Firestore-specific mapping)
  factory User.fromFirestore(Map<String, dynamic> firestoreData) {
    return User(
      id: firestoreData['id'] ?? '',
      name: firestoreData['name'] ?? '',
      email: firestoreData['email'] ?? '',
      password: firestoreData['password'] ??
          '', // Password handling should be more secure
      height: firestoreData['height']?.toDouble(),
      weight: firestoreData['weight']?.toDouble(),
      dailyCalorieGoal: firestoreData['dailyCalorieGoal'],
    );
  }

  //convert the User to a Firestore document format
  Map<String, dynamic> toFirestore() {
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
}
