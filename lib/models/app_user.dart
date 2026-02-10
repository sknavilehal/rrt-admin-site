/// App user model representing users of the RRT mobile app
class AppUser {
  final String senderId;
  final String name;
  final String mobileNumber;
  final String state;
  final String district;
  final bool blocked;
  final String? blockedAt;
  final String? blockedBy;
  final String? blockedReason;

  AppUser({
    required this.senderId,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.district,
    required this.blocked,
    this.blockedAt,
    this.blockedBy,
    this.blockedReason,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      senderId: json['sender_id'] ?? json['senderId'] ?? '',
      name: json['name'] ?? 'Unknown',
      mobileNumber: json['mobile_number'] ?? json['mobileNumber'] ?? 'N/A',
      state: json['state'] ?? 'Unknown',
      district: json['district'] ?? 'Unknown',
      blocked: json['blocked'] ?? false,
      blockedAt: json['blockedAt'],
      blockedBy: json['blockedBy'],
      blockedReason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'name': name,
      'mobile_number': mobileNumber,
      'state': state,
      'district': district,
      'blocked': blocked,
      if (blockedAt != null) 'blockedAt': blockedAt,
      if (blockedBy != null) 'blockedBy': blockedBy,
      if (blockedReason != null) 'reason': blockedReason,
    };
  }
}

/// Paginated response for users list
class UsersListResponse {
  final List<AppUser> users;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  UsersListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      users: (json['users'] as List?)
              ?.map((u) => AppUser.fromJson(u))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 50,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
