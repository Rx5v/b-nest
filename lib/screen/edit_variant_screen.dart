// lib/screen/edit_variant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/variant_provider.dart';
import 'package:admin_batik/models/variant_model.dart';
import 'package:admin_batik/models/product_model.dart';

class EditVariantScreen extends StatefulWidget {
  final VariantModel variant;
  final String productName;

  const EditVariantScreen({
    super.key,
    required this.variant,
    required this.productName,
  });

  @override
  State<EditVariantScreen> createState() => _EditVariantScreenState();
}

class _EditVariantScreenState extends State<EditVariantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _stockController;

  // State untuk dropdowns
  String? _selectedSize;
  String? _selectedMaterial;
  String? _selectedCollarType;
  String? _selectedSleeveType;

  // Opsi dropdown
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _materials = [
    'Katun',
    'Sutra',
    'Linen',
    'Rayon',
    'Serat Nanas',
    'Kain Grey',
  ];
  final List<String> _collarTypes = [
    'Mandarin',
    'Bulat',
    'V',
    'Kotak',
    'Rebah',
    'Pita',
    'Bertha',
    'Cibi',
  ];
  final List<String> _sleeveTypes = ['Pendek', 'Panjang'];

  Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi form dengan data varian yang ada
    _lengthController = TextEditingController(
      text: widget.variant.length.toString(),
    );
    _widthController = TextEditingController(
      text: widget.variant.width.toString(),
    );
    _stockController = TextEditingController(
      text: widget.variant.stock.toString(),
    );

    _selectedSize = widget.variant.size;
    _selectedMaterial = widget.variant.material;
    _selectedCollarType = widget.variant.collarType;
    _selectedSleeveType = widget.variant.sleeveType;
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() => _serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, String> finalData = {
      'size': _selectedSize!,
      'length': _lengthController.text,
      'width': _widthController.text,
      'material': _selectedMaterial!,
      'collar_type': _selectedCollarType!,
      'sleeve_type': _selectedSleeveType!,
      'stock': _stockController.text,
      '_method': 'PUT',
    };
    finalData.removeWhere((key, value) => value.isEmpty);

    final result = await Provider.of<VariantProvider>(
      context,
      listen: false,
    ).updateVariant(widget.variant.id, finalData);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.of(context).pop(true); // Kirim sinyal sukses
      } else {
        final serverErrors = result['errors'] as Map<String, dynamic>?;
        if (serverErrors != null) {
          final newErrors = <String, String>{};
          serverErrors.forEach((key, value) {
            if (value is List && value.isNotEmpty) newErrors[key] = value[0];
          });
          setState(() => _serverErrors = newErrors);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update variant.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Variant for ${widget.productName}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2, color: Colors.grey),
                title: const Text("Product (Read-only)"),
                subtitle: Text(
                  widget.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildStandardDropdown(
                'size',
                'Size',
                _sizes,
                _selectedSize,
                (val) => setState(() => _selectedSize = val),
                isRequired: true,
              ),
              _buildTextFormField(
                'length',
                _lengthController,
                'Length (cm)',
                TextInputType.number,
              ),
              _buildTextFormField(
                'width',
                _widthController,
                'Width (cm)',
                TextInputType.number,
              ),
              _buildStandardDropdown(
                'material',
                'Material',
                _materials,
                _selectedMaterial,
                (val) => setState(() => _selectedMaterial = val),
                isRequired: true,
              ),
              _buildStandardDropdown(
                'collar_type',
                'Collar Type',
                _collarTypes,
                _selectedCollarType,
                (val) => setState(() => _selectedCollarType = val),
                isRequired: true,
              ),
              _buildStandardDropdown(
                'sleeve_type',
                'Sleeve Type',
                _sleeveTypes,
                _selectedSleeveType,
                (val) => setState(() => _selectedSleeveType = val),
                isRequired: true,
              ),
              _buildTextFormField(
                'stock',
                _stockController,
                'Stock',
                TextInputType.number,
                isRequired: true,
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Update Variant'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardDropdown(
    String key,
    String label,
    List<String> items,
    String? currentValue,
    ValueChanged<String?> onChanged, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: _serverErrors[key], // Tampilkan error server di sini
        ),
        items:
            items
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
        onChanged: (value) {
          // Hapus error server untuk field ini saat user mengubah nilainya
          if (_serverErrors.containsKey(key)) {
            setState(() {
              _serverErrors.remove(key);
            });
          }
          onChanged(value);
        },
        validator: (value) {
          if (isRequired && value == null) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // Helper untuk textfield, sekarang dengan parameter 'key'
  Widget _buildTextFormField(
    String key,
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: _serverErrors[key], // Tampilkan error server di sini
        ),
        keyboardType: keyboardType,
        onChanged: (value) {
          // Hapus error server untuk field ini saat user mulai mengetik
          if (_serverErrors.containsKey(key)) {
            setState(() {
              _serverErrors.remove(key);
            });
          }
        },
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (keyboardType == TextInputType.number &&
              value != null &&
              value.isNotEmpty &&
              int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
