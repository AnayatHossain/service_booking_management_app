class ProviderServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final bool isFeatured;
  final double rating;
  final int totalReviews;
  final List<String> availableDays;
  final List<String> timeSlots;
  final List<String> includes;

  const ProviderServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    this.isFeatured = false,
    this.rating = 4.8,
    this.totalReviews = 0,
    this.availableDays = const [],
    this.timeSlots = const [],
    this.includes = const [],
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      durationMinutes: json['duration_minutes'] ?? 60,
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      isFeatured: json['is_featured'] ?? false,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
      totalReviews: json['total_reviews'] ?? 0,
      availableDays: (json['available_days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timeSlots: (json['time_slots'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      includes: (json['includes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [
        'Vetted & background checked professionals',
        'Comprehensive servicing',
        'Full satisfaction guarantee with free rework',
        '24/7 dedicated in-app support & easy cancel',
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'rating': rating,
      'total_reviews': totalReviews,
      'available_days': availableDays,
      'time_slots': timeSlots,
      'includes': includes,
    };
  }

  ProviderServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    bool? isFeatured,
    double? rating,
    int? totalReviews,
    List<String>? availableDays,
    List<String>? timeSlots,
    List<String>? includes,
  }) {
    return ProviderServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      availableDays: availableDays ?? this.availableDays,
      timeSlots: timeSlots ?? this.timeSlots,
      includes: includes ?? this.includes,
    );
  }
}
