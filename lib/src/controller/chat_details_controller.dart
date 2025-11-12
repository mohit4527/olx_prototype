import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/chat_model/chat_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';
import 'chat_controller.dart';

class ChatDetailsController extends GetxController {
  late Chat chat;
  String? userId;
  final messageController = TextEditingController();
  var messages = <Message>[].obs;
  var isLoading = true.obs;
  var isReady = false.obs;

  Future<void> initChat(dynamic newChatArg) async {
    try {
      isLoading(true);
      isReady(false);
      String? initialMessage;
      if (newChatArg is Chat) {
        chat = newChatArg;
      } else if (newChatArg is Map) {
        // arguments passed as {'chat': Chat, 'initialMessage': '...'}
        chat = newChatArg['chat'] as Chat;
        initialMessage = newChatArg['initialMessage'] as String?;
      } else {
        Get.snackbar(
          "Error",
          "Invalid chat argument.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        isLoading(false);
        return;
      }
      messages.clear();

      userId ??= await AuthService.getLoggedInUserId();
      if (userId == null || chat.id.isEmpty) {
        isLoading(false);
        Get.snackbar(
          "Error",
          "User or Chat details are missing.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }

      await fetchMessages();

      // If we have an initial message provided, prefill the input so user sees context
      if (initialMessage != null && initialMessage.isNotEmpty) {
        messageController.text = initialMessage;
      }

      isReady(true);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to init chat: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMessages() async {
    try {
      isLoading(true);
      if (chat.id.isEmpty) {
        Get.snackbar(
          "Error",
          "Chat ID is empty.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }
      final result = await ApiService.getMessages(chat.id);
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      messages.assignAll(result);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load messages: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    if (!isReady.value || userId == null || chat.id.isEmpty) {
      Get.snackbar(
        "Error",
        "Chat is not ready. Please wait.",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
      return;
    }

    messageController.clear();

    // Optimistic UI
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chat.id,
      senderId: userId!,
      content: content,
      createdAt: DateTime.now(),
    );
    messages.add(tempMessage);

    try {
      final sent = await ApiService.sendMessage(chat.id, userId!, content);

      final idx = messages.indexWhere((m) => m.id == tempMessage.id);
      if (idx != -1) messages[idx] = sent;

      final chatController = Get.find<ChatController>();
      chatController.updateLastMessage(
        chat.id,
        sent.content,
        sent.createdAt.toIso8601String(),
      );
    } catch (e) {
      messages.removeWhere((m) => m.id == tempMessage.id);
      messageController.text = content;
      Get.snackbar(
        "Error",
        "Failed to send message: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
