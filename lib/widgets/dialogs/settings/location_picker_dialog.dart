import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkinsalonapp/services/settings/location_settings_service.dart';
import 'package:walkinsalonapp/core/app_config.dart';

Future<LatLng?> showLocationPickerDialog(
  BuildContext context, {
  LatLng? initialLocation,
  required Function(String address) onAddressPicked,
  String title = 'Select Salon Location',
}) async {
  final locationService = LocationService();

  LatLng start;
  try {
    final current = await locationService.getCurrentLocation();
    start = initialLocation ?? current;
  } catch (e) {
    debugPrint('Error getting current location in dialog: $e');
    // Fallback to a default location (Bengaluru)
    start = initialLocation ?? const LatLng(12.9716, 77.5946);
  }

  if (!context.mounted) return null;

  MapController controller = MapController();

  return showDialog<LatLng>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.darkBackground.withValues(alpha: 0.6),
    builder: (dialogContext) {
      LatLng? selected = start;
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: AppConfig.padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            backgroundColor: AppConfig.adaptiveSurface(
              context,
            ).withValues(alpha: 0.95),
            child: SizedBox(
              width: 420,
              height: 480,
              child: Column(
                children: [
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: AppConfig.adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  // Map area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: controller,
                            options: MapOptions(
                              initialCenter: start,
                              initialZoom: 15,
                              onTap: (tapPosition, latLng) async {
                                setState(() {
                                  selected = latLng;
                                  isLoading = true;
                                });

                                try {
                                  final addr = await locationService
                                      .reverseGeocode(
                                        latLng.latitude,
                                        latLng.longitude,
                                      );

                                  if (addr != null) {
                                    onAddressPicked(addr);
                                  }
                                } catch (e) {
                                  debugPrint('Error reverse geocoding: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to get address for this location',
                                        ),
                                      ),
                                    );
                                  }
                                }

                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                        color: AppColors.error,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Reverse-geocode spinner
                          if (isLoading)
                            Container(
                              color: AppColors.darkBackground.withValues(
                                alpha: 0.26,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Footer actions
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            "Cancel",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.darkTextPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(dialogContext, selected),
                          child: const Text("Done"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
