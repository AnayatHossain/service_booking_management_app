class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
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
  final String createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
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
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get canBeCancelled => !isCancelled && !isCompleted;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
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
      createdAt: json['created_at'] ?? '',
    );
  }
}
