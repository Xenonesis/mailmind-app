import 'package:hive/hive.dart';

part 'email_model.g.dart';

@HiveType(typeId: 1)
class Email extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String sender;

  @HiveField(3)
  final String senderEmail;

  @HiveField(4)
  final List<String> recipients;

  @HiveField(5)
  final String body;

  @HiveField(6)
  final String? htmlBody;

  @HiveField(7)
  final DateTime receivedAt;

  @HiveField(8)
  final String category;

  @HiveField(9)
  final String priority;

  @HiveField(10)
  final String? summary;

  @HiveField(11)
  final bool isRead;

  @HiveField(12)
  final bool isImportant;

  @HiveField(13)
  final List<String>? attachments;

  @HiveField(14)
  final String? threadId;

  Email({
    required this.id,
    required this.subject,
    required this.sender,
    required this.senderEmail,
    required this.recipients,
    required this.body,
    this.htmlBody,
    required this.receivedAt,
    required this.category,
    required this.priority,
    this.summary,
    this.isRead = false,
    this.isImportant = false,
    this.attachments,
    this.threadId,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      sender: json['sender'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      recipients: List<String>.from(json['recipients'] ?? []),
      body: json['body'] ?? '',
      htmlBody: json['htmlBody'],
      receivedAt: json['receivedAt'] != null 
          ? DateTime.parse(json['receivedAt']) 
          : DateTime.now(),
      category: json['category'] ?? 'inbox',
      priority: json['priority'] ?? 'low',
      summary: json['summary'],
      isRead: json['isRead'] ?? false,
      isImportant: json['isImportant'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      threadId: json['threadId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'sender': sender,
      'senderEmail': senderEmail,
      'recipients': recipients,
      'body': body,
      'htmlBody': htmlBody,
      'receivedAt': receivedAt.toIso8601String(),
      'category': category,
      'priority': priority,
      'summary': summary,
      'isRead': isRead,
      'isImportant': isImportant,
      'attachments': attachments,
      'threadId': threadId,
    };
  }

  String get shortPreview {
    final cleanBody = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleanBody.length > 100 
        ? '${cleanBody.substring(0, 100)}...' 
        : cleanBody;
  }

  bool get hasAttachments {
    return attachments != null && attachments!.isNotEmpty;
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(receivedAt);
    
    if (difference.inDays == 0) {
      return '${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${receivedAt.day}/${receivedAt.month}/${receivedAt.year}';
    }
  }

  @override
  String toString() {
    return 'Email(id: $id, subject: $subject, sender: $sender, category: $category, priority: $priority)';
  }
}