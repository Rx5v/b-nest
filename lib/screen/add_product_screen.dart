// lib/screen/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart'; // Meskipun tidak membuat instance langsung, berguna untuk referensi field
import 'package:google_fonts/google_fonts.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName =
      '/add-product'; // Untuk named navigation jika dipakai

  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk setiap field
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _batikTypeController = TextEditingController(); // subCategory
  final _imageUrlController =
      TextEditingController(); // Placeholder untuk URL gambar
  final _productCodeController =
      TextEditingController(); // Opsional, jika user input kode
  final _codeController =
      TextEditingController(); // Mengganti _productCodeController
  final _stockController = TextEditingController();
  String? _selectedCategory; // Untuk dropdown kategori
  String? _selectedStatus; // Untuk dropdown status

  final List<String> _categories = ['Kain', 'Kaos', 'Kemeja'];
  final List<String> _statuses = ['Tersedia', 'Tidak Tersedia'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _batikTypeController.dispose();
    _imageUrlController.dispose();
    _productCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, jangan lakukan apa-apa
    }
    _formKey.currentState!.save(); // Panggil onSaved pada setiap TextFormField

    setState(() {
      _isLoading = true;
    });

    // Siapkan data produk dari input form
    // Anda mungkin perlu menyesuaikan `productCode` jika di-generate oleh backend
    // atau jika user tidak menginputkannya.
    final productData = {
      'name': _nameController.text,
      'code':
          _codeController.text.isEmpty
              ? null
              : _codeController
                  .text, // Kirim null jika kosong, backend bisa generate
      'description': _descriptionController.text,
      'price': num.tryParse(_priceController.text) ?? 0, // Kirim sebagai num
      'category': _selectedCategory, // Langsung kirim string kategori
      'batik_type': _batikTypeController.text,
      'status': _selectedStatus, // Langsung kirim string status
      'stock': int.tryParse(_stockController.text) ?? 0, // Tambahkan stock
      // Untuk 'images', jika API mengharapkan list of URLs dalam JSON:
      'images':
          _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList() // Contoh jika URL dipisah koma
              : [], // Atau null jika API memperbolehkan
      // Jika API memerlukan field lain, tambahkan di sini
    };

    try {
      final success = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).addProduct(productData);

      if (mounted) {
        // Cek apakah widget masih ada di tree
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(
            context,
          ).pop(); // Kembali ke halaman sebelumnya (ProductScreen)
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).errorMessage ??
                    'Failed to add product.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Product',
          style: GoogleFonts.crimsonPro(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFA16C22),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextFormField(
                  _nameController,
                  'Name',
                  TextInputType.text,
                ),
                _buildTextFormField(
                  _descriptionController,
                  'Description',
                  TextInputType.multiline,
                  maxLines: 3,
                ),
                _buildTextFormField(
                  _priceController,
                  'Price',
                  TextInputType.number,
                ),
                _buildDropdownFormField(
                  value: _selectedCategory,
                  hint: 'Select Category',
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Please select a category' : null,
                ),
                _buildTextFormField(
                  _batikTypeController,
                  'Batik Type / Sub Category',
                  TextInputType.text,
                ),
                _buildDropdownFormField(
                  value: _selectedStatus,
                  hint: 'Select Status',
                  items: _statuses,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Please select a status' : null,
                ),
                _buildTextFormField(
                  _imageUrlController,
                  'Image URL (Optional)',
                  TextInputType.url,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA16C22),
                      ),
                    )
                    : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: Text(
                        'Save Product',
                        style: GoogleFonts.crimsonPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA16C22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (label.contains('Optional'))
            return null; // Lewati validasi jika opsional
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Price' &&
              (double.tryParse(value) == null || double.parse(value) < 0)) {
            return 'Please enter a valid price';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
