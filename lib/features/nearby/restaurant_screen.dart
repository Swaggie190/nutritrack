import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nutritrack/core/constants/app_constants.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/nearby_restaurant_service.dart';
import 'package:nutritrack/widgets/service_unavailable_dialog.dart';

class NearbyRestaurantsPage extends StatefulWidget {
  const NearbyRestaurantsPage({Key? key}) : super(key: key);

  @override
  _NearbyRestaurantsPageState createState() => _NearbyRestaurantsPageState();
}

class _NearbyRestaurantsPageState extends State<NearbyRestaurantsPage> {
  final MapController _mapController = MapController();
  final NearbyRestaurantService _restaurantService = NearbyRestaurantService();
  List<Restaurant> _restaurants = [];
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  //getting current location with Geolocator
  Future<void> _getCurrentLocation() async {
    if (_isDisposed) return;

    try {
      //Handling permissions to access user location
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final permissionRequest = await Geolocator.requestPermission();
        if (permissionRequest == LocationPermission.denied) {
          _safeSetState(() {
            _error = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (_isDisposed) return;

      final position = await Geolocator.getCurrentPosition();
      _safeSetState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      await _fetchNearbyRestaurants();
    } catch (e) {
      if (!_isDisposed) {
        _safeSetState(() {
          _error = 'Unable to access location services';
          _isLoading = false;
        });
      }
    }
  }

  //Fetch restaurants based on user location
  Future<void> _fetchNearbyRestaurants() async {
    if (_userLocation == null || _isDisposed) return;

    try {
      final restaurants =
          await _restaurantService.getNearbyRestaurants(_userLocation!);
      if (!_isDisposed) {
        _safeSetState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        _safeSetState(() {
          _error = AppConstants.networkError;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isDisposed) return;

    _safeSetState(() {
      _isLoading = true;
      _error = null;
    });
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Restaurants',
            style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: ThemeConstants.errorColor),
              const SizedBox(height: ThemeConstants.defaultPadding),
              Text(_error!, style: ThemeConstants.bodyStyle),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          //Using FluuterMap to draw the map on the UI and handle markers
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(0, 0),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: ThemeConstants.primaryColor,
                        size: 40,
                      ),
                    ),
                  ..._restaurants.map(
                    (restaurant) => Marker(
                      point: LatLng(restaurant.latitude, restaurant.longitude),
                      width: 30,
                      height: 30,
                      child: GestureDetector(
                        onTap: () => _showRestaurantDetails(restaurant),
                        child: const Icon(
                          Icons.restaurant,
                          color: ThemeConstants.secondaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return Card(
                  elevation: ThemeConstants.defaultElevation,
                  margin: const EdgeInsets.only(
                      bottom: ThemeConstants.smallPadding),
                  child: ListTile(
                    title: Text(
                      restaurant.name,
                      style: ThemeConstants.cardTitleStyle,
                    ),
                    subtitle: Text(
                      '${restaurant.cuisine}\n${restaurant.address}',
                      style: ThemeConstants.bodyStyle.copyWith(fontSize: 14),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: ThemeConstants.secondaryColor,
                      child: Icon(Icons.restaurant, color: Colors.white),
                    ),
                    onTap: () {
                      if (!_isDisposed) {
                        _mapController.move(
                          LatLng(restaurant.latitude, restaurant.longitude),
                          16.0,
                        );
                        _showRestaurantDetails(restaurant);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Details shown when a user clicks on a found location
  void _showRestaurantDetails(Restaurant restaurant) {
    if (_isDisposed) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(ThemeConstants.largeBorderRadius)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              style: ThemeConstants.subheadingStyle,
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            Text(
              'Cuisine: ${restaurant.cuisine}',
              style: ThemeConstants.bodyStyle,
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            Text(
              'Address: ${restaurant.address}',
              style: ThemeConstants.bodyStyle,
            ),
            const SizedBox(height: ThemeConstants.largePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
                ),
                onPressed: () {
                  ServiceUnavailable();
                  Navigator.pop(context);
                },
                child: Text(
                  'Get Directions',
                  style: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
