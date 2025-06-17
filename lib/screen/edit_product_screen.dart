// lib/screen/edit_product_screen.dart
import 'dart:io';
import 'package:admin_batik/models/product_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _batikTypeController;
  late TextEditingController _codeController;
  late TextEditingController _stockController;

  // State untuk dropdowns
  String? _selectedCategory;
  String? _selectedStatus;

  // State untuk gambar
  final ImagePicker _picker = ImagePicker();
  List<XFile> _newSelectedImages = [];
  List<ProductImageModel> _existingImages = [];
  final List<String> _categories = ['Kain', 'Kaos', 'Kemeja'];
  final List<String> _statuses = ['Tersedia', 'Tidak Tersedia'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi form dengan data produk yang ada
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.priceAsDouble.toStringAsFixed(0),
    );
    _batikTypeController = TextEditingController(
      text: widget.product.batikType,
    );
    _codeController = TextEditingController(text: widget.product.code);
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _selectedCategory = widget.product.category;
    _selectedStatus = widget.product.status;
    _existingImages = List<ProductImageModel>.from(widget.product.images);
  }

  @override
  void dispose() {
    // ... dispose semua controller
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newSelectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newSelectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final updatedFields = {
      'name': _nameController.text,
      'code': _codeController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'category': _selectedCategory!,
      'batik_type': _batikTypeController.text,
      'status': _selectedStatus!,
      'stock': _stockController.text,
    };

    final newImagePaths = _newSelectedImages.map((file) => file.path).toList();

    try {
      final success = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).updateProduct(widget.product.id, updatedFields, newImagePaths);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
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
                ),
                _buildTextFormField(
                  _nameController,
                  'Name',
                  TextInputType.text,
                ),
                // ... (lainnya) ...
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
                const SizedBox(height: 16),
                Text('Images', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildImagePicker(),

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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child:
              (_existingImages.isEmpty && _newSelectedImages.isEmpty)
                  ? Center(
                    child: Text(
                      'No images.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        _existingImages.length + _newSelectedImages.length,
                    itemBuilder: (context, index) {
                      Widget imageWidget;
                      VoidCallback onRemove;

                      if (index < _existingImages.length) {
                        // Tampilkan gambar dari URL (yang sudah ada)
                        final imageModel = _existingImages[index];
                        imageWidget = Image.network(
                          imageModel.fullImageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Icon(Icons.error),
                        );
                        onRemove = () => _removeExistingImage(index);
                      } else {
                        // Tampilkan gambar dari file (yang baru dipilih)
                        final imageIndex = index - _existingImages.length;
                        final imageFile = _newSelectedImages[imageIndex];
                        imageWidget = Image.file(
                          File(imageFile.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                        onRemove = () => _removeNewImage(imageIndex);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageWidget,
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
                                onPressed: onRemove,
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
          label: const Text('Add New Images'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFA16C22)),
        ),
      ],
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
          if (readOnly) return null;
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
