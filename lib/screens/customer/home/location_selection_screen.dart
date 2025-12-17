import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/location_service.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  // Popular cities in India (as per BookMyShow example)
  final List<Map<String, dynamic>> _popularCities = [
    {'name': 'Mumbai', 'icon': Icons.apartment},
    {'name': 'Delhi-NCR', 'icon': Icons.location_city},
    {'name': 'Bengaluru', 'icon': Icons.computer},
    {'name': 'Hyderabad', 'icon': Icons.business},
    {'name': 'Chandigarh', 'icon': Icons.grid_view},
    {'name': 'Ahmedabad', 'icon': Icons.factory},
    {'name': 'Pune', 'icon': Icons.school},
    {'name': 'Chennai', 'icon': Icons.temple_hindu},
    {'name': 'Kolkata', 'icon': Icons.location_city},
    {'name': 'Kochi', 'icon': Icons.water},
  ];

  void _selectCity(String city) async {
    await _locationService.saveSelectedCity(city);
    if (mounted) {
      Navigator.pop(context, city);
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLoading = true;
    });

    final city = await _locationService.getCurrentCity();

    setState(() {
      _isLoading = false;
    });

    if (city != null) {
      _selectCity(city);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not detect location. Please select manually.'),
          ),
        );
      }
    }
  }

  Future<void> _openMapPicker() async {
    final picked = await showLocationPickerDialog(
      context,
      title: 'Select Your Location',
      onAddressPicked: (_) {},
    );

    if (picked != null) {
      // Reverse geocode to get city
      try {
        final city = await _locationService.getCityFromCoordinates(
          picked.latitude,
          picked.longitude,
        );

        if (city != null) {
          _selectCity(city);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not determine city from selected location.'),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error getting city from coordinates: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppConfig.adaptiveSurface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppConfig.adaptiveTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Location",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppConfig.adaptiveSurface(context),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search for your city",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppConfig.adaptiveBackground(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _selectCity(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _detectLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                          const SizedBox(width: 8),
                          Text(
                            "Detect my location",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _openMapPicker,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Select on map",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Popular Cities
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Popular Cities",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppConfig.adaptiveTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _popularCities.length,
                    itemBuilder: (context, index) {
                      final city = _popularCities[index];
                      return InkWell(
                        onTap: () => _selectCity(city['name']),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppConfig.adaptiveTextColor(
                                context,
                              ).withValues(alpha: 0.1),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                city['icon'],
                                size: 32,
                                color: AppConfig.adaptiveTextColor(
                                  context,
                                ).withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                city['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConfig.adaptiveTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Expand to show all cities (future implementation)
                      },
                      child: Text(
                        "View All Cities",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
