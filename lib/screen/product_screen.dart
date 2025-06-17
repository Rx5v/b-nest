// lib/screen/product_screen.dart
import 'package:admin_batik/models/product_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/screen/add_product_screen.dart';
import 'package:admin_batik/screen/edit_product_screen.dart';
import 'package:admin_batik/screen/product_variant_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ProductScreen({super.key, required this.onBack});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts(refresh: true),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<ProductProvider>(context, listen: false).loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  Future<void> _showDeleteConfirmationDialog(
    int productId,
    String productName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah Anda yakin ingin menghapus produk "$productName"?',
                ),
                const Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(productId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(int productId) async {
    final success = await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).deleteProduct(productId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).errorMessage ??
                  'Gagal menghapus produk.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF3A3A3A),
                ),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  'Daftar Produk',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Tambah',
                  style: GoogleFonts.crimsonPro(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA16C22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              productProvider.isLoading && productProvider.products.isEmpty
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFA16C22)),
                  )
                  : productProvider.errorMessage != null &&
                      productProvider.products.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${productProvider.errorMessage}\nPull to refresh.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.crimsonPro(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  )
                  : productProvider.products.isEmpty
                  ? Center(
                    child: Text(
                      'No products found.\nPull to refresh.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh:
                        () => productProvider.fetchProducts(refresh: true),
                    color: const Color(0xFFA16C22),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount:
                          productProvider.products.length +
                          (productProvider.hasMoreProducts ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= productProvider.products.length) {
                          return productProvider.hasMoreProducts
                              ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFA16C22),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final product = productProvider.products[index];
                        return _buildProductItem(product);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildProductItem(ProductModel product) {
    ProductImageModel? firstImage =
        product.images.isNotEmpty ? product.images.first : null;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shadowColor: Colors.grey.withOpacity(0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: firstImage?.fullImageUrl ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.code,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.category} - ${product.batikType}',
                        style: GoogleFonts.crimsonPro(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bagian Tengah: Harga dan Stok
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                _buildInfoChip(
                  Icons.sell_outlined,
                  _formatPrice(product.priceAsDouble),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.inventory_2_outlined,
                  'Stok: ${product.stock}',
                  Colors.blueGrey,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        product.status.toLowerCase() == 'tersedia'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.status,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          product.status.toLowerCase() == 'tersedia'
                              ? Colors.green.shade800
                              : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),

          // Bagian Bawah: Tombol Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.edit_note,
                label: 'Edit',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProductScreen(product: product),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.style,
                label: 'Varian',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductVariantDetailScreen(product: product),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.delete_forever,
                label: 'Hapus',
                color: Colors.red.shade700,
                onTap: () {
                  _showDeleteConfirmationDialog(product.id, product.name);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat chip info (Harga, Stok)
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.crimsonPro(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat tombol aksi
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.crimsonPro(
                  color: color ?? Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
