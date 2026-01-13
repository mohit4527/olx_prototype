import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/comment_model/comment_model.dart';
import '../services/apiServices/apiServices.dart';
import '../controller/token_controller.dart';

class CommentController extends GetxController {
  final TokenController tokenController = Get.find<TokenController>();

  // Observable lists for comments
  var productComments = <Comment>[].obs;
  var carComments = <Comment>[].obs;

  // Loading states
  var isLoadingProductComments = false.obs;
  var isLoadingCarComments = false.obs;
  var isAddingComment = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMore = true.obs;

  // Text controller for comment input
  final commentTextController = TextEditingController();

  @override
  void onClose() {
    commentTextController.dispose();
    super.onClose();
  }

  /// Add comment on product
  Future<void> addProductComment({
    required String productId,
    required String comment,
  }) async {
    print('\n🟢 [CommentController.addProductComment] START');
    print('Parameters:');
    print('  - productId: $productId');
    print('  - comment: "$comment"');
    print('  - comment.trim().isEmpty: ${comment.trim().isEmpty}');

    if (comment.trim().isEmpty) {
      print('❌ Comment is empty!');
      Get.snackbar(
        'Error',
        'Please enter a comment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('🟢 [CommentController.addProductComment] END - Empty Comment\n');
      return;
    }

    try {
      isAddingComment.value = true;
      print('🔄 isAddingComment set to TRUE');

      final userId = tokenController.userUid.value;
      print('👤 User ID: $userId');
      print('👤 User ID is empty: ${userId.isEmpty}');

      print('💬 Comment to add: "$comment"');
      print('📡 Calling ApiService.addCommentOnProduct...');

      final response = await ApiService.addCommentOnProduct(
        userId: userId,
        productId: productId,
        comment: comment,
      );

      print('📥 API Response received:');
      print('  - Response is null: ${response == null}');
      if (response != null) {
        print('  - Response: $response');
        print('  - Status: ${response['status']}');
        print('  - Message: ${response['message']}');
      }

      if (response != null && response['status'] == true) {
        print('✅ Comment added successfully!');

        // Refresh comments list
        print('🔄 Fetching updated comments...');
        await getProductComments(productId: productId);

        Get.snackbar(
          'Success',
          'Comment added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        print('🟢 [CommentController.addProductComment] END - SUCCESS\n');
      } else {
        print('❌ Failed to add comment!');
        final errorMsg = response?['message'] ?? 'Failed to add comment';
        print('Error message: $errorMsg');
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print('🟢 [CommentController.addProductComment] END - FAILURE\n');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in addProductComment:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('🟢 [CommentController.addProductComment] END - EXCEPTION\n');
    } finally {
      isAddingComment.value = false;
      print('🔄 isAddingComment set to FALSE');
    }
  }

  /// Get product comments
  Future<void> getProductComments({
    required String productId,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      isLoadingProductComments.value = true;
      currentPage.value = 1;
      productComments.clear();
    }

    try {
      print(
        '[CommentController] 📖 Fetching product comments, page: ${currentPage.value}',
      );

      final response = await ApiService.getProductComments(
        productId: productId,
        page: currentPage.value,
        limit: 10,
      );

      print('📥 GET Comments Response:');
      print('  - Response is null: ${response == null}');
      if (response != null) {
        print('  - Full Response: $response');
        print('  - Status key exists: ${response.containsKey('status')}');
        print('  - Status value: ${response['status']}');
        print('  - Comments key exists: ${response.containsKey('comments')}');
        print('  - Data key exists: ${response.containsKey('data')}');
      }

      if (response != null && response['status'] == true) {
        // API returns comments in 'data' array
        final commentsData = response['data'] as List?;
        if (commentsData != null) {
          final newComments = commentsData
              .map((c) => Comment.fromJson(c))
              .toList();

          if (loadMore) {
            productComments.addAll(newComments);
          } else {
            productComments.value = newComments;
          }

          print('✅ Comments parsed successfully!');
          print('📊 Total comments in list: ${productComments.length}');
          print(
            '📝 Comments: ${productComments.map((c) => c.comment).toList()}',
          );

          // Check if there are more pages
          final pagination = response['pagination'];
          if (pagination != null) {
            final totalPages = pagination['totalPages'] ?? 1;
            hasMore.value = currentPage.value < totalPages;
          } else {
            hasMore.value = false;
          }

          print('[CommentController] ✅ Loaded ${newComments.length} comments');
        }
      }
    } catch (e) {
      print('[CommentController] ❌ Error fetching comments: $e');
    } finally {
      isLoadingProductComments.value = false;
    }
  }

  /// Add comment on car (dealer product)
  Future<void> addCarComment({
    required String carId,
    required String comment,
  }) async {
    print('\n🔵 [CommentController.addCarComment] START');
    print('Parameters:');
    print('  - carId: $carId');
    print('  - comment: "$comment"');
    print('  - comment.trim().isEmpty: ${comment.trim().isEmpty}');

    if (comment.trim().isEmpty) {
      print('❌ Comment is empty!');
      Get.snackbar(
        'Error',
        'Please enter a comment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('🔵 [CommentController.addCarComment] END - Empty Comment\n');
      return;
    }

    try {
      isAddingComment.value = true;
      print('🔄 isAddingComment set to TRUE');

      final userId = tokenController.userUid.value;
      print('👤 User ID: $userId');
      print('👤 User ID is empty: ${userId.isEmpty}');

      print('💬 Comment to add: "$comment"');
      print('📡 Calling ApiService.addCommentOnCar...');

      final response = await ApiService.addCommentOnCar(
        userId: userId,
        carId: carId,
        comment: comment,
      );

      print('📥 API Response received:');
      print('  - Response is null: ${response == null}');
      if (response != null) {
        print('  - Response: $response');
        print('  - Status: ${response['status']}');
        print('  - Message: ${response['message']}');
      }

      if (response != null && response['status'] == true) {
        print('✅ Comment added successfully!');

        // Refresh comments list
        print('🔄 Fetching updated comments...');
        await getCarComments(carId: carId);

        Get.snackbar(
          'Success',
          'Comment added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        print('🔵 [CommentController.addCarComment] END - SUCCESS\n');
      } else {
        print('❌ Failed to add comment!');
        final errorMsg = response?['message'] ?? 'Failed to add comment';
        print('Error message: $errorMsg');
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print('🔵 [CommentController.addCarComment] END - FAILURE\n');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in addCarComment:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('🔵 [CommentController.addCarComment] END - EXCEPTION\n');
    } finally {
      isAddingComment.value = false;
      print('🔄 isAddingComment set to FALSE');
    }
  }

  /// Get car comments
  Future<void> getCarComments({
    required String carId,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      isLoadingCarComments.value = true;
      currentPage.value = 1;
      carComments.clear();
    }

    try {
      print(
        '[CommentController] 📖 Fetching car comments, page: ${currentPage.value}',
      );

      final response = await ApiService.getCarComments(
        carId: carId,
        page: currentPage.value,
        limit: 10,
      );

      print('📥 GET Car Comments Response:');
      print('  - Response is null: ${response == null}');
      if (response != null) {
        print('  - Full Response: $response');
        print('  - Status key exists: ${response.containsKey('status')}');
        print('  - Status value: ${response['status']}');
        print('  - Comments key exists: ${response.containsKey('comments')}');
        print('  - Data key exists: ${response.containsKey('data')}');
      }

      if (response != null && response['status'] == true) {
        // API returns comments in 'data' array
        final commentsData = response['data'] as List?;
        if (commentsData != null) {
          final newComments = commentsData
              .map((c) => Comment.fromJson(c))
              .toList();

          if (loadMore) {
            carComments.addAll(newComments);
          } else {
            carComments.value = newComments;
          }

          // Check if there are more pages
          final pagination = response['pagination'];
          if (pagination != null) {
            final totalPages = pagination['totalPages'] ?? 1;
            hasMore.value = currentPage.value < totalPages;
          } else {
            hasMore.value = false;
          }

          print('[CommentController] ✅ Loaded ${newComments.length} comments');
        }
      }
    } catch (e) {
      print('[CommentController] ❌ Error fetching comments: $e');
    } finally {
      isLoadingCarComments.value = false;
    }
  }

  /// Delete comment
  Future<void> deleteComment({
    required String commentId,
    required bool isProduct,
    required String targetId,
  }) async {
    try {
      final userId = tokenController.userUid.value;

      print('[CommentController] 🗑️ Deleting comment: $commentId');

      final success = await ApiService.deleteComment(
        commentId: commentId,
        userId: userId,
      );

      if (success) {
        print('[CommentController] ✅ Comment deleted successfully');

        // Refresh comments list
        if (isProduct) {
          await getProductComments(productId: targetId);
        } else {
          await getCarComments(carId: targetId);
        }

        Get.snackbar(
          'Success',
          'Comment deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete comment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[CommentController] ❌ Error deleting comment: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Edit comment
  Future<void> editComment({
    required String commentId,
    required String comment,
    required bool isProduct,
    required String targetId,
  }) async {
    try {
      final userId = tokenController.userUid.value;

      print('[CommentController] ✏️ Editing comment: $commentId');

      final response = await ApiService.editComment(
        commentId: commentId,
        userId: userId,
        comment: comment,
      );

      if (response != null && response['status'] == true) {
        print('[CommentController] ✅ Comment edited successfully');

        // Refresh comments list
        if (isProduct) {
          await getProductComments(productId: targetId);
        } else {
          await getCarComments(carId: targetId);
        }

        Get.snackbar(
          'Success',
          'Comment updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to edit comment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[CommentController] ❌ Error editing comment: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reply to comment
  Future<void> replyToComment({
    required String parentCommentId,
    required String comment,
    required bool isProduct,
    required String targetId,
  }) async {
    try {
      final userId = tokenController.userUid.value;

      print('[CommentController] 💬 Replying to comment: $parentCommentId');

      final response = await ApiService.replyToComment(
        parentCommentId: parentCommentId,
        userId: userId,
        comment: comment,
        targetType: isProduct ? 'product' : 'car',
        targetId: targetId,
      );

      if (response != null && response['status'] == true) {
        print('[CommentController] ✅ Reply posted successfully');

        // Refresh comments list
        if (isProduct) {
          await getProductComments(productId: targetId);
        } else {
          await getCarComments(carId: targetId);
        }

        Get.snackbar(
          'Success',
          'Reply posted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to post reply',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[CommentController] ❌ Error posting reply: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Load more comments
  Future<void> loadMoreComments({
    required String targetId,
    required bool isProduct,
  }) async {
    if (!hasMore.value) return;

    currentPage.value++;

    if (isProduct) {
      await getProductComments(productId: targetId, loadMore: true);
    } else {
      await getCarComments(carId: targetId, loadMore: true);
    }
  }
}
