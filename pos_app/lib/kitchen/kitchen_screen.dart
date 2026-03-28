import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';
import '../shared/printer_screen.dart';
import '../login_screen.dart';

class KitchenScreen extends StatefulWidget {
  final User user;

  const KitchenScreen({super.key, required this.user});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<Order> _activeOrders = [];
  List<Order> _historyOrders = [];
  bool _loadingActive = true;
  bool _loadingHistory = true;
  StreamSubscription? _orderCreatedSub;
  StreamSubscription? _orderUpdatedSub;

  // Kitchen station colour / theme
  static const Color _accent = Color(0xFFFF6B35);
  static const Color _accentBg = Color(0xFFFFF4F0);
  static const Color _dark = Color(0xFF1A0800);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActive();
    _loadHistory();

    SocketService().init();
    _orderCreatedSub = SocketService().onOrderCreated.listen((_) {
      if (mounted) {
        _loadActive();
        if (_tabController.index == 1) _loadHistory();
      }
    });
    _orderUpdatedSub = SocketService().onOrderUpdated.listen((_) {
      if (mounted) {
        _loadActive();
        if (_tabController.index == 1) _loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderCreatedSub?.cancel();
    _orderUpdatedSub?.cancel();
    super.dispose();
  }

  Future<void> _loadActive() async {
    try {
      final orders = await _api.fetchOrders(includeItems: true, stationFilter: 'Kitchen');
      final active = orders.where((o) =>
        (o.status == 'Pending' || o.status == 'In Progress')
      ).toList();
      if (!mounted) return;
      setState(() { _activeOrders = active; _loadingActive = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingActive = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final orders = await _api.fetchOrders(includeItems: true, stationFilter: 'Kitchen');
      final history = orders.where((o) =>
        (o.status == 'Ready' || o.status == 'Completed')
      ).toList();
      if (!mounted) return;
      setState(() { _historyOrders = history; _loadingHistory = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _markStatus(Order order, String status) async {
    final updated = await _api.updateOrderStatus(order.id, status);
    if (!mounted) return;
    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${order.orderCode ?? "Order"} marked as $status'),
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadActive();
    }
  }

  Future<void> _viewOrderDetail(Order order) async {
    Order? full;
    try { full = await _api.fetchOrderDetails(order.id); } catch (_) { full = order; }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _accentBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.restaurant_menu, color: _accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(full!.orderCode ?? '#${full.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    if (full.tableNo != null)
                      Text('Table ${full.tableNo}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ])),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ...full.items.where((i) => i.station == 'Kitchen').map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: _accentBg, borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 12))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (item.extras.isNotEmpty)
                        Text('+ ${item.extras.map((e) => e.name).join(', ')}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFDE68A))),
                            child: Text('⚠ ${item.notes}', style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontStyle: FontStyle.italic)),
                          ),
                        ),
                    ])),
                  ]),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'In Progress': return const Color(0xFF3B82F6);
      case 'Ready': return const Color(0xFF10B981);
      case 'Completed': return const Color(0xFF94A3B8);
      default: return _accent; // Pending
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveOrdersTab(),
                _buildHistoryTab(),
                const PrinterScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      decoration: BoxDecoration(
        color: _dark,
        border: Border(bottom: BorderSide(color: _accent.withValues(alpha: 0.3))),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kitchen Display', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text('${_activeOrders.length} active order${_activeOrders.length == 1 ? '' : 's'}',
              style: TextStyle(color: _accent, fontSize: 13)),
        ]),
        const Spacer(),
        // Auto-refresh indicator
        IconButton(
          onPressed: () { _loadActive(); _loadHistory(); },
          icon: const Icon(Icons.refresh, color: Colors.white60),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white60),
          color: const Color(0xFF1A1A1A),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF94A3B8)),
                title: const Text('Logout', style: TextStyle(color: Color(0xFF64748B))),
                onTap: () {
                  SocketService().disconnect();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _dark,
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: _accent, width: 3)),
        ),
        labelColor: _accent,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: [
          Tab(text: 'Active Orders${_activeOrders.isNotEmpty ? ' (${_activeOrders.length})' : ''}'),
          const Tab(text: 'History'),
          const Tab(text: 'Printer'),
        ],
        onTap: (i) { if (i == 1) _loadHistory(); },
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    if (_loadingActive) {
      return Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_activeOrders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle_outline, size: 72, color: Colors.white.withValues(alpha: 0.15)),
        const SizedBox(height: 16),
        Text('No active orders', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 18)),
        const SizedBox(height: 6),
        Text('All caught up! Orders will appear here.', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14)),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _loadActive,
      color: _accent,
      backgroundColor: _dark,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          childAspectRatio: 0.75,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _activeOrders.length,
        itemBuilder: (ctx, i) => _buildOrderCard(_activeOrders[i]),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isPending = order.status == 'Pending';
    final isInProgress = order.status == 'In Progress';
    final borderColor = isPending ? _accent : const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: () => _viewOrderDetail(order),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.orderCode ?? '#${order.id}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  if (order.tableNo != null)
                    Row(children: [
                      const Icon(Icons.table_chart_outlined, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text('Table ${order.tableNo}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order.status, style: TextStyle(color: borderColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Text(_timeAgo(order.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ]),
            ),

            // Items list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.where((i) => i.station == 'Kitchen').isEmpty
                      ? [const Text('Tap to view items', style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic))]
                      : order.items.where((i) => i.station == 'Kitchen').map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: borderColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(child: Text('${item.quantity}', style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 12))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              if (item.extras.isNotEmpty)
                                Text('+ ${item.extras.map((e) => e.name).join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Text('⚠ ${item.notes}', style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontStyle: FontStyle.italic)),
                            ])),
                          ]),
                        )).toList(),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(children: [
                if (isPending) ...[
                  Expanded(child: _actionBtn('Start', const Color(0xFF3B82F6), () => _markStatus(order, 'In Progress'))),
                ] else if (isInProgress) ...[
                  Expanded(child: _actionBtn('Mark Ready ✓', const Color(0xFF10B981), () => _markStatus(order, 'Ready'))),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_loadingHistory) return Center(child: CircularProgressIndicator(color: _accent));
    if (_historyOrders.isEmpty) {
      return Center(child: Text('No completed orders yet.', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historyOrders.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final order = _historyOrders[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                order.status == 'Ready' ? Icons.done : Icons.done_all,
                color: _statusColor(order.status), size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.orderCode ?? '#${order.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                order.tableNo != null ? 'Table ${order.tableNo} · ${_timeAgo(order.createdAt)}' : _timeAgo(order.createdAt),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(order.status, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
        );
      },
    );
  }
}
