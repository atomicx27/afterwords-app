enum ContactMethod {
  email,
  whatsapp,
  sms,
  telegram,
}

class RecipientModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? whatsappNumber;
  final ContactMethod preferredMethod;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipientModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.whatsappNumber,
    this.preferredMethod = ContactMethod.email,
    this.avatarUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      preferredMethod: ContactMethod.values.firstWhere(
        (e) => e.name == json['preferred_method'],
        orElse: () => ContactMethod.email,
      ),
      avatarUrl: json['avatar_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'preferred_method': preferredMethod.name,
      'avatar_url': avatarUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RecipientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? whatsappNumber,
    ContactMethod? preferredMethod,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      preferredMethod: preferredMethod ?? this.preferredMethod,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayContact {
    switch (preferredMethod) {
      case ContactMethod.email:
        return email;
      case ContactMethod.whatsapp:
        return whatsappNumber ?? phoneNumber ?? email;
      case ContactMethod.sms:
        return phoneNumber ?? email;
      case ContactMethod.telegram:
        return phoneNumber ?? email;
    }
  }

  bool get hasPhoneNumber => phoneNumber != null && phoneNumber!.isNotEmpty;
  bool get hasWhatsApp => whatsappNumber != null && whatsappNumber!.isNotEmpty;
}