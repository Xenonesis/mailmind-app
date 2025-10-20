import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/models/email_model.dart';
import 'package:mailmind/theme/app_theme.dart';
import 'package:mailmind/providers/email_provider.dart';

class EmailCard extends ConsumerStatefulWidget {
  final Email email;
  final VoidCallback? onTap;

  const EmailCard({
    super.key,
    required this.email,
    this.onTap,
  });

  @override
  ConsumerState<EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends ConsumerState<EmailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationDurationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(theme),
          ),
        );
      },
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: widget.email.isRead
              ? theme.colorScheme.outline.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.2),
          width: widget.email.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(
              widget.email.isRead ? 0.05 : 0.1,
            ),
            blurRadius: widget.email.isRead ? 4 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: () {
            if (!widget.email.isRead) {
              ref.read(emailListProvider.notifier).markAsRead(widget.email.id);
            }
            widget.onTap?.call();
          },
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: AppTheme.spacingSm),
                _buildContent(theme),
                const SizedBox(height: AppTheme.spacingMd),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildAvatar(theme),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.email.sender,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: widget.email.isRead 
                            ? FontWeight.w600 
                            : FontWeight.w700,
                        color: widget.email.isRead
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  _buildTimeChip(theme),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.email.senderEmail ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildQuickActions(theme),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final initial = widget.email.sender.isNotEmpty 
        ? widget.email.sender[0].toUpperCase()
        : '?';
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getAvatarColors(initial),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: _getAvatarColors(initial)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  List<Color> _getAvatarColors(String initial) {
    final colors = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Indigo to Purple
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Cyan to Blue
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber to Red
      [const Color(0xFFEC4899), const Color(0xFFBE185D)], // Pink
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // Purple
    ];
    
    final index = initial.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Widget _buildTimeChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        widget.email.formattedDate,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: widget.email.isImportant ? Icons.star : Icons.star_border,
          color: widget.email.isImportant 
              ? AppTheme.warningColor 
              : theme.colorScheme.onSurfaceVariant,
          onPressed: () {
            ref.read(emailListProvider.notifier).markAsImportant(
              widget.email.id,
              !widget.email.isImportant,
            );
          },
        ),
        const SizedBox(width: AppTheme.spacingXs),
        _buildMoreActionsButton(theme),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingXs),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreActionsButton(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _showDeleteConfirmation();
            break;
          case 'mark_unread':
            ref.read(emailListProvider.notifier).markAsRead(
              widget.email.id,
              false,
            );
            break;
          case 'archive':
            _showSnackBar('Email archived');
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'mark_unread',
          icon: Icons.mark_email_unread_rounded,
          label: 'Mark as unread',
          theme: theme,
        ),
        _buildPopupMenuItem(
          value: 'archive',
          icon: Icons.archive_rounded,
          label: 'Archive',
          theme: theme,
        ),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_rounded,
          label: 'Delete',
          theme: theme,
          isDestructive: true,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
        ? theme.colorScheme.error 
        : theme.colorScheme.onSurface;
    
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject
        Text(
          widget.email.subject,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: widget.email.isRead 
                ? FontWeight.w500 
                : FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppTheme.spacingXs),
        
        // Preview
        Text(
          widget.email.summary ?? widget.email.shortPreview ?? 'No preview available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildCategoryChip(theme),
        const SizedBox(width: AppTheme.spacingSm),
        _buildPriorityChip(theme),
        const Spacer(),
        if (widget.email.hasAttachments) ...[
          Icon(
            Icons.attach_file_rounded,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppTheme.spacingXs),
        ],
        if (!widget.email.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    final categoryColor = _getCategoryColor(widget.email.category);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(widget.email.category),
            size: 12,
            color: categoryColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.email.category.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    final priorityColor = _getPriorityColor(widget.email.priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(widget.email.priority),
            size: 12,
            color: priorityColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.email.priority.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: priorityColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF3B82F6); // Blue
      case 'personal':
        return const Color(0xFF10B981); // Green
      case 'important':
        return const Color(0xFFF59E0B); // Amber
      case 'promotions':
        return const Color(0xFFEC4899); // Pink
      case 'social':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'important':
        return Icons.star_rounded;
      case 'promotions':
        return Icons.local_offer_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'low':
        return AppTheme.successColor;
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'medium':
        return Icons.keyboard_arrow_up_rounded;
      case 'low':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text(
                    'Delete Email',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this email? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(emailListProvider.notifier).deleteEmail(widget.email.id);
              Navigator.of(context).pop();
              _showSnackBar('Email deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
      ),
    );
  }
}