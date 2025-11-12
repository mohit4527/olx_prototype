import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CategoryController extends GetxController {
  final selectedTab = RxString('user');
  final selectedCategory = RxString('all');
  final isLoading = false.obs;
  final productList = RxList<Map<String, dynamic>>();

  // Caching mechanism
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Debouncing mechanism
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();
    // Load products immediately but with cache check
    _loadProductsWithCache();

    // Listen to tab changes with debouncing
    ever(selectedTab, (_) => _debouncedFetch());
  }

  /// Debounced fetch to avoid rapid API calls
  void _debouncedFetch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _loadProductsWithCache();
    });
  }

  /// Load products with cache optimization
  Future<void> _loadProductsWithCache() async {
    final tab = selectedTab.value;
    final cacheKey = '${tab}_products';

    // Check if we have valid cached data
    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      print('[CategoryController] Using cached data for $cacheKey');
      _applyFiltersToProducts(_cache[cacheKey]!);
      return;
    }

    // If no valid cache, fetch from API
    await fetchProducts();
  }

  /// Check if cache is still valid
  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamp.containsKey(cacheKey)) return false;
    final timestamp = _cacheTimestamp[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheValidDuration;
  }

  /// Apply filters to cached products (much faster than API call)
  void _applyFiltersToProducts(List<Map<String, dynamic>> allItems) {
    final category = selectedCategory.value;

    List<Map<String, dynamic>> filtered;
    if (category == 'all') {
      filtered = allItems;
    } else if (category == 'others') {
      filtered = allItems
          .where(
            (item) =>
                item['category'] != 'cars' && item['category'] != 'two-wheeler',
          )
          .toList();
    } else {
      filtered = allItems
          .where((item) => item['category'] == category)
          .toList();
    }

    productList.assignAll(filtered);
  }

  /// Original fetch method with caching
  Future<void> fetchProducts() async {
    if (isLoading.value) return; // Prevent multiple simultaneous calls

    isLoading.value = true;
    final tab = selectedTab.value;
    final cacheKey = '${tab}_products';

    // Reduced limit for faster response
    final apiUrl = tab == 'user'
        ? 'https://oldmarket.bhoomi.cloud/api/products?page=1&limit=50'
        : 'http://oldmarket.bhoomi.cloud/api/dealers/dealer/cars';

    try {
      print('[CategoryController] Fetching fresh data for $tab');
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {'Connection': 'keep-alive'}, // Optimize connection
          )
          .timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allItems = tab == 'user'
            ? List<Map<String, dynamic>>.from(data['data'] ?? [])
            : List<Map<String, dynamic>>.from(data['data'] ?? []);

        // Cache the raw data
        _cache[cacheKey] = allItems;
        _cacheTimestamp[cacheKey] = DateTime.now();

        print(
          '[CategoryController] Cached ${allItems.length} items for $cacheKey',
        );

        // Apply current filters
        _applyFiltersToProducts(allItems);
      } else {
        productList.clear();
        Get.snackbar(
          "Error",
          "Failed to fetch products (${response.statusCode})",
        );
      }
    } catch (e) {
      productList.clear();
      print('[CategoryController] Error: $e');
      Get.snackbar("Error", "Connection timeout. Please check your internet.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fast category filtering (uses cached data if available)
  void filterByCategory(String category) {
    selectedCategory.value = category;

    final tab = selectedTab.value;
    final cacheKey = '${tab}_products';

    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      // Use cached data for instant filtering
      _applyFiltersToProducts(_cache[cacheKey]!);
    } else {
      // Fetch fresh data if no valid cache
      fetchProducts();
    }
  }

  /// Refresh data (clears cache and fetches fresh)
  Future<void> refreshData() async {
    final tab = selectedTab.value;
    final cacheKey = '${tab}_products';

    // Clear cache for this tab
    _cache.remove(cacheKey);
    _cacheTimestamp.remove(cacheKey);

    await fetchProducts();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _cache.clear();
    _cacheTimestamp.clear();
    super.onClose();
  }
}
