// lib/src/custom_widgets/chat_screen_helper.dart

import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/chat_model/chat_model.dart';
import 'package:intl/intl.dart';

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
        style: const TextStyle(
          color: Colors.grey,
        ),
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

  static ImageProvider buildChatImage(String? productImage,
      String? profilePicture) {
    String? imageUrl;

    if (profilePicture != null && profilePicture.isNotEmpty) {
      if (profilePicture.startsWith("http")) {
        imageUrl = profilePicture;
      } else {
        imageUrl = "https://oldmarket.bhoomi.cloud/${profilePicture.replaceAll(
            "\\", "/")}";
      }
    } else if (productImage != null && productImage.isNotEmpty) {
      if (productImage.startsWith("http")) {
        imageUrl = productImage;
      } else {
        imageUrl =
        "https://oldmarket.bhoomi.cloud/${productImage.replaceAll("\\", "/")}";
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

  const MessageBubble({Key? key, required this.message, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool sentByMe = message.senderId == currentUserId;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sentByMe ? const Color(0xFF075E54) : Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}