import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/email_model.dart';
import '../../providers/email_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/summary_box.dart';

class EmailDetailsScreen extends ConsumerStatefulWidget {
  final Email email;

  const EmailDetailsScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailDetailsScreen> createState() => _EmailDetailsScreenState();
}

class _EmailDetailsScreenState extends ConsumerState<EmailDetailsScreen> {
  bool _showFullHeaders = false;

  @override
  void initState() {
    super.initState();
    // Mark as read when opening details
    if (!widget.email.isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(emailListProvider.notifier).markAsRead(widget.email.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Details'),
        actions: [
          // Important Toggle
          IconButton(
            onPressed: () {
              ref.read(emailListProvider.notifier).markAsImportant(
                widget.email.id,
                !widget.email.isImportant,
              );
            },
            icon: Icon(
              widget.email.isImportant ? Icons.star : Icons.star_border,
              color: widget.email.isImportant ? Colors.amber : null,
            ),
          ),
          
          // More Actions
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation();
                  break;
                case 'mark_unread':
                  // Mark as unread logic
                  break;
                case 'forward':
                  // Forward logic
                  break;
                case 'reply':
                  // Reply logic
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reply',
                child: Row(
                  children: [
                    Icon(Icons.reply),
                    SizedBox(width: 8),
                    Text('Reply'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'forward',
                child: Row(
                  children: [
                    Icon(Icons.forward),
                    SizedBox(width: 8),
                    Text('Forward'),
                  ],
                ),
              ),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject
                    Text(
                      widget.email.subject,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sender Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            widget.email.sender.isNotEmpty 
                                ? widget.email.sender[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.email.sender,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.email.senderEmail,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(widget.email.receivedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recipients (if not just to current user)
                    if (widget.email.recipients.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFullHeaders = !_showFullHeaders;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              'To: ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _showFullHeaders 
                                    ? widget.email.recipients.join(', ')
                                    : widget.email.recipients.first + 
                                      (widget.email.recipients.length > 1 
                                          ? ' +${widget.email.recipients.length - 1} more'
                                          : ''),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _showFullHeaders 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Tags Row
                    Row(
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.getCategoryColor(widget.email.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppTheme.getCategoryIcon(widget.email.category),
                                size: 14,
                                color: AppTheme.getCategoryColor(widget.email.category),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.email.category.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.getCategoryColor(widget.email.category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Priority Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.getPriorityColor(widget.email.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppTheme.getPriorityIcon(widget.email.priority),
                                size: 14,
                                color: AppTheme.getPriorityColor(widget.email.priority),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.email.priority.toUpperCase()} PRIORITY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.getPriorityColor(widget.email.priority),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // AI Summary Box
            if (widget.email.summary != null && widget.email.summary!.isNotEmpty)
              SummaryBox(summary: widget.email.summary!),
            
            const SizedBox(height: 16),
            
            // Email Body Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Email Body
                    SelectableText(
                      widget.email.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Attachments (if any)
            if (widget.email.attachments != null && widget.email.attachments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments (${widget.email.attachments!.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      ...widget.email.attachments!.map((attachment) => 
                        ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text(attachment),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // Download attachment logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Download functionality not implemented'),
                                ),
                              );
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      
      // Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Reply functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply functionality not implemented'),
                    ),
                  );
                },
                icon: const Icon(Icons.reply),
                label: const Text('Reply'),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Forward functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forward functionality not implemented'),
                    ),
                  );
                },
                icon: const Icon(Icons.forward),
                label: const Text('Forward'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
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
              ref.read(emailListProvider.notifier).deleteEmail(widget.email.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close email details
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