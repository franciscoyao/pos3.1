import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';

class TablesView extends StatefulWidget {
  final User user;
  final void Function(String tableNumber) onOpenNewOrderForTable;

  const TablesView({super.key, required this.user, required this.onOpenNewOrderForTable});

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  final ApiService _api = ApiService();
  List<TableRecord> _tables = [];
  bool _isLoading = true;
  
  StreamSubscription? _tableUpdateSub;
  StreamSubscription? _orderUpdateSub;
  StreamSubscription? _checkoutSub;

  @override
  void initState() {
    super.initState();
    _loadTables();
    
    final socketService = SocketService();
    _tableUpdateSub = socketService.onTableUpdated.listen((_) {
      if (mounted) _loadTables();
    });
    _orderUpdateSub = socketService.onOrderUpdated.listen((_) {
      if (mounted) _loadTables();
    });
    _checkoutSub = socketService.onCheckoutCompleted.listen((_) {
      if (mounted) _loadTables();
    });
  }

  @override
  void dispose() {
    _tableUpdateSub?.cancel();
    _orderUpdateSub?.cancel();
    _checkoutSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);
    try {
      final tables = await _api.fetchTables();
      setState(() { _tables = tables; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTable() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Table'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Table number (e.g. T1, T2)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _api.createTable(result);
      _loadTables();
    }
  }

  Future<void> _handleMerge(TableRecord targetTable) async {
    final orders = await _api.fetchOrders();
    try {
      final targetOrder = orders.firstWhere((o) => o.tableNo == targetTable.tableNumber && o.status != 'Completed');
      final sourceOrders = orders.where((o) => o.tableNo != targetTable.tableNumber && o.tableNo != null && o.status != 'Completed').toList();
      
      if (sourceOrders.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No other active tables to merge from.')));
        return;
      }
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Merge into Table ${targetTable.tableNumber}'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sourceOrders.length,
              itemBuilder: (c, i) {
                final source = sourceOrders[i];
                return ListTile(
                  leading: const Icon(Icons.table_restaurant),
                  title: Text('Table ${source.tableNo}'),
                  subtitle: Text(source.orderCode ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await _api.mergeOrders(targetOrder.id, source.id);
                      if (success) {
                        _loadTables();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully merged Table ${source.tableNo} into Table ${targetTable.tableNumber}.')));
                      } else {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to merge tables.'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    child: const Text('Merge'),
                  ),
                );
              }
            )
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))
          ]
        )
      );

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target open order not found. Create an order first.')));
    }
  }

  void _showTableOptions(TableRecord table) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table ${table.tableNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(table.status, style: TextStyle(color: _statusColor(table.status), fontWeight: FontWeight.w600)),
            if (table.orderCode != null) ...[
              const SizedBox(height: 4),
              Text('Order: ${table.orderCode}', style: const TextStyle(color: Color(0xFF64748B))),
            ],
            const SizedBox(height: 20),
            if (table.status == 'Available') ...[
              _sheetButton(Icons.add_shopping_cart, 'New Order for this table', const Color(0xFF0F172A), () {
                Navigator.pop(context);
                widget.onOpenNewOrderForTable(table.tableNumber);
              }),
            ] else ...[
              _sheetButton(Icons.receipt_long, 'View / Checkout Order', const Color(0xFF0F172A), () {
                Navigator.pop(context);
                widget.onOpenNewOrderForTable(table.tableNumber);
              }),
              const SizedBox(height: 8),
              _sheetButton(Icons.call_merge, 'Merge from another table', const Color(0xFF3B82F6), () {
                Navigator.pop(context);
                _handleMerge(table);
              }),
              const SizedBox(height: 8),
              _sheetButton(Icons.lock_reset, 'Mark as Available', Colors.green, () async {
                await _api.updateTable(table.id, {'status': 'Available', 'order_code': null, 'guest_count': 0});
                if (!mounted) return;
                Navigator.pop(context);
                _loadTables();
              }),
            ],
            const SizedBox(height: 8),
            _sheetButton(Icons.event_seat, 'Mark as Reserved', Colors.orange.shade700, () async {
              await _api.updateTable(table.id, {'status': 'Reserved', 'order_code': table.orderCode, 'guest_count': table.guestCount});
              if (!mounted) return;
              Navigator.pop(context);
              _loadTables();
            }),
          ],
        ),
      ),
    );
  }

  Widget _sheetButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Occupied': return const Color(0xFFF59E0B);
      case 'Reserved': return const Color(0xFFEF4444);
      default: return const Color(0xFF10B981);
    }
  }

  Color _bgColor(String status) {
    switch (status) {
      case 'Occupied': return const Color(0xFFFFF7ED);
      case 'Reserved': return const Color(0xFFFEF2F2);
      default: return const Color(0xFFF0FDF4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                const Text('Table Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addTable,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Table'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(width: 10),
                IconButton(onPressed: _loadTables, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              _legend(const Color(0xFF10B981), 'Available'),
              const SizedBox(width: 20),
              _legend(const Color(0xFFF59E0B), 'Occupied'),
              const SizedBox(width: 20),
              _legend(const Color(0xFFEF4444), 'Reserved'),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tables.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No tables yet. Add your first table.', style: TextStyle(color: Color(0xFF94A3B8))),
                      ]))
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160, childAspectRatio: 1.0,
                          crossAxisSpacing: 12, mainAxisSpacing: 12,
                        ),
                        itemCount: _tables.length,
                        itemBuilder: (context, i) {
                          final table = _tables[i];
                          final color = _statusColor(table.status);
                          final bg = _bgColor(table.status);
                          return GestureDetector(
                            onTap: () => _showTableOptions(table),
                            child: Container(
                              decoration: BoxDecoration(
                                color: bg, borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.table_restaurant, size: 32, color: color),
                                  const SizedBox(height: 8),
                                  Text(table.tableNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                    child: Text(table.status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                                  ),
                                  if (table.orderCode != null) ...[
                                    const SizedBox(height: 4),
                                    Text(table.orderCode!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
    ]);
  }
}
