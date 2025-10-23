import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkinsalonapp/widgets/dialogs/settings/location_picker_dialog.dart';

class SalonDetailsForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: salonName,
          decoration: const InputDecoration(labelText: 'Salon Name'),
        ),
        TextField(
          controller: phone,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
        ),
        TextField(
          controller: email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          controller: address,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.location_on),
          label: const Text('Select Location on Map'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.padding,
              vertical: AppConstants.padding * 0.75,
            ),
          ),
          onPressed: () async {
            print("Opening location picker dialog..."); // debug
            final loc = await showLocationPickerDialog(
              context,
              initialLocation: null, // optionally pass last known location
              onAddressPicked: (addr) {
                address.text = addr;
              },
            );

            if (loc != null) {
              onMapSelect(loc, address.text);
            }
          },
        ),
      ],
    );
  }
}
