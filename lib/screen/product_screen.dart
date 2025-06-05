// lib/screen/product_screen.dart
import 'package:admin_batik/models/product_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/screen/add_product_screen.dart';
import 'package:admin_batik/screen/edit_product_screen.dart'; // Impor EditProductScreen
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Future.microtask(
    //   () => Provider.of<ProductProvider>(
    //     context,
    //     listen: false,
    //   ).fetchProducts(refresh: true),
    // );

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
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    print("productProvider.isLoading: ${productProvider.isLoading}");
    print(
      "productProvider.products.isEmpty: ${productProvider.products.isEmpty}",
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add',
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
                      child: CircularProgressIndicator(
                        color: Color(0xFFA16C22),
                      ),
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
                          print("index: ${index}");
                          print(
                            "productProvider.products.length: ${productProvider.products.length}",
                          );
                          print(
                            "productProvider.hasMoreProducts: ${productProvider.hasMoreProducts}",
                          );
                          if (index == productProvider.products.length &&
                              productProvider.hasMoreProducts) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFA16C22),
                                ),
                              ),
                            );
                          }
                          if (index >= productProvider.products.length) {
                            return const SizedBox.shrink();
                          }
                          final product = productProvider.products[index];
                          return GestureDetector(
                            // Tambahkan GestureDetector di sini
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditProductScreen(product: product),
                                ),
                              );
                            },
                            child: _buildProductItem(product),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    ProductImageModel? firstImage =
        product.images.isNotEmpty ? product.images.first : null;

    // print("product.images.first${product.images.first.fullImageUrl}");
    // print(firstImage?.fullImageUrl);
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (firstImage != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  // GANTI Image.network DENGAN INI
                  child: CachedNetworkImage(
                    imageUrl: firstImage.fullImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Color(0xFFA16C22),
                              ),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 24,
                          ),
                        ),
                  ),
                ),
              ),
            if (firstImage == null)
              SizedBox(
                width: 70,
                child: Text(
                  product.code,
                  style: GoogleFonts.crimsonPro(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (firstImage == null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                  if (product.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                      child: Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        product.category,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (product.batikType.isNotEmpty)
                        Text(
                          ' - ${product.batikType}',
                          style: GoogleFonts.crimsonPro(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPrice(product.priceAsDouble),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.crimsonPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        product.status.toLowerCase() == 'tersedia'
                            ? Colors.amber.shade100
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.status,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          product.status.toLowerCase() == 'tersedia'
                              ? Colors.amber.shade800
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
