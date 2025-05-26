import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/message_provider.dart';
import '../models/message_model.dart';

class RecentMessagesCard extends StatelessWidget {
  const RecentMessagesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Messages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/messages'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<MessageProvider>(
              builder: (context, messageProvider, _) {
                final recentMessages = messageProvider.messages.take(3).toList();
                
                if (recentMessages.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first message to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/messages/create'),
                          child: const Text('Create Message'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: recentMessages
                      .map((message) => _MessageListItem(message: message))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageListItem extends StatelessWidget {
  final MessageModel message;

  const _MessageListItem({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(message.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(message.type),
              color: _getTypeColor(message.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(message.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(message.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(message.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${message.recipientIds.length} recipient${message.recipientIds.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.audio:
        return Icons.audiotrack;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.image:
        return Icons.image;
    }
  }

  Color _getTypeColor(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Colors.blue;
      case MessageType.audio:
        return Colors.green;
      case MessageType.video:
        return Colors.red;
      case MessageType.image:
        return Colors.purple;
    }
  }

  String _getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.draft:
        return 'Draft';
      case MessageStatus.scheduled:
        return 'Scheduled';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.draft:
        return Colors.grey;
      case MessageStatus.scheduled:
        return Colors.orange;
      case MessageStatus.sent:
        return Colors.green;
      case MessageStatus.failed:
        return Colors.red;
    }
  }
}