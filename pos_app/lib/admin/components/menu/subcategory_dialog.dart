import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'menu_widgets.dart';

class SubcategoryDialog extends StatefulWidget {
  final Client client;
  final Subcategory? subcategory;
  final List<Category> categories;
  final VoidCallback onSuccess;

  const SubcategoryDialog({
    super.key,
    required this.client,
    this.subcategory,
    required this.categories,
    required this.onSuccess,
  });

  @override
  State<SubcategoryDialog> createState() => _SubcategoryDialogState();
}

class _SubcategoryDialogState extends State<SubcategoryDialog> {
  late TextEditingController nameController;
  late TextEditingController sortController;
  String? categoryId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.subcategory?.name ?? '',
    );
    sortController = TextEditingController(
      text: widget.subcategory?.sortOrder.toString() ?? '0',
    );
    categoryId =
        widget.subcategory?.categoryId.toString() ??
        (widget.categories.isNotEmpty
            ? widget.categories.first.id.toString()
            : null);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subcategory != null;

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
                      isEditing ? 'Edit Subcategory' : 'Add Subcategory',
                      style: TextStyle(fontSize: isMobile ? 18 : 20),
                    ),
                    Text(
                      isEditing
                          ? 'Update existing menu subcategory'
                          : 'Create a new menu subcategory',
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuDialogField(
                  label: 'Subcategory Name',
                  controller: nameController,
                  hint: 'e.g., Starters, Main Course, Drinks',
                ),
                const SizedBox(height: 16),
                MenuDialogDropdown<String>(
                  label: 'Parent Category',
                  value: categoryId,
                  items: widget.categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id.toString(),
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => categoryId = v),
                ),
                const SizedBox(height: 16),
                MenuDialogField(
                  label: 'Sort Order',
                  controller: sortController,
                  isNumeric: true,
                ),
              ],
            ),
          ),
          actions: [
            if (isEditing)
              TextButton.icon(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
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

  Future<void> _handleDelete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text(
          'Are you sure you want to delete ${widget.subcategory!.name}? All items in this subcategory will lose their subcategory assignment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.client.subcategories.delete(widget.subcategory!.id!);
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

  Future<void> _handleSave() async {
    if (categoryId == null) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (widget.subcategory != null) {
        await widget.client.subcategories.update(
          widget.subcategory!.id!,
          int.parse(categoryId!),
          nameController.text,
          int.tryParse(sortController.text) ?? 0,
        );
      } else {
        await widget.client.subcategories.create(
          int.parse(categoryId!),
          nameController.text,
          int.tryParse(sortController.text) ?? 0,
        );
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
