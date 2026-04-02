import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import 'components/menu/product_dialog.dart';
import 'components/menu/category_dialog.dart';
import 'components/menu/subcategory_dialog.dart';
import 'components/menu/menu_widgets.dart';

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> products = [];
  List<Category> categories = [];
  List<Subcategory> subcategories = [];
  Set<int> selectedProductIds = {};
  bool isLoading = true;
  String searchQuery = '';
  String? selectedType = 'All Types';
  String? selectedStation = 'All Stations';
  int? selectedCategoryId; // Added for sidebar selection
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          selectedProductIds.clear();
        });
      }
    });
    _loadData();
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _eventSubscription = client.events.subscribe().listen((event) {
      if (event.eventType == 'product_updated') {
        _loadDataQuietly();
      }
    });
  }

  Future<void> _loadDataQuietly() async {
    try {
      final loadedProducts = await client.products.getAll();
      final loadedCategories = await client.categories.getAll();
      final loadedSubcategories = await client.subcategories.getAll();
      if (mounted) {
        setState(() {
          products = loadedProducts;
          categories = loadedCategories;
          subcategories = loadedSubcategories;
          // Maintain selected category if it still exists
          if (categories.isNotEmpty) {
            if (selectedCategoryId == null ||
                !categories.any((c) => c.id == selectedCategoryId)) {
              selectedCategoryId = categories.first.id;
            }
          } else {
            selectedCategoryId = null;
          }
        });
      }
    } catch (e) {
      // Silently fail for background updates
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      selectedProductIds.clear();
    });
    try {
      final loadedProducts = await client.products.getAll();
      final loadedCategories = await client.categories.getAll();
      final loadedSubcategories = await client.subcategories.getAll();
      if (mounted) {
        setState(() {
          products = loadedProducts;
          categories = loadedCategories;
          subcategories = loadedSubcategories;
          isLoading = false;
          // Select first category by default if none selected
          if (categories.isNotEmpty) {
            if (selectedCategoryId == null ||
                !categories.any((c) => c.id == selectedCategoryId)) {
              selectedCategoryId = categories.first.id;
            }
          } else {
            selectedCategoryId = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load menu data: $e')));
      }
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onSelectionChanged(int productId, bool selected) {
    setState(() {
      if (selected) {
        selectedProductIds.add(productId);
      } else {
        selectedProductIds.remove(productId);
      }
    });
  }

  Future<void> _onToggleAvailability(Product product, bool isAvailable) async {
    try {
      final updatedProduct = product.copyWith(isAvailable: isAvailable);
      await client.products.update(product.id!, updatedProduct);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _onDuplicateProduct(Product product) async {
    try {
      final newProduct = product.copyWith(
        id: null,
        name: '${product.name} (Copy)',
        itemCode: product.itemCode != null ? '${product.itemCode}_copy' : null,
      );
      await client.products.create(newProduct);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Row(
          children: [
            if (!isMobile) _buildSidebar(),
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Column(
                  children: [
                    _buildHeader(isMobile),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildMainContent(isMobile),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddDialog(isCategory: true),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  tooltip: 'Add Category',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSidebarItem(
                    title: 'All Items',
                    icon: Icons.grid_view_rounded,
                    isSelected: selectedCategoryId == null,
                    onTap: () => setState(() => selectedCategoryId = null),
                  );
                }
                final cat = categories[index - 1];
                return _buildSidebarItem(
                  title: cat.name,
                  icon: Icons.folder_open_rounded,
                  isSelected: selectedCategoryId == cat.id,
                  onTap: () => setState(() => selectedCategoryId = cat.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () => _showAddDialog(category: cat),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF0F172A) : Colors.grey[500],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF0F172A) : Colors.grey[700],
          ),
        ),
        trailing: isSelected ? trailing : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategoryId == null
                        ? 'All Menu Items'
                        : categories
                              .firstWhere((c) => c.id == selectedCategoryId)
                              .name,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (!isMobile)
                    Text(
                      'Manage your menu availability and pricing',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                ],
              ),
              Row(
                children: [
                  if (selectedProductIds.isNotEmpty) ...[
                    Text(
                      '${selectedProductIds.length} selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmBulkDelete(),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Selected',
                    ),
                    const VerticalDivider(width: 24, indent: 8, endIndent: 8),
                  ],
                  if (selectedCategoryId != null) ...[
                    OutlinedButton.icon(
                      onPressed: () => _showSubcategoryDialog(),
                      icon: const Icon(Icons.playlist_add_rounded, size: 20),
                      label: const Text('Add Section'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (isMobile)
                    IconButton(
                      onPressed: () => _showMobileCategoryPicker(),
                      icon: const Icon(Icons.menu_open_rounded),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                    label: const Text(
                      'Add Item',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFiltersBar(isMobile),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    final filteredProducts = products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (p.itemCode?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
      final matchesType = selectedType == 'All Types' || p.type == selectedType;
      final matchesStation =
          selectedStation == 'All Stations' || p.station == selectedStation;
      final matchesCategory =
          selectedCategoryId == null || p.categoryId == selectedCategoryId;
      return matchesSearch && matchesType && matchesStation && matchesCategory;
    }).toList();

    if (filteredProducts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No items found',
        message:
            'Try adjusting your filters or add a new item to this category.',
        buttonText: 'Add New Item',
        onAction: () => _showAddDialog(),
      );
    }

    // Group items by subcategory if a category is selected
    if (selectedCategoryId != null) {
      final categorySubcategories =
          subcategories
              .where((s) => s.categoryId == selectedCategoryId)
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (categorySubcategories.isEmpty)
            _buildProductGrid(filteredProducts, isMobile)
          else ...[
            // Items with no subcategory
            _buildSubcategorySection(
              'Other Items',
              filteredProducts.where((p) => p.subcategoryId == null).toList(),
              isMobile,
            ),
            // Items grouped by subcategory
            ...categorySubcategories.map((sub) {
              final subProducts = filteredProducts
                  .where((p) => p.subcategoryId == sub.id)
                  .toList();
              return _buildSubcategorySection(
                sub.name,
                subProducts,
                isMobile,
                subcategory: sub,
              );
            }),
          ],
        ],
      );
    }

    return _buildProductGrid(filteredProducts, isMobile);
  }

  Widget _buildSubcategorySection(
    String title,
    List<Product> subProducts,
    bool isMobile, {
    Subcategory? subcategory,
  }) {
    if (subProducts.isEmpty && subcategory == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (subcategory != null)
                IconButton(
                  onPressed: () =>
                      _showSubcategoryDialog(subcategory: subcategory),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit Subcategory',
                ),
            ],
          ),
        ),
        if (subProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'No items in this section',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          _buildProductGrid(subProducts, isMobile),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductGrid(List<Product> gridProducts, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: gridProducts.length,
      itemBuilder: (context, index) => _buildProductCard(gridProducts[index]),
    );
  }

  void _showSubcategoryDialog({Subcategory? subcategory}) {
    showDialog(
      context: context,
      builder: (context) => SubcategoryDialog(
        client: client,
        subcategory: subcategory,
        categories: categories,
        onSuccess: _loadData,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isSelected = selectedProductIds.contains(product.id);

    return InkWell(
      onLongPress: () => _onSelectionChanged(product.id!, !isSelected),
      onTap: () {
        if (selectedProductIds.isNotEmpty) {
          _onSelectionChanged(product.id!, !isSelected);
        } else {
          _showAddDialog(product: product);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : Colors.grey[100]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0F172A).withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Placeholder
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    image: product.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl == null
                      ? Center(
                          child: Icon(
                            Icons.fastfood_rounded,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: product.isAvailable,
                            onChanged: (v) => _onToggleAvailability(product, v),
                            activeThumbColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (product.type != null)
                            _buildPill(product.type!, Colors.blue),
                          const SizedBox(width: 4),
                          if (product.station != null)
                            _buildPill(product.station!, Colors.orange),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            onPressed: () => _onDuplicateProduct(product),
                            tooltip: 'Duplicate',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showAddDialog(product: product),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _confirmDeleteProduct(product),
                            tooltip: 'Delete',
                            color: Colors.red[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toLowerCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showMobileCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('All Items'),
                      selected: selectedCategoryId == null,
                      onTap: () {
                        setState(() => selectedCategoryId = null);
                        Navigator.pop(context);
                      },
                    );
                  }
                  final cat = categories[index - 1];
                  return ListTile(
                    title: Text(cat.name),
                    selected: selectedCategoryId == cat.id,
                    onTap: () {
                      setState(() => selectedCategoryId = cat.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey, size: 20),
                hintText: 'Search items...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  label: 'Type',
                  value: selectedType!,
                  items: ['All Types', 'Dine-In', 'Takeaway', 'Both'],
                  onChanged: (v) => setState(() => selectedType = v),
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  label: 'Station',
                  value: selectedStation!,
                  items: ['All Stations', 'Kitchen', 'Bar', 'Counter'],
                  onChanged: (v) => setState(() => selectedStation = v),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      selectedType = 'All Types';
                      selectedStation = 'All Stations';
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Search items...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(
            label: 'Type',
            value: selectedType!,
            items: ['All Types', 'Dine-In', 'Takeaway', 'Both'],
            onChanged: (v) => setState(() => selectedType = v),
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            label: 'Station',
            value: selectedStation!,
            items: ['All Stations', 'Kitchen', 'Bar', 'Counter'],
            onChanged: (v) => setState(() => selectedStation = v),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                searchQuery = '';
                selectedType = 'All Types';
                selectedStation = 'All Stations';
              });
            },
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Reset Filters',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog({
    Product? product,
    Category? category,
    bool isCategory = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        if (isCategory || category != null) {
          return CategoryDialog(
            client: client,
            category: category,
            onSuccess: _loadData,
          );
        } else {
          return ProductDialog(
            client: client,
            product: product,
            categories: categories,
            subcategories: subcategories,
            defaultCategoryId: selectedCategoryId,
            onSuccess: _loadData,
          );
        }
      },
    );
  }

  void _confirmDeleteProduct(Product p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${p.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await client.products.delete(p.id!);
                if (mounted) {
                  navigator.pop();
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete ${selectedProductIds.length} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                for (final id in selectedProductIds) {
                  await client.products.delete(id);
                }
                if (mounted) {
                  navigator.pop();
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
