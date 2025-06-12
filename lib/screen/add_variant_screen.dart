// lib/screen/add_variant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/variant_provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddVariantScreen extends StatefulWidget {
  final int? productId;
  final String? productName;

  const AddVariantScreen({super.key, this.productId, this.productName});

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _stockController;

  // State untuk dropdown
  ProductModel? _selectedProduct;
  String? _selectedSize;
  String? _selectedMaterial;
  String? _selectedCollarType;
  String? _selectedSleeveType;

  // STATE BARU: Untuk menyimpan error dari server
  Map<String, String> _serverErrors = {};

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

  @override
  void initState() {
    super.initState();
    _lengthController = TextEditingController();
    _widthController = TextEditingController();
    _stockController = TextEditingController();
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Bersihkan error lama setiap kali submit
    setState(() {
      _serverErrors = {};
    });

    if (!_formKey.currentState!.validate()) return;

    if (widget.productId == null && _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, String> finalData = {
      'product_id':
          widget.productId?.toString() ?? _selectedProduct!.id.toString(),
      'size': _selectedSize!,
      'length': _lengthController.text,
      'width': _widthController.text,
      'material': _selectedMaterial!,
      'collar_type': _selectedCollarType!,
      'sleeve_type': _selectedSleeveType!,
      'stock': _stockController.text,
    };
    finalData.removeWhere((key, value) => value.isEmpty);

    final result = await Provider.of<VariantProvider>(
      context,
      listen: false,
    ).addVariant(finalData);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.of(context).pop(true);
      } else {
        final serverErrors = result['errors'] as Map<String, dynamic>?;
        if (serverErrors != null) {
          // Jika ada error validasi spesifik dari server
          final newErrors = <String, String>{};
          serverErrors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              newErrors[key] =
                  value[0]; // Ambil pesan error pertama untuk field tersebut
            }
          });
          setState(() {
            _serverErrors = newErrors;
          });
        } else {
          // Jika error umum
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to add variant.'),
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
      appBar: AppBar(
        title: Text(
          widget.productId != null
              ? 'Add Variant for ${widget.productName}'
              : 'Add New Variant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFA16C22),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ... (DropdownSearch dan info produk tidak berubah)
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA16C22),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Variant'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk dropdown, sekarang dengan parameter 'key' untuk error handling
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
