class CustomerModel {
  final String uid;
  final String email;
  final String name;
  final String? profileImage;
  final String? phoneNumber;
  final List<String> favoriteSalons;
  final String role;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImage,
    this.phoneNumber,
    this.favoriteSalons = const [],
    this.role = 'customer',
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'],
      favoriteSalons: List<String>.from(map['favoriteSalons'] ?? []),
      role: map['role'] ?? 'customer',
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'favoriteSalons': favoriteSalons,
      'role': role,
      'emailVerified': emailVerified,
    };
  }

  /// Create a copy with updated fields
  CustomerModel copyWith({
    String? name,
    String? profileImage,
    String? phoneNumber,
    List<String>? favoriteSalons,
    bool? emailVerified,
  }) {
    return CustomerModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoriteSalons: favoriteSalons ?? this.favoriteSalons,
      role: role,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty;
  }

  /// Get display name (fallback to email if name is empty)
  String get displayName {
    return name.isNotEmpty ? name : email.split('@').first;
  }
}
