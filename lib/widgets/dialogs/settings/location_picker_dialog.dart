import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkinsalonapp/services/settings/location_settings_service.dart';
import 'package:walkinsalonapp/core/app_config.dart';

Future<LatLng?> showLocationPickerDialog(
  BuildContext context, {
  LatLng? initialLocation,
  required Function(String address) onAddressPicked,
}) async {
  final locationService = LocationService();
  final current = await locationService.getCurrentLocation();
  if (!context.mounted) return null;

  LatLng start = initialLocation ?? current;
  MapController controller = MapController();

  return showDialog<LatLng>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.darkBackground.withOpacity(0.6),
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
            backgroundColor: AppConfig.adaptiveSurface(context).withOpacity(0.95),
            child: SizedBox(
              width: 420,
              height: 480,
              child: Column(
                children: [
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.map_outlined, color: AppConfig.adaptiveTextColor(context).withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(
                          'Select Salon Location',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
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

                                final addr =
                                    await locationService.reverseGeocode(
                                  latLng.latitude,
                                  latLng.longitude,
                                );

                                if (addr != null) {
                                  onAddressPicked(addr);
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
                              color: AppColors.darkBackground.withOpacity(0.26),
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
                        horizontal: 16, vertical: 10),
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
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
