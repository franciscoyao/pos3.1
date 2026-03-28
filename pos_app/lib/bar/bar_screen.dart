import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/printer_screen.dart';
import '../shared/socket_service.dart';
import '../login_screen.dart';

class BarScreen extends StatefulWidget {
  final User user;

  const BarScreen({super.key, required this.user});

  @override
  State<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends State<BarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<Order> _activeOrders = [];
  List<Order> _historyOrders = [];
  bool _loadingActive = true;
  bool _loadingHistory = true;
  Timer? _refreshTimer;

  StreamSubscription? _orderUpdatedSub;
  StreamSubscription? _orderCreatedSub;

  // Bar station colour / theme
  static const Color _accent = Color(0xFF8B5CF6); // purple
  static const Color _dark = Color(0xFF0D0B1A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActive();
    _loadHistory();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadActive();
      if (_tabController.index == 1) _loadHistory();
    });

    final socketService = SocketService();
    _orderUpdatedSub = socketService.onOrderUpdated.listen((_) {
      if (mounted) {
        _loadActive();
        if (_tabController.index == 1) _loadHistory();
      }
    });
    _orderCreatedSub = socketService.onOrderCreated.listen((_) {
      if (mounted) _loadActive();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();
    super.dispose();
  }

  Future<void> _loadActive() async {
    try {
      final orders = await _api.fetchOrders(includeItems: true, stationFilter: 'Bar');
      // Bar sees Pending and In Progress
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
      final orders = await _api.fetchOrders(includeItems: true, stationFilter: 'Bar');
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
        backgroundColor: const Color(0xFF1E1B2E),
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
                    decoration: BoxDecoration(color: _accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_bar, color: _accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(full!.orderCode ?? '#${full.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                    if (full.tableNo != null)
                      Text('Table ${full.tableNo}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ])),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.white54)),
                ]),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 8),
                ...full.items.where((i) => i.station == 'Bar').map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: _accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 12))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                      if (item.extras.isNotEmpty)
                        Text('+ ${item.extras.map((e) => e.name).join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: Text('⚠ ${item.notes}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontStyle: FontStyle.italic)),
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
      case 'Completed': return const Color(0xFF64748B);
      default: return _accent;
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
      backgroundColor: _dark,
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
        color: const Color(0xFF13102A),
        border: Border(bottom: BorderSide(color: _accent.withValues(alpha: 0.3))),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_bar, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bar Display', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text('${_activeOrders.length} active order${_activeOrders.length == 1 ? '' : 's'}',
              style: TextStyle(color: _accent, fontSize: 13)),
        ]),
        const Spacer(),
        IconButton(
          onPressed: () { _loadActive(); _loadHistory(); },
          icon: const Icon(Icons.refresh, color: Colors.white60),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.logout, color: Colors.white60, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF13102A),
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
    if (_loadingActive) return Center(child: CircularProgressIndicator(color: _accent));
    if (_activeOrders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_bar, size: 72, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 16),
        Text('No active drink orders', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 18)),
        const SizedBox(height: 6),
        Text('Orders will appear here automatically.', style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 14)),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _loadActive,
      color: _accent,
      backgroundColor: const Color(0xFF13102A),
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
          color: const Color(0xFF1E1B2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.orderCode ?? '#${order.id}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  if (order.tableNo != null)
                    Row(children: [
                      const Icon(Icons.table_chart_outlined, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text('Table ${order.tableNo}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: borderColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(order.status, style: TextStyle(color: borderColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Text(_timeAgo(order.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ]),
            ),

            // Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.where((i) => i.station == 'Bar').isEmpty
                      ? [const Text('Tap to view items', style: TextStyle(color: Colors.white24, fontSize: 13, fontStyle: FontStyle.italic))]
                      : order.items.where((i) => i.station == 'Bar').map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(color: borderColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: Center(child: Text('${item.quantity}', style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 12))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              if (item.extras.isNotEmpty)
                                Text('+ ${item.extras.map((e) => e.name).join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Text('⚠ ${item.notes}', style: const TextStyle(color: Colors.amber, fontSize: 11, fontStyle: FontStyle.italic)),
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
                if (isPending)
                  Expanded(child: _actionBtn('Start Preparing', const Color(0xFF3B82F6), () => _markStatus(order, 'In Progress'))),
                if (isInProgress)
                  Expanded(child: _actionBtn('Ready to Serve ✓', const Color(0xFF10B981), () => _markStatus(order, 'Ready'))),
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
            color: const Color(0xFF1E1B2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
