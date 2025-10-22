import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dashboard_buisness.dart';
import 'package:walkinsalonapp/widgets/dialogs/barbers/add_barber_dialog.dart';
import 'package:walkinsalonapp/widgets/dialogs/barbers/add_specialty_dialog.dart';
import 'package:walkinsalonapp/screens/business/widgets/cover_image_picker.dart';
import 'package:walkinsalonapp/screens/business/widgets/profile_image_picker.dart';
import 'package:walkinsalonapp/screens/business/widgets/dashboard/barber_dashboard_card.dart';
import 'package:walkinsalonapp/services/image_upload_service.dart';
import 'package:walkinsalonapp/services/business_dashboard_service.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';

final supabase = Supabase.instance.client;
final _uuid = const Uuid();

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
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

  @override
  void dispose() {
    _salonNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  // 💇 List of barbers, each with their own specialties
  final List<Map<String, dynamic>> _barbers = [];

  // 📍 Pick location
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📍 Location selected: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
          ),
        ),
      );
    }
  }

  // 📂 Pick image
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

  // ☁️ Upload image
  Future<String?> _uploadImage(dynamic file, String type) async {
    return await ImageUploadService.uploadImage(file, type);
  }

  // 💾 Save business details
Future<void> _saveBusinessDetails() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isSaving = true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in.");

    final uid = user.uid;

    // ✅ Upload images (if any)
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

    // ✅ Assign IDs to barbers if not set
    for (var barber in _barbers) {
      barber['barberId'] ??= _uuid.v4();
    }

    // ✅ Prepare business data
    final businessData = {
      'businessId': uid,
      'salonName': _salonNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'openTime': _openTimeController.text.trim(),
      'closeTime': _closeTimeController.text.trim(),
      'barbers': _barbers,
      'profileImage': profileUrl,
      'coverImage': coverUrl,
      'avgRating': 0.0,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final firestore = FirebaseFirestore.instance;

    // ✅ Save business data to `/businesses/{uid}`
    await firestore.collection('businesses').doc(uid).set(businessData, SetOptions(merge: true));

    // ✅ Mark user as having completed setup
    await firestore.collection('users').doc(uid).update({
      'role': 'business',
      'businessId': uid,
      'businessSetupComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Business details saved successfully!')),
    );

    // ✅ Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BusinessDashboardPage()),
    );
  } catch (e) {
    debugPrint("❌ Error saving business details: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}

  // ➕ Add a barber
  void _addBarber() async {
    final newBarber = await showAddBarberDialog(context);
    if (newBarber != null) {
      setState(() => _barbers.add(newBarber));
    }
  }

  // ➕ Add a specialty
  void _addSpecialty(int index) async {
    final specialty = await showAddSpecialtyDialog(
      context,
      _barbers[index]['name'],
    );
    if (specialty != null) {
      setState(() => _barbers[index]['specialties'].add(specialty));
    }
  }

  // 🖼️ UI
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    DecorationImage? coverDecoration;
    if (kIsWeb && _webCoverImage != null) {
      coverDecoration = DecorationImage(
        image: MemoryImage(_webCoverImage!),
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _coverImage != null) {
      coverDecoration = DecorationImage(
        image: FileImage(_coverImage!),
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Cover image
              CoverImagePicker(
                webCoverImage: _webCoverImage,
                coverImage: _coverImage,
                onTap: () => _pickFile(false),
              ),

              const SizedBox(height: 12),

              // Profile image
              ProfileImagePicker(
                webProfileImage: _webProfileImage,
                profileImage: _profileImage,
                onTap: () => _pickFile(true),
              ),

              const SizedBox(height: 20),

              // Business info
              TextFormField(
                controller: _salonNameController,
                decoration: const InputDecoration(labelText: 'Salon Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Select Location on Map'),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openTimeController,
                      decoration: const InputDecoration(labelText: 'Open Time'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _closeTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Close Time',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 💇 Barbers section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Barbers',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: _addBarber,
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                  ),
                ],
              ),

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

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveBusinessDetails,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
