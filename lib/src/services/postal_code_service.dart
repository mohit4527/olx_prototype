import 'dart:convert';
import 'package:http/http.dart' as http;

class PostalCodeService {
  /// Universal postal code lookup supporting multiple countries
  /// Tries common countries automatically if country not specified
  static Future<Map<String, String>?> getLocationFromPostalCode(
    String postalCode, {
    String? countryCode,
  }) async {
    print('🔍 [PostalCode] Starting lookup for: $postalCode');

    // Clean postal code
    final cleanCode = postalCode.trim().replaceAll(' ', '');
    if (cleanCode.isEmpty) {
      print('❌ [PostalCode] Empty postal code');
      return null;
    }

    print('📍 [PostalCode] Cleaned code: $cleanCode');

    // If country code provided, try that first
    if (countryCode != null && countryCode.isNotEmpty) {
      print('🌍 [PostalCode] Trying specific country: $countryCode');
      final result = await _tryZippopotam(countryCode, cleanCode);
      if (result != null) {
        print('✅ [PostalCode] Found in $countryCode: $result');
        return result;
      }
    }

    // Try common countries in order (limited to top 15 for speed)
    final commonCountries = [
      'IN', // India
      'US', // United States
      'GB', // United Kingdom
      'CA', // Canada
      'AU', // Australia
      'DE', // Germany
      'FR', // France
      'IT', // Italy
      'ES', // Spain
      'NL', // Netherlands
      'CH', // Switzerland
      'SG', // Singapore
      'MY', // Malaysia
      'AE', // UAE
      'BR', // Brazil
    ];

    // Try each country
    print('🔄 [PostalCode] Trying ${commonCountries.length} countries...');
    int attemptCount = 0;

    for (final country in commonCountries) {
      attemptCount++;
      print(
        '🌐 [PostalCode] Attempt $attemptCount/${commonCountries.length}: Trying $country...',
      );

      final result = await _tryZippopotam(country, cleanCode);
      if (result != null) {
        print('✅ [PostalCode] SUCCESS! Found in $country: $result');
        return result;
      }
    }

    print('❌ [PostalCode] NOT FOUND in any of $attemptCount countries');
    print('💡 [PostalCode] Tried: ${commonCountries.join(", ")}');
    return null;
  }

  /// Try Zippopotam API for specific country
  static Future<Map<String, String>?> _tryZippopotam(
    String countryCode,
    String postalCode,
  ) async {
    try {
      final url =
          'http://api.zippopotam.us/${countryCode.toUpperCase()}/$postalCode';
      print('   🌐 [API] Calling: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 3));

      print('   📡 [API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('   📦 [API] Response data: $data');

        // Extract location data
        final country = data['country'] ?? '';
        final places = data['places'] as List?;

        if (places != null && places.isNotEmpty) {
          final place = places[0];
          final state = place['state'] ?? '';
          final city = place['place name'] ?? '';

          print(
            '   ✅ [API] Extracted: Country=$country, State=$state, City=$city',
          );

          return {
            'country': country,
            'state': state,
            'city': city,
            'countryCode': countryCode.toUpperCase(),
          };
        } else {
          print('   ⚠️ [API] No places found in response');
        }
      } else {
        print('   ❌ [API] Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('   ⚠️ [API] Error for $countryCode: $e');
    }

    return null;
  }

  /// Get country name from code
  static String getCountryName(String countryCode) {
    final countries = {
      'IN': 'India',
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'NL': 'Netherlands',
      'BE': 'Belgium',
      'CH': 'Switzerland',
      'AT': 'Austria',
      'SE': 'Sweden',
      'NO': 'Norway',
      'DK': 'Denmark',
      'FI': 'Finland',
      'PL': 'Poland',
      'PT': 'Portugal',
      'GR': 'Greece',
      'CZ': 'Czech Republic',
      'IE': 'Ireland',
      'NZ': 'New Zealand',
      'SG': 'Singapore',
      'MY': 'Malaysia',
      'TH': 'Thailand',
      'PH': 'Philippines',
      'ID': 'Indonesia',
      'VN': 'Vietnam',
      'ZA': 'South Africa',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'AR': 'Argentina',
      'CL': 'Chile',
      'CO': 'Colombia',
      'PE': 'Peru',
      'JP': 'Japan',
      'KR': 'South Korea',
      'CN': 'China',
      'TW': 'Taiwan',
      'HK': 'Hong Kong',
      'AE': 'United Arab Emirates',
      'SA': 'Saudi Arabia',
      'EG': 'Egypt',
      'TR': 'Turkey',
      'RU': 'Russia',
      'UA': 'Ukraine',
      'PK': 'Pakistan',
      'BD': 'Bangladesh',
      'LK': 'Sri Lanka',
      'NP': 'Nepal',
    };

    return countries[countryCode.toUpperCase()] ?? countryCode;
  }
}
