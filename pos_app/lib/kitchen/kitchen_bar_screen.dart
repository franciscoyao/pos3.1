import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../login_screen.dart';
import '../admin/printer_management_view.dart';
import '../admin/settings_view.dart';
import '../waiter/order_history_view.dart';
import '../shared/printer_service.dart';

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
        statusFilter: 'Pending,In Progress,Ready',
        stationFilter: widget.station,
      );
      if (mounted) {
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant, size: 24, color: Color(0xFF0F172A)),
          const SizedBox(width: 12),
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
            '${widget.station} Display',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const Spacer(),
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
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout, size: 18, color: Color(0xFF0F172A)),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    final activeCount = allOrders.length;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.station == 'Kitchen' ? Icons.restaurant : Icons.local_bar,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.station} Orders',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '$activeCount active orders',
                style: TextStyle(color: Colors.grey[500]),
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
                builder: (_) => Dialog(
                  child: SizedBox(
                    width: 1000,
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
                builder: (_) => const Dialog(
                  child: SizedBox(
                    width: 800,
                    height: 600,
                    child: PrinterManagementView(),
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
                builder: (_) => const Dialog(
                  child: SizedBox(
                    width: 800,
                    height: 600,
                    child: SettingsView(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn('Pending', 'Pending'),
          const SizedBox(width: 24),
          _buildKanbanColumn('In Progress', 'In Progress'),
          const SizedBox(width: 24),
          _buildKanbanColumn('Ready', 'Ready'),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, String status) {
    final orders = allOrders.where((o) => o.status == status).toList();
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(PosOrder order) {
    final createdAt = order.createdAt ?? DateTime.now();
    final timeAgo = DateTime.now().difference(createdAt).inMinutes;
    final isUrgent = timeAgo > 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.tableNo != null
                          ? 'Table ${order.tableNo}'
                          : 'Takeaway',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '#${order.orderCode?.substring(order.orderCode!.length - 4) ?? "N/A"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (isUrgent)
                  const Icon(Icons.priority_high, color: Colors.red, size: 20),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: (order.items ?? []).length,
            itemBuilder: (context, idx) {
              final item = order.items![idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.productName ?? "N/A",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.print_outlined),
                  onPressed: () {
                    PrinterService().printKOT(
                      order,
                      station: widget.station,
                      items: order.items ?? [],
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton(order)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(PosOrder order) {
    String nextStatus = '';
    String label = '';
    Color color = Colors.blue;

    switch (order.status) {
      case 'Pending':
        nextStatus = 'In Progress';
        label = 'Start';
        color = const Color(0xFF0F172A);
        break;
      case 'In Progress':
        nextStatus = 'Ready';
        label = 'Mark Ready';
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
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
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
