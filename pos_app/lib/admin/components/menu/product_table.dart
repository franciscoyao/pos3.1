import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'menu_widgets.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;
  final Set<int> selectedIds;
  final Function(Product) onEdit;
  final Function(Product) onDelete;
  final Function(Product) onDuplicate;
  final Function(int, bool) onSelectionChanged;
  final Function(bool) onSelectAll;
  final Function(Product, bool) onToggleAvailability;

  const ProductTable({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = products[index];
              final isSelected = selectedIds.contains(p.id);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                p.itemCode ?? 'No Code',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (v) =>
                              onSelectionChanged(p.id!, v ?? false),
                          activeColor: const Color(0xFF0F172A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            if (p.type == 'Dine-In' || p.type == 'Both')
                              const MenuTag(label: 'dine-in'),
                            if (p.type == 'Takeaway' || p.type == 'Both')
                              const SizedBox(width: 4),
                            if (p.type == 'Takeaway' || p.type == 'Both')
                              const MenuTag(label: 'takeaway'),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => onToggleAvailability(p, !p.isAvailable),
                          child: MenuStatusBadge(isAvailable: p.isAvailable),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => onEdit(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_outlined, size: 20),
                              onPressed: () => onDuplicate(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => onDelete(p),
                              color: Colors.red[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }

        final allSelected =
            products.isNotEmpty && selectedIds.length == products.length;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 24,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: allSelected,
                    onChanged: (v) => onSelectAll(v ?? false),
                    activeColor: const Color(0xFF0F172A),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Station',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: products.map((p) {
                final isSelected = selectedIds.contains(p.id);
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (v) => onSelectionChanged(p.id!, v ?? false),
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (v) => onSelectionChanged(p.id!, v ?? false),
                        activeColor: const Color(0xFF0F172A),
                      ),
                    ),
                    DataCell(Text(p.itemCode ?? '-')),
                    DataCell(
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text('€${p.price.toStringAsFixed(2)}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.station ?? '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          if (p.type == 'Dine-In' || p.type == 'Both')
                            const MenuTag(label: 'dine-in'),
                          if (p.type == 'Takeaway' || p.type == 'Both')
                            const SizedBox(width: 4),
                          if (p.type == 'Takeaway' || p.type == 'Both')
                            const MenuTag(label: 'takeaway'),
                        ],
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => onToggleAvailability(p, !p.isAvailable),
                        borderRadius: BorderRadius.circular(20),
                        child: MenuStatusBadge(isAvailable: p.isAvailable),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => onEdit(p),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_outlined, size: 20),
                            onPressed: () => onDuplicate(p),
                            tooltip: 'Duplicate',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => onDelete(p),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
