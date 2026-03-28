import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';
import 'dart:async';

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  final ApiService apiService = ApiService();
  int _tabIndex = 0; // 0 for Menu Items, 1 for Categories
  
  List<Product> products = [];
  List<Category> categories = [];
  List<Subcategory> subcategories = [];
  bool isLoading = true;
  StreamSubscription? _productSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _productSub = SocketService().onProductUpdated.listen((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _productSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final cats = await apiService.fetchCategories();
      final prods = await apiService.fetchProducts();
      final subcats = await apiService.fetchSubcategories();
      if (mounted) {
        setState(() {
          categories = cats;
          products = prods;
          subcategories = subcats;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menu data: $e')),
        );
      }
    }
  }

  void _showManageExtrasDialog(Product p) {
    showDialog(
      context: context,
      builder: (ctx) => _ManageExtrasDialog(product: p, apiService: apiService, onSaved: _loadData),
    );
  }

  void _showManageSubcategoriesDialog(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => _ManageSubcategoriesDialog(
        category: cat,
        apiService: apiService,
        allSubcategories: subcategories,
        onSaved: _loadData,
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final sortOrderController = TextEditingController(text: '0');
    String selectedStation = 'None';
    final stationOptions = ['Kitchen', 'Bar', 'None'];
    String selectedOrderType = 'Both';
    final orderTypeOptions = ['Both', 'Dine-In', 'Takeaway'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sort Order',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStation,
                        isExpanded: true,
                        items: stationOptions.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStation = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Order Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedOrderType,
                        isExpanded: true,
                        items: orderTypeOptions.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedOrderType = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final orderStr = sortOrderController.text.trim();
                    final nav = Navigator.of(context);
                    if (name.isNotEmpty) {
                      final newCat = await apiService.createCategory(
                        name, 
                        int.tryParse(orderStr) ?? 0,
                        selectedStation == 'None' ? null : selectedStation,
                        selectedOrderType,
                      );
                      if (newCat != null) {
                        _loadData(); // refresh list
                      }
                    }
                    nav.pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final sortOrderController = TextEditingController(text: category.sortOrder.toString());
    
    final stationOptions = ['Kitchen', 'Bar', 'None'];
    String selectedStation = 'None';
    if (category.station != null && stationOptions.contains(category.station)) {
      selectedStation = category.station!;
    }

    final orderTypeOptions = ['Both', 'Dine-In', 'Takeaway'];
    String selectedOrderType = category.orderType ?? 'Both';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sort Order',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStation,
                        isExpanded: true,
                        items: stationOptions.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStation = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Order Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedOrderType,
                        isExpanded: true,
                        items: orderTypeOptions.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedOrderType = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final orderStr = sortOrderController.text.trim();
                    final nav = Navigator.of(context);
                    if (name.isNotEmpty) {
                      final updatedCat = await apiService.updateCategory(
                        category.id,
                        name, 
                        int.tryParse(orderStr) ?? 0,
                        selectedStation == 'None' ? null : selectedStation,
                        selectedOrderType,
                      );
                      if (updatedCat != null) {
                        _loadData();
                      }
                    }
                    nav.pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDeleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await apiService.deleteCategory(category.id);
                if (success) {
                  _loadData();
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete category. It may contain menu items.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                nav.pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMenuItemDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '0.00');
    
    Category? selectedCategory = categories.isNotEmpty ? categories.first : null;
    Subcategory? selectedSubcategory;
    
    final stationOptions = ['Kitchen', 'Bar', 'None'];
    String selectedStation = 'Kitchen';
    
    final typeOptions = ['dine-in', 'takeaway', 'Both'];
    String selectedType = 'Both';
    
    if (selectedCategory != null) {
      _generateItemCode(selectedCategory, selectedSubcategory, codeController);
      if (selectedCategory.station != null && selectedCategory.station!.isNotEmpty) {
        final st = selectedCategory.station!;
        if (!stationOptions.contains(st)) stationOptions.add(st);
        selectedStation = st;
      }
      if (selectedCategory.orderType != null && typeOptions.contains(selectedCategory.orderType)) {
        selectedType = selectedCategory.orderType!;
      }
    }

    bool isAvailable = true;
    bool allowPriceEdit = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create a new menu item', style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogField('Item Code', codeController),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDialogField('Price', priceController, isNumber: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDialogField('Name', nameController),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Category>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      items: categories.map((c) {
                                        return DropdownMenuItem<Category>(
                                          value: c,
                                          child: Text(c.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setDialogState(() {
                                          selectedCategory = val;
                                          selectedSubcategory = null;
                                          if (selectedCategory?.station != null && selectedCategory!.station!.isNotEmpty) {
                                            final st = selectedCategory!.station!;
                                            if (!stationOptions.contains(st)) stationOptions.add(st);
                                            selectedStation = st;
                                          }
                                          if (selectedCategory?.orderType != null && typeOptions.contains(selectedCategory!.orderType)) {
                                            selectedType = selectedCategory!.orderType!;
                                          }
                                          _generateItemCode(selectedCategory, selectedSubcategory, codeController);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Subcategory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Subcategory?>(
                                      value: selectedSubcategory,
                                      hint: const Text('None'),
                                      isExpanded: true,
                                      items: subcategories
                                          .where((s) => s.categoryId == selectedCategory?.id)
                                          .map((s) {
                                        return DropdownMenuItem<Subcategory>(
                                          value: s,
                                          child: Text(s.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setDialogState(() {
                                          selectedSubcategory = val;
                                          _generateItemCode(selectedCategory, selectedSubcategory, codeController);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStation,
                                      isExpanded: true,
                                      items: stationOptions.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(s),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() => selectedStation = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Order Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedType,
                                      isExpanded: true,
                                      items: typeOptions.map((t) {
                                        return DropdownMenuItem<String>(
                                          value: t,
                                          child: Text(t),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() => selectedType = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: isAvailable,
                            onChanged: (val) => setDialogState(() => isAvailable = val),
                            activeThumbColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Allow Price Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: allowPriceEdit,
                            onChanged: (val) => setDialogState(() => allowPriceEdit = val),
                            activeThumbColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || selectedCategory == null) return;
                    
                    final nav = Navigator.of(context);
                    final newProduct = await apiService.createProduct({
                      'item_code': codeController.text.trim(),
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text.trim()) ?? 0,
                      'category_id': selectedCategory?.id,
                      'subcategory_id': selectedSubcategory?.id,
                      'station': selectedStation == 'None' ? '' : selectedStation,
                      'type': selectedType,
                      'is_available': isAvailable,
                      'allow_price_edit': allowPriceEdit,
                    });
                    
                    if (newProduct != null) {
                      _loadData();
                    }
                    nav.pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditMenuItemDialog(Product product) {
    final codeController = TextEditingController(text: product.itemCode ?? '');
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(2));
    
    final stationOptions = ['Kitchen', 'Bar', 'None'];
    String selectedStation = 'Kitchen';
    if (product.station != null && stationOptions.contains(product.station)) {
      selectedStation = product.station!;
    } else if (product.station == '' || product.station == null) {
      selectedStation = 'None';
    } else if (product.station != null) {
      if (!stationOptions.contains(product.station!)) {
         stationOptions.add(product.station!);
      }
      selectedStation = product.station!;
    }
    
    final typeOptions = ['dine-in', 'takeaway', 'Both'];
    String selectedType = 'Both';
    if (product.type != null && typeOptions.contains(product.type)) {
      selectedType = product.type!;
    }
    
    Category? selectedCategory;
    try {
      selectedCategory = categories.firstWhere((c) => c.id == product.categoryId);
    } catch (_) {}
    
    Subcategory? selectedSubcategory;
    if (product.subcategoryId != null) {
      try {
        selectedSubcategory = subcategories.firstWhere((s) => s.id == product.subcategoryId);
      } catch (_) {}
    }

    bool isAvailable = product.isAvailable;
    bool allowPriceEdit = product.allowPriceEdit;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Update menu item details', style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogField('Item Code', codeController),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDialogField('Price', priceController, isNumber: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDialogField('Name', nameController),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Category>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      items: categories.map((c) {
                                        return DropdownMenuItem<Category>(
                                          value: c,
                                          child: Text(c.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setDialogState(() {
                                          selectedCategory = val;
                                          selectedSubcategory = null;
                                          if (selectedCategory?.station != null && selectedCategory!.station!.isNotEmpty) {
                                            final st = selectedCategory!.station!;
                                            if (!stationOptions.contains(st)) stationOptions.add(st);
                                            selectedStation = st;
                                          }
                                          if (selectedCategory?.orderType != null && typeOptions.contains(selectedCategory!.orderType)) {
                                            selectedType = selectedCategory!.orderType!;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Subcategory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Subcategory?>(
                                      value: selectedSubcategory,
                                      hint: const Text('None'),
                                      isExpanded: true,
                                      items: subcategories
                                          .where((s) => s.categoryId == selectedCategory?.id)
                                          .map((s) {
                                        return DropdownMenuItem<Subcategory>(
                                          value: s,
                                          child: Text(s.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setDialogState(() {
                                          selectedSubcategory = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStation,
                                      isExpanded: true,
                                      items: stationOptions.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(s),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() => selectedStation = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Order Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedType,
                                      isExpanded: true,
                                      items: typeOptions.map((t) {
                                        return DropdownMenuItem<String>(
                                          value: t,
                                          child: Text(t),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() => selectedType = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: isAvailable,
                            onChanged: (val) => setDialogState(() => isAvailable = val),
                            activeThumbColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Allow Price Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: allowPriceEdit,
                            onChanged: (val) => setDialogState(() => allowPriceEdit = val),
                            activeThumbColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || selectedCategory == null) return;
                    
                    final nav = Navigator.of(context);
                    final updatedProduct = await apiService.updateProduct(product.id, {
                      'item_code': codeController.text.trim(),
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text.trim()) ?? 0,
                      'category_id': selectedCategory?.id,
                      'subcategory_id': selectedSubcategory?.id,
                      'station': selectedStation == 'None' ? '' : selectedStation,
                      'type': selectedType,
                      'is_available': isAvailable,
                      'allow_price_edit': allowPriceEdit,
                    });
                    
                    if (updatedProduct != null) {
                      _loadData();
                    }
                    nav.pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDeleteMenuItem(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Menu Item?'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await apiService.deleteProduct(product.id);
                if (success) {
                  _loadData();
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete item. It may have been ordered.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                nav.pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _generateItemCode(Category? cat, Subcategory? sub, TextEditingController codeCtrl) {
    if (cat == null) return;
    String catPart = cat.name.length >= 3 ? cat.name.substring(0, 3).toUpperCase() : cat.name.toUpperCase();
    String subPart = '';
    if (sub != null && sub.name.trim().isNotEmpty) {
      subPart = sub.name.length >= 3 ? sub.name.substring(0, 3).toUpperCase() : sub.name.toUpperCase();
    }
    
    int count = products.where((p) => p.categoryId == cat.id).length + 1;
    String numPart = count.toString().padLeft(3, '0');
    
    if (subPart.isNotEmpty && subPart.toUpperCase() != 'NONE') {
      codeCtrl.text = '$catPart-$subPart-$numPart';
    } else {
      codeCtrl.text = '$catPart-$numPart';
    }
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Menu Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Manage menu items and categories', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_outlined, size: 18),
                    label: const Text('Import CSV'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export CSV'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _tabIndex == 0 ? _showAddMenuItemDialog : _showAddCategoryDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(_tabIndex == 0 ? 'Add Item' : 'Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Tabs
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab(0, 'Menu Items'),
                _buildTab(1, 'Categories'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tab Content
          Expanded(
            child: _tabIndex == 0 ? _buildMenuItemsContent() : _buildCategoriesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemsContent() {
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: 'Search by name or item code...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter('All Types'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter('All Stations'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Table Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Menu Items (${products.length})', style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A))),
                ),
                
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24, child: Icon(Icons.check_box_outline_blank, color: Color(0xFFCBD5E1), size: 20)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _headerText('Code')),
                      Expanded(flex: 3, child: _headerText('Name')),
                      Expanded(flex: 2, child: _headerText('Price')),
                      Expanded(flex: 2, child: _headerText('Station')),
                      Expanded(flex: 2, child: _headerText('Type')),
                      Expanded(flex: 2, child: _headerText('Status')),
                      SizedBox(width: 120, child: _headerText('Actions', align: TextAlign.right)),
                    ],
                  ),
                ),
                
                // Table Body Empty State / List
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Text(
                            'No menu items found. Add one to get started.',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Row(
                                children: [
                                  const SizedBox(width: 24, child: Icon(Icons.check_box_outline_blank, color: Color(0xFFCBD5E1), size: 20)),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: Text(p.itemCode ?? '-', style: const TextStyle(fontSize: 14))),
                                  Expanded(flex: 3, child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                                  Expanded(flex: 2, child: Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14))),
                                  Expanded(flex: 2, child: _pillTag(p.station ?? 'kitchen', outline: true)),
                                  Expanded(flex: 2, child: _pillTag(p.type ?? 'dine-in', outline: false)),
                                  Expanded(flex: 2, child: _statusTag(p.isAvailable)),
                                  SizedBox(
                                    width: 120,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _showManageExtrasDialog(p),
                                          child: const Icon(Icons.list_alt, size: 18, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => _showEditMenuItemDialog(p),
                                          child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => _confirmDeleteMenuItem(p),
                                          child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _pillTag(String text, {required bool outline}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : const Color(0xFFF1F5F9),
        border: outline ? Border.all(color: const Color(0xFFE2E8F0)) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
    );
  }
  
  Widget _statusTag(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF0F172A) : Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(isAvailable ? 'Available' : 'Unavailable', style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  Widget _buildCategoriesContent() {
    return categories.isEmpty
        ? const Center(
            child: Text(
              'No categories found. Add one to get started.',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showManageSubcategoriesDialog(cat),
                              child: const Icon(Icons.layers_outlined, size: 20, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _showEditCategoryDialog(cat),
                              child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _confirmDeleteCategory(cat),
                              child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sort Order:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text('${cat.sortOrder}', style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text('${products.where((p) => p.categoryId == cat.id).length}', style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Station:', style: TextStyle(color: Color(0xFF94A3B8))),
                        _pillTag(cat.station ?? 'None', outline: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Type:', style: TextStyle(color: Color(0xFF94A3B8))),
                        _pillTag(cat.orderType ?? 'Both', outline: false),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
  }
}

class _ManageExtrasDialog extends StatefulWidget {
  final Product product;
  final ApiService apiService;
  final VoidCallback onSaved;

  const _ManageExtrasDialog({required this.product, required this.apiService, required this.onSaved});

  @override
  State<_ManageExtrasDialog> createState() => _ManageExtrasDialogState();
}

class _ManageExtrasDialogState extends State<_ManageExtrasDialog> {
  late List<ProductExtra> extras;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController(text: '0.00');
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    extras = List.from(widget.product.extras);
  }

  Future<void> _addExtra() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text) ?? 0;
    if (name.isEmpty) return;
    setState(() => isSaving = true);
    final ne = await widget.apiService.addProductExtra(widget.product.id, name, price);
    if (!mounted) return;
    setState(() {
      if (ne != null) extras.add(ne);
      isSaving = false;
      nameCtrl.clear();
      priceCtrl.text = '0.00';
    });
    widget.onSaved();
  }

  Future<void> _deleteExtra(ProductExtra e) async {
    if (e.id == null) return;
    setState(() => isSaving = true);
    final success = await widget.apiService.deleteProductExtra(e.id!);
    if (!mounted) return;
    setState(() {
      if (success) extras.removeWhere((ex) => ex.id == e.id);
      isSaving = false;
    });
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Sides/Extras', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adding sides to: ${widget.product.name}', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl, 
                    decoration: InputDecoration(
                      hintText: 'Extra Name (e.g. Bacon)',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    )
                  )
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80, 
                  child: TextField(
                    controller: priceCtrl, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Price',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    )
                  )
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSaving ? null : _addExtra,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (extras.isEmpty) 
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16), 
                child: Text("No sides added yet.", style: TextStyle(color: Color(0xFF94A3B8)))
              ),
            ...extras.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('+\$${e.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(width: 12),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: isSaving ? null : () => _deleteExtra(e)),
                ],
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done', style: TextStyle(color: Color(0xFF0F172A)))),
      ],
    );
  }
}

class _ManageSubcategoriesDialog extends StatefulWidget {
  final Category category;
  final ApiService apiService;
  final List<Subcategory> allSubcategories;
  final VoidCallback onSaved;

  const _ManageSubcategoriesDialog({required this.category, required this.apiService, required this.allSubcategories, required this.onSaved});

  @override
  State<_ManageSubcategoriesDialog> createState() => _ManageSubcategoriesDialogState();
}

class _ManageSubcategoriesDialogState extends State<_ManageSubcategoriesDialog> {
  late List<Subcategory> _subcats;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController sortCtrl = TextEditingController(text: '0');
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _subcats = widget.allSubcategories.where((s) => s.categoryId == widget.category.id).toList();
  }

  Future<void> _addSubcategory() async {
    final name = nameCtrl.text.trim();
    final sort = int.tryParse(sortCtrl.text.trim()) ?? 0;
    if (name.isEmpty) return;
    
    setState(() => isSaving = true);
    final ne = await widget.apiService.createSubcategory(widget.category.id, name, sort);
    if (!mounted) return;
    
    setState(() {
      if (ne != null) _subcats.add(ne);
      isSaving = false;
      nameCtrl.clear();
      sortCtrl.text = '0';
    });
    widget.onSaved();
  }

  Future<void> _deleteSubcategory(Subcategory s) async {
    setState(() => isSaving = true);
    final success = await widget.apiService.deleteSubcategory(s.id);
    if (!mounted) return;
    setState(() {
      if (success) _subcats.removeWhere((ex) => ex.id == s.id);
      isSaving = false;
    });
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Subcategories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Under Category: ${widget.category.name}', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: nameCtrl, 
                    decoration: InputDecoration(
                      hintText: 'Name (e.g. Burgers)',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: sortCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Sort',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  onPressed: isSaving ? null : _addSubcategory,
                  child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Current Subcategories', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _subcats.isEmpty
                ? const Text('No subcategories.', style: TextStyle(color: Color(0xFF94A3B8)))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subcats.length,
                    itemBuilder: (ctx, i) {
                      final sub = _subcats[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Expanded(child: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Text('Sort: ${sub.sortOrder}', style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: isSaving ? null : () => _deleteSubcategory(sub),
                              child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFF64748B)))),
      ],
    );
  }
}
