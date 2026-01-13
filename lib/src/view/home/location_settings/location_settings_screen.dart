import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/location_controller.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final LocationController controller = Get.put(LocationController());
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  
  String selectedCurrency = '';
  String currencySymbol = '';
  
  // Country to Currency mapping
  final Map<String, Map<String, String>> countryCurrencyMap = {
    'india': {'name': 'Indian Rupee', 'symbol': '₹', 'code': 'INR'},
    'united states': {'name': 'US Dollar', 'symbol': '\$', 'code': 'USD'},
    'usa': {'name': 'US Dollar', 'symbol': '\$', 'code': 'USD'},
    'united kingdom': {'name': 'British Pound', 'symbol': '£', 'code': 'GBP'},
    'uk': {'name': 'British Pound', 'symbol': '£', 'code': 'GBP'},
    'canada': {'name': 'Canadian Dollar', 'symbol': 'C\$', 'code': 'CAD'},
    'australia': {'name': 'Australian Dollar', 'symbol': 'A\$', 'code': 'AUD'},
    'japan': {'name': 'Japanese Yen', 'symbol': '¥', 'code': 'JPY'},
    'china': {'name': 'Chinese Yuan', 'symbol': '¥', 'code': 'CNY'},
    'germany': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
    'france': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
    'italy': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
    'spain': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
    'russia': {'name': 'Russian Ruble', 'symbol': '₽', 'code': 'RUB'},
    'brazil': {'name': 'Brazilian Real', 'symbol': 'R\$', 'code': 'BRL'},
    'mexico': {'name': 'Mexican Peso', 'symbol': 'Mex\$', 'code': 'MXN'},
    'south africa': {'name': 'South African Rand', 'symbol': 'R', 'code': 'ZAR'},
    'saudi arabia': {'name': 'Saudi Riyal', 'symbol': '﷼', 'code': 'SAR'},
    'uae': {'name': 'UAE Dirham', 'symbol': 'د.إ', 'code': 'AED'},
    'dubai': {'name': 'UAE Dirham', 'symbol': 'د.إ', 'code': 'AED'},
    'singapore': {'name': 'Singapore Dollar', 'symbol': 'S\$', 'code': 'SGD'},
    'malaysia': {'name': 'Malaysian Ringgit', 'symbol': 'RM', 'code': 'MYR'},
    'thailand': {'name': 'Thai Baht', 'symbol': '฿', 'code': 'THB'},
    'indonesia': {'name': 'Indonesian Rupiah', 'symbol': 'Rp', 'code': 'IDR'},
    'pakistan': {'name': 'Pakistani Rupee', 'symbol': '₨', 'code': 'PKR'},
    'bangladesh': {'name': 'Bangladeshi Taka', 'symbol': '৳', 'code': 'BDT'},
    'sri lanka': {'name': 'Sri Lankan Rupee', 'symbol': 'Rs', 'code': 'LKR'},
    'nepal': {'name': 'Nepalese Rupee', 'symbol': 'रू', 'code': 'NPR'},
  };
  
  void updateCurrency(String country) {
    if (country.isEmpty) {
      setState(() {
        selectedCurrency = '';
        currencySymbol = '';
      });
      return;
    }
    
    final countryLower = country.toLowerCase().trim();
    final currencyData = countryCurrencyMap[countryLower];
    
    if (currencyData != null) {
      setState(() {
        selectedCurrency = '${currencyData['name']} (${currencyData['code']})';
        currencySymbol = currencyData['symbol']!;
      });
      print('✅ Currency updated: $selectedCurrency with symbol: $currencySymbol');
    } else {
      setState(() {
        selectedCurrency = 'Currency not found for "$country"';
        currencySymbol = '';
      });
      print('⚠️ Currency not found for: $country');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: const Text(
          'Location Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer().height2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(AppSizer().height2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appGreen.shade100,
                    AppColors.appGreen.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 40, color: AppColors.appGreen),
                  SizedBox(width: AppSizer().width3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Your Location',
                          style: TextStyle(
                            fontSize: AppSizer().fontSize18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appGreen.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select country, state, and city to see relevant products',
                          style: TextStyle(
                            fontSize: AppSizer().fontSize14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer().height3),

            // Country TextField
            _buildSectionTitle('Country'),
            SizedBox(height: AppSizer().height1),
            _buildTextField(
              controller: countryController,
              hint: 'Enter Country (e.g. India)',
              icon: Icons.public,
              onChanged: (value) {
                controller.updateCountry(value.trim());
                updateCurrency(value.trim());
              },
            ),
            
            // Currency Display
            if (selectedCurrency.isNotEmpty) ...[
              SizedBox(height: AppSizer().height1),
              Container(
                padding: EdgeInsets.all(AppSizer().height2),
                decoration: BoxDecoration(
                  color: AppColors.appGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.appGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppColors.appGreen,
                      size: 20,
                    ),
                    SizedBox(width: AppSizer().width2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currency',
                            style: TextStyle(
                              fontSize: AppSizer().fontSize12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            selectedCurrency,
                            style: TextStyle(
                              fontSize: AppSizer().fontSize14,
                              color: AppColors.appGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (currencySymbol.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer().width3,
                          vertical: AppSizer().height1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.appGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currencySymbol,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSizer().height2),

            // State TextField
            _buildSectionTitle('State'),
            SizedBox(height: AppSizer().height1),
            _buildTextField(
              controller: stateController,
              hint: 'Enter State (e.g. Uttar Pradesh)',
              icon: Icons.map,
              onChanged: (value) {
                controller.updateState(value.trim());
              },
            ),

            SizedBox(height: AppSizer().height2),

            // City TextField
            _buildSectionTitle('City'),
            SizedBox(height: AppSizer().height1),
            _buildTextField(
              controller: cityController,
              hint: 'Enter City (e.g. Noida)',
              icon: Icons.location_city,
              onChanged: (value) {
                controller.updateCity(value.trim());
              },
            ),

            SizedBox(height: AppSizer().height4),

            // Search Products Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.searchProductsByLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Search Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizer().height2),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizer().fontSize16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appGreen.shade300, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        textCapitalization:
            TextCapitalization.words, //🔥Auto-capitalize first letter
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: AppSizer().fontSize15,
          ),
          prefixIcon: Icon(icon, color: AppColors.appGreen, size: 20),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: AppSizer().fontSize15,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
