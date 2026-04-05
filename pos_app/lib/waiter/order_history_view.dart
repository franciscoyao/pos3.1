import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../shared/responsive_layout.dart';

class OrderHistoryView extends StatefulWidget {
  final String? stationFilter;
  const OrderHistoryView({super.key, this.stationFilter});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  List<PosOrder> orders = [];
  bool isLoading = true;
  String selectedFilter = 'All';
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'order_created' ||
          event.eventType == 'order_updated' ||
          event.eventType == 'checkout_completed') {
        _loadOrdersQuietly();
      }
    });
  }

  Future<void> _loadOrdersQuietly() async {
    try {
      String? statusFilter;
      if (selectedFilter != 'All' && selectedFilter != 'Kiosk') {
        statusFilter = selectedFilter;
      }
      final fetchedOrders = await client.orders.getAll(
        includeItems: true,
        statusFilter: statusFilter,
        stationFilter: widget.stationFilter,
      );
      if (mounted) {
        setState(() {
          if (selectedFilter == 'Kiosk') {
            orders = fetchedOrders.where((o) => o.waiterName == 'Kiosk').toList();
          } else {
            orders = fetchedOrders;
          }
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    try {
      String? statusFilter;
      if (selectedFilter != 'All' && selectedFilter != 'Kiosk') {
        statusFilter = selectedFilter;
      }
      final fetchedOrders = await client.orders.getAll(
        includeItems: true,
        statusFilter: statusFilter,
        stationFilter: widget.stationFilter,
      );
      if (mounted) {
        setState(() {
          if (selectedFilter == 'Kiosk') {
            orders = fetchedOrders
                .where((o) => o.waiterName == 'Kiosk')
                .toList();
          } else {
            orders = fetchedOrders;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order History',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review past and current orders',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final filters = [
      'All',
      'Scheduled',
      'Pending',
      'In Progress',
      'Ready',
      'Completed',
      'Cancelled',
      'Kiosk',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selectedFilter == f,
                  onSelected: (val) {
                    if (val) {
                      setState(() => selectedFilter = f);
                      _loadOrders();
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF0F172A),
                  labelStyle: TextStyle(
                    color: selectedFilter == f
                        ? Colors.white
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(PosOrder order) {
    final timeFormat = DateFormat('hh:mm a, MMM dd');
    final statusColor = _getStatusColor(order.status);
    final isMobile = ResponsiveLayout.isMobile(context);

    final leftInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Order #${order.orderCode?.substring(order.orderCode!.length - 4) ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusBadge(order.status, statusColor),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          order.createdAt != null
              ? 'Placed: ${timeFormat.format(order.createdAt!)}'
              : 'N/A',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        if (order.status == 'Scheduled' && order.scheduledTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scheduled: ${timeFormat.format(order.scheduledTime!.toLocal())}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Waiter: ${order.waiterName ?? 'System'} • ${order.orderType ?? 'Dine-In'} ${order.tableNo != null ? ' (Table ${order.tableNo})' : ''}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );

    final middleItems = Text(
      (order.items ?? [])
          .map((i) => '${i.quantity}x ${i.productName}')
          .join(', '),
      style: TextStyle(color: Colors.grey[600], fontSize: 14),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final rightTotal = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          '€${order.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _showOrderDetails(order),
          child: const Text('View Details'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfo,
                const Divider(height: 24),
                middleItems,
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    rightTotal,
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 2, child: leftInfo),
                Expanded(flex: 3, child: middleItems),
                Expanded(flex: 1, child: rightTotal),
              ],
            ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'ready':
        return const Color(0xFF10B981);
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(PosOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Order Details #${order.orderCode?.substring(order.orderCode!.length - 4)}',
        ),
        content: SizedBox(
          width: ResponsiveLayout.isMobile(context) ? null : 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...(order.items ?? []).map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.productName ?? 'Unknown')),
                      Text('€${item.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '€${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
