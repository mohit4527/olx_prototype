import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  var isSendingMedia = false.obs;
  final ImagePicker _picker = ImagePicker();

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

  // Pick and send image
  Future<void> pickAndSendImage({required ImageSource source}) async {
    try {
      print('📷 [ChatMedia] Starting image picker, source: $source');

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        print('⚠️ [ChatMedia] No image selected');
        return;
      }

      print('✅ [ChatMedia] Image picked: ${pickedFile.path}');
      final file = File(pickedFile.path);
      await _sendMediaFile(file, 'image');
    } catch (e) {
      print('❌ [ChatMedia] Error picking image: $e');
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }

  // Pick and send video
  Future<void> pickAndSendVideo() async {
    try {
      print('🎥 [ChatMedia] Starting video picker');

      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        print('⚠️ [ChatMedia] No video selected');
        return;
      }

      print('✅ [ChatMedia] Video picked: ${pickedFile.path}');
      final file = File(pickedFile.path);
      await _sendMediaFile(file, 'video');
    } catch (e) {
      print('❌ [ChatMedia] Error picking video: $e');
      Get.snackbar(
        "Error",
        "Failed to pick video: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }

  // Send media file
  Future<void> _sendMediaFile(File file, String mediaType) async {
    if (!isReady.value || userId == null || chat.id.isEmpty) {
      print('❌ [ChatMedia] Chat not ready');
      Get.snackbar(
        "Error",
        "Chat is not ready. Please wait.",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
      return;
    }

    try {
      print('📤 [ChatMedia] Starting to send $mediaType');
      print('📤 [ChatMedia] File: ${file.path}');
      print('📤 [ChatMedia] ChatId: ${chat.id}');
      print('📤 [ChatMedia] SenderId: $userId');

      isSendingMedia(true);

      // Show loading message
      Get.snackbar(
        "Sending",
        "Uploading $mediaType...",
        backgroundColor: AppColors.appGreen.withOpacity(0.8),
        colorText: AppColors.appWhite,
        duration: const Duration(seconds: 2),
      );

      final sentMessage = await ApiService.sendMediaMessage(
        chatId: chat.id,
        senderId: userId!,
        mediaFile: file,
      );

      print('✅ [ChatMedia] Message sent successfully!');
      print('✅ [ChatMedia] Message ID: ${sentMessage.id}');
      print('✅ [ChatMedia] Content: ${sentMessage.content}');

      messages.add(sentMessage);

      // Update chat list
      final chatController = Get.find<ChatController>();
      chatController.updateLastMessage(
        chat.id,
        sentMessage.content ?? '[$mediaType]',
        sentMessage.createdAt.toIso8601String(),
      );

      Get.snackbar(
        "Success",
        "${mediaType.capitalize} sent successfully!",
        backgroundColor: AppColors.appGreen,
        colorText: AppColors.appWhite,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [ChatMedia] Failed to send $mediaType: $e');
      
      // Better error message for server issues
      String errorMsg;
      if (e.toString().contains('ENOENT') || e.toString().contains('no such file')) {
        errorMsg = "Server upload folder not configured. Please contact support.";
      } else if (e.toString().contains('500')) {
        errorMsg = "Server error. Please try again later.";
      } else {
        errorMsg = "Failed to send $mediaType. Check your connection.";
      }
      
      Get.snackbar(
        "Upload Failed",
        errorMsg,
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSendingMedia(false);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
