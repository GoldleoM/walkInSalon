import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get the user's current location (returns a default location if denied)
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Default: Bengaluru
      return const LatLng(12.9716, 77.5946);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Default: Bengaluru
      return const LatLng(12.9716, 77.5946);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // ignore: avoid_print
      print("Error getting current location: $e");
      return const LatLng(12.9716, 77.5946);
    }
  }

  /// Reverse-geocode a [LatLng] coordinate to a human-readable address.
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final res = await http.get(
        url,
        headers: {'User-Agent': 'WalkInSalonApp/1.0 (contact@example.com)'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('display_name')) {
          return data['display_name'];
        }
      } else {
        // ignore: avoid_print
        print('Reverse geocode failed with status: ${res.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print("Reverse geocode error: $e");
    }
    return null;
  }
}
