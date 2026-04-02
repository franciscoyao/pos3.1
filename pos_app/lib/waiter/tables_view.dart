import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';

class TablesView extends StatefulWidget {
  final Function(String)? onAddItems;
  final Function(String)? onCheckout;

  const TablesView({super.key, this.onAddItems, this.onCheckout});

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  List<RestaurantTable> tables = [];
  List<PosOrder> takeawayOrders = [];
  Map<String, List<PosOrder>> tableOrders = {};
  bool isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'table_updated' ||
          event.eventType == 'order_created' ||
          event.eventType == 'order_updated') {
        _loadDataQuietly();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await _loadDataQuietly();
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadDataQuietly() async {
    try {
      final fetchedTables = await client.tables.getAll();
      final fetchedOrders = await client.orders.getAll(
        includeItems: true,
        statusFilter: 'Pending,In Progress',
      );

      final Map<String, List<PosOrder>> ordersMap = {};
      final List<PosOrder> takeaways = [];
      for (final order in fetchedOrders) {
        if (order.orderType == 'Takeaway') {
          takeaways.add(order);
        } else if (order.tableNo != null) {
          ordersMap.putIfAbsent(order.tableNo!, () => []).add(order);
        }
      }

      if (mounted) {
        setState(() {
          tables = fetchedTables;
          tableOrders = ordersMap;
          takeawayOrders = takeaways;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tables: $e')));
      }
    }
  }

  Future<void> _addTable() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Table'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Table Number (e.g. 9)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      try {
        await client.tables.create(result.trim());
        _loadDataQuietly();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding table: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final activeTables = tables
        .where((t) => tableOrders.containsKey(t.tableNumber))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tables',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tables.length} tables • $activeTables active',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.85,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: tables.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddTableCard();
                return _buildTableCard(tables[index - 1]);
              },
            ),
            if (takeawayOrders.isNotEmpty) ...[
              const SizedBox(height: 48),
              const Row(
                children: [
                  Icon(Icons.takeout_dining_rounded, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Active Takeaway Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: takeawayOrders.length,
                itemBuilder: (context, index) {
                  return _buildTakeawayCard(takeawayOrders[index]);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTakeawayCard(PosOrder order) {
    final totalAmount = order.total;
    final timeFormat = DateFormat('hh:mm a');

    return InkWell(
      onTap: () => _showTableDetails(
        RestaurantTable(tableNumber: 'Takeaway', status: 'Occupied'),
        [order],
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBAE6FD)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.waiterName == 'Kiosk' ? 'Kiosk' : 'Takeaway',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${order.orderCode?.substring(order.orderCode!.length - 4) ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
            const Spacer(),
            Text(
              '€${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(0xFF0369A1),
                ),
                const SizedBox(width: 4),
                Text(
                  order.createdAt != null
                      ? timeFormat.format(order.createdAt!)
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTableCard() {
    return InkWell(
      onTap: _addTable,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Add Table',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(RestaurantTable table) {
    final orders = tableOrders[table.tableNumber] ?? [];
    final isActive = orders.isNotEmpty;
    final totalAmount = orders.fold(0.0, (sum, o) => sum + o.total);

    String duration = '0m';
    if (isActive) {
      final latestOrder = orders.reduce(
        (a, b) =>
            (a.updatedAt ?? DateTime(0)).isAfter(b.updatedAt ?? DateTime(0))
            ? a
            : b,
      );
      final diff = DateTime.now().difference(
        latestOrder.updatedAt ?? DateTime.now(),
      );
      if (diff.inHours > 0) {
        duration = '${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        duration = '${diff.inMinutes}m';
      }
    }

    return InkWell(
      onTap: () => _showTableDetails(table, orders),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFEF3C7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFFDE68A) : Colors.grey[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Table',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              table.tableNumber,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
            ),
            const Spacer(),
            if (isActive) ...[
              Text(
                '€${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
              Text(
                '${orders.length} orders',
                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isActive ? const Color(0xFF92400E) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? const Color(0xFF92400E) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTableDetails(RestaurantTable table, List<PosOrder> orders) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 450,
            height: double.infinity,
            color: Colors.white,
            child: _TableDetailsSidebar(
              table: table,
              orders: orders,
              onUpdate: _loadDataQuietly,
              onAddItems: widget.onAddItems,
              onSplit: (t, o) => _showSplitItemsDialog(context, t, o),
              onMerge: (t) => _showMergeTableDialog(context, t),
              onCheckout: () {
                Navigator.pop(context); // Close sidebar
                if (widget.onCheckout != null) {
                  widget.onCheckout!(table.tableNumber);
                }
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  void _showMergeTableDialog(
    BuildContext context,
    RestaurantTable sourceTable,
  ) {
    final otherTables = tables
        .where((t) => t.tableNumber != sourceTable.tableNumber)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Merge Table ${sourceTable.tableNumber} into...'),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: otherTables.length,
            itemBuilder: (context, index) {
              final target = otherTables[index];
              return ListTile(
                title: Text('Table ${target.tableNumber}'),
                subtitle: Text(target.status),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    await client.tables.mergeTables(
                      sourceTable.tableNumber,
                      target.tableNumber,
                    );
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close sidebar
                      _loadDataQuietly();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Merged Table ${sourceTable.tableNumber} into ${target.tableNumber}',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error merging tables: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSplitItemsDialog(
    BuildContext context,
    RestaurantTable sourceTable,
    List<PosOrder> orders,
  ) {
    if (orders.isEmpty) return;

    // Flatten all items from all orders of this table
    final allItems = orders.expand((o) => o.items ?? []).toList();
    final Map<int, int> selectedQuantities = {};
    final targetTableController = TextEditingController();
    bool isSplitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Split Items to New Table'),
            content: SizedBox(
              width: 500,
              child: isSplitting
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Splitting items...'),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Select Items and Quantities to Move:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: allItems.length,
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              final currentQty =
                                  selectedQuantities[item.id] ?? 0;
                              final isSelected = currentQty > 0;

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[100]!,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          selectedQuantities[item.id!] = 1;
                                        } else {
                                          selectedQuantities.remove(item.id);
                                        }
                                      });
                                    },
                                  ),
                                  title: Text(item.productName ?? 'Unknown'),
                                  subtitle: Text(
                                    '€${item.price.toStringAsFixed(2)} each (Max: ${item.quantity})',
                                  ),
                                  trailing: isSelected
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                              onPressed: currentQty > 1
                                                  ? () => setDialogState(
                                                      () =>
                                                          selectedQuantities[item
                                                                  .id!] =
                                                              currentQty - 1,
                                                    )
                                                  : null,
                                            ),
                                            Text(
                                              '$currentQty',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              onPressed:
                                                  currentQty < item.quantity
                                                  ? () => setDialogState(
                                                      () =>
                                                          selectedQuantities[item
                                                                  .id!] =
                                                              currentQty + 1,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '2. Target Table Number:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: targetTableController,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Enter Table Number (e.g. 15)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.grid_view_rounded),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
            ),
            actions: isSplitting
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          (selectedQuantities.isNotEmpty &&
                              targetTableController.text.trim().isNotEmpty)
                          ? () async {
                              setDialogState(() => isSplitting = true);
                              try {
                                final itemIds = selectedQuantities.keys
                                    .toList();
                                final qtys = selectedQuantities.values.toList();

                                await client.tables.moveItemsToTable(
                                  itemIds,
                                  qtys,
                                  targetTableController.text.trim(),
                                );

                                if (context.mounted) {
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(context); // Close sidebar
                                  _loadDataQuietly();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Successfully moved items to Table ${targetTableController.text.trim()}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setDialogState(() => isSplitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error splitting items: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Split and Move Items',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
          );
        },
      ),
    );
  }
}

class _TableDetailsSidebar extends StatelessWidget {
  final RestaurantTable table;
  final List<PosOrder> orders;
  final VoidCallback onUpdate;
  final Function(String)? onAddItems;
  final Function(RestaurantTable, List<PosOrder>) onSplit;
  final Function(RestaurantTable) onMerge;
  final VoidCallback onCheckout;

  const _TableDetailsSidebar({
    required this.table,
    required this.orders,
    required this.onUpdate,
    this.onAddItems,
    required this.onSplit,
    required this.onMerge,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orders.fold(0.0, (sum, o) => sum + o.total);
    final isActive = orders.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Table ${table.tableNumber}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ordered',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Manage orders and table status',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to New Order with this table pre-selected
                Navigator.pop(context);
                if (onAddItems != null) {
                  onAddItems!(table.tableNumber);
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Items',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onSplit(table, orders),
                    icon: const Icon(
                      Icons.table_rows_outlined,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Split Table',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onMerge(table),
                    icon: const Icon(Icons.merge_type, color: Colors.black),
                    label: const Text(
                      'Merge',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(
                  Icons.restaurant_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${orders.length} active',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('No active orders'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) =>
                          _buildOrderItems(orders[index]),
                    ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '€${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print_outlined, color: Colors.red),
                    label: const Text(
                      'Print Bill',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFFEE2E2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isActive ? onCheckout : null,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(PosOrder order) {
    final timeFormat = DateFormat('hh:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50]!,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderCode?.substring(order.orderCode!.length - 4) ?? 'N/A'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  order.createdAt != null
                      ? timeFormat.format(order.createdAt!)
                      : 'N/A',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: (order.items ?? [])
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(item.productName ?? 'Unknown'),
                          const Spacer(),
                          Text('€${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
