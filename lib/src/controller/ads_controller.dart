import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/model/short_video_model/short_video_model.dart';
import 'package:olx_prototype/src/model/all_product_model/all_product_model.dart';
import 'package:olx_prototype/src/model/user_desler_products/user_dealer_product_model.dart';
import 'short_video_controller.dart';

class AdsController extends GetxController {
  var loadingVideos = false.obs;
  var loadingProducts = false.obs;
  var myVideos = <VideoModel>[].obs;
  var myProducts = <AllProductModel>[].obs;
  var dealerProducts = <DealerProduct>[].obs;
  var loadingDealerProducts = false.obs;
  var lastError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('AdsController', 'onInit called');
    fetchMyVideos();
    fetchMyProducts();
  }

  Future<void> fetchMyVideos() async {
    try {
      Logger.d('AdsController', 'fetchMyVideos start');
      loadingVideos.value = true;
      // Use authenticated endpoint `/api/videos/my` which relies on Authorization header
      // This ensures the backend returns videos for the bearer-tokened user.
      final list = await ApiService.getMyVideos();

      // Ensure we only keep videos uploaded by the current user. Some backends
      // may return related items; double-check by filtering on uploaderId.
      String currentUserId = '';
      try {
        final prefs = await SharedPreferences.getInstance();
        currentUserId =
            prefs.getString('userId') ?? prefs.getString('user_uid') ?? '';
      } catch (_) {}

      final filtered = list.where((v) {
        if (currentUserId.isEmpty)
          return true; // if we couldn't resolve userId, keep all
        return v.uploaderId.isNotEmpty && v.uploaderId == currentUserId;
      }).toList();

      myVideos.assignAll(filtered);
      Logger.d('AdsController', 'All videos loaded: ${myVideos.length}');
      lastError.value = '';
    } catch (e) {
      Logger.d('AdsController', 'fetchMyVideos error: $e');
      lastError.value = e.toString();
    } finally {
      loadingVideos.value = false;
    }
  }

  /// Refresh videos and products, optionally retrying when no videos are found.
  /// Returns true when at least one video or product is found.
  Future<bool> refreshWithRetry({int retries = 3, int delayMs = 1500}) async {
    for (var attempt = 0; attempt < retries; attempt++) {
      await Future.wait([fetchMyVideos(), fetchMyProducts()]);
      if (myVideos.isNotEmpty || myProducts.isNotEmpty) {
        return true;
      }
      // Wait before next attempt
      await Future.delayed(Duration(milliseconds: delayMs * (attempt + 1)));
    }
    // final attempt done, set helpful lastError if API provided one
    if (ApiService.apiLastError.isNotEmpty) {
      lastError.value = ApiService.apiLastError;
    }
    return false;
  }

  Future<void> fetchMyProducts() async {
    try {
      Logger.d('AdsController', 'fetchMyProducts start');
      loadingProducts.value = true;
      final mine = await ApiService.getMyProducts();
      myProducts.assignAll(mine);
      Logger.d('AdsController', 'All products loaded: ${myProducts.length}');
    } catch (e) {
      Logger.d('AdsController', 'fetchMyProducts error: $e');
    } finally {
      loadingProducts.value = false;
    }
  }

  /// Fetch dealer products for the logged-in dealer (if any)
  Future<void> fetchDealerProducts() async {
    try {
      Logger.d('AdsController', 'fetchDealerProducts start');
      loadingDealerProducts(true);
      final prefs = await SharedPreferences.getInstance();
      final dealerId = prefs.getString('dealerId') ?? '';
      Logger.d('AdsController', 'fetchDealerProducts -> dealerId=$dealerId');
      if (dealerId.isEmpty) {
        dealerProducts.clear();
        return;
      }

      // Call the backend map-style endpoint (used by controller logic)
      final res = await ApiService.getDealerCars(dealerId);
      Logger.d('AdsController', 'getDealerCars raw response: $res');

      if (res != null && res['status'] == true) {
        final List<dynamic> data = res['data'] ?? [];
        Logger.d('AdsController', 'getDealerCars data length: ${data.length}');
        final parsed = data
            .map((e) => DealerProduct.fromJson(e as Map<String, dynamic>))
            .toList();
        dealerProducts.assignAll(parsed);
        Logger.d(
          'AdsController',
          'dealerProducts parsed: ${dealerProducts.length}',
        );
      } else {
        dealerProducts.clear();
        Logger.d('AdsController', 'getDealerCars returned no data or error');
      }

      // Also call the alternative fetch method (list style) for extra debugging
      try {
        final alt = await ApiService.fetchDealerProducts();
        Logger.d(
          'AdsController',
          'fetchDealerProducts() alt returned ${alt.length} items',
        );
      } catch (e) {
        Logger.d('AdsController', 'fetchDealerProducts() alt call failed: $e');
      }
    } catch (e, st) {
      print('[AdsController] fetchDealerProducts error: $e\n$st');
      dealerProducts.clear();
    } finally {
      loadingDealerProducts(false);
    }
  }

  /// Delete a dealer car by type and id. dealerType is the category (e.g., "cars")
  Future<bool> deleteDealerProduct(String dealerType, String carId) async {
    try {
      Logger.d(
        'AdsController',
        'deleteDealerProduct called -> dealerType=$dealerType carId=$carId',
      );
      final ok = await ApiService.deleteDealerCar(dealerType, carId);
      Logger.d('AdsController', 'deleteDealerCar returned: $ok');
      if (ok) {
        dealerProducts.removeWhere((p) => p.id == carId);
        Logger.d('AdsController', 'Removed dealer product locally: $carId');
      }
      return ok;
    } catch (e, st) {
      print('[AdsController] deleteDealerProduct error: $e\n$st');
      return false;
    }
  }

  Future<bool> deleteVideo(String videoId) async {
    try {
      Logger.d('AdsController', 'deleteVideo start -> $videoId');

      // Optimistically remove the video from the local list so UI updates immediately.
      final index = myVideos.indexWhere((v) => v.id == videoId);
      VideoModel? removed;
      int removedIndexInShort = -1;
      VideoModel? removedFromShort;
      if (index >= 0) {
        removed = myVideos.removeAt(index);
        Logger.d(
          'AdsController',
          'Optimistically removed video locally: $videoId at index $index',
        );
      }

      // Also optimistically remove from global short videos lists so the deleted
      // video disappears everywhere at once. We'll try to restore on Undo.
      try {
        if (Get.isRegistered<ShortVideoController>()) {
          final shortCtrl = Get.find<ShortVideoController>();
          removedIndexInShort = shortCtrl.videos.indexWhere(
            (v) => v.id == videoId,
          );
          if (removedIndexInShort >= 0) {
            removedFromShort = shortCtrl.videos.removeAt(removedIndexInShort);
            // Also remove from suggestedVideos if present
            shortCtrl.suggestedVideos.removeWhere((v) => v.id == videoId);
            Logger.d(
              'AdsController',
              'Also removed from ShortVideoController at index $removedIndexInShort',
            );
          }
        }
      } catch (e) {
        Logger.d(
          'AdsController',
          'Could not remove from ShortVideoController: $e',
        );
      }
      // Show an Undo snackbar for a short time before actually calling the server.
      // If the user taps Undo, restore the item and cancel any pending background retry.
      final undone = Completer<bool>();

      // Show snackbar with Undo action
      Get.snackbar(
        'Deleted',
        'Video removed — undo?',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.appGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            if (!undone.isCompleted) undone.complete(true);
          },
          child: const Text('Undo', style: TextStyle(color: Colors.white)),
        ),
      );

      // Wait for either undo or timeout
      final completed = await Future.any([
        undone.future.catchError((_) => false),
        Future.delayed(const Duration(seconds: 4), () => false),
      ]);

      if (completed == true) {
        // User undid the delete — restore locally and cancel pending background retry.
        if (removed != null) {
          final insertAt = index.clamp(0, myVideos.length);
          myVideos.insert(insertAt, removed);
          Logger.d(
            'AdsController',
            'Restore by undo: $videoId at index $insertAt',
          );
        }
        // Restore in ShortVideoController too
        try {
          if (removedFromShort != null &&
              Get.isRegistered<ShortVideoController>()) {
            final shortCtrl = Get.find<ShortVideoController>();
            final insertAtShort = removedIndexInShort.clamp(
              0,
              shortCtrl.videos.length,
            );
            shortCtrl.videos.insert(insertAtShort, removedFromShort);
            // Optionally refresh suggestedVideos
            shortCtrl.fetchSuggestedVideos();
            Logger.d(
              'AdsController',
              'Restored video into ShortVideoController at $insertAtShort',
            );
          }
        } catch (e) {
          Logger.d(
            'AdsController',
            'Could not restore to ShortVideoController: $e',
          );
        }
        ApiService.cancelPendingDelete(videoId);
        return false;
      }

      // Proceed with server delete now (user did not undo)
      print('[AdsController] Calling ApiService.deleteVideoById for $videoId');
      final ok = await ApiService.deleteVideoById(videoId);
      print(
        '[AdsController] ApiService.deleteVideoById returned: $ok; apiLastError=${ApiService.apiLastError}',
      );
      if (ok) {
        // Ensure other controllers remove this video as well (finalize removal)
        try {
          if (Get.isRegistered<ShortVideoController>()) {
            final shortCtrl = Get.find<ShortVideoController>();
            shortCtrl.videos.removeWhere((v) => v.id == videoId);
            shortCtrl.suggestedVideos.removeWhere((v) => v.id == videoId);
            Logger.d(
              'AdsController',
              'Confirmed removal from ShortVideoController',
            );
          }
        } catch (e) {
          Logger.d(
            'AdsController',
            'Error while cleaning ShortVideoController after delete: $e',
          );
        }

        Get.snackbar(
          'Deleted',
          'Video deleted',
          backgroundColor: AppColors.appGreen,
          colorText: Colors.white,
        );
        return true;
      }

      // If server failed, notify and enqueue background retry.
      // Important UX change: do NOT automatically restore the item here.
      // Keeping the optimistic removal gives the user immediate feedback and
      // avoids flicker where the item reappears after a failed server call.
      // We enqueue a background delete and provide a "Restore" action in
      // the snackbar so the user can undo the scheduled deletion if desired.
      final errMsg = ApiService.apiLastError.isNotEmpty
          ? ApiService.apiLastError
          : 'Failed to delete video. Will retry in background.';
      print('[AdsController] Delete failed for $videoId; errMsg=$errMsg');

      Get.snackbar(
        'Delete scheduled',
        errMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () {
            // User asked to restore the item: cancel the background retry
            // and put the item back into the local list.
            ApiService.cancelPendingDelete(videoId);
            if (removed != null) {
              final insertAt = index.clamp(0, myVideos.length);
              myVideos.insert(insertAt, removed);
              Logger.d(
                'AdsController',
                'Restore after cancel pending delete: $videoId at index $insertAt',
              );
            }
          },
          child: const Text('Restore', style: TextStyle(color: Colors.white)),
        ),
      );

      // Enqueue background delete so the app will retry until the server
      // removes it. We intentionally keep the item removed locally to
      // avoid confusing UI flicker when server returns errors.
      ApiService.enqueueDelete(videoId);

      return false;
    } catch (e) {
      Logger.d('AdsController', 'deleteVideo error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      Logger.d('AdsController', 'deleteProduct start -> $productId');
      final ok = await ApiService.deleteMyProduct(productId);
      if (ok) {
        myProducts.removeWhere((p) => p.id == productId);
        Logger.d('AdsController', 'Product removed locally: $productId');
      }
      if (!ok) {
        final err = ApiService.apiLastError;
        Logger.d('AdsController', 'deleteProduct failed: $err');
        final retry = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete failed'),
            content: Text(err.isNotEmpty ? err : 'Failed to delete product'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        if (retry == true) {
          final retryOk = await ApiService.deleteMyProduct(productId);
          if (retryOk) {
            myProducts.removeWhere((p) => p.id == productId);
            Get.snackbar(
              'Deleted',
              'Product deleted',
              backgroundColor: AppColors.appGreen,
              colorText: Colors.white,
            );
            return true;
          } else {
            Get.snackbar(
              'Delete failed',
              ApiService.apiLastError.isNotEmpty
                  ? ApiService.apiLastError
                  : 'Failed to delete product',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
      return ok;
    } catch (e) {
      print('[AdsController] deleteProduct error: $e');
      return false;
    }
  }

  /// Debug helper: call several dealer-related endpoints and print results
  /// so the UI can show in-terminal evidence that the dealer APIs are reachable.
  Future<void> debugCallDealerApis() async {
    try {
      Logger.d('AdsController', 'debugCallDealerApis start');
      final prefs = await SharedPreferences.getInstance();
      final dealerId = prefs.getString('dealerId') ?? '';
      Logger.d('AdsController', 'debugCallDealerApis -> dealerId=$dealerId');

      // 1) getDealerCars
      try {
        final cars = await ApiService.getDealerCars(dealerId);
        print('[AdsController][debug] getDealerCars -> $cars');
      } catch (e) {
        print('[AdsController][debug] getDealerCars error: $e');
      }

      // 2) getDealerStats
      try {
        final stats = await ApiService.getDealerStats(dealerId);
        print('[AdsController][debug] getDealerStats -> $stats');
      } catch (e) {
        print('[AdsController][debug] getDealerStats error: $e');
      }

      // 3) fetchDealerProducts (alt list)
      try {
        final list = await ApiService.fetchDealerProducts();
        print(
          '[AdsController][debug] fetchDealerProducts (alt) -> length=${list.length}',
        );
      } catch (e) {
        print('[AdsController][debug] fetchDealerProducts (alt) error: $e');
      }

      Logger.d('AdsController', 'debugCallDealerApis finished');
    } catch (e) {
      print('[AdsController] debugCallDealerApis error: $e');
    }
  }
}
