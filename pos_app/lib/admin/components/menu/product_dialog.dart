import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'menu_widgets.dart';

class ProductDialog extends StatefulWidget {
  final Client client;
  final Product? product;
  final List<Category> categories;
  final List<Subcategory> subcategories;
  final int? defaultCategoryId;
  final VoidCallback onSuccess;

  const ProductDialog({
    super.key,
    required this.client,
    this.product,
    required this.categories,
    required this.subcategories,
    this.defaultCategoryId,
    required this.onSuccess,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController priceController;
  String? categoryId;
  String? subcategoryId;
  late bool isAvailable;
  late bool allowPriceEdit;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(
      text: widget.product?.itemCode ?? '',
    );
    nameController = TextEditingController(text: widget.product?.name ?? '');
    priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '0',
    );
    categoryId =
        widget.product?.categoryId?.toString() ??
        widget.defaultCategoryId?.toString() ??
        (widget.categories.isNotEmpty
            ? widget.categories.first.id.toString()
            : null);
    subcategoryId = widget.product?.subcategoryId?.toString();
    isAvailable = widget.product?.isAvailable ?? true;
    allowPriceEdit = widget.product?.allowPriceEdit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Menu Item' : 'Add Menu Item',
                      style: TextStyle(fontSize: isMobile ? 18 : 20),
                    ),
                    Text(
                      isEditing
                          ? 'Update existing menu item'
                          : 'Create a new menu item',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMobile) ...[
                    MenuDialogField(
                      label: 'Item Code',
                      controller: codeController,
                    ),
                    const SizedBox(height: 16),
                    MenuDialogField(
                      label: 'Price',
                      controller: priceController,
                      isNumeric: true,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: MenuDialogField(
                            label: 'Item Code',
                            controller: codeController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuDialogField(
                            label: 'Price',
                            controller: priceController,
                            isNumeric: true,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  MenuDialogField(label: 'Name', controller: nameController),
                  const SizedBox(height: 16),
                  if (isMobile) ...[
                    MenuDialogDropdown<String>(
                      label: 'Category',
                      value: categoryId,
                      items: widget.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id.toString(),
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        categoryId = v;
                        subcategoryId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    MenuDialogDropdown<String>(
                      label: 'Subcategory',
                      value: subcategoryId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...widget.subcategories
                            .where((s) => s.categoryId.toString() == categoryId)
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id.toString(),
                                child: Text(s.name),
                              ),
                            ),
                      ],
                      onChanged: (v) => setState(() => subcategoryId = v),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: MenuDialogDropdown<String>(
                            label: 'Category',
                            value: categoryId,
                            items: widget.categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id.toString(),
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              categoryId = v;
                              subcategoryId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuDialogDropdown<String>(
                            label: 'Subcategory',
                            value: subcategoryId,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...widget.subcategories
                                  .where(
                                    (s) =>
                                        s.categoryId.toString() == categoryId,
                                  )
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.id.toString(),
                                      child: Text(s.name),
                                    ),
                                  ),
                            ],
                            onChanged: (v) => setState(() => subcategoryId = v),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildInheritedInfo(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Available',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: isAvailable,
                    activeThumbColor: const Color(0xFF0F172A),
                    onChanged: (v) => setState(() => isAvailable = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Allow Price Edit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: allowPriceEdit,
                    activeThumbColor: const Color(0xFF0F172A),
                    onChanged: (v) => setState(() => allowPriceEdit = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: isMobile ? const Size(double.infinity, 50) : null,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInheritedInfo() {
    final selectedCategory = widget.categories.firstWhere(
      (c) => c.id.toString() == categoryId,
      orElse: () => Category(
        name: 'None',
        sortOrder: 0,
        station: 'N/A',
        orderType: 'N/A',
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inherited Station',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  selectedCategory.station ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inherited Type',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  selectedCategory.orderType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Find the selected category to inherit its properties
    final selectedCategory = widget.categories.firstWhere(
      (c) => c.id.toString() == categoryId,
      orElse: () => Category(
        name: 'Default',
        sortOrder: 0,
        station: 'Kitchen',
        orderType: 'Both',
      ),
    );

    final newProduct = Product(
      id: widget.product?.id,
      itemCode: codeController.text,
      name: nameController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      categoryId: categoryId != null ? int.parse(categoryId!) : null,
      subcategoryId: subcategoryId != null ? int.parse(subcategoryId!) : null,
      station: selectedCategory.station,
      type: selectedCategory.orderType,
      isAvailable: isAvailable,
      allowPriceEdit: allowPriceEdit,
    );

    try {
      if (widget.product != null) {
        await widget.client.products.update(widget.product!.id!, newProduct);
      } else {
        await widget.client.products.create(newProduct);
      }
      if (mounted) {
        navigator.pop();
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
