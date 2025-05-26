class CheckInLogModel {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final String? deviceInfo;
  final String? location;
  final bool isSuccessful;
  final String? failureReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  CheckInLogModel({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.deviceInfo,
    this.location,
    this.isSuccessful = true,
    this.failureReason,
    this.metadata,
    required this.createdAt,
  });

  factory CheckInLogModel.fromJson(Map<String, dynamic> json) {
    return CheckInLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      deviceInfo: json['device_info'] as String?,
      location: json['location'] as String?,
      isSuccessful: json['is_successful'] as bool? ?? true,
      failureReason: json['failure_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'check_in_time': checkInTime.toIso8601String(),
      'device_info': deviceInfo,
      'location': location,
      'is_successful': isSuccessful,
      'failure_reason': failureReason,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CheckInLogModel copyWith({
    String? id,
    String? userId,
    DateTime? checkInTime,
    String? deviceInfo,
    String? location,
    bool? isSuccessful,
    String? failureReason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return CheckInLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInTime: checkInTime ?? this.checkInTime,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      location: location ?? this.location,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}