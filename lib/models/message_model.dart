enum MessageType {
  text,
  audio,
  video,
  image,
}

enum MessageStatus {
  draft,
  scheduled,
  sent,
  failed,
}

class MessageModel {
  final String id;
  final String userId;
  final String title;
  final String? content;
  final MessageType type;
  final String? mediaUrl;
  final String? mediaPath;
  final MessageStatus status;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final List<String> recipientIds;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.type,
    this.mediaUrl,
    this.mediaPath,
    this.status = MessageStatus.draft,
    this.scheduledFor,
    this.sentAt,
    this.recipientIds = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      mediaUrl: json['media_url'] as String?,
      mediaPath: json['media_path'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.draft,
      ),
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      recipientIds: json['recipient_ids'] != null
          ? List<String>.from(json['recipient_ids'] as List)
          : [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type.name,
      'media_url': mediaUrl,
      'media_path': mediaPath,
      'status': status.name,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'recipient_ids': recipientIds,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    MessageType? type,
    String? mediaUrl,
    String? mediaPath,
    MessageStatus? status,
    DateTime? scheduledFor,
    DateTime? sentAt,
    List<String>? recipientIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaPath: mediaPath ?? this.mediaPath,
      status: status ?? this.status,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      recipientIds: recipientIds ?? this.recipientIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasMedia => mediaUrl != null || mediaPath != null;
  bool get isScheduled => status == MessageStatus.scheduled;
  bool get isSent => status == MessageStatus.sent;
  bool get isDraft => status == MessageStatus.draft;
}