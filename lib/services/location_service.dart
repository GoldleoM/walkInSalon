import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static const String _selectedCityKey = 'selected_city';

  /// Get current city from device location
  Future<String?> getCurrentCity() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Try geocoding package first (works on mobile)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Prioritize administrativeArea (state/city) over locality (area/neighborhood)
          final city =
              place.administrativeArea ??
              place.subAdministrativeArea ??
              place.locality;

          if (city != null && city.isNotEmpty) {
            debugPrint('City from geocoding: $city');
            return city;
          }
        }
      } catch (e) {
        debugPrint('Geocoding package failed (likely on web): $e');
      }

      // Fallback to Nominatim API (works on web and mobile)
      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
          ),
          headers: {'User-Agent': 'WalkInSalonApp/1.0'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('address')) {
            final address = data['address'];
            // Prioritize city/state level over suburbs/localities
            final city =
                address['city'] ??
                address['state_district'] ??
                address['state'] ??
                address['town'] ??
                address['county'];

            if (city != null && city.isNotEmpty) {
              debugPrint('City from Nominatim: $city');
              return city;
            }
          }
        }
      } catch (e) {
        debugPrint('Nominatim API failed: $e');
      }

      return null;
    } catch (e) {
      debugPrint('Error getting current city: $e');
      return null;
    }
  }

  /// Get city from coordinates
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    // Try geocoding package first (works on mobile)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Prioritize administrativeArea (state/city) over locality (area/neighborhood)
        final city = place.administrativeArea ??
            place.subAdministrativeArea ??
            place.locality;

        if (city != null && city.isNotEmpty) {
          debugPrint('City from geocoding: $city');
          return city;
        }
      }
    } catch (e) {
      debugPrint('Geocoding package failed (likely on web): $e');
    }

    // Fallback to Nominatim API (works on web and mobile)
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json',
        ),
        headers: {'User-Agent': 'WalkInSalonApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('address')) {
          final address = data['address'];
          // Prioritize city/state level over suburbs/localities
          final city = address['city'] ??
              address['state_district'] ??
              address['state'] ??
              address['town'] ??
              address['county'];

          if (city != null && city.isNotEmpty) {
            debugPrint('City from Nominatim: $city');
            return city;
          }
        }
      }
    } catch (e) {
      debugPrint('Nominatim API failed: $e');
    }

    return null;
  }

  /// Save selected city to local storage
  Future<void> saveSelectedCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCityKey, city);
      debugPrint('Saved city: $city');
    } catch (e) {
      debugPrint('Error saving selected city: $e');
    }
  }

  /// Get saved selected city from local storage
  Future<String?> getSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final city = prefs.getString(_selectedCityKey);
      debugPrint('Retrieved saved city: $city');
      return city;
    } catch (e) {
      debugPrint('Error getting saved city: $e');
      return null;
    }
  }
}
