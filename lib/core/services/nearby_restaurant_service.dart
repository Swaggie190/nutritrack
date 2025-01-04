import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class NearbyRestaurantService {
  static const String overpassApiUrl =
      'https://overpass-api.de/api/interpreter';
  static const double searchRadius = 1000; // 1km radius

  Future<List<Restaurant>> getNearbyRestaurants(LatLng userLocation) async {
    // Create Overpass QL query to find restaurants
    final query = """
      [out:json][timeout:25];
      (
        node["amenity"="restaurant"](around:$searchRadius,${userLocation.latitude},${userLocation.longitude});
      );
      out body;
      >;
      out skel qt;
    """;

    try {
      final response = await http.post(
        Uri.parse(overpassApiUrl),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        return elements.map((element) {
          return Restaurant(
            id: element['id'].toString(),
            name: element['tags']['name'] ?? 'Unknown Restaurant',
            latitude: element['lat'].toDouble(),
            longitude: element['lon'].toDouble(),
            cuisine: element['tags']['cuisine'] ?? 'Not specified',
            address: element['tags']['addr:street'] ?? 'Address not available',
          );
        }).toList();
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Error fetching nearby restaurants: $e');
    }
  }
}

class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String cuisine;
  final String address;

  Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cuisine,
    required this.address,
  });
}
