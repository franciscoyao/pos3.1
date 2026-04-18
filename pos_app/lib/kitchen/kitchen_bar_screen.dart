import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../login_screen.dart';
import '../admin/printer_management_view.dart';
import '../admin/settings_view.dart';
import '../waiter/order_history_view.dart';
import '../shared/printer_service.dart';
import '../shared/responsive_layout.dart';

class KitchenBarScreen extends StatefulWidget {
  final String station; // 'Kitchen' or 'Bar'
  const KitchenBarScreen({super.key, required this.station});

  @override
  State<KitchenBarScreen> createState() => _KitchenBarScreenState();
}

class _KitchenBarScreenState extends State<KitchenBarScreen> {
  List<PosOrder> allOrders = [];
  bool isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupWebsocket();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupWebsocket() {
    _subscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'order_created' ||
          event.eventType == 'order_updated' ||
          event.eventType == 'table_updated') {
        _loadOrdersQuietly();
      }
    });
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    await _loadOrdersQuietly();
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadOrdersQuietly() async {
    try {
      final fetched = await client.orders.getAll(
        includeItems: true,
        statusFilter: 'Pending,In Progress,Ready,Scheduled',
        stationFilter: widget.station,
      );
      if (mounted) {
        // Auto-print newly incoming pending orders
        if (allOrders.isNotEmpty) {
          final existingPendingIds = allOrders
              .where((o) => o.status == 'Pending')
              .map((o) => o.id)
              .toSet();
          final newPendingOrders = fetched
              .where(
                (o) =>
                    o.status == 'Pending' && !existingPendingIds.contains(o.id),
              )
              .toList();

          for (final order in newPendingOrders) {
            PrinterService().printKOT(
              order,
              station: widget.station,
              items: order.items ?? [],
            );
          }
        }

        setState(() {
          allOrders = fetched;
        });
      }
    } catch (e) {
      debugPrint('Error loading station orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          _buildSubHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildKanbanBoard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (!isMobile) ...[
            const Icon(Icons.restaurant, size: 24, color: Color(0xFF0F172A)),
            const SizedBox(width: 12),
          ],
          const Text(
            'POS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isMobile ? widget.station : '${widget.station} Display',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const Spacer(),
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout, size: 20, color: Color(0xFF0F172A)),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    final isMobile = ResponsiveLayout.isMobile(context);
    final activeCount = allOrders.length;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Row(
        children: [
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.station == 'Kitchen'
                    ? Icons.restaurant
                    : Icons.local_bar,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile ? widget.station : '${widget.station} Orders',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '$activeCount active orders',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  child: SizedBox(
                    width: ResponsiveLayout.isMobile(ctx)
                        ? MediaQuery.of(ctx).size.width * 0.9
                        : 1000,
                    height: 800,
                    child: OrderHistoryView(stationFilter: widget.station),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Printer Settings'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  child: SizedBox(
                    width: ResponsiveLayout.isMobile(ctx)
                        ? MediaQuery.of(ctx).size.width * 0.9
                        : 800,
                    height: 600,
                    child: const PrinterManagementView(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('General Settings'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  child: SizedBox(
                    width: ResponsiveLayout.isMobile(ctx)
                        ? MediaQuery.of(ctx).size.width * 0.9
                        : 800,
                    height: 600,
                    child: const SettingsView(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard() {
    final isMobile = ResponsiveLayout.isMobile(context);
    final columns = [
      _buildKanbanColumn('Scheduled', 'Scheduled', isMobile),
      if (!isMobile) const SizedBox(width: 24),
      _buildKanbanColumn('Pending', 'Pending', isMobile),
      if (!isMobile) const SizedBox(width: 24),
      _buildKanbanColumn('In Progress', 'In Progress', isMobile),
      if (!isMobile) const SizedBox(width: 24),
      _buildKanbanColumn('Ready', 'Ready', isMobile),
    ];

    if (isMobile) {
      return ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: columns,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns,
      ),
    );
  }

  Widget _buildKanbanColumn(String title, String status, bool isMobile) {
    final orders = allOrders.where((o) => o.status == status).toList();
    final child = Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orders.length}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    'No $title',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      _buildOrderCard(orders[index]),
                ),
        ),
      ],
    );

    if (isMobile) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(right: 16),
        child: child,
      );
    }
    return Expanded(child: child);
  }

  Widget _buildOrderCard(PosOrder order) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final createdAt = order.createdAt ?? DateTime.now();
    final timeAgo = DateTime.now().difference(createdAt).inMinutes;
    final isUrgent = timeAgo > 15;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.tableNo != null
                            ? 'Table ${order.tableNo}'
                            : 'Takeaway',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      Text(
                        '#${order.orderCode?.substring(order.orderCode!.length - 4) ?? "N/A"}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      if (order.status == 'Scheduled' &&
                          order.scheduledTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'HH:mm',
                                ).format(order.scheduledTime!.toLocal()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUrgent)
                  const Icon(Icons.priority_high, color: Colors.red, size: 18),
                Text(
                  '${timeAgo}m',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUrgent ? Colors.red : Colors.grey[400],
                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            itemCount: (order.items ?? []).length,
            itemBuilder: (context, idx) {
              final item = order.items![idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.productName ?? "N/A",
                        style: TextStyle(fontSize: isMobile ? 13 : 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              0,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.print_outlined, size: isMobile ? 20 : 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 36 : 48,
                      minHeight: isMobile ? 36 : 48,
                    ),
                    onPressed: () {
                      PrinterService().printKOT(
                        order,
                        station: widget.station,
                        items: order.items ?? [],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton(order, isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(PosOrder order, bool isMobile) {
    String nextStatus = '';
    String label = '';
    Color color = Colors.blue;

    switch (order.status) {
      case 'Scheduled':
        nextStatus = 'Pending';
        label = 'Accept';
        color = Colors.blue;
        break;
      case 'Pending':
        nextStatus = 'In Progress';
        label = 'Start';
        color = const Color(0xFF0F172A);
        break;
      case 'In Progress':
        nextStatus = 'Mark Ready';
        label = 'Ready';
        color = Colors.orange;
        break;
      case 'Ready':
        nextStatus = 'Completed';
        label = 'Complete';
        color = const Color(0xFF10B981);
        break;
    }

    if (nextStatus.isEmpty) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () => _updateStatus(order, nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, isMobile ? 40 : 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
    );
  }

  Future<void> _updateStatus(PosOrder order, String status) async {
    try {
      await client.orders.updateStatus(order.id!, status);
      _loadOrdersQuietly();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
