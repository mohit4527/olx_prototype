// lib/src/view/home/chat_details/chat_details_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/chat_details_controller.dart';
import '../../../custom_widgets/chat_screen_helper.dart';
import '../../../model/chat_model/chat_model.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final ChatDetailsController c = Get.put(ChatDetailsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.initChat(args);
    });

    // determine display chat & sellerName for header rendering
    Chat chat;
    String? sellerName;
    if (args is Chat) {
      chat = args;
    } else if (args is Map && args['chat'] is Chat) {
      chat = args['chat'] as Chat;
      sellerName = args['sellerName'] as String?;
    } else {
      // fallback: create a minimal chat to avoid crashes
      chat = Chat(
        id: '',
        productId: null,
        productName: null,
        sellerId: null,
        buyerId: null,
        sellerName: sellerName ?? 'Seller',
        productImage: null,
        profilePicture: null,
        lastMessage: null,
        time: null,
      );
    }

    return Scaffold(
      key: ValueKey(chat.id),
      backgroundColor: AppColors.appBlack,
      appBar: AppBar(
        backgroundColor: AppColors.appBlack,
        leadingWidth: 70,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                final sellerId = chat.sellerId ?? '';
                final displayName = sellerName ?? chat.sellerName ?? 'User';

                if (sellerId.isNotEmpty) {
                  // Navigate to seller products screen with profile mode
                  Get.toNamed(
                    '/ads_screen',
                    arguments: {
                      'profileUserId': sellerId,
                      'profileName': displayName,
                      'profileAvatar': chat.profilePicture ?? '',
                    },
                  );
                }
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: ChatTile.buildChatImage(
                  chat.productImage,
                  chat.profilePicture,
                ),
              ),
            ),
            SizedBox(width: AppSizer().width1),
            Expanded(
              child: Text(
                // Prefer product name in the chat header when available,
                // fall back to provided sellerName or the chat display name.
                chat.productName ?? sellerName ?? chat.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.flag, color: AppColors.appWhite),
          SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundchat.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  key: ValueKey("list-${chat.id}"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  reverse: true,
                  itemCount: c.messages.length,
                  itemBuilder: (context, index) {
                    final m = c.messages[c.messages.length - 1 - index];
                    return MessageBubble(
                      message: m,
                      currentUserId: c.userId ?? "",
                    );
                  },
                );
              }),
            ),
            _buildMessageInput(c),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatDetailsController c) {
    return Obx(() {
      final ready = c.isReady.value;
      return Container(
        color: AppColors.appBlack,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: ready
                          ? const Color(0xff232e33)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: c.messageController,
                      enabled: ready,
                      style: const TextStyle(color: Colors.white),
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      // We don't use onSubmitted for send because Enter should insert a newline.
                    ),
                  ),
                ),
                SizedBox(width: AppSizer().width1),
                Container(
                  decoration: BoxDecoration(
                    color: ready
                        ? const Color(0xFF075E54)
                        : Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.appWhite),
                    onPressed: ready ? c.sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
