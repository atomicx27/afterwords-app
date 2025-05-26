import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../providers/recipient_provider.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer2<MessageProvider, RecipientProvider>(
              builder: (context, messageProvider, recipientProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.message_outlined,
                        label: 'Messages',
                        value: messageProvider.totalMessages.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.schedule,
                        label: 'Scheduled',
                        value: messageProvider.scheduledCount.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.send,
                        label: 'Sent',
                        value: messageProvider.sentCount.toString(),
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.people_outlined,
                        label: 'Recipients',
                        value: recipientProvider.totalRecipients.toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}