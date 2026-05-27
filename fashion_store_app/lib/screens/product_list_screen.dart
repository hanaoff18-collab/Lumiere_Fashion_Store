import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../services/catalog_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final CatalogRepository _catalog = CatalogRepository();
  String _selectedSort = 'Latest';
  bool _isGridView = true;
  String _query = '';
  bool _featuredOnly = false;
  double _maxPrice = 1000;

  List<Product> _applySortAndFilter(List<Product> source) {
    final filteredCategory = widget.category == null
        ? source
        : source.where((p) => p.category == widget.category).toList();
    final filtered = filteredCategory.where((p) {
      final queryMatch = _query.trim().isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.description.toLowerCase().contains(_query.toLowerCase());
      final featuredMatch = !_featuredOnly || p.isFeatured;
      final priceMatch = p.price <= _maxPrice;
      return queryMatch && featuredMatch && priceMatch;
    }).toList();
    final products = List<Product>.from(filtered);
    switch (_selectedSort) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(
        context,
        widget.category ?? 'All products',
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _catalog.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load products.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }
          final base = snapshot.data ?? [];
          final sortedProducts = _applySortAndFilter(base);
          return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _chip(
                  icon: Icons.filter_list_rounded,
                  label: 'Filters',
                  onTap: _openFilterSheet,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                        items: ['Latest', 'Price: Low to High', 'Price: High to Low']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSort = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${sortedProducts.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedProducts.isEmpty
                ? Center(
                    child: Text(
                      'No products match your filters.',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: sortedProducts.length,
                        itemBuilder: (ctx, index) {
                          return ProductCard(
                            product: sortedProducts[index],
                            layout: ProductCardLayout.grid,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: sortedProducts.length,
                        itemBuilder: (ctx, index) {
                          return ProductCard(
                            product: sortedProducts[index],
                            layout: ProductCardLayout.list,
                          );
                        },
                      ),
          ),
        ],
      );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    double tempMax = _maxPrice;
    bool tempFeatured = _featuredOnly;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: tempFeatured,
                    onChanged: (v) => setModal(() => tempFeatured = v),
                    title: const Text('Featured deals only'),
                  ),
                  const SizedBox(height: 6),
                  Text('Max price: \$${tempMax.toStringAsFixed(0)}'),
                  Slider(
                    min: 20,
                    max: 1000,
                    value: tempMax.clamp(20, 1000),
                    onChanged: (v) => setModal(() => tempMax = v),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _featuredOnly = false;
                            _maxPrice = 1000;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _featuredOnly = tempFeatured;
                            _maxPrice = tempMax;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
