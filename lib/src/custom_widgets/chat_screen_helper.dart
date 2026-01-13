// lib/src/custom_widgets/chat_screen_helper.dart

import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/chat_model/chat_model.dart';
import 'package:intl/intl.dart';
import '../view/home/chat_details/video_player_screen.dart';

/// Helper function to format the time since the last message
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d';
  } else {
    return DateFormat('d MMM').format(dateTime);
  }
}

/// ------------------------- Chat Tile -------------------------
class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({Key? key, required this.chat, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: buildChatImage(chat.productImage, chat.profilePicture),
        onBackgroundImageError: (_, __) =>
            const Icon(Icons.person, color: AppColors.appWhite),
      ),
      title: Text(
        chat.displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.appWhite,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time != null ? formatTimeAgo(DateTime.parse(chat.time!)) : '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.appBlack,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  static ImageProvider buildChatImage(
    String? productImage,
    String? profilePicture,
  ) {
    String? imageUrl;

    // अब product image को priority देते हैं क्योंकि chat product के बारे में है
    if (productImage != null && productImage.isNotEmpty) {
      if (productImage.startsWith("http")) {
        imageUrl = productImage;
      } else {
        imageUrl =
            "https://oldmarket.bhoomi.cloud/${productImage.replaceAll("\\", "/")}";
      }
    } else if (profilePicture != null && profilePicture.isNotEmpty) {
      if (profilePicture.startsWith("http")) {
        imageUrl = profilePicture;
      } else {
        imageUrl =
            "https://oldmarket.bhoomi.cloud/${profilePicture.replaceAll("\\", "/")}";
      }
    }

    if (imageUrl != null) {
      return NetworkImage(imageUrl);
    } else {
      return const AssetImage("assets/images/OldMarketLogo.png");
    }
  }
}

// ------------------------- Message Bubble -------------------------
class MessageBubble extends StatelessWidget {
  final Message message;
  final String currentUserId;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool sentByMe = message.senderId == currentUserId;
    final messageType = message.messageType ?? 'text';
    final isMedia = messageType == 'image' || messageType == 'video';

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: isMedia ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sentByMe ? const Color(0xFF075E54) : Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: _buildMessageContent(context, messageType),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, String messageType) {
    switch (messageType) {
      case 'image':
        return _buildImageMessage(context);
      case 'video':
        return _buildVideoMessage(context);
      default:
        return Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        );
    }
  }

  Widget _buildImageMessage(BuildContext context) {
    if (message.mediaUrl == null || message.mediaUrl!.isEmpty) {
      return const Text('Image', style: TextStyle(color: Colors.white70));
    }

    // Build full URL
    final String baseUrl = 'https://oldmarket.bhoomi.cloud';
    final String imageUrl = message.mediaUrl!.startsWith('http')
        ? message.mediaUrl!
        : '$baseUrl${message.mediaUrl}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, imageUrl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
            minWidth: 150,
            minHeight: 150,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 180,
                height: 180,
                color: Colors.grey.shade800,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 180,
                height: 180,
                color: Colors.grey.shade800,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    if (message.mediaUrl == null || message.mediaUrl!.isEmpty) {
      return const Text('Video', style: TextStyle(color: Colors.white70));
    }

    // Build full URL
    final String baseUrl = 'https://oldmarket.bhoomi.cloud';
    final String videoUrl = message.mediaUrl!.startsWith('http')
        ? message.mediaUrl!
        : '$baseUrl${message.mediaUrl}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () => _playVideo(context, videoUrl),
        child: Container(
          width: 180,
          height: 180,
          color: Colors.grey.shade800,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 50,
                color: Colors.white,
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Video',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(child: Image.network(imageUrl)),
          ),
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: videoUrl)),
    );
  }
}
