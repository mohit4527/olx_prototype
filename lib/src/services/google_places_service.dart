import 'dart:convert';
import 'package:http/http.dart' as http;

const String GOOGLE_API_KEY = "AIzaSyBQx7m5RcWfgRtYZzvwxRLcMa3Ks-Z0xUI";

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static Future<List<PlaceAutocomplete>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final String url =
        '$_baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&types=(cities)'
        '&key=$GOOGLE_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((prediction) => PlaceAutocomplete.fromJson(prediction))
              .toList();
        }
      }
      print('Google Places API Error: ${response.body}');
      return [];
    } catch (e) {
      print('Error searching cities: $e');
      return [];
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final String url =
        '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=geometry,name,formatted_address'
        '&key=$GOOGLE_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      print('Google Place Details API Error: ${response.body}');
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
}

class PlaceAutocomplete {
  final String placeId;
  final String description;

  PlaceAutocomplete({required this.placeId, required this.description});

  factory PlaceAutocomplete.fromJson(Map<String, dynamic> json) {
    return PlaceAutocomplete(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final double lat;
  final double lng;
  final String? address;

  PlaceDetails({
    required this.name,
    required this.lat,
    required this.lng,
    this.address,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry['location'];

    return PlaceDetails(
      name: json['name'] ?? '',
      lat: location['lat'].toDouble(),
      lng: location['lng'].toDouble(),
      address: json['formatted_address'],
    );
  }
}
