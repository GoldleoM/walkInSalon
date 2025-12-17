import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';

class SalonDetailsForm extends StatefulWidget {
  final TextEditingController salonName;
  final TextEditingController phone;
  final TextEditingController address;
  final TextEditingController email;
  final TextEditingController openTime;
  final TextEditingController closeTime;
  final Function(LatLng, String) onMapSelect;

  const SalonDetailsForm({
    super.key,
    required this.salonName,
    required this.phone,
    required this.address,
    required this.email,
    required this.openTime,
    required this.closeTime,
    required this.onMapSelect,
  });

  @override
  State<SalonDetailsForm> createState() => _SalonDetailsFormState();
}

class _SalonDetailsFormState extends State<SalonDetailsForm> {
  bool _isLoadingMap = false;

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

    if (picked != null && mounted) {
      setState(() {
        controller.text = picked.format(context); // e.g. "9:00 AM"
      });
    }
  }

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
        const SizedBox(height: 12),
        // 🕒 Operating Hours
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(widget.openTime),
                child: AbsorbPointer(
                  child: TextField(
                    controller: widget.openTime,
                    decoration: const InputDecoration(
                      labelText: 'Open Time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(widget.closeTime),
                child: AbsorbPointer(
                  child: TextField(
                    controller: widget.closeTime,
                    decoration: const InputDecoration(
                      labelText: 'Close Time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
