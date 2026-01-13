import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/postal_code_service.dart';
import 'all_products_controller.dart';
import '../constants/app_colors.dart';

class LocationController extends GetxController {
  // Observable variables
  var selectedCountry = ''.obs;
  var selectedState = ''.obs;
  var selectedCity = ''.obs;
  var currency = '₹'.obs;
  var isLocationSaved = false.obs;

  // Postal code loading state
  var isLoadingPostalCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocation();
  }

  // Full Country-State-City data
  final countries = <String, Map<String, dynamic>>{
    'India': {
      'currency': '₹',
      'states': {
        'Andhra Pradesh': [
          'Visakhapatnam',
          'Vijayawada',
          'Guntur',
          'Nellore',
          'Tirupati',
          'Kakinada',
        ],
        'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Pasighat', 'Tawang'],
        'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
        'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga'],
        'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg'],
        'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa', 'Ponda'],
        'Gujarat': [
          'Ahmedabad',
          'Surat',
          'Vadodara',
          'Rajkot',
          'Bhavnagar',
          'Jamnagar',
        ],
        'Haryana': ['Chandigarh', 'Faridabad', 'Gurgaon', 'Hisar', 'Panipat'],
        'Himachal Pradesh': [
          'Shimla',
          'Manali',
          'Dharamshala',
          'Solan',
          'Mandi',
        ],
        'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'],
        'Karnataka': ['Bangalore', 'Mysore', 'Mangalore', 'Hubli', 'Belgaum'],
        'Kerala': [
          'Thiruvananthapuram',
          'Kochi',
          'Kozhikode',
          'Thrissur',
          'Kollam',
        ],
        'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
        'Maharashtra': [
          'Mumbai',
          'Pune',
          'Nagpur',
          'Thane',
          'Nashik',
          'Aurangabad',
        ],
        'Manipur': ['Imphal', 'Thoubal', 'Bishnupur'],
        'Meghalaya': ['Shillong', 'Tura', 'Jowai'],
        'Mizoram': ['Aizawl', 'Lunglei', 'Champhai'],
        'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
        'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Brahmapur', 'Puri'],
        'Punjab': [
          'Chandigarh',
          'Ludhiana',
          'Amritsar',
          'Jalandhar',
          'Patiala',
        ],
        'Rajasthan': [
          'Jaipur',
          'Jodhpur',
          'Udaipur',
          'Kota',
          'Ajmer',
          'Bikaner',
        ],
        'Sikkim': ['Gangtok', 'Namchi', 'Gyalshing'],
        'Tamil Nadu': [
          'Chennai',
          'Coimbatore',
          'Madurai',
          'Salem',
          'Tiruchirappalli',
        ],
        'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam'],
        'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
        'Uttar Pradesh': [
          'Lucknow',
          'Kanpur',
          'Ghaziabad',
          'Agra',
          'Meerut',
          'Varanasi',
          'Noida',
        ],
        'Uttarakhand': [
          'Dehradun',
          'Haridwar',
          'Roorkee',
          'Haldwani',
          'Nainital',
        ],
        'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
        'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Vasant Kunj'],
      },
    },
    'United States': {
      'currency': '\$',
      'states': {
        'California': [
          'Los Angeles',
          'San Francisco',
          'San Diego',
          'San Jose',
          'Sacramento',
        ],
        'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio', 'Fort Worth'],
        'Florida': ['Miami', 'Orlando', 'Tampa', 'Jacksonville'],
        'New York': ['New York City', 'Buffalo', 'Rochester', 'Albany'],
        'Illinois': ['Chicago', 'Aurora', 'Rockford', 'Joliet'],
        'Pennsylvania': ['Philadelphia', 'Pittsburgh', 'Allentown'],
        'Ohio': ['Columbus', 'Cleveland', 'Cincinnati'],
        'Georgia': ['Atlanta', 'Augusta', 'Columbus'],
        'Michigan': ['Detroit', 'Grand Rapids', 'Ann Arbor'],
        'Washington': ['Seattle', 'Spokane', 'Tacoma'],
      },
    },
    'United Kingdom': {
      'currency': '£',
      'states': {
        'England': [
          'London',
          'Manchester',
          'Birmingham',
          'Liverpool',
          'Leeds',
          'Sheffield',
        ],
        'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen', 'Dundee'],
        'Wales': ['Cardiff', 'Swansea', 'Newport'],
        'Northern Ireland': ['Belfast', 'Derry', 'Lisburn'],
      },
    },
    'Canada': {
      'currency': 'C\$',
      'states': {
        'Ontario': ['Toronto', 'Ottawa', 'Mississauga', 'Hamilton', 'London'],
        'Quebec': ['Montreal', 'Quebec City', 'Laval', 'Gatineau'],
        'British Columbia': ['Vancouver', 'Victoria', 'Surrey', 'Burnaby'],
        'Alberta': ['Calgary', 'Edmonton', 'Red Deer'],
        'Manitoba': ['Winnipeg', 'Brandon', 'Steinbach'],
      },
    },
    'Australia': {
      'currency': 'A\$',
      'states': {
        'New South Wales': ['Sydney', 'Newcastle', 'Wollongong'],
        'Victoria': ['Melbourne', 'Geelong', 'Ballarat'],
        'Queensland': ['Brisbane', 'Gold Coast', 'Townsville', 'Cairns'],
        'Western Australia': ['Perth', 'Mandurah', 'Bunbury'],
        'South Australia': ['Adelaide', 'Mount Gambier'],
      },
    },
    'Germany': {
      'currency': '€',
      'states': {
        'Bavaria': ['Munich', 'Nuremberg', 'Augsburg'],
        'Berlin': ['Berlin'],
        'Hamburg': ['Hamburg'],
        'Hesse': ['Frankfurt', 'Wiesbaden', 'Kassel'],
        'North Rhine-Westphalia': ['Cologne', 'Dusseldorf', 'Dortmund'],
      },
    },
    'France': {
      'currency': '€',
      'states': {
        'Ile-de-France': ['Paris', 'Versailles'],
        'Provence': ['Marseille', 'Nice', 'Toulon'],
        'Auvergne-Rhône-Alpes': ['Lyon', 'Grenoble'],
        'Nouvelle-Aquitaine': ['Bordeaux', 'Limoges'],
        'Occitanie': ['Toulouse', 'Montpellier'],
      },
    },
    'Japan': {
      'currency': '¥',
      'states': {
        'Tokyo': ['Tokyo', 'Shibuya', 'Shinjuku'],
        'Osaka': ['Osaka', 'Sakai'],
        'Kyoto': ['Kyoto', 'Uji'],
        'Hokkaido': ['Sapporo', 'Asahikawa'],
        'Fukuoka': ['Fukuoka', 'Kitakyushu'],
      },
    },
    'China': {
      'currency': '¥',
      'states': {
        'Beijing': ['Beijing'],
        'Shanghai': ['Shanghai'],
        'Guangdong': ['Guangzhou', 'Shenzhen', 'Dongguan'],
        'Zhejiang': ['Hangzhou', 'Ningbo', 'Wenzhou'],
        'Jiangsu': ['Nanjing', 'Suzhou', 'Wuxi'],
      },
    },
    'Brazil': {
      'currency': 'R\$',
      'states': {
        'São Paulo': ['São Paulo', 'Campinas', 'Santos'],
        'Rio de Janeiro': ['Rio de Janeiro', 'Niterói'],
        'Minas Gerais': ['Belo Horizonte', 'Uberlândia'],
        'Bahia': ['Salvador', 'Feira de Santana'],
        'Paraná': ['Curitiba', 'Londrina', 'Maringá'],
      },
    },
  };

  // Get list of countries
  List<String> get countryList => countries.keys.toList();

  // Get list of states for selected country
  List<String> get stateList {
    if (selectedCountry.value.isEmpty) return [];
    final countryData = countries[selectedCountry.value];
    if (countryData == null) return [];
    return (countryData['states'] as Map<String, dynamic>).keys.toList();
  }

  // Get list of cities for selected state
  List<String> get cityList {
    if (selectedCountry.value.isEmpty || selectedState.value.isEmpty) return [];
    final countryData = countries[selectedCountry.value];
    if (countryData == null) return [];
    final states = countryData['states'] as Map<String, List<String>>;
    return states[selectedState.value] ?? [];
  }

  // Update country and currency
  void updateCountry(String country) {
    selectedCountry.value = country;
    selectedState.value = '';
    selectedCity.value = '';

    // Update currency based on country
    final countryData = countries[country];
    if (countryData != null) {
      currency.value = countryData['currency'];
    }
    print('✅ Country updated: $country, Currency: ${currency.value}');
  }

  // Update state
  void updateState(String state) {
    selectedState.value = state;
    selectedCity.value = '';
    print('✅ State updated: $state');
  }

  // Update city
  void updateCity(String city) {
    selectedCity.value = city;
    print('✅ City updated: $city');
  }

  // Save location to SharedPreferences
  Future<void> saveLocation() async {
    if (selectedCountry.value.isEmpty ||
        selectedState.value.isEmpty ||
        selectedCity.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select Country, State and City',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_country', selectedCountry.value);
      await prefs.setString('user_state', selectedState.value);
      await prefs.setString('user_city', selectedCity.value);
      await prefs.setString('user_currency', currency.value);
      await prefs.setBool('location_saved', true);

      isLocationSaved.value = true;

      Get.snackbar(
        'Success',
        'Location saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      Get.back(); // Close location settings screen

      print(
        '✅ Location saved: ${selectedCity.value}, ${selectedState.value}, ${selectedCountry.value}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final country = prefs.getString('user_country') ?? '';
      final state = prefs.getString('user_state') ?? '';
      final city = prefs.getString('user_city') ?? '';
      final savedCurrency = prefs.getString('user_currency') ?? '₹';
      final saved = prefs.getBool('location_saved') ?? false;

      if (country.isNotEmpty) {
        selectedCountry.value = country;
        selectedState.value = state;
        selectedCity.value = city;
        currency.value = savedCurrency;
        isLocationSaved.value = saved;

        print('✅ Loaded saved location: $city, $state, $country');
      }
    } catch (e) {
      print('⚠️ Error loading location: $e');
    }
  }

  // Get formatted location string
  String get formattedLocation {
    if (selectedCity.value.isEmpty) return 'Set Location';
    return '${selectedCity.value}, ${selectedState.value}';
  }

  // Get full location string
  String get fullLocation {
    if (selectedCity.value.isEmpty) return '';
    return '${selectedCity.value}, ${selectedState.value}, ${selectedCountry.value}';
  }

  /// Fetch location from postal code using universal API
  Future<void> fetchLocationFromPostalCode(String postalCode) async {
    print('\n🚀 [LocationController] fetchLocationFromPostalCode called');
    print('📝 [LocationController] Input: "$postalCode"');

    if (postalCode.trim().isEmpty) {
      print('❌ [LocationController] Empty postal code');
      Get.snackbar(
        'Error',
        'Please enter a postal code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      print('⏳ [LocationController] Setting loading state...');
      isLoadingPostalCode.value = true;

      print('🔍 [LocationController] Calling PostalCodeService...');

      final locationData = await PostalCodeService.getLocationFromPostalCode(
        postalCode,
      );

      print('📦 [LocationController] Service returned: $locationData');

      if (locationData != null) {
        // Update location fields
        final country = locationData['country'] ?? '';
        final state = locationData['state'] ?? '';
        final city = locationData['city'] ?? '';

        print(
          '🌍 [LocationController] Extracted - Country: $country, State: $state, City: $city',
        );

        // Check if country exists in our hardcoded list
        print(
          '🔍 [LocationController] Checking if "$country" exists in hardcoded list...',
        );
        print(
          '📋 [LocationController] Available countries: ${countries.keys.toList()}',
        );

        if (countries.containsKey(country)) {
          print('✅ [LocationController] Country found in hardcoded list!');
          // Use existing country data
          updateCountry(country);

          // Try to match state
          final states = countries[country]!['states'] as Map<String, dynamic>;
          final matchedState = states.keys.firstWhere(
            (s) => s.toLowerCase() == state.toLowerCase(),
            orElse: () => state,
          );

          if (states.containsKey(matchedState)) {
            updateState(matchedState);

            // Try to match city
            final cities = states[matchedState] as List;
            final matchedCity = cities.firstWhere(
              (c) => c.toLowerCase() == city.toLowerCase(),
              orElse: () => city,
            );

            updateCity(matchedCity);
          } else {
            // State not in list, use API data
            selectedState.value = state;
            selectedCity.value = city;
          }
        } else {
          // Country not in hardcoded list, use API data directly
          selectedCountry.value = country;
          selectedState.value = state;
          selectedCity.value = city;

          // Set currency based on country code
          final countryCode = locationData['countryCode'] ?? '';
          currency.value = _getCurrencyForCountry(countryCode);
        }

        print('🎉 [LocationController] Successfully updated location!');
        Get.snackbar(
          '✅ Success',
          'Location found: $city, $state, $country',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: Duration(seconds: 3),
        );
      } else {
        print('❌ [LocationController] Location data is NULL');
        Get.snackbar(
          '❌ Postal Code Not Found',
          'Could not find "$postalCode" in our database.\n\n'
              '💡 Try these valid codes:\n'
              '🇮🇳 India: 110001, 400001, 560001\n'
              '🇺🇸 USA: 90001, 10001, 60601\n'
              '🇬🇧 UK: SW1A1AA, M11AA\n\n'
              '✅ Or select location manually below',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 6),
          margin: EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print('💥 [LocationController] EXCEPTION: $e');
      print('📚 [LocationController] Stack trace: ${StackTrace.current}');
      Get.snackbar(
        '⚠️ Error',
        'Failed to fetch location: $e\nPlease check your internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: Duration(seconds: 4),
      );
    } finally {
      print('🏁 [LocationController] Resetting loading state\n');
      isLoadingPostalCode.value = false;
    }
  }

  /// Get currency symbol for country code
  String _getCurrencyForCountry(String countryCode) {
    final currencies = {
      'IN': '₹', // India
      'US': '\$', // USA
      'GB': '£', // UK
      'CA': 'C\$', // Canada
      'AU': 'A\$', // Australia
      'EU': '€', // Europe
      'DE': '€', // Germany
      'FR': '€', // France
      'IT': '€', // Italy
      'ES': '€', // Spain
      'NL': '€', // Netherlands
      'JP': '¥', // Japan
      'CN': '¥', // China
      'KR': '₩', // South Korea
      'RU': '₽', // Russia
      'BR': 'R\$', // Brazil
      'MX': 'Mex\$', // Mexico
      'AE': 'AED', // UAE
      'SA': 'SAR', // Saudi Arabia
      'SG': 'S\$', // Singapore
      'MY': 'RM', // Malaysia
      'TH': '฿', // Thailand
      'PH': '₱', // Philippines
      'ID': 'Rp', // Indonesia
      'VN': '₫', // Vietnam
      'ZA': 'R', // South Africa
      'TR': '₺', // Turkey
      'EG': 'E£', // Egypt
      'PK': 'Rs', // Pakistan
      'BD': '৳', // Bangladesh
      'LK': 'Rs', // Sri Lanka
      'NP': 'Rs', // Nepal
    };

    return currencies[countryCode.toUpperCase()] ?? '\$';
  }

  /// Search products by selected location
  Future<void> searchProductsByLocation() async {
    // Trim whitespace from inputs
    final country = selectedCountry.value.trim();
    final state = selectedState.value.trim();
    final city = selectedCity.value.trim();

    if (country.isEmpty || state.isEmpty || city.isEmpty) {
      Get.snackbar(
        'Location Required',
        'Please select Country, State and City first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(Icons.location_off, color: Colors.white, size: 24),
        duration: Duration(seconds: 3),
        isDismissible: true,
      );
      return;
    }

    print('🔍 [LocationController] Searching products for:');
    print('   Country: $country');
    print('   State: $state');
    print('   City: $city');

    // ✅ CHECK: Count products in this location BEFORE navigating
    final productController = Get.find<ProductController>();

    // Ensure products are loaded
    if (productController.productList.isEmpty) {
      print('⚠️ [LocationController] Products not loaded, fetching...');
      productController.fetchProducts();
      // Wait a bit for products to load
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Filter and count products for this location
    final filterCountry = country.toLowerCase();
    final filterState = state.toLowerCase();
    final filterCity = city.toLowerCase();

    final matchingProducts = productController.productList.where((product) {
      final productCountry = (product.country ?? '').trim().toLowerCase();
      final productState = (product.state ?? '').trim().toLowerCase();
      final productCity = (product.city ?? '').trim().toLowerCase();

      bool matchesCountry =
          productCountry.contains(filterCountry) ||
          filterCountry.contains(productCountry);

      bool matchesState =
          productState.contains(filterState) ||
          filterState.contains(productState);

      bool matchesCity =
          productCity.contains(filterCity) || filterCity.contains(productCity);

      return matchesCountry && matchesState && matchesCity;
    }).toList();

    print(
      '📊 [LocationController] Found ${matchingProducts.length} products in $city, $state',
    );

    // ✅ Show message if no products found
    if (matchingProducts.isEmpty) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Products Available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currently there are no products uploaded in:',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$state, $country',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '💡 Try searching in nearby cities or select a different location.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appGreen,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
      return; // Don't navigate
    }

    // ✅ Products found - Navigate to filtered products screen
    Get.toNamed(
      '/filtered_products',
      arguments: {'country': country, 'state': state, 'city': city},
    );
  }
}
