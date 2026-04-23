class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String> interests;
  final List<String> bookmarkedEventIds;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? countryCode;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.interests = const [],
    this.bookmarkedEventIds = const [],
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.countryCode,
    required this.joinedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? interests,
    List<String>? bookmarkedEventIds,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? countryCode,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      bookmarkedEventIds: bookmarkedEventIds ?? this.bookmarkedEventIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'bookmarkedEventIds': bookmarkedEventIds,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'countryCode': countryCode,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      interests: (json['interests'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      bookmarkedEventIds:
          (json['bookmarkedEventIds'] as List<dynamic>? ?? const [])
              .map((item) => item as String)
              .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      countryCode: (json['countryCode'] as String?) ?? (json['country_code'] as String?),
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
