/// Model representing a User in the application.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? school;
  final String? major;
  final DateTime createdAt;

  /// Creates a [UserModel].
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.school,
    this.major,
    required this.createdAt,
  });

  /// Creates a [UserModel] from a map, typically from Firestore.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      school: map['school'] as String?,
      major: map['major'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the [UserModel] to a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'school': school,
      'major': major,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of the [UserModel] with updated fields.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? school,
    String? major,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      school: school ?? this.school,
      major: major ?? this.major,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
