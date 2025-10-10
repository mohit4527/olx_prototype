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
    final Chat chat = Get.arguments as Chat;
    final ChatDetailsController c = Get.put(ChatDetailsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.initChat(chat);
    });

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
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: ChatTile.buildChatImage(
                chat.productImage,
                chat.profilePicture,
              ),
            ),
            SizedBox(width: AppSizer().width1),
            Expanded(
              child: Text(
                chat.displayName,
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 140),
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
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => ready ? c.sendMessage() : null,
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
      );
    });
  }
}
