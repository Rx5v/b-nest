// lib/screen/product_variant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/providers/variant_provider.dart';
import 'package:admin_batik/screen/add_variant_screen.dart';

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
    print(widget.product.id);
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
              : variantProvider.errorMessage != null
              ? Center(child: Text('Error: ${variantProvider.errorMessage}'))
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
                        title: Text('Size: ${variant.size}'),
                        subtitle: Text(
                          'Stock: ${variant.stock} | Material: ${variant.material ?? 'N/A'}',
                        ),
                        trailing: const Icon(Icons.edit_note),
                        onTap: () {
                          // TODO: Navigasi ke halaman edit varian
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                // Blok .then() ini akan dieksekusi setelah halaman AddVariantScreen ditutup
                if (isSuccess == true) {
                  // Jika AddVariantScreen mengirim 'true', berarti sukses, maka refresh data
                  Provider.of<VariantProvider>(
                    context,
                    listen: false,
                  ).fetchVariantsForProduct(widget.product.id);

                  // Tampilkan SnackBar di sini
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Variant added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
