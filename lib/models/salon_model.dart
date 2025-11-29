class SalonModel {
  final String uid;
  final String salonName;
  final String address;
  final String? city;
  final double rating;
  final String? imageUrl;
  final bool isOpen;
  final List<Map<String, dynamic>>
  services; // Keeping as Map for flexibility for now
  final List<Map<String, dynamic>> barbers;
  final double? latitude;
  final double? longitude;

  SalonModel({
    required this.uid,
    required this.salonName,
    required this.address,
    this.city,
    this.rating = 0.0,
    this.imageUrl,
    this.isOpen = true,
    this.services = const [],
    this.barbers = const [],
    this.latitude,
    this.longitude,
  });

  factory SalonModel.fromMap(Map<String, dynamic> map, String id) {
    return SalonModel(
      uid: id,
      salonName: map['salonName'] ?? 'Unknown Salon',
      address: map['address'] ?? 'No Address',
      city: map['city'],
      rating: (map['avgRating'] ?? 0).toDouble(),
      imageUrl:
          map['bannerImage'] ??
          map['image'], // Handling potential different keys
      isOpen: map['isOpen'] ?? true,
      services: List<Map<String, dynamic>>.from(map['services'] ?? []),
      barbers: List<Map<String, dynamic>>.from(map['barbers'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
