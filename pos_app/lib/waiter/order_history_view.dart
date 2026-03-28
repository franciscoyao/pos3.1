import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final ApiService _api = ApiService();
  List<Order> _orders = [];
  List<Order> _filtered = [];
  bool _isLoading = true;
  String _statusFilter = 'All';
  final List<String> _statuses = ['All', 'Pending', 'In Progress', 'Ready', 'Completed'];
  int? _expandedId;

  StreamSubscription? _orderUpdatedSub;
  StreamSubscription? _orderCreatedSub;

  @override
  void initState() {
    super.initState();
    _loadOrders();

    final socketService = SocketService();
    _orderUpdatedSub = socketService.onOrderUpdated.listen((_) {
      if (mounted) _loadOrders();
    });
    _orderCreatedSub = socketService.onOrderCreated.listen((_) {
      if (mounted) _loadOrders();
    });
  }

  @override
  void dispose() {
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _api.fetchOrders();
      setState(() { _orders = orders; _applyFilter(); _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _statusFilter == 'All' ? _orders : _orders.where((o) => o.status == _statusFilter).toList();
    });
  }

  Future<void> _tapOrder(Order order) async {
    if (_expandedId == order.id) {
      setState(() => _expandedId = null);
      return;
    }
    try {
      final full = await _api.fetchOrderDetails(order.id);
      final idx = _orders.indexWhere((o) => o.id == full.id);
      if (idx >= 0) setState(() { _orders[idx] = full; _applyFilter(); _expandedId = full.id; });
    } catch (_) {
      setState(() => _expandedId = order.id);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed': return const Color(0xFF10B981);
      case 'In Progress': return const Color(0xFF3B82F6);
      case 'Ready': return const Color(0xFF8B5CF6);
      default: return const Color(0xFFF59E0B);
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
            child: Row(children: [
              const Text('Order History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Spacer(),
              IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh)),
            ]),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _statuses.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final status = _statuses[i];
                  final selected = _statusFilter == status;
                  return GestureDetector(
                    onTap: () { setState(() => _statusFilter = status); _applyFilter(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(status, style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600, fontSize: 13,
                      )),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No orders found.', style: TextStyle(color: Color(0xFF94A3B8))),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _filtered.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final order = _filtered[i];
                          final isExpanded = _expandedId == order.id;
                          return GestureDetector(
                            onTap: () => _tapOrder(order),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isExpanded ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(order.orderCode ?? '#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        if (order.orderType != null) Text(order.orderType!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        if (order.tableNo != null) ...[
                                          const Text(' · ', style: TextStyle(color: Color(0xFF94A3B8))),
                                          const Icon(Icons.table_chart_outlined, size: 13, color: Color(0xFF64748B)),
                                          const SizedBox(width: 3),
                                          Text(order.tableNo!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        ],
                                      ]),
                                    ])),
                                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _statusColor(order.status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(order.status, style: TextStyle(color: _statusColor(order.status), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ]),
                                  ]),

                                  // Expanded items
                                  if (isExpanded && order.items.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(children: [
                                        Text('${item.quantity}×', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(item.name, style: const TextStyle(fontSize: 13)),
                                          if (item.notes != null && item.notes!.isNotEmpty)
                                            Text(item.notes!, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                                        ])),
                                        Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                                      ]),
                                    )),
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
}
