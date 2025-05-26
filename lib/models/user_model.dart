class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? lastCheckIn;
  final int checkInIntervalHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.lastCheckIn,
    this.checkInIntervalHours = 24, // Default to daily check-in
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      lastCheckIn: json['last_check_in'] != null 
          ? DateTime.parse(json['last_check_in'] as String)
          : null,
      checkInIntervalHours: json['check_in_interval_hours'] as int? ?? 24,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'last_check_in': lastCheckIn?.toIso8601String(),
      'check_in_interval_hours': checkInIntervalHours,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? lastCheckIn,
    int? checkInIntervalHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInIntervalHours: checkInIntervalHours ?? this.checkInIntervalHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (lastCheckIn == null) return false;
    final deadline = lastCheckIn!.add(Duration(hours: checkInIntervalHours));
    return DateTime.now().isAfter(deadline);
  }

  Duration? get timeUntilDeadline {
    if (lastCheckIn == null) return null;
    final deadline = lastCheckIn!.add(Duration(hours: checkInIntervalHours));
    final now = DateTime.now();
    if (now.isAfter(deadline)) return null;
    return deadline.difference(now);
  }
}