import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/google_places_service.dart';

class CitySearchOverlay extends StatefulWidget {
  final Function(String city, double lat, double lng) onCitySelected;

  const CitySearchOverlay({super.key, required this.onCitySelected});

  @override
  State<CitySearchOverlay> createState() => _CitySearchOverlayState();
}

class _CitySearchOverlayState extends State<CitySearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  // Indian cities with coordinates as fallback
  final List<Map<String, dynamic>> indianCities = [
    {'name': 'Delhi', 'lat': 28.6139, 'lng': 77.2090},
    {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Bangalore', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'Hyderabad', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lng': 72.5714},
    {'name': 'Chennai', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Kolkata', 'lat': 22.5726, 'lng': 88.3639},
    {'name': 'Pune', 'lat': 18.5204, 'lng': 73.8567},
    {'name': 'Jaipur', 'lat': 26.9124, 'lng': 75.7873},
    {'name': 'Surat', 'lat': 21.1702, 'lng': 72.8311},
    {'name': 'Lucknow', 'lat': 26.8467, 'lng': 80.9462},
    {'name': 'Kanpur', 'lat': 26.4499, 'lng': 80.3319},
    {'name': 'Nagpur', 'lat': 21.1458, 'lng': 79.0882},
    {'name': 'Patna', 'lat': 25.5941, 'lng': 85.1376},
    {'name': 'Indore', 'lat': 22.7196, 'lng': 75.8577},
    {'name': 'Thane', 'lat': 19.2183, 'lng': 72.9781},
    {'name': 'Bhopal', 'lat': 23.2599, 'lng': 77.4126},
    {'name': 'Visakhapatnam', 'lat': 17.6868, 'lng': 83.2185},
    {'name': 'Vadodara', 'lat': 22.3072, 'lng': 73.1812},
    {'name': 'Firozabad', 'lat': 27.1502, 'lng': 78.3957},
    {'name': 'Ludhiana', 'lat': 30.9010, 'lng': 75.8573},
    {'name': 'Rajkot', 'lat': 22.3039, 'lng': 70.8022},
    {'name': 'Agra', 'lat': 27.1767, 'lng': 78.0081},
    {'name': 'Siliguri', 'lat': 26.7271, 'lng': 88.3953},
    {'name': 'Nashik', 'lat': 19.9975, 'lng': 73.7898},
    {'name': 'Faridabad', 'lat': 28.4089, 'lng': 77.3178},
    {'name': 'Patiala', 'lat': 30.3398, 'lng': 76.3869},
    {'name': 'Ghaziabad', 'lat': 28.6692, 'lng': 77.4538},
    {'name': 'Kalyan', 'lat': 19.2437, 'lng': 73.1355},
    {'name': 'Noida', 'lat': 28.5355, 'lng': 77.3910},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    // First try local search for faster results
    final localResults = indianCities
        .where((city) => city['name'].toString().toLowerCase().contains(query))
        .take(10)
        .toList();

    setState(() {
      _suggestions = localResults;
      _isLoading = false;
    });

    // Also try Google Places API in background if needed
    try {
      final googleResults = await GooglePlacesService.searchCities(query);

      if (mounted && googleResults.isNotEmpty) {
        setState(() {
          // Combine local and Google results, prioritizing local
          final combinedResults = List<Map<String, dynamic>>.from(localResults);

          for (final place in googleResults) {
            // Check if not already in local results
            final exists = combinedResults.any(
              (city) =>
                  city['name'].toString().toLowerCase() ==
                  place.description.toLowerCase(),
            );

            if (!exists) {
              combinedResults.add({
                'name': place.description,
                'placeId': place.placeId,
                'isGoogle': true,
              });
            }
          }

          _suggestions = combinedResults.take(15).toList();
        });
      }
    } catch (e) {
      print('Google Places error: $e');
      // Continue with local results only
    }
  }

  void _onCityTap(Map<String, dynamic> city) async {
    if (city['isGoogle'] == true && city['placeId'] != null) {
      // Handle Google Places result
      setState(() => _isLoading = true);

      try {
        final details = await GooglePlacesService.getPlaceDetails(
          city['placeId'],
        );

        if (details != null) {
          widget.onCitySelected(details.name, details.lat, details.lng);
        } else {
          // Fallback to city name with default coordinates
          widget.onCitySelected(city['name'], 28.6139, 77.2090);
        }
      } catch (e) {
        print('Error getting place details: $e');
        widget.onCitySelected(city['name'], 28.6139, 77.2090);
      }

      setState(() => _isLoading = false);
    } else {
      // Handle local city result
      widget.onCitySelected(city['name'], city['lat'], city['lng']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Search City',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Search Field
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),

              // Loading or Results
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else if (_suggestions.isNotEmpty)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: suggestion['isGoogle'] == true
                              ? Colors.green
                              : Colors.blue,
                        ),
                        title: Text(
                          suggestion['name'] ??
                              suggestion['description'] ??
                              'City',
                        ),
                        subtitle: suggestion['isGoogle'] == true
                            ? Text(
                                'Google Places',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              )
                            : Text(
                                'Popular City',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                        onTap: () => _onCityTap(suggestion),
                      );
                    },
                  ),
                ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
