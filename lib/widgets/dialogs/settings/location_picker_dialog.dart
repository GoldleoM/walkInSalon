  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:walkinsalonapp/services/settings/location_settings_service.dart';

  Future<LatLng?> showLocationPickerDialog(
    BuildContext context, {
    LatLng? initialLocation,
    required Function(String address) onAddressPicked,
  }) async {
    final locationService = LocationService();
    final current = await locationService.getCurrentLocation();

    LatLng start = initialLocation ?? current;
    MapController controller = MapController();
    LatLng? selected = start;

    return showDialog<LatLng>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Salon Location'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: start,
                initialZoom: 15,
                onTap: (tap, latLng) async {
                  setState(() => selected = latLng);
                  final addr = await locationService.reverseGeocode(
                    latLng.latitude,
                    latLng.longitude,
                  );
                  if (addr != null) onAddressPicked(addr);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.walkinsalon.app',
                ),
                if (selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selected!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
