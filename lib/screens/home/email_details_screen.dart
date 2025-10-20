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

class _EmailDetailsScreenState extends ConsumerState<EmailDetailsScreen>
    with TickerProviderStateMixin {
  bool _showFullHeaders = false;
  bool _isLoading = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Mark as read when opening details
    if (!widget.email.isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(emailListProvider.notifier).markAsRead(widget.email.id);
      });
    }
    
    // Start loading simulation and animations
    _startLoadingSequence();
  }
  
  void _startLoadingSequence() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Start animations in sequence
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _slideController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _scaleController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return _buildLoadingScreen(theme);
    }
    
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Header Card
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildEmailHeader(theme),
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // AI Summary Box
                if (widget.email.summary != null && widget.email.summary!.isNotEmpty)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      )),
                      child: SummaryBox(summary: widget.email.summary!),
                    ),
                  ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Email Body Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    )),
                    child: _buildEmailBody(theme),
                  ),
                ),
                
                // Attachments (if any)
                if (widget.email.attachments != null && widget.email.attachments!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                      )),
                      child: _buildAttachments(theme),
                    ),
                  ),
                ],
                
                const SizedBox(height: AppTheme.spacingXl * 2),
              ],
            ),
          ),
        ),
      ),
      
      // Action Buttons
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
          )),
          child: _buildActionButtons(theme),
        ),
      ),
    );
  }
  
  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Loading email details...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
          'Email Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      actions: [
        // Important Toggle with animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: IconButton(
                onPressed: () {
                  ref.read(emailListProvider.notifier).markAsImportant(
                    widget.email.id,
                    !widget.email.isImportant,
                  );
                  _showSnackBar(
                    widget.email.isImportant 
                        ? 'Removed from important' 
                        : 'Marked as important',
                    icon: widget.email.isImportant 
                        ? Icons.star_border 
                        : Icons.star,
                  );
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.email.isImportant ? Icons.star : Icons.star_border,
                    key: ValueKey(widget.email.isImportant),
                    color: widget.email.isImportant ? Colors.amber : null,
                  ),
                ),
              ),
            );
          },
        ),
        
        // More Actions
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildMoreActionsMenu(theme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreActionsMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _showDeleteConfirmation();
            break;
          case 'mark_unread':
            ref.read(emailListProvider.notifier).markAsRead(widget.email.id, false);
            _showSnackBar('Marked as unread', icon: Icons.mark_email_unread);
            break;
          case 'forward':
            _showSnackBar('Forward functionality not implemented', icon: Icons.forward);
            break;
          case 'reply':
            _showSnackBar('Reply functionality not implemented', icon: Icons.reply);
            break;
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'reply',
          icon: Icons.reply_rounded,
          text: 'Reply',
          theme: theme,
        ),
        _buildPopupMenuItem(
          value: 'forward',
          icon: Icons.forward_rounded,
          text: 'Forward',
          theme: theme,
        ),
        _buildPopupMenuItem(
          value: 'mark_unread',
          icon: Icons.mark_email_unread_rounded,
          text: 'Mark as unread',
          theme: theme,
        ),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_rounded,
          text: 'Delete',
          theme: theme,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              Text(
                widget.email.subject,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Sender Info
              Row(
                children: [
                  _buildSenderAvatar(theme),
                  const SizedBox(width: AppTheme.spacingMd),
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
                        const SizedBox(height: 2),
                        Text(
                          widget.email.senderEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTimeChip(theme),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLg),
              
              // Recipients (if not just to current user)
              if (widget.email.recipients.isNotEmpty) ...[
                _buildRecipientsSection(theme),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              
              // Tags Row
              _buildTagsRow(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSenderAvatar(ThemeData theme) {
    final initial = widget.email.sender.isNotEmpty 
        ? widget.email.sender[0].toUpperCase()
        : '?';
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        DateFormat('MMM dd, yyyy • HH:mm').format(widget.email.receivedAt),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecipientsSection(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () {
          setState(() {
            _showFullHeaders = !_showFullHeaders;
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _showFullHeaders 
                        ? widget.email.recipients.join(', ')
                        : widget.email.recipients.first + 
                          (widget.email.recipients.length > 1 
                              ? ' +${widget.email.recipients.length - 1} more'
                              : ''),
                    key: ValueKey(_showFullHeaders),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _showFullHeaders ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsRow(ThemeData theme) {
    return Row(
      children: [
        // Category Chip
        _buildCategoryChip(theme),
        const SizedBox(width: AppTheme.spacingSm),
        // Priority Chip
        _buildPriorityChip(theme),
      ],
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    final categoryColor = AppTheme.getCategoryColor(widget.email.category);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.1),
            categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppTheme.getCategoryIcon(widget.email.category),
            size: 14,
            color: categoryColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.email.category.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    final priorityColor = AppTheme.getPriorityColor(widget.email.priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            priorityColor.withOpacity(0.1),
            priorityColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppTheme.getPriorityIcon(widget.email.priority),
            size: 14,
            color: priorityColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.email.priority.toUpperCase()} PRIORITY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: priorityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailBody(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.message_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Message',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
              
              // Email Body
              SelectableText(
                widget.email.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Attachments (${widget.email.attachments!.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
              
              ...widget.email.attachments!.asMap().entries.map((entry) {
                final index = entry.key;
                final attachment = entry.value;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < widget.email.attachments!.length - 1 
                        ? AppTheme.spacingSm 
                        : 0,
                  ),
                  child: _buildAttachmentItem(attachment, theme),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String attachment, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: () {
            _showSnackBar('Download functionality not implemented', icon: Icons.download);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    attachment,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    _showSnackBar('Download functionality not implemented', icon: Icons.download);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                onPressed: () {
                  _showSnackBar('Reply functionality not implemented', icon: Icons.reply);
                },
                icon: Icons.reply_rounded,
                label: 'Reply',
                theme: theme,
                isOutlined: true,
              ),
            ),
            
            const SizedBox(width: AppTheme.spacingMd),
            
            Expanded(
              child: _buildActionButton(
                onPressed: () {
                  _showSnackBar('Forward functionality not implemented', icon: Icons.forward);
                },
                icon: Icons.forward_rounded,
                label: 'Forward',
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required ThemeData theme,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    }
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Email'),
        content: Text(
          'Are you sure you want to delete this email? This action cannot be undone.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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