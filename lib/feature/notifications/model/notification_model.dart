class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'review', 'promo', 'system', 'reminder'
  final bool isRead;
  final String createdAt;
  final String? appointmentId;
  final String? serviceId;
  final String? serviceName;
  final String? serviceImage;
  final double? servicePrice;
  final String? clientName;
  final String? clientAvatar;
  final String? date;
  final String? timeSlot;
  final String? status; // 'Pending', 'Confirmed', 'Completed', 'Cancelled'
  final double? rating;
  final String? review;
  final String? recipientRole;
  final bool canReview;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.appointmentId,
    this.serviceId,
    this.serviceName,
    this.serviceImage,
    this.servicePrice,
    this.clientName,
    this.clientAvatar,
    this.date,
    this.timeSlot,
    this.status,
    this.rating,
    this.review,
    this.recipientRole,
    this.canReview = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
    String? appointmentId,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    double? servicePrice,
    String? clientName,
    String? clientAvatar,
    String? date,
    String? timeSlot,
    String? status,
    double? rating,
    String? review,
    String? recipientRole,
    bool? canReview,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
      servicePrice: servicePrice ?? this.servicePrice,
      clientName: clientName ?? this.clientName,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      recipientRole: recipientRole ?? this.recipientRole,
      canReview: canReview ?? this.canReview,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'system').toString(),
      isRead: json['is_read'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
      appointmentId: json['appointment_id']?.toString(),
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name']?.toString(),
      serviceImage: json['service_image']?.toString(),
      servicePrice: (json['service_price'] is num) ? (json['service_price'] as num).toDouble() : null,
      clientName: json['client_name']?.toString(),
      clientAvatar: json['client_avatar']?.toString(),
      date: json['date']?.toString(),
      timeSlot: json['time_slot']?.toString(),
      status: json['status']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      review: json['review']?.toString(),
      recipientRole: json['recipient_role']?.toString(),
      canReview: json['can_review'] == true,
    );
  }
}
