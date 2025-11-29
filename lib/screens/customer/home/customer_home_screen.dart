// Customer Home Screen with radius-based salon filtering (30km)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/screens/customer/home/location_selection_screen.dart';
import 'package:walkinsalonapp/screens/customer/home/widgets/salon_card.dart';
import 'package:walkinsalonapp/screens/customer/salon/salon_details_screen.dart';
import 'package:walkinsalonapp/screens/customer/bookings/my_bookings_screen.dart';
import 'package:walkinsalonapp/screens/customer/profile/customer_profile_screen.dart';
import 'package:walkinsalonapp/services/location_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    CustomerHomeContent(),
    MyBookingsScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppConfig.adaptiveSurface(context),
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CustomerHomeContent extends StatefulWidget {
  const CustomerHomeContent({super.key});

  @override
  State<CustomerHomeContent> createState() => _CustomerHomeContentState();
}

class _CustomerHomeContentState extends State<CustomerHomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _currentCity = 'Select Location';
  Position? _currentPosition;
  List<SalonModel> _allSalons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadLocation();
    await _fetchSalons();
  }

  Future<void> _loadLocation() async {
    final savedCity = await _locationService.getSavedCity();
    if (savedCity != null) {
      setState(() => _currentCity = savedCity);
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openLocationSelection(),
      );
    }
    // Get current position for distance calculations
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = pos);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _fetchSalons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('businesses')
          .get();
      final salons = snapshot.docs
          .map((doc) => SalonModel.fromMap(doc.data(), doc.id))
          .toList();
      setState(() {
        _allSalons = salons;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching salons: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openLocationSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
    );
    if (result != null && result is String) {
      setState(() => _currentCity = result);
    }
  }

  String? _calculateDistance(SalonModel salon) {
    if (_currentPosition == null ||
        salon.latitude == null ||
        salon.longitude == null) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      salon.latitude!,
      salon.longitude!,
    );
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<SalonModel> get _filteredSalons {
    const double radiusMeters = 30000; // 30 km
    return _allSalons.where((salon) {
      final matchesSearch =
          salon.salonName.toLowerCase().contains(_searchQuery) ||
          salon.address.toLowerCase().contains(_searchQuery);
      // City filter (keep for backward compatibility)
      final matchesCity =
          _currentCity == 'Select Location' ||
          (salon.city != null &&
              salon.city!.toLowerCase().contains(_currentCity.toLowerCase())) ||
          salon.address.toLowerCase().contains(_currentCity.toLowerCase());
      // Radius filter
      bool withinRadius = true;
      if (_currentPosition != null &&
          salon.latitude != null &&
          salon.longitude != null) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          salon.latitude!,
          salon.longitude!,
        );
        withinRadius = distance <= radiusMeters;
      }
      if (_selectedCategory == 'All') {
        return matchesSearch && matchesCity && withinRadius;
      }
      final matchesCategory = salon.services.any(
        (s) => s['name'].toString().toLowerCase().contains(
          _selectedCategory.toLowerCase(),
        ),
      );
      return matchesSearch && matchesCategory && matchesCity && withinRadius;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppConfig.adaptiveSurface(context),
        elevation: 0,
        title: GestureDetector(
          onTap: _openLocationSelection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConfig.adaptiveTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _currentCity,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppConfig.adaptiveTextColor(context),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppConfig.adaptiveTextColor(context),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search for salons, services...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppConfig.adaptiveSurface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 24),
            // Category chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All', _selectedCategory == 'All'),
                  _buildCategoryChip('Haircut', _selectedCategory == 'Haircut'),
                  _buildCategoryChip('Facial', _selectedCategory == 'Facial'),
                  _buildCategoryChip('Massage', _selectedCategory == 'Massage'),
                  _buildCategoryChip('Makeup', _selectedCategory == 'Makeup'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Salon list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSalons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory,
                            size: 64,
                            color: AppColors.secondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No salons found in $_currentCity.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.secondary),
                          ),
                          TextButton(
                            onPressed: _openLocationSelection,
                            child: const Text('Change Location'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredSalons.length,
                      itemBuilder: (c, i) {
                        final salon = _filteredSalons[i];
                        return SalonCard(
                          salon: salon,
                          distance: _calculateDistance(salon),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SalonDetailsScreen(salon: salon),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = label),
        backgroundColor: AppConfig.adaptiveSurface(context),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : AppConfig.adaptiveTextColor(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
