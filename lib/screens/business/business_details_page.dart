import 'dart:io';
import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Unused
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/auth/login/login_page.dart';
import 'package:walkinsalonapp/providers/business_provider.dart'; // Provider
import 'package:walkinsalonapp/providers/image_upload_provider.dart'; // Provider
import 'package:walkinsalonapp/screens/business/business_dashboard_page.dart';
import 'package:walkinsalonapp/widgets/dialogs/barbers/add_barber_dialog.dart';
import 'package:walkinsalonapp/widgets/dialogs/barbers/add_specialty_dialog.dart';
import 'package:walkinsalonapp/screens/business/widgets/cover_image_picker.dart';
import 'package:walkinsalonapp/screens/business/widgets/profile_image_picker.dart';
import 'package:walkinsalonapp/widgets/dashboard/barber_dashboard_card.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';
import 'package:walkinsalonapp/widgets/dialogs/services/add_service_dialog.dart';
import 'package:walkinsalonapp/widgets/dashboard/service_list_item.dart';

final supabase = Supabase.instance.client;
final _uuid = const Uuid();

class BusinessDetailsPage extends ConsumerStatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  ConsumerState<BusinessDetailsPage> createState() =>
      _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends ConsumerState<BusinessDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _salonNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();

  File? _profileImage;
  File? _coverImage;
  Uint8List? _webProfileImage;
  Uint8List? _webCoverImage;

  bool _isSaving = false;
  double? _latitude;
  double? _longitude;

  final List<Map<String, dynamic>> _barbers = [];
  final List<Map<String, dynamic>> _services = [];

  // 🕓 Pick a time with popup
  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  // 🗺️ Location picker
  Future<void> _pickLocation() async {
    final picked = await showLocationPickerDialog(
      context,
      onAddressPicked: (address) {
        _addressController.text = address;
      },
    );

    if (picked != null) {
      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📍 Location selected: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
          ),
        ),
      );
    }
  }

  // 🖼️ File picker
  Future<void> _pickFile(bool isProfile) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          if (isProfile) {
            _webProfileImage = result.files.single.bytes;
          } else {
            _webCoverImage = result.files.single.bytes;
          }
        });
      } else if (result.files.single.path != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(result.files.single.path!);
          } else {
            _coverImage = File(result.files.single.path!);
          }
        });
      }
    }
  }

  Future<String?> _uploadImage(dynamic file, String type) async {
    // 🛠️ USE RIVERPOD PROVIDER
    return await ref.read(imageUploadServiceProvider).uploadImage(file, type);
  }

  Future<void> _saveBusinessDetails() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");
      // final uid = user.uid; // Unused

      String? profileUrl;
      String? coverUrl;

      if (_profileImage != null || _webProfileImage != null) {
        profileUrl = await _uploadImage(
          kIsWeb ? _webProfileImage : _profileImage!,
          'profile',
        );
      }

      if (_coverImage != null || _webCoverImage != null) {
        coverUrl = await _uploadImage(
          kIsWeb ? _webCoverImage : _coverImage!,
          'cover',
        );
      }

      for (var barber in _barbers) {
        barber['barberId'] ??= _uuid.v4();
      }

      final businessData = {
        'salonName': _salonNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'openTime': _openTimeController.text.trim(),
        'closeTime': _closeTimeController.text.trim(),
        'barbers': _barbers,
        'services': _services,
        'profileImage': profileUrl,
        'coverImage': coverUrl,
        'avgRating': 0.0,
        'status': 'active',
      };

      // 🛠️ USE RIVERPOD PROVIDER
      await ref.read(businessServiceProvider).saveBusinessDetails(businessData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Business details saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BusinessDashboardPage()),
      );
    } catch (e) {
      debugPrint("❌ Error saving business details: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addBarber() async {
    final newBarber = await showAddBarberDialog(context);
    if (newBarber != null) {
      setState(() => _barbers.add(newBarber));
    }
  }

  void _addSpecialty(int index) async {
    final specialty = await showAddSpecialtyDialog(
      context,
      _barbers[index]['name'],
    );
    if (specialty != null) {
      setState(() => _barbers[index]['specialties'].add(specialty));
    }
  }

  void _addService() async {
    final newService = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddServiceDialog(),
    );
    if (newService != null) {
      setState(() => _services.add(newService));
    }
  }

  void _editService(int index) async {
    final updatedService = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddServiceDialog(initialService: _services[index]),
    );
    if (updatedService != null) {
      setState(() => _services[index] = updatedService);
    }
  }

  void _deleteService(int index) {
    setState(() => _services.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Business Setup",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.dynamicGradient(context),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.padding,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 650),
              padding: const EdgeInsets.all(32),
              decoration: AppDecorations.glassPanel(context),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Salon Details",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Complete your salon setup to get started",
                      style: GoogleFonts.inter(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // 🖼️ Cover + Profile
                    CoverImagePicker(
                      webCoverImage: _webCoverImage,
                      coverImage: _coverImage,
                      onTap: () => _pickFile(false),
                    ),
                    const SizedBox(height: 16),

                    ProfileImagePicker(
                      webProfileImage: _webProfileImage,
                      profileImage: _profileImage,
                      onTap: () => _pickFile(true),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(_salonNameController, "Salon Name", false),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, "Phone Number", false),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, "Address", false),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text("Select Location on Map"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.smallRadius,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🕒 Time Pickers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(_openTimeController),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                _openTimeController,
                                "Open Time",
                                true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(_closeTimeController),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                _closeTimeController,
                                "Close Time",
                                true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Services",
                          style: GoogleFonts.poppins(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: _addService,
                          icon: Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _services.asMap().entries.map((entry) {
                        final index = entry.key;
                        final service = entry.value;
                        return ServiceListItem(
                          service: service,
                          onEdit: () => _editService(index),
                          onDelete: () => _deleteService(index),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Barbers",
                          style: GoogleFonts.poppins(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: _addBarber,
                          icon: Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children: _barbers.map((barber) {
                        final index = _barbers.indexOf(barber);
                        return BarberCard(
                          barber: barber,
                          onAddSpecialty: () => _addSpecialty(index),
                          onDeleteSpecialty: (spec) {
                            setState(() => barber['specialties'].remove(spec));
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // ✅ Save + Cancel buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveBusinessDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.smallRadius,
                                ),
                              ),
                              elevation: AppConstants.elevation,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Save Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.onSurface,
                              side: BorderSide(
                                color: colors.outline.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.smallRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable themed input
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool read,
  ) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      readOnly: read,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
        filled: true,
        fillColor: colors.surface.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
