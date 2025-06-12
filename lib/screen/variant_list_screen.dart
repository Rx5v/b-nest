// lib/screen/variant_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/variant_provider.dart';
import 'package:admin_batik/screen/add_variant_screen.dart';

class VariantListScreen extends StatefulWidget {
  const VariantListScreen({super.key});

  @override
  State<VariantListScreen> createState() => _VariantListScreenState();
}

class _VariantListScreenState extends State<VariantListScreen> {
  @override
  void initState() {
    super.initState();
    // Gunakan Future.microtask untuk memanggil fetch saat build selesai
    Future.microtask(
      () =>
          Provider.of<VariantProvider>(context, listen: false).fetchVariants(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variantProvider = Provider.of<VariantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Variants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddVariantScreen()),
                ),
          ),
        ],
      ),
      body:
          variantProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : variantProvider.errorMessage != null
              ? Center(child: Text('Error: ${variantProvider.errorMessage}'))
              : RefreshIndicator(
                onRefresh: () => variantProvider.fetchVariants(),
                child: ListView.builder(
                  itemCount: variantProvider.variants.length,
                  itemBuilder: (context, index) {
                    final variant = variantProvider.variants[index];
                    return ListTile(
                      title: Text(
                        '${variant.product?.name ?? 'Unknown Product'} - Size: ${variant.size}',
                      ),
                      subtitle: Text(
                        'Stock: ${variant.stock}, Material: ${variant.material ?? 'N/A'}',
                      ),
                      // Tambahkan tombol edit/delete di sini jika perlu
                    );
                  },
                ),
              ),
    );
  }
}
