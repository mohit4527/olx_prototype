// lib/src/view/home/chat/old_market_chats_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/chat_details_controller.dart';
import '../../../custom_widgets/chat_screen_helper.dart';
import '../../../model/chat_model/chat_model.dart';
import '../../../utils/app_routes.dart';

class OldMarketChatsScreen extends StatefulWidget {
  const OldMarketChatsScreen({Key? key}) : super(key: key);

  @override
  State<OldMarketChatsScreen> createState() => _OldMarketChatsScreenState();
}

class _OldMarketChatsScreenState extends State<OldMarketChatsScreen> {
  late final ChatController chatController;

  @override
  void initState() {
    super.initState();
    // Initialize controller once
    chatController = Get.put(ChatController(), permanent: false);
  }

  @override
  void dispose() {
    // Clean disposal
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        title: Text(
          'Old Market Chats',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          GetBuilder<ChatController>(
            builder: (controller) {
              final isSelection = controller.selectionMode.value;
              final hasSelected = controller.selectedChats.isNotEmpty;
              return isSelection
                  ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: hasSelected
                          ? () {
                              controller.deleteSelectedChats();
                              controller.update();
                            }
                          : null,
                    )
                  : const SizedBox.shrink();
            },
          ),

          // ✅ Popup Menu
          GetBuilder<ChatController>(
            builder: (controller) {
              final isSelection = controller.selectionMode.value;
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Select All') {
                    controller.selectAllChats();
                    controller.update();
                  } else if (value == 'Cancel') {
                    controller.cancelSelection();
                    controller.update();
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Select All',
                    enabled: !isSelection,
                    child: const Text('Select All'),
                  ),
                  if (isSelection)
                    const PopupMenuItem(value: 'Cancel', child: Text('Cancel')),
                ],
              );
            },
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [_buildChip('All Messages', isSelected: true)],
              ),
            ),
            Expanded(
              child: GetBuilder<ChatController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.chats.isEmpty) {
                    return const Center(
                      child: Text(
                        "No chats found",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: controller.chats.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final Chat chat = controller.chats[index];
                      final isSelected = controller.selectedChats.contains(
                        chat.id,
                      );
                      final selectionMode = controller.selectionMode.value;

                      return GestureDetector(
                        key: ValueKey('chat_${chat.id}_$index'),
                        onLongPress: () {
                          controller.toggleSelectionMode(chat.id);
                          controller.update();
                        },
                        onTap: () {
                          if (selectionMode) {
                            controller.toggleChatSelection(chat.id);
                            controller.update();
                          } else {
                            if (Get.isRegistered<ChatDetailsController>()) {
                              Get.delete<ChatDetailsController>(force: true);
                            }
                            Get.toNamed(
                              AppRoutes.chat_details,
                              arguments: chat,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.grey.shade800
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (selectionMode)
                                Container(
                                  width: 56,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) {
                                      controller.toggleChatSelection(chat.id);
                                      controller.update();
                                    },
                                    checkColor: Colors.white,
                                    activeColor: AppColors.appGreen,
                                  ),
                                )
                              else
                                Container(
                                  width: 56,
                                  height: 56,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey.shade700,
                                        backgroundImage:
                                            ChatTile.buildChatImage(
                                              chat.productImage,
                                              chat.profilePicture,
                                            ),
                                      ),
                                      if (chat.unreadCount > 0)
                                        Positioned(
                                          right: -4,
                                          top: -4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black87,
                                                width: 1,
                                              ),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Center(
                                              child: Text(
                                                chat.unreadCount > 99
                                                    ? '99+'
                                                    : chat.unreadCount
                                                          .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chat.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chat.lastMessage ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(chat.time ?? ''),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false, int? unreadCount}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.appGreen : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        unreadCount != null ? '$label $unreadCount' : label,
        style: TextStyle(
          color: isSelected ? AppColors.appWhite : Colors.white70,
        ),
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24)
        return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
      if (diff.inDays == 1) return 'Yesterday';

      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return '';
    }
  }
}
