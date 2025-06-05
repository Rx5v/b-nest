// lib/screen/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart'; // Meskipun tidak membuat instance langsung, berguna untuk referensi field
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

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

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Tambahkan gambar baru ke list yang sudah ada
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
    final productFields = {
      'name': _nameController.text,
      'code': _codeController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'category':
          _selectedCategory!, // Pastikan tidak null karena ada validator
      'batik_type': _batikTypeController.text,
      'status': _selectedStatus!, // Pastikan tidak null karena ada validator
      'stock': _stockController.text,
    };
    productFields.removeWhere((key, value) => value.isEmpty && key == 'code');

    // Dapatkan list path dari XFile
    final imagePaths = _selectedImages.map((file) => file.path).toList();

    try {
      final success = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).addProduct(productFields, imagePaths);
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
                const SizedBox(height: 16),
                // UI untuk memilih dan menampilkan gambar
                Text('Images', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildImagePicker(),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child:
              _selectedImages.isEmpty
                  ? Center(
                    child: Text(
                      'No images selected.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Select Images'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFA16C22)),
        ),
      ],
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
