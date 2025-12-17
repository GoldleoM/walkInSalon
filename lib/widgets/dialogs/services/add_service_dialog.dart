import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:uuid/uuid.dart';

class AddServiceDialog extends StatefulWidget {
  final Map<String, dynamic>? initialService;

  const AddServiceDialog({super.key, this.initialService});

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _nameController.text = widget.initialService!['name'];
      _priceController.text = widget.initialService!['price'].toString();
      _durationController.text = (widget.initialService!['duration'] ?? 30).toString();
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final service = {
      'id': widget.initialService?['id'] ?? _uuid.v4(),
      'name': _nameController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'duration': int.parse(_durationController.text.trim()),
    };

    Navigator.pop(context, service);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      backgroundColor: colors.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialService != null ? "Edit Service" : "Add Service",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: "Service Name",
                icon: Icons.cut_outlined,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: "Price (₹)",
                      icon: Icons.currency_rupee,
                      limit: 6,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return "Required";
                        if (double.tryParse(v) == null) return "Invalid";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: "Duration (min)",
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      limit: 3,
                      validator: (v) {
                        if (v!.isEmpty) return "Required";
                        if (int.tryParse(v) == null) return "Invalid";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? limit,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: limit,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        prefixIcon: Icon(icon, size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
