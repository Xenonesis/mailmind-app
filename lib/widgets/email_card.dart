import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/email_model.dart';
import '../theme/app_theme.dart';
import '../providers/email_provider.dart';

class EmailCard extends ConsumerWidget {
  final Email email;
  final VoidCallback? onTap;

  const EmailCard({
    super.key,
    required this.email,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: email.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          if (!email.isRead) {
            ref.read(emailListProvider.notifier).markAsRead(email.id);
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      email.sender.isNotEmpty 
                          ? email.sender[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Email Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender and Time Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                email.sender,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: email.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              email.formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Subject
                        Text(
                          email.subject,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: email.isRead 
                                ? FontWeight.w400 
                                : FontWeight.w600,
                            color: email.isRead 
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Preview or Summary
                        Text(
                          email.summary ?? email.shortPreview,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom Row with Tags and Actions
              Row(
                children: [
                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(email.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppTheme.getCategoryIcon(email.category),
                          size: 12,
                          color: AppTheme.getCategoryColor(email.category),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          email.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.getCategoryColor(email.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Priority Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getPriorityColor(email.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppTheme.getPriorityIcon(email.priority),
                          size: 12,
                          color: AppTheme.getPriorityColor(email.priority),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          email.priority.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.getPriorityColor(email.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Important Button
                      IconButton(
                        onPressed: () {
                          ref.read(emailListProvider.notifier).markAsImportant(
                            email.id,
                            !email.isImportant,
                          );
                        },
                        icon: Icon(
                          email.isImportant 
                              ? Icons.star 
                              : Icons.star_border,
                          color: email.isImportant 
                              ? Colors.amber 
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      
                      // More Actions Button
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'delete':
                              _showDeleteConfirmation(context, ref);
                              break;
                            case 'mark_unread':
                              // Mark as unread logic would go here
                              break;
                            case 'archive':
                              // Archive logic would go here
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'mark_unread',
                            child: Row(
                              children: [
                                Icon(Icons.mark_email_unread),
                                SizedBox(width: 8),
                                Text('Mark as unread'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive),
                                SizedBox(width: 8),
                                Text('Archive'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(emailListProvider.notifier).deleteEmail(email.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}