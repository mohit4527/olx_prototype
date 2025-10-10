// lib/src/controller/chat_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/chat_model/chat_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';
import '../utils/app_routes.dart';
import 'chat_details_controller.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;
  var chats = <Chat>[].obs;
  String? userId;

  var selectionMode = false.obs;
  var selectedChats = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserIdAndFetchChats();
  }

  // Helper to safely show snackbars after the current frame to ensure
  // overlay/context is available. Calling Get.snackbar directly during
  // controller initialization can cause a null overlay and crash.
  void _showSnackbar(String title, String message, {Color? backgroundColor}) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor ?? AppColors.appRed,
        );
      });
    } catch (e) {
      // Fallback: schedule on microtask if WidgetsBinding isn't ready
      Future.microtask(
        () => Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor ?? AppColors.appRed,
        ),
      );
    }
  }

  Future<void> _loadUserIdAndFetchChats() async {
    userId = await AuthService.getLoggedInUserId();
    if (userId != null) {
      await fetchChats();
    } else {
      isLoading(false);
      _showSnackbar(
        "Error",
        "User not logged in",
        backgroundColor: AppColors.appRed,
      );
    }
  }

  Future<void> fetchChats() async {
    try {
      isLoading(true);
      if (userId == null) {
        _showSnackbar(
          "Error",
          "User not logged in",
          backgroundColor: AppColors.appRed,
        );
        return;
      }
      final result = await ApiService.getChats(userId!);

      final Map<String, Chat> localChatMap = {for (var c in chats) c.id: c};
      for (int i = 0; i < result.length; i++) {
        if (localChatMap.containsKey(result[i].id)) {
          final localChat = localChatMap[result[i].id]!;
          result[i] = result[i].copyWith(
            lastMessage: localChat.lastMessage ?? result[i].lastMessage,
            time: localChat.time ?? result[i].time,
          );
        }
      }

      result.sort((a, b) {
        final aTime =
            DateTime.tryParse(a.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      chats.assignAll(result);
    } catch (e) {
      _showSnackbar(
        "Error",
        "Failed to load chats: ${e.toString()}",
        backgroundColor: AppColors.appRed,
      );
    } finally {
      isLoading(false);
    }
  }

  void toggleSelectionMode(String chatId) {
    if (!selectionMode.value) {
      selectionMode.value = true;
      selectedChats.add(chatId);
    }
  }

  void toggleChatSelection(String chatId) {
    if (selectedChats.contains(chatId)) {
      selectedChats.remove(chatId);
    } else {
      selectedChats.add(chatId);
    }
    if (selectedChats.isEmpty) {
      selectionMode.value = false;
    }
  }

  void selectAllChats() {
    selectionMode.value = true;
    selectedChats.clear();
    for (var chat in chats) {
      selectedChats.add(chat.id);
    }
  }

  void cancelSelection() {
    selectionMode.value = false;
    selectedChats.clear();
  }

  void deleteSelectedChats() {
    chats.removeWhere((c) => selectedChats.contains(c.id));
    selectedChats.clear();
    selectionMode.value = false;
    Get.snackbar(
      'Deleted',
      'Selected chats removed locally',
      backgroundColor: Colors.green,
    );
  }

  void updateLastMessage(String chatId, String lastMessage, String time) {
    final chatToUpdate = chats.firstWhereOrNull((c) => c.id == chatId);
    if (chatToUpdate != null) {
      chats.removeWhere((c) => c.id == chatId);
      final updatedChat = chatToUpdate.copyWith(
        lastMessage: lastMessage,
        time: time,
        productImage: chatToUpdate.productImage,
        profilePicture: chatToUpdate.profilePicture,
      );
      chats.insert(0, updatedChat);
    }
  }

  /// Called when a new incoming message is received (e.g. via push/socket).
  /// If [incrementUnread] is true, unreadCount will be incremented by 1.
  /// If [unreadCount] is provided it will overwrite the existing value.
  void markIncomingMessage(
    String chatId,
    String lastMessage,
    String time, {
    bool incrementUnread = true,
    int? unreadCount,
  }) {
    final chatToUpdate = chats.firstWhereOrNull((c) => c.id == chatId);
    if (chatToUpdate != null) {
      chats.removeWhere((c) => c.id == chatId);
      final newUnread =
          unreadCount ??
          (incrementUnread
              ? (chatToUpdate.unreadCount + 1)
              : chatToUpdate.unreadCount);
      final updatedChat = chatToUpdate.copyWith(
        lastMessage: lastMessage,
        time: time,
        unreadCount: newUnread,
        productImage: chatToUpdate.productImage,
        profilePicture: chatToUpdate.profilePicture,
      );
      chats.insert(0, updatedChat);
    } else {
      // If chat not found locally, attempt to create a minimal chat entry so it appears
      final newChat = Chat(
        id: chatId,
        productId: null,
        productName: null,
        sellerId: null,
        buyerId: null,
        sellerName: null,
        productImage: null,
        profilePicture: null,
        lastMessage: lastMessage,
        time: time,
        unreadCount: unreadCount ?? (incrementUnread ? 1 : 0),
      );
      chats.insert(0, newChat);
    }
  }

  void updateChatImage(String productId, String imageUrl) {
    final index = chats.indexWhere((c) => c.productId == productId);
    if (index != -1) {
      final updatedChat = chats[index].copyWith(productImage: imageUrl);
      chats[index] = updatedChat;
      chats.refresh(); // notify UI
    }
  }

  Future<void> startAndNavigateToChat({
    required String productId,
    required String productName,
    required String sellerId,
    String? productImage,
  }) async {
    final buyerId = await AuthService.getLoggedInUserId();
    if (buyerId == null || productId.isEmpty || sellerId.isEmpty) {
      Get.snackbar(
        "Error",
        "Required user or product ID is missing.",
        backgroundColor: AppColors.appRed,
      );
      return;
    }

    try {
      final existingChat = chats.firstWhereOrNull(
        (c) => c.productId == productId,
      );
      if (existingChat != null) {
        if (Get.isRegistered<ChatDetailsController>()) {
          Get.delete<ChatDetailsController>(force: true);
        }
        Get.toNamed(AppRoutes.chat_details, arguments: existingChat);
        return;
      }

      final newChatId = await ApiService.startChat(
        productId,
        buyerId,
        sellerId,
      );
      if (newChatId.isEmpty) throw Exception("Empty chat ID received.");

      final newChat = Chat(
        id: newChatId,
        productId: productId,
        productName: productName,
        sellerId: sellerId,
        buyerId: buyerId,
        productImage: productImage,
        lastMessage: '',
        time: DateTime.now().toIso8601String(),
      );

      chats.removeWhere((c) => c.id == newChat.id);
      chats.insert(0, newChat);

      if (Get.isRegistered<ChatDetailsController>()) {
        Get.delete<ChatDetailsController>(force: true);
      }
      Get.toNamed(AppRoutes.chat_details, arguments: newChat);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to start chat: ${e.toString()}",
        backgroundColor: AppColors.appRed,
      );
    }
  }
}
