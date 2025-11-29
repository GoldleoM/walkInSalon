import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';

class SalonDetailsForm extends StatefulWidget {
  final TextEditingController salonName;
  final TextEditingController phone;
  final TextEditingController address;
  final TextEditingController email;
  final Function(LatLng, String) onMapSelect;

  const SalonDetailsForm({
    super.key,
    required this.salonName,
    required this.phone,
    required this.address,
    required this.email,
    required this.onMapSelect,
  });

  @override
  State<SalonDetailsForm> createState() => _SalonDetailsFormState();
}

class _SalonDetailsFormState extends State<SalonDetailsForm> {
  bool _isLoadingMap = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.salonName,
          decoration: const InputDecoration(labelText: 'Salon Name'),
        ),
        TextField(
          controller: widget.phone,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
        ),
        TextField(
          controller: widget.email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          controller: widget.address,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: _isLoadingMap
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.location_on),
          label: Text(
            _isLoadingMap ? 'Loading Map...' : 'Select Location on Map',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.padding,
              vertical: AppConstants.padding * 0.75,
            ),
          ),
          onPressed: _isLoadingMap ? null : _openLocationPicker,
        ),
      ],
    );
  }

  Future<void> _openLocationPicker() async {
    setState(() => _isLoadingMap = true);
    debugPrint("Opening location picker dialog...");

    try {
      final loc = await showLocationPickerDialog(
        context,
        initialLocation: null,
        onAddressPicked: (addr) {
          widget.address.text = addr;
        },
      );

      if (loc != null) {
        widget.onMapSelect(loc, widget.address.text);
      }
    } catch (e) {
      debugPrint("Error opening location picker: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMap = false);
      }
    }
  }
}
