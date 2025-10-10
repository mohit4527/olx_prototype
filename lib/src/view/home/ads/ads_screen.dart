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

/// AdsScreen: cleaned single-definition file
class AdsScreen extends StatefulWidget {
  const AdsScreen({Key? key}) : super(key: key);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final AdsController controller = Get.put(AdsController());
  TabController? _tabController;
  String? _currentDealerId;
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _fullUrl(String path) => ApiService().fullMediaUrl(path);

  @override
  void initState() {
    super.initState();
    _loadDealerId();
    // TabController will be initialized in didChangeDependencies where we have a TickerProvider
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer reading the DefaultTabController until after the first frame so the
    // DefaultTabController ancestor (provided in build) is available. This
    // prevents an exception when didChangeDependencies runs before build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final tc = DefaultTabController.of(context);
        // If we previously attached a listener to a different controller, remove it
        if (_tabController != null && _tabController != tc) {
          try {
            _tabController!.removeListener(_handleTabChange);
          } catch (_) {}
        }
        _tabController = tc;
        _tabController!.addListener(_handleTabChange);
      } catch (e) {
        // no DefaultTabController found; ignore. This can happen during tests
        // or if the widget tree changes. We intentionally swallow the error
        // because the UI still renders correctly.
        // print('[AdsScreen] DefaultTabController not available yet: $e');
      }
    });
  }

  void _handleTabChange() {
    if (_tabController == null) return;
    if (_tabController!.indexIsChanging) return;
    final idx = _tabController!.index;
    print('[AdsScreen] Tab changed -> index=$idx');
    if (idx == 1) {
      print(
        '[AdsScreen] Dealer tab selected -> fetching dealer products for debug',
      );
      controller.fetchDealerProducts();
      // Also run a broader debug sweep across dealer endpoints so the
      // terminal clearly shows which dealer APIs are reachable and what
      // responses they return.
      controller.debugCallDealerApis();
      // Provide immediate in-app feedback so you know the debug sweep ran.
      try {
        Get.snackbar(
          'Debug',
          'Dealer APIs invoked — check terminal for responses',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    try {
      _tabController?.removeListener(_handleTabChange);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadDealerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentDealerId = prefs.getString('dealerId');
      });
      if (_currentDealerId != null && _currentDealerId!.isNotEmpty)
        await controller.fetchDealerProducts();
    } catch (_) {}
  }

  Future<void> _showVideosSheet(BuildContext context) async {
    await controller.fetchMyVideos();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                // Green header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.appGreen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
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
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    if (controller.loadingVideos.value)
                      return const Center(child: CircularProgressIndicator());
                    if (controller.myVideos.isEmpty)
                      return const Center(
                        child: Text('No videos uploaded yet'),
                      );
                    return ListView.separated(
                      controller: sc,
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 8,
                        bottom: 12,
                      ),
                      itemCount: controller.myVideos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final v = controller.myVideos[idx];
                        final videoUrl = v.videoUrl.isNotEmpty
                            ? _fullUrl(v.videoUrl)
                            : '';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: SizedBox(
                            height: 130,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Inline autoplaying preview (muted)
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: 140,
                                    height: double.infinity,
                                    color: Colors.grey[200],
                                    child: videoUrl.isNotEmpty
                                        ? VideoPlayerWidget(
                                            videoUrl: videoUrl,
                                            muted: true,
                                            enableTapToToggle: true,
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 48,
                                            ),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          v.title.isNotEmpty
                                              ? v.title
                                              : 'Video',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (v.duration > 0)
                                          Text(
                                            '${v.duration}s',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Tooltip(
                                    message: 'Delete',
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 24,
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
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final ok = await controller
                                              .deleteVideo(v.id);
                                          if (ok) {
                                            await controller.fetchMyVideos();
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
                                              backgroundColor: Colors.red,
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
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black26,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 96,
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 56, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Price on its own line
                  Text(
                    _currency.format(
                      double.tryParse((p.price ?? '0').toString()) ?? 0,
                    ),
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location shown under the price (robust parsing)
                  Builder(
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
                                (loc.state ?? loc['state'] ?? '')?.toString() ??
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
                      return Text(
                        locationText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),

            if (showActions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Edit',
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
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
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Ads',
            style: TextStyle(
              color: AppColors.appWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.appGreen,
          actions: [
            IconButton(
              icon: const Icon(Icons.video_library, color: AppColors.appWhite),
              tooltip: 'My Videos',
              onPressed: () => _showVideosSheet(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'User'),
              Tab(text: 'Dealer'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // User products
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Obx(() {
                if (controller.loadingProducts.value)
                  return const Center(child: CircularProgressIndicator());
                if (controller.myProducts.isEmpty)
                  return const Center(child: Text('No products found'));
                return GridView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: controller.myProducts.length,
                  itemBuilder: (ctx, idx) => _productCard(
                    controller.myProducts[idx],
                    isDealer: false,
                    showActions: true,
                  ),
                );
              }),
            ),

            // Dealer products
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Obx(() {
                if (controller.loadingDealerProducts.value)
                  return const Center(child: CircularProgressIndicator());
                if (_currentDealerId == null || _currentDealerId!.isEmpty)
                  return const Center(child: Text('You are not a dealer'));
                if (controller.dealerProducts.isEmpty)
                  return const Center(child: Text('No dealer products found'));
                return GridView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: controller.dealerProducts.length,
                  itemBuilder: (ctx, idx) => _productCard(
                    controller.dealerProducts[idx],
                    isDealer: true,
                    showActions: true,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Using VideoPlayerWidget for inline previews.
