// lib/src/view/home/chat_details/chat_details_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
                // Attachment button (WhatsApp style)
                Builder(
                  builder: (ctx) => Container(
                    decoration: BoxDecoration(
                      color: ready
                          ? const Color(0xff232e33)
                          : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: ready ? AppColors.appGreen : Colors.grey,
                        size: 28,
                      ),
                      onPressed: ready
                          ? () => _showAttachmentOptions(ctx, c)
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: AppSizer().width1),
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
                Obx(() {
                  final isSending = c.isSendingMedia.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: ready
                          ? const Color(0xFF075E54)
                          : Colors.grey.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              color: AppColors.appWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.appWhite,
                            ),
                            onPressed: ready ? c.sendMessage : null,
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Show attachment options (WhatsApp style)
  void _showAttachmentOptions(BuildContext context, ChatDetailsController c) {
    print('📎 [ChatMedia] Showing attachment options');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.appGreen,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).pop();
                    c.pickAndSendImage(source: ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.of(context).pop();
                    c.pickAndSendImage(source: ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).pop();
                    c.pickAndSendVideo();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
