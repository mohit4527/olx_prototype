// ...existing code...
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ads_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
// removed app_sizer import (unused)
import '../../../constants/app_colors.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:olx_prototype/src/custom_widgets/shortVideoWidget.dart';
import 'dart:developer' as developer;

class AdsScreen extends StatefulWidget {
  const AdsScreen({Key? key}) : super(key: key);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen>
    with AutomaticKeepAliveClientMixin {
  final AdsController controller = Get.put(AdsController());
  String? _currentDealerId;
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  bool get wantKeepAlive => true;

  String _fullUrl(String path) => ApiService().fullMediaUrl(path);

  // profile mode state
  bool _isProfileView = false;
  String? _profileUserId;
  List<dynamic> _profileProducts = [];
  bool _loadingProfile = false;
  // Filter state for profile view
  String _selectedFilter = 'all'; // 'all', 'products', 'videos'
  // videos loading flag removed - videos are loaded when Videos tab is opened

  @override
  void initState() {
    super.initState();

    // Check for profile navigation args
    try {
      final args = Get.arguments;
      if (args != null && args is Map && args['profileUserId'] != null) {
        _isProfileView = true;
        _profileUserId = args['profileUserId'].toString();
        _loadProductsForProfile();
      } else {
        _loadDealerId();
      }
    } catch (e) {
      // fallback
      _loadDealerId();
    }

    // TabController removed - UI now uses a single view with a dropdown to switch modes
  }

  @override
  void dispose() {
    // No TabController to dispose
    super.dispose();
  }

  Future<void> _loadDealerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentDealerId = prefs.getString('dealerId');
      });
      if (_currentDealerId != null && _currentDealerId!.isNotEmpty) {
        await controller.fetchDealerProducts();
      }
      // Default load user products
      await controller.fetchMyProducts();
    } catch (_) {}
  }

  // New: attempt to load products for a profile user id.
  // This tries controller helper first; if missing or failing, falls back to empty list.
  Future<void> _loadProductsForProfile() async {
    if (_profileUserId == null) return;
    setState(() {
      _loadingProfile = true;
      _profileProducts = [];
    });

    try {
      final dyn = controller as dynamic;
      // If it's the current user, reuse fetchMyProducts and fetchMyVideos
      bool loaded = false;
      try {
        final currentId = (dyn.currentUserId is Rx
            ? dyn.currentUserId.value
            : (dyn.currentUserId ?? ''));
        if (currentId != null && currentId.toString() == _profileUserId) {
          await controller.fetchMyProducts();
          await controller
              .fetchMyVideos(); // Also fetch videos for current user
          _profileProducts = List.from(controller.myProducts);
          loaded = true;
        }
      } catch (_) {}

      if (!loaded) {
        try {
          // try calling a controller helper if implemented (safe with try/catch)
          await dyn.fetchProductsByUserId(_profileUserId);
          await dyn.fetchVideosByUserId(
            _profileUserId,
          ); // Also fetch videos for profile user
          _profileProducts = (dyn.profileProducts as List?) ?? [];
          loaded = true;
        } catch (_) {
          // ignore and fall through
        }
      }

      if (!loaded) {
        // final fallback: try calling a generic method on ApiService if available
        try {
          final api = ApiService();
          final res = await (api as dynamic).getProductsByUser(_profileUserId);
          _profileProducts = (res as List?) ?? [];
          loaded = true;
        } catch (e) {
          developer.log('Profile fetch fallback failed: $e', name: 'AdsScreen');
        }
      }
    } catch (e) {
      developer.log('Error loading profile products: $e', name: 'AdsScreen');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  String? _profileNameFromArgs() {
    try {
      final args = Get.arguments;
      if (args is Map && args['profileName'] != null)
        return args['profileName'].toString();
    } catch (_) {}
    return null;
  }

  String? _profileAvatarFromArgs() {
    try {
      final args = Get.arguments;
      if (args is Map && args['profileAvatar'] != null)
        return args['profileAvatar'].toString();
    } catch (_) {}
    return null;
  }

  Widget _productCard(
    dynamic p, {
    bool isDealer = false,
    bool showActions = false,
  }) {
    final imageUrl = isDealer
        ? ((p.images != null && (p.images as List).isNotEmpty)
              ? _fullUrl((p.images as List).first.toString())
              : '')
        : ((p.mediaUrl != null && (p.mediaUrl as List).isNotEmpty)
              ? _fullUrl((p.mediaUrl as List).first.toString())
              : '');
    return GestureDetector(
      onTap: () async {
        if (isDealer) {
          await Get.toNamed(
            AppRoutes.dealer_product_description,
            arguments: p.id,
          );
        } else {
          await Get.toNamed(AppRoutes.description, arguments: {'carId': p.id});
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        margin: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Container(
                height: 115,
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 56,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title text with proper height
                  Container(
                    height: 20,
                    child: Text(
                      p.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Price with fixed height
                  Container(
                    height: 18,
                    child: Text(
                      _currency.format(
                        double.tryParse((p.price ?? '0').toString()) ?? 0,
                      ),
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Location with fixed height
                  Container(
                    height: 16,
                    child: Builder(
                      builder: (_) {
                        final loc = p.location;
                        String locationText = '';
                        try {
                          if (loc == null) {
                            locationText = '';
                          } else if (loc is String) {
                            locationText = loc;
                          } else if (loc is Map) {
                            final city = (loc['city'] ?? loc['town'] ?? '')
                                .toString();
                            final state = (loc['state'] ?? '').toString();
                            final country = (loc['country'] ?? '').toString();
                            final parts = [
                              city,
                              state,
                              country,
                            ].where((s) => s.isNotEmpty).toList();
                            locationText = parts.join(', ');
                          } else if (loc is List) {
                            // join list items
                            try {
                              locationText = loc
                                  .map((e) => e?.toString() ?? '')
                                  .where((s) => s.isNotEmpty)
                                  .join(', ');
                            } catch (_) {
                              locationText = loc.toString();
                            }
                          } else {
                            // attempt dynamic property access (city/state/country)
                            try {
                              final city =
                                  (loc.city ?? loc['city'] ?? loc.town ?? '')
                                      ?.toString() ??
                                  '';
                              final state =
                                  (loc.state ?? loc['state'] ?? '')
                                      ?.toString() ??
                                  '';
                              final country =
                                  (loc.country ?? loc['country'] ?? '')
                                      ?.toString() ??
                                  '';
                              final parts = [
                                city,
                                state,
                                country,
                              ].where((s) => s.isNotEmpty).toList();
                              locationText = parts.join(', ');
                              if (locationText.isEmpty)
                                locationText = loc.toString();
                            } catch (_) {
                              // fallback to toString
                              try {
                                locationText = loc?.toString() ?? '';
                              } catch (_) {
                                locationText = '';
                              }
                            }
                          }
                        } catch (_) {
                          try {
                            locationText = loc?.toString() ?? '';
                          } catch (_) {
                            locationText = '';
                          }
                        }
                        return Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: Colors.grey.shade800,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                locationText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade800,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (showActions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 2.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Edit',
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          final res = await Get.toNamed(
                            AppRoutes.edit_product,
                            arguments: {'product': p},
                          );

                          // If the editor returned an updated product, apply it locally
                          if (res is Map && res['product'] != null) {
                            final updated = res['product'];
                            try {
                              if (isDealer) {
                                // Replace in dealerProducts list
                                final idx = controller.dealerProducts
                                    .indexWhere((d) => d.id == updated.id);
                                if (idx >= 0) {
                                  controller.dealerProducts[idx] = updated;
                                } else {
                                  // fallback: refresh dealer products
                                  await controller.fetchDealerProducts();
                                }
                              } else {
                                final idx = controller.myProducts.indexWhere(
                                  (d) => d.id == updated.id,
                                );
                                if (idx >= 0) {
                                  controller.myProducts[idx] = updated;
                                } else {
                                  await controller.fetchMyProducts();
                                }
                              }
                              Get.snackbar(
                                'Saved',
                                'Product updated',
                                backgroundColor: AppColors.appGreen,
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              // On error, fall back to refreshing the relevant list
                              if (isDealer)
                                await controller.fetchDealerProducts();
                              else
                                await controller.fetchMyProducts();
                            }
                            return;
                          }

                          // older behavior: boolean success indicator
                          if (res == true) {
                            if (isDealer) {
                              await controller.fetchDealerProducts();
                            } else {
                              await controller.fetchMyProducts();
                            }
                            Get.snackbar(
                              'Saved',
                              'Product updated',
                              backgroundColor: AppColors.appGreen,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 2),
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text(
                                'Are you sure you want to delete this product?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            bool ok = false;
                            if (isDealer) {
                              ok = await controller.deleteDealerProduct(
                                p.sellerType,
                                p.id,
                              );
                              if (ok) await controller.fetchDealerProducts();
                            } else {
                              ok = await controller.deleteProduct(p.id);
                              if (ok) await controller.fetchMyProducts();
                            }
                            if (ok) {
                              Get.snackbar(
                                'Deleted',
                                'Product deleted',
                                backgroundColor: AppColors.appGreen,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to delete',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Enhanced product card for seller products screen with larger images and better spacing
  Widget _sellerProductCard(
    dynamic p, {
    bool isDealer = false,
    bool showActions = false,
  }) {
    final imageUrl = isDealer
        ? ((p.images != null && (p.images as List).isNotEmpty)
              ? _fullUrl((p.images as List).first.toString())
              : '')
        : ((p.mediaUrl != null && (p.mediaUrl as List).isNotEmpty)
              ? _fullUrl((p.mediaUrl as List).first.toString())
              : '');
    return GestureDetector(
      onTap: () async {
        if (isDealer) {
          await Get.toNamed(
            AppRoutes.dealer_product_description,
            arguments: p.id,
          );
        } else {
          await Get.toNamed(AppRoutes.description, arguments: {'carId': p.id});
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.15),
        margin: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 140, // Reduced height to prevent overflow
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 45,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.appGreen,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Reduced padding to prevent overflow
                constraints: const BoxConstraints(
                  minHeight: 0,
                ), // Allow flexible height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Use minimum space needed
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Title with controlled space and proper ellipsis
                    Flexible(
                      child: Text(
                        p.title ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Slightly smaller font
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        maxLines: 2, // Reduced to 2 lines to save space
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    // Price with better styling and overflow protection
                    Text(
                      _currency.format(
                        double.tryParse((p.price ?? '0').toString()) ?? 0,
                      ),
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // Slightly smaller
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    // Location with compact styling
                    Flexible(
                      child: Builder(
                        builder: (_) {
                          final loc = p.location;
                          String locationText = '';
                          try {
                            if (loc == null) {
                              locationText = '';
                            } else if (loc is String) {
                              locationText = loc;
                            } else if (loc is Map) {
                              final city = (loc['city'] ?? loc['town'] ?? '')
                                  .toString();
                              final state = (loc['state'] ?? '').toString();
                              final country = (loc['country'] ?? '').toString();
                              final parts = [
                                city,
                                state,
                                country,
                              ].where((s) => s.isNotEmpty).toList();
                              locationText = parts.join(', ');
                            } else if (loc is List) {
                              try {
                                locationText = loc
                                    .map((e) => e?.toString() ?? '')
                                    .where((s) => s.isNotEmpty)
                                    .join(', ');
                              } catch (_) {
                                locationText = loc.toString();
                              }
                            } else {
                              try {
                                final city =
                                    (loc.city ?? loc['city'] ?? loc.town ?? '')
                                        ?.toString() ??
                                    '';
                                final state =
                                    (loc.state ?? loc['state'] ?? '')
                                        ?.toString() ??
                                    '';
                                final country =
                                    (loc.country ?? loc['country'] ?? '')
                                        ?.toString() ??
                                    '';
                                final parts = [
                                  city,
                                  state,
                                  country,
                                ].where((s) => s.isNotEmpty).toList();
                                locationText = parts.join(', ');
                                if (locationText.isEmpty)
                                  locationText = loc.toString();
                              } catch (_) {
                                try {
                                  locationText = loc?.toString() ?? '';
                                } catch (_) {
                                  locationText = '';
                                }
                              }
                            }
                          } catch (_) {
                            try {
                              locationText = loc?.toString() ?? '';
                            } catch (_) {
                              locationText = '';
                            }
                          }
                          return Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  locationText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1, // Single line to save space
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showActions)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Edit',
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 32,
                          minWidth: 32,
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          final res = await Get.toNamed(
                            AppRoutes.edit_product,
                            arguments: {'product': p},
                          );

                          if (res is Map && res['product'] != null) {
                            final updated = res['product'];
                            try {
                              if (isDealer) {
                                final idx = controller.dealerProducts
                                    .indexWhere((d) => d.id == updated.id);
                                if (idx >= 0) {
                                  controller.dealerProducts[idx] = updated;
                                } else {
                                  await controller.fetchDealerProducts();
                                }
                              } else {
                                final idx = controller.myProducts.indexWhere(
                                  (d) => d.id == updated.id,
                                );
                                if (idx >= 0) {
                                  controller.myProducts[idx] = updated;
                                } else {
                                  await controller.fetchMyProducts();
                                }
                              }
                              Get.snackbar(
                                'Saved',
                                'Product updated',
                                backgroundColor: AppColors.appGreen,
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              if (isDealer)
                                await controller.fetchDealerProducts();
                              else
                                await controller.fetchMyProducts();
                            }
                            return;
                          }

                          if (res == true) {
                            if (isDealer) {
                              await controller.fetchDealerProducts();
                            } else {
                              await controller.fetchMyProducts();
                            }
                            Get.snackbar(
                              'Saved',
                              'Product updated',
                              backgroundColor: AppColors.appGreen,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 32,
                          minWidth: 32,
                        ),
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text(
                                'Are you sure you want to delete this product?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            bool ok = false;
                            if (isDealer) {
                              ok = await controller.deleteDealerProduct(
                                p.sellerType,
                                p.id,
                              );
                              if (ok) await controller.fetchDealerProducts();
                            } else {
                              ok = await controller.deleteProduct(p.id);
                              if (ok) await controller.fetchMyProducts();
                            }
                            if (ok) {
                              Get.snackbar(
                                'Deleted',
                                'Product deleted',
                                backgroundColor: AppColors.appGreen,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to delete',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _videoCard(dynamic video) {
    final videoUrl = video.videoUrl?.toString() ?? '';
    final title = video.title?.toString() ?? 'Video';
    final duration = video.duration?.toString() ?? '0';

    // Check if this is current user's video (for edit/delete actions)
    final bool isOwner =
        !_isProfileView; // If not in profile view, it's owner's videos

    return GestureDetector(
      onTap: () {
        // Navigate to shortVideo screen with this specific video
        // Find the index of this video in the current list
        List<dynamic> currentVideos = [];
        int targetIndex = 0;

        if (_isProfileView) {
          // Profile view - use filtered videos
          final filteredContent = _getFilteredContent();
          final videoContent = filteredContent
              .where((content) => content['type'] == 'video')
              .toList();
          currentVideos = videoContent
              .map((content) => content['data'])
              .toList();
          targetIndex = currentVideos.indexWhere((v) => v.id == video.id);
        } else {
          // Regular view - use myVideos from controller
          currentVideos = List.from(controller.myVideos);
          targetIndex = currentVideos.indexWhere((v) => v.id == video.id);
        }

        if (targetIndex == -1) targetIndex = 0; // Fallback to first video

        Get.toNamed(
          AppRoutes.shortVideo,
          arguments: {
            'videos': currentVideos,
            'currentIndex': targetIndex,
            'id': video.id,
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        margin: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Container(
                height: 115,
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: videoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: VideoPlayerWidget(
                                key: ValueKey(videoUrl),
                                videoUrl: _fullUrl(videoUrl),
                                muted: true,
                                enableTapToToggle: false,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_filled,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Video unavailable',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // Play button overlay
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    // Duration overlay
                    if (duration != '0')
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${duration}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with fixed height
                  Container(
                    height: 30,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Duration info with fixed height
                  Container(
                    height: 16,
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 14,
                          color: AppColors.appGreen,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          duration != '0' ? '${duration}s' : 'Video',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons for owner's videos
            if (isOwner)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 2.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Video'),
                              content: const Text(
                                'Are you sure you want to delete this video?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final ok = await controller.deleteVideo(video.id);
                            if (ok) {
                              await controller.fetchMyVideos();
                              Get.snackbar(
                                'Deleted',
                                'Video deleted successfully',
                                backgroundColor: AppColors.appGreen,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to delete video',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // If profile view -> show header + profile products and videos combined
    if (_isProfileView) {
      // compute visible counts for the profile header
      final int productCount = _profileProducts.length;
      List<dynamic> profileVideos = [];
      try {
        final dyn = controller as dynamic;
        final currentId = (dyn.currentUserId is Rx
            ? dyn.currentUserId.value
            : (dyn.currentUserId ?? ''));

        print("🎬 AdsScreen Profile Debug:");
        print("  - Profile User ID: $_profileUserId");
        print("  - Current User ID: $currentId");
        print("  - My Videos Count: ${controller.myVideos.length}");
        print(
          "  - Profile Videos Count: ${(dyn.profileVideos as List?)?.length ?? 0}",
        );

        if (currentId != null && currentId.toString() == _profileUserId) {
          profileVideos = List.from(controller.myVideos);
          print("  - Using myVideos: ${profileVideos.length}");
        } else {
          profileVideos = List.from((dyn.profileVideos as List?) ?? []);
          print("  - Using profileVideos: ${profileVideos.length}");
        }
      } catch (e) {
        print("  - Error accessing videos: $e");
        profileVideos = [];
      }
      final int videoCount = profileVideos.length;
      print("  - Final Video Count: $videoCount");

      return Scaffold(
        appBar: AppBar(
          title: Text('Seller Products'),
          backgroundColor: AppColors.appGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: _loadingProfile
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Profile header like Instagram: big avatar + name under it
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (_profileAvatarFromArgs() != null &&
                                    _profileAvatarFromArgs()!.isNotEmpty)
                                ? NetworkImage(_profileAvatarFromArgs()!)
                                      as ImageProvider
                                : null,
                            child:
                                (_profileAvatarFromArgs() == null ||
                                    _profileAvatarFromArgs()!.isEmpty)
                                ? const Icon(Icons.person, size: 36)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _profileNameFromArgs() ?? 'Seller',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // counts row - no navigation, just display
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.appGreen.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.appGreen.withOpacity(0.12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Products',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$productCount',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.appGreen.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.appGreen.withOpacity(0.12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Videos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$videoCount',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _filterButton(
                              'All',
                              'all',
                              _selectedFilter == 'all',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _filterButton(
                              'Products',
                              'products',
                              _selectedFilter == 'products',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _filterButton(
                              'Videos',
                              'videos',
                              _selectedFilter == 'videos',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area: Filtered products and videos in cards
                    Expanded(
                      child: _getFilteredContent().isEmpty
                          ? Center(
                              child: Text(
                                _selectedFilter == 'all'
                                    ? 'User has not uploaded any content'
                                    : _selectedFilter == 'products'
                                    ? 'No products found'
                                    : 'No videos found',
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 5.0,
                              ),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      // Better aspect ratio for profile view cards (taller cards)
                                      childAspectRatio: _isProfileView
                                          ? 0.75
                                          : 0.635,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                    ),
                                itemCount: _getFilteredContent().length,
                                itemBuilder: (ctx, idx) {
                                  final content = _getFilteredContent()[idx];
                                  if (content['type'] == 'product') {
                                    // Use enhanced card for profile view, regular card for own ads
                                    return _isProfileView
                                        ? _sellerProductCard(
                                            content['data'],
                                            isDealer: false,
                                            showActions: false,
                                          )
                                        : _productCard(
                                            content['data'],
                                            isDealer: false,
                                            showActions: false,
                                          );
                                  } else {
                                    // Video card
                                    return _videoCard(content['data']);
                                  }
                                },
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      );
    }

    // Regular (non-profile) view: Tabbed view with Products & Videos
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appGreen,
          title: const Text(
            'My Ads',
            style: TextStyle(
              color: AppColors.appWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Videos'),
            ],
          ),
          // no actions required in the Ads app bar (removed video icon per request)
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Products tab with internal dropdown
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: GetBuilder<AdsController>(
                        id: 'products',
                        builder: (ctrl) {
                          if (ctrl.loadingProducts.value)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );

                          if (ctrl.myProducts.isEmpty)
                            return const Center(
                              child: Text('No products found'),
                            );

                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.660,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                ),
                            itemCount: ctrl.myProducts.length,
                            itemBuilder: (ctx, idx) => _productCard(
                              ctrl.myProducts[idx],
                              isDealer: false,
                              showActions: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Videos tab - inline list (replaces bottom sheet)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.appGreen,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Videos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          GetBuilder<AdsController>(
                            builder: (ctrl) => IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await ctrl.fetchMyVideos();
                                ctrl.update(['videos']);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GetBuilder<AdsController>(
                        id: 'videos',
                        builder: (ctrl) {
                          if (ctrl.loadingVideos.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (ctrl.myVideos.isEmpty) {
                            return const Center(
                              child: Text('No videos uploaded yet'),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 5,
                              right: 5,
                              bottom: 12,
                            ),
                            itemCount: ctrl.myVideos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, idx) {
                              final v = ctrl.myVideos[idx];
                              final videoUrl = v.videoUrl.isNotEmpty
                                  ? _fullUrl(v.videoUrl)
                                  : '';
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to shortVideo screen with this specific video
                                  Get.toNamed(
                                    AppRoutes.shortVideo,
                                    arguments: {
                                      'videos': ctrl.myVideos,
                                      'currentIndex': idx,
                                      'id': v.id,
                                    },
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                  child: SizedBox(
                                    height: 150,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(5),
                                              ),
                                          child: Container(
                                            width: 160,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                    left: Radius.circular(12),
                                                  ),
                                            ),
                                            child: videoUrl.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.horizontal(
                                                          left: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                    child: VideoPlayerWidget(
                                                      videoUrl: videoUrl,
                                                      muted: true,
                                                      enableTapToToggle: true,
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          const BorderRadius.horizontal(
                                                            left:
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                    ),
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .play_circle_filled,
                                                            size: 56,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Video',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  v.title.isNotEmpty
                                                      ? v.title
                                                      : 'Untitled Video',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.videocam,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    if (v.duration > 0)
                                                      Text(
                                                        '${v.duration}s duration',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    else
                                                      Text(
                                                        'Video content',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4.0,
                                          ),
                                          child: Tooltip(
                                            message: 'Delete',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 24,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        title: const Text(
                                                          'Delete Video',
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to delete this video?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  false,
                                                                ),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  true,
                                                                ),
                                                            child: const Text(
                                                              'Delete',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                if (confirm == true) {
                                                  final ok = await ctrl
                                                      .deleteVideo(v.id);
                                                  if (ok) {
                                                    await ctrl.fetchMyVideos();
                                                    Get.snackbar(
                                                      'Deleted',
                                                      'Video deleted',
                                                      backgroundColor:
                                                          AppColors.appGreen,
                                                      colorText: Colors.white,
                                                    );
                                                  } else {
                                                    Get.snackbar(
                                                      'Error',
                                                      'Failed to delete video',
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String title, String value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appGreen : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.appGreen : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredContent() {
    List<Map<String, dynamic>> content = [];

    // Add products
    if (_selectedFilter == 'all' || _selectedFilter == 'products') {
      for (var product in _profileProducts) {
        content.add({'type': 'product', 'data': product});
      }
    }

    // Add videos
    if (_selectedFilter == 'all' || _selectedFilter == 'videos') {
      List<dynamic> profileVideos = [];
      try {
        final dyn = controller as dynamic;
        final currentId = (dyn.currentUserId is Rx
            ? dyn.currentUserId.value
            : (dyn.currentUserId ?? ''));

        if (currentId != null && currentId.toString() == _profileUserId) {
          profileVideos = List.from(controller.myVideos);
        } else {
          profileVideos = List.from((dyn.profileVideos as List?) ?? []);
        }
      } catch (e) {
        profileVideos = [];
      }

      for (var video in profileVideos) {
        content.add({'type': 'video', 'data': video});
      }
    }

    return content;
  }
}
// ...existing code...