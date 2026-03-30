import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'menu_widgets.dart';

class CategoryDialog extends StatefulWidget {
  final Client client;
  final Category? category;
  final VoidCallback onSuccess;

  const CategoryDialog({
    super.key,
    required this.client,
    this.category,
    required this.onSuccess,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late TextEditingController nameController;
  late TextEditingController sortController;
  late String orderType;
  late String station;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category?.name ?? '');
    sortController = TextEditingController(
      text: widget.category?.sortOrder.toString() ?? '0',
    );
    orderType = widget.category?.orderType ?? 'Dine-In';
    station = widget.category?.station ?? 'Kitchen';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                      isEditing ? 'Edit Category' : 'Add Category',
                      style: TextStyle(fontSize: isMobile ? 18 : 20),
                    ),
                    Text(
                      isEditing
                          ? 'Update existing menu category'
                          : 'Create a new menu category',
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
                  label: 'Category Name',
                  controller: nameController,
                  hint: 'e.g., Appetizers, Main Course, Desserts',
                ),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  MenuDialogDropdown<String>(
                    label: 'Menu Type',
                    value: orderType,
                    items: ['Dine-In', 'Takeaway', 'Both']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => orderType = v!),
                  ),
                  const SizedBox(height: 16),
                  MenuDialogDropdown<String>(
                    label: 'Station',
                    value: station,
                    items: ['Kitchen', 'Bar', 'Counter']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => station = v!),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: MenuDialogDropdown<String>(
                          label: 'Menu Type',
                          value: orderType,
                          items: ['Dine-In', 'Takeaway', 'Both']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => orderType = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MenuDialogDropdown<String>(
                          label: 'Station',
                          value: station,
                          items: ['Kitchen', 'Bar', 'Counter']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => station = v!),
                        ),
                      ),
                    ],
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
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete ${widget.category!.name}? All items in this category will become uncategorized.',
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
        await widget.client.categories.delete(widget.category!.id!);
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
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (widget.category != null) {
        await widget.client.categories.update(
          widget.category!.id!,
          nameController.text,
          int.tryParse(sortController.text) ?? 0,
          station,
          orderType,
        );
      } else {
        await widget.client.categories.create(
          nameController.text,
          int.tryParse(sortController.text) ?? 0,
          station,
          orderType,
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
