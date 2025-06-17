// lib/screen/product_variant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/providers/variant_provider.dart';
import 'package:admin_batik/screen/add_variant_screen.dart';
import 'package:admin_batik/screen/edit_variant_screen.dart'; // Impor halaman edit

class ProductVariantDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductVariantDetailScreen({super.key, required this.product});

  @override
  State<ProductVariantDetailScreen> createState() =>
      _ProductVariantDetailScreenState();
}

class _ProductVariantDetailScreenState
    extends State<ProductVariantDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<VariantProvider>(
        context,
        listen: false,
      ).fetchVariantsForProduct(widget.product.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variantProvider = Provider.of<VariantProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Variants for ${widget.product.name}')),
      body:
          variantProvider.isLoadingProductVariants
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh:
                    () => variantProvider.fetchVariantsForProduct(
                      widget.product.id,
                    ),
                child: ListView.builder(
                  itemCount: variantProvider.variantsForProduct.length,
                  itemBuilder: (context, index) {
                    final variant = variantProvider.variantsForProduct[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          'Size: ${variant.size}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Stock: ${variant.stock} | Material: ${variant.material ?? 'N/A'}',
                        ),
                        trailing: const Icon(
                          Icons.edit_note,
                          color: Colors.blue,
                        ),
                        onTap: () {
                          // NAVIGASI KE HALAMAN EDIT
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditVariantScreen(
                                        variant: variant,
                                        productName: widget.product.name,
                                      ),
                                ),
                              )
                              .then((isSuccess) {
                                // Setelah halaman edit ditutup, refresh data jika ada perubahan
                                if (isSuccess == true) {
                                  variantProvider.fetchVariantsForProduct(
                                    widget.product.id,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Variant updated successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              });
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder:
                      (_) => AddVariantScreen(
                        productId: widget.product.id,
                        productName: widget.product.name,
                      ),
                ),
              )
              .then((isSuccess) {
                if (isSuccess == true) {
                  // Refresh juga setelah menambah varian baru
                  variantProvider.fetchVariantsForProduct(widget.product.id);
                }
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
