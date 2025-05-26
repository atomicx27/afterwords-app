import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class CheckInStatusCard extends StatelessWidget {
  const CheckInStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        final isOverdue = user.isOverdue;
        final timeUntilDeadline = user.timeUntilDeadline;
        final lastCheckIn = user.lastCheckIn;

        Color cardColor;
        IconData statusIcon;
        String statusText;
        String timeText;

        if (isOverdue) {
          cardColor = Colors.red;
          statusIcon = Icons.warning;
          statusText = 'Check-in Overdue!';
          timeText = 'Please check in immediately';
        } else if (timeUntilDeadline != null) {
          if (timeUntilDeadline.inHours < 6) {
            cardColor = Colors.orange;
            statusIcon = Icons.schedule;
            statusText = 'Check-in Due Soon';
          } else {
            cardColor = Colors.green;
            statusIcon = Icons.check_circle;
            statusText = 'All Good';
          }
          
          if (timeUntilDeadline.inDays > 0) {
            timeText = '${timeUntilDeadline.inDays} days remaining';
          } else if (timeUntilDeadline.inHours > 0) {
            timeText = '${timeUntilDeadline.inHours} hours remaining';
          } else {
            timeText = '${timeUntilDeadline.inMinutes} minutes remaining';
          }
        } else {
          cardColor = Colors.grey;
          statusIcon = Icons.help_outline;
          statusText = 'No Check-in Required';
          timeText = 'Set up your check-in schedule';
        }

        return Card(
          color: cardColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: cardColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                          Text(
                            timeText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOverdue || (timeUntilDeadline?.inHours ?? 25) < 24)
                      ElevatedButton(
                        onPressed: () => context.go('/check-in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Check In'),
                      ),
                  ],
                ),
                if (lastCheckIn != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last check-in: ${_formatDateTime(lastCheckIn)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}