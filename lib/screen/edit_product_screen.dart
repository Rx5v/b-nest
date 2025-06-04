// lib/screen/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  final ProductModel product; // Produk yang akan diedit

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk setiap field
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _batikTypeController; // subCategory
  late TextEditingController _imageUrlController;
  late TextEditingController _codeController;
  late TextEditingController _stockController;

  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _categories = ['Kain', 'Kaos', 'Kemeja'];
  // Sesuaikan nilai status ini dengan yang ada di API atau yang valid
  final List<String> _statuses = ['Tersedia', 'Tidak Tersedia'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk yang ada
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.priceAsDouble.toStringAsFixed(0),
    ); // Harga tanpa desimal
    _batikTypeController = TextEditingController(
      text: widget.product.batikType,
    );
    // Menggabungkan list URL gambar menjadi satu string dipisahkan koma untuk diedit di TextField
    _imageUrlController = TextEditingController(
      text: widget.product.images.join(', '),
    );
    _codeController = TextEditingController(text: widget.product.code);
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );

    _selectedCategory = widget.product.category;
    // Pastikan nilai status dari produk ada dalam list _statuses
    if (_statuses.contains(widget.product.status)) {
      _selectedStatus = widget.product.status;
    } else if (widget.product.status.toLowerCase() == "available" &&
        _statuses.contains("Tersedia")) {
      _selectedStatus = "Tersedia"; // Fallback jika case berbeda
    } else if (widget.product.status.toLowerCase() == "not available" &&
        _statuses.contains("Tidak Tersedia")) {
      _selectedStatus = "Tidak Tersedia"; // Fallback
    }
    // Jika kategori produk tidak ada di list, bisa set default atau biarkan null (akan tampilkan hint)
    if (!_categories.contains(widget.product.category)) {
      _selectedCategory = null; // Atau _categories.first jika ingin ada default
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _batikTypeController.dispose();
    _imageUrlController.dispose();
    _codeController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final updatedProductData = {
      'id': widget.product.id,
      'name': _nameController.text,
      'code':
          _codeController.text, // Kode biasanya tidak diubah, tapi bisa jadi
      'description': _descriptionController.text,
      'price': num.tryParse(_priceController.text) ?? widget.product.price,
      'category': _selectedCategory ?? widget.product.category,
      'batik_type': _batikTypeController.text,
      'status': _selectedStatus ?? widget.product.status,
      'stock': int.tryParse(_stockController.text) ?? widget.product.stock,
      'images':
          _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : [], // Atau kirim list gambar lama jika tidak diubah dan API tidak menganggap list kosong sebagai penghapusan
      // Tambahkan field lain yang bisa diupdate jika ada
    };

    try {
      final success = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).updateProduct(widget.product.id, updatedProductData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Kembali ke ProductScreen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).errorMessage ??
                    'Failed to update product.',
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
          'Edit Product',
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
                  _codeController,
                  'Product Code',
                  TextInputType.text,
                  readOnly: true,
                ), // Kode produk biasanya tidak bisa diedit
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
                _buildTextFormField(
                  _stockController,
                  'Stock',
                  TextInputType.number,
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
                  'Image URLs (comma-separated)',
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
                      icon: const Icon(Icons.save_as),
                      label: Text(
                        'Update Product',
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
    bool readOnly = false,
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
        readOnly: readOnly,
        validator: (value) {
          if (label.contains('(Optional')) return null;
          if (readOnly) return null; // Tidak perlu validasi jika read-only
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if ((label == 'Price' || label == 'Stock') &&
              (num.tryParse(value) == null || num.parse(value) < 0)) {
            return 'Please enter a valid non-negative number for $label';
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
