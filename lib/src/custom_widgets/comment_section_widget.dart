import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../controller/comment_controller.dart';
import '../controller/token_controller.dart';
import '../model/comment_model/comment_model.dart';

class CommentSection extends StatefulWidget {
  final String targetId;
  final bool isProduct; // true for product, false for car
  final CommentController commentController;

  const CommentSection({
    Key? key,
    required this.targetId,
    required this.isProduct,
    required this.commentController,
  }) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _textController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, FocusNode> _replyFocusNodes = {};
  final Map<String, FocusNode> _editFocusNodes = {};

  String? _replyingToCommentId;
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    // Load comments when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isProduct) {
        widget.commentController.getProductComments(productId: widget.targetId);
      } else {
        widget.commentController.getCarComments(carId: widget.targetId);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _replyControllers.values.forEach((controller) => controller.dispose());
    _editControllers.values.forEach((controller) => controller.dispose());
    _replyFocusNodes.values.forEach((node) => node.dispose());
    _editFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  TextEditingController _getReplyController(String commentId) {
    if (!_replyControllers.containsKey(commentId)) {
      _replyControllers[commentId] = TextEditingController();
    }
    return _replyControllers[commentId]!;
  }

  TextEditingController _getEditController(
    String commentId,
    String currentText,
  ) {
    if (!_editControllers.containsKey(commentId)) {
      _editControllers[commentId] = TextEditingController(text: currentText);
    }
    return _editControllers[commentId]!;
  }

  FocusNode _getReplyFocusNode(String commentId) {
    if (!_replyFocusNodes.containsKey(commentId)) {
      _replyFocusNodes[commentId] = FocusNode();
    }
    return _replyFocusNodes[commentId]!;
  }

  FocusNode _getEditFocusNode(String commentId) {
    if (!_editFocusNodes.containsKey(commentId)) {
      _editFocusNodes[commentId] = FocusNode();
    }
    return _editFocusNodes[commentId]!;
  }

  void _startReply(String commentId) {
    setState(() {
      _replyingToCommentId = commentId;
      _editingCommentId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getReplyFocusNode(commentId).requestFocus();
    });
  }

  void _startEdit(String commentId) {
    setState(() {
      _editingCommentId = commentId;
      _replyingToCommentId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEditFocusNode(commentId).requestFocus();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokenController = Get.find<TokenController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment Input Section
        Container(
          padding: EdgeInsets.all(AppSizer().height2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.appGreen,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: AppSizer().width2),

              // Comment Input Field
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColors.appGreen),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _addComment(value),
                ),
              ),
              SizedBox(width: AppSizer().width2),

              // Send Button
              Obx(
                () => IconButton(
                  icon: widget.commentController.isAddingComment.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.appGreen,
                          ),
                        )
                      : Icon(Icons.send, color: AppColors.appGreen),
                  onPressed: widget.commentController.isAddingComment.value
                      ? null
                      : () => _addComment(_textController.text),
                ),
              ),
            ],
          ),
        ),

        // Comments List Header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizer().height2,
            vertical: AppSizer().height1,
          ),
          child: Obx(() {
            final comments = widget.isProduct
                ? widget.commentController.productComments
                : widget.commentController.carComments;
            return Text(
              'Comments (${comments.length})',
              style: TextStyle(
                fontSize: AppSizer().fontSize16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            );
          }),
        ),

        // Comments List
        Obx(() {
          final isLoading = widget.isProduct
              ? widget.commentController.isLoadingProductComments.value
              : widget.commentController.isLoadingCarComments.value;

          final comments = widget.isProduct
              ? widget.commentController.productComments
              : widget.commentController.carComments;

          if (isLoading) {
            return Container(
              padding: EdgeInsets.all(AppSizer().height3),
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: AppColors.appGreen),
            );
          }

          if (comments.isEmpty) {
            return Container(
              padding: EdgeInsets.all(AppSizer().height3),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: AppSizer().height1),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: AppSizer().fontSize14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Be the first to comment!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: AppSizer().fontSize12,
                    ),
                  ),
                ],
              ),
            );
          }

          // Organize comments into parent-child structure
          print(
            '\n🔍 [CommentSection] Organizing ${comments.length} comments...',
          );
          final allComments = List<Comment>.from(comments);
          final parentComments = <Comment>[];
          final repliesMap = <String, List<Comment>>{};

          // Separate parent comments and replies
          for (final comment in allComments) {
            print(
              '📝 Comment ID: ${comment.id}, ParentID: ${comment.parentCommentId}, Text: ${comment.comment?.substring(0, comment.comment!.length > 20 ? 20 : comment.comment!.length)}...',
            );

            if (comment.parentCommentId == null ||
                comment.parentCommentId!.isEmpty) {
              // This is a parent comment
              print('   ✅ Added as PARENT comment');
              parentComments.add(comment);
            } else {
              // This is a reply
              print(
                '   ➡️ Added as REPLY to parent: ${comment.parentCommentId}',
              );
              if (!repliesMap.containsKey(comment.parentCommentId)) {
                repliesMap[comment.parentCommentId!] = [];
              }
              repliesMap[comment.parentCommentId]!.add(comment);
            }
          }

          print('📊 Organization Result:');
          print('   - Parent comments: ${parentComments.length}');
          print('   - Replies map size: ${repliesMap.length}');
          repliesMap.forEach((parentId, replies) {
            print('   - Parent $parentId has ${replies.length} replies');
          });

          // Attach replies to their parent comments
          for (final parent in parentComments) {
            if (repliesMap.containsKey(parent.id)) {
              parent.replies = repliesMap[parent.id];
              print(
                '🔗 Attached ${parent.replies!.length} replies to parent: ${parent.id}',
              );
            }
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: parentComments.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final comment = parentComments[index];
              return _buildCommentWithReplies(comment, tokenController);
            },
          );
        }),

        // Load More Button
        Obx(() {
          if (widget.commentController.hasMore.value) {
            return Container(
              padding: EdgeInsets.all(AppSizer().height2),
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () {
                  widget.commentController.loadMoreComments(
                    targetId: widget.targetId,
                    isProduct: widget.isProduct,
                  );
                },
                icon: Icon(Icons.expand_more),
                label: Text('Load More Comments'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.appGreen,
                ),
              ),
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  // Build parent comment with nested replies
  Widget _buildCommentWithReplies(
    Comment comment,
    TokenController tokenController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent comment
        _buildCommentItem(comment, tokenController, isReply: false),

        // Nested replies with indentation
        if (comment.replies != null && comment.replies!.isNotEmpty)
          ...comment.replies!.map((reply) {
            return Padding(
              padding: EdgeInsets.only(left: AppSizer().width8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                child: _buildCommentItem(reply, tokenController, isReply: true),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildCommentItem(
    Comment comment,
    TokenController tokenController, {
    bool isReply = false,
  }) {
    final currentUserId = tokenController.userUid.value;
    final isOwnComment = comment.userId == currentUserId;
    final userName = comment.user?.name ?? 'Anonymous';

    // Build full image URL if avatar exists
    String userAvatar = '';
    if (comment.user?.avatar != null && comment.user!.avatar!.isNotEmpty) {
      final avatar = comment.user!.avatar!;
      if (avatar.startsWith('http')) {
        userAvatar = avatar;
      } else {
        // Prepend base URL for relative paths
        userAvatar =
            'https://oldmarket.bhoomi.cloud${avatar.startsWith('/') ? avatar : '/$avatar'}';
      }
    }

    final timeAgo = comment.createdAt != null
        ? timeago.format(comment.createdAt!)
        : 'just now';

    return Container(
      padding: EdgeInsets.all(AppSizer().height2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.appGreen,
            backgroundImage: userAvatar.isNotEmpty
                ? NetworkImage(userAvatar)
                : null,
            child: userAvatar.isEmpty
                ? Icon(Icons.person, size: 18, color: Colors.white)
                : null,
          ),
          SizedBox(width: AppSizer().width2),

          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizer().fontSize14,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: AppSizer().fontSize12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),

                // Comment text or Edit TextField
                if (_editingCommentId == comment.id)
                  // Edit TextField
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _getEditController(
                              comment.id ?? '',
                              comment.comment ?? '',
                            ),
                            focusNode: _getEditFocusNode(comment.id ?? ''),
                            decoration: InputDecoration(
                              hintText: 'Edit your comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.appGreen,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) =>
                                _submitEdit(comment.id ?? ''),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Send button
                        IconButton(
                          icon: Icon(Icons.send, color: AppColors.appGreen),
                          onPressed: () => _submitEdit(comment.id ?? ''),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        // Cancel button
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: _cancelEdit,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                else
                  // Normal Comment text
                  Text(
                    comment.comment ?? '',
                    style: TextStyle(
                      fontSize: AppSizer().fontSize14,
                      color: Colors.black87,
                    ),
                  ),

                // Edit/Reply/Delete Actions Row
                if (_editingCommentId != comment.id) SizedBox(height: 8),
                if (_editingCommentId != comment.id)
                  Row(
                    children: [
                      // Reply button (for all comments)
                      TextButton.icon(
                        onPressed: () {
                          _startReply(comment.id ?? '');
                        },
                        icon: Icon(Icons.reply, size: 16),
                        label: Text('Reply'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.appGreen,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),

                      // Edit button (only for own comments)
                      if (isOwnComment)
                        TextButton.icon(
                          onPressed: () {
                            _startEdit(comment.id ?? '');
                          },
                          icon: Icon(Icons.edit_outlined, size: 16),
                          label: Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                      // Delete button (only for own comments)
                      // Delete button (only for own comments)
                      if (isOwnComment)
                        TextButton.icon(
                          onPressed: () {
                            _showDeleteDialog(comment.id ?? '');
                          },
                          icon: Icon(Icons.delete_outline, size: 16),
                          label: Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),

                // Reply TextField (shown below comment when replying)
                if (_replyingToCommentId == comment.id)
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${userName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _getReplyController(
                                  comment.id ?? '',
                                ),
                                focusNode: _getReplyFocusNode(comment.id ?? ''),
                                decoration: InputDecoration(
                                  hintText: 'Write your reply...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.appGreen,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (value) =>
                                    _submitReply(comment.id ?? ''),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Send button
                            IconButton(
                              icon: Icon(Icons.send, color: AppColors.appGreen),
                              onPressed: () => _submitReply(comment.id ?? ''),
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                            ),
                            // Cancel button
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: _cancelReply,
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addComment(String text) {
    print('\n========== COMMENT SEND BUTTON PRESSED ==========');
    print('📝 Comment text: "$text"');
    print('📏 Comment length: ${text.length}');
    print('❓ Is empty: ${text.trim().isEmpty}');
    print('🎯 Target ID: ${widget.targetId}');
    print('🏷️  Is Product: ${widget.isProduct}');
    print('🏷️  Target Type: ${widget.isProduct ? "product" : "car"}');

    if (text.trim().isEmpty) {
      print('❌ Comment is empty, not sending');
      print('========================================\n');
      return;
    }

    // Clear text field immediately
    print('🧹 Clearing text field immediately...');
    _textController.clear();

    if (widget.isProduct) {
      print('📤 Calling commentController.addProductComment...');
      widget.commentController.addProductComment(
        productId: widget.targetId,
        comment: text,
      );
    } else {
      print('📤 Calling commentController.addCarComment...');
      widget.commentController.addCarComment(
        carId: widget.targetId,
        comment: text,
      );
    }
    print('========================================\n');
  }

  void _submitReply(String parentCommentId) async {
    final replyText = _getReplyController(parentCommentId).text.trim();
    if (replyText.isEmpty) {
      Get.snackbar(
        'Error',
        'Reply cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Clear the reply field and hide reply box
    _getReplyController(parentCommentId).clear();
    setState(() {
      _replyingToCommentId = null;
    });

    // Post reply
    await widget.commentController.replyToComment(
      parentCommentId: parentCommentId,
      comment: replyText,
      isProduct: widget.isProduct,
      targetId: widget.targetId,
    );
  }

  void _submitEdit(String commentId) async {
    final newText = _getEditController(commentId, '').text.trim();
    if (newText.isEmpty) {
      Get.snackbar(
        'Error',
        'Comment cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Hide edit field
    setState(() {
      _editingCommentId = null;
    });

    // Edit comment
    await widget.commentController.editComment(
      commentId: commentId,
      comment: newText,
      isProduct: widget.isProduct,
      targetId: widget.targetId,
    );
  }

  void _showDeleteDialog(String commentId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(context).pop();
              // Then delete comment
              await widget.commentController.deleteComment(
                commentId: commentId,
                isProduct: widget.isProduct,
                targetId: widget.targetId,
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
