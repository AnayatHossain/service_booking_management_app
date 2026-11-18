class ProviderDashboardModel {
  final String providerName;
  final String institutionName;
  final String? avatarUrl;
  final int totalServices;
  final int totalBookings;
  final int pendingBookings;
  final int completedBookings;
  final int unreadCount;
  final List<dynamic> recentBookings;

  const ProviderDashboardModel({
    this.providerName = 'Apex Pro Services',
    this.institutionName = '',
    this.avatarUrl,
    this.totalServices = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.completedBookings = 0,
    this.unreadCount = 0,
    this.recentBookings = const [],
  });

  ProviderDashboardModel copyWith({
    String? providerName,
    String? institutionName,
    String? avatarUrl,
    int? totalServices,
    int? totalBookings,
    int? pendingBookings,
    int? completedBookings,
    int? unreadCount,
    List<dynamic>? recentBookings,
  }) {
    return ProviderDashboardModel(
      providerName: providerName ?? this.providerName,
      institutionName: institutionName ?? this.institutionName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalServices: totalServices ?? this.totalServices,
      totalBookings: totalBookings ?? this.totalBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      unreadCount: unreadCount ?? this.unreadCount,
      recentBookings: recentBookings ?? this.recentBookings,
    );
  }
}
