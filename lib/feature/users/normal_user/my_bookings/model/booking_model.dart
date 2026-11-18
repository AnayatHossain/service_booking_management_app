class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String? userAvatar;
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double servicePrice;
  final String serviceImage;
  final String date;
  final String timeSlot;
  final int durationMinutes;
  final String status;
  final String? customerNotes;
  final bool isRated;
  final double? rating;
  final String? review;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.userAvatar,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.servicePrice,
    required this.serviceImage,
    required this.date,
    required this.timeSlot,
    required this.durationMinutes,
    required this.status,
    this.customerNotes,
    this.isRated = false,
    this.rating,
    this.review,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get canBeCancelled => (isPending || isConfirmed);
  bool get isAlreadyRated => isRated || rating != null;
  bool get canBeRated => isCompleted && !isAlreadyRated;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? json['phone'],
      userAvatar: json['user_avatar'] ?? json['client_avatar'],
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceCategory: json['service_category'] ?? '',
      servicePrice: (json['service_price'] is num) ? (json['service_price'] as num).toDouble() : 0.0,
      serviceImage: json['service_image'] ?? '',
      date: json['date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 60,
      status: json['status'] ?? 'Pending',
      customerNotes: json['customer_notes'],
      isRated: json['is_rated'] == true,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      review: json['review'],
      createdAt: json['created_at'] ?? '',
    );
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAvatar,
    String? serviceId,
    String? serviceName,
    String? serviceCategory,
    double? servicePrice,
    String? serviceImage,
    String? date,
    String? timeSlot,
    int? durationMinutes,
    String? status,
    String? customerNotes,
    bool? isRated,
    double? rating,
    String? review,
    String? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userAvatar: userAvatar ?? this.userAvatar,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceImage: serviceImage ?? this.serviceImage,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      customerNotes: customerNotes ?? this.customerNotes,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  BookingModel copyWithRatingReset() {
    return BookingModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userAvatar: userAvatar,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      servicePrice: servicePrice,
      serviceImage: serviceImage,
      date: date,
      timeSlot: timeSlot,
      durationMinutes: durationMinutes,
      status: status,
      customerNotes: customerNotes,
      isRated: false,
      rating: null,
      review: null,
      createdAt: createdAt,
    );
  }
}
