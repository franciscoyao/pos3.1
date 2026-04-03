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
  List<Reservation> reservations = [];
  bool isLoading = true;
  String _selectedTab = 'Tables'; // 'Tables' or 'Reservations'
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
          event.eventType == 'order_updated' ||
          event.eventType == 'reservation_updated') {
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
        statusFilter: 'Pending,In Progress,Scheduled',
      );
      final fetchedReservations = await client.reservations.getAll();

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
          reservations = fetchedReservations;
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
                    Text(
                      _selectedTab == 'Tables' ? 'Tables' : 'Reservations',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedTab == 'Tables'
                          ? '${tables.length} tables • $activeTables active'
                          : '${reservations.length} total reservations',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('Tables', Icons.grid_view_rounded),
                      _buildTabButton('Reservations', Icons.event_note_rounded),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_selectedTab == 'Tables')
              _buildTablesGrid()
            else
              _buildReservationsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF0F172A) : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0F172A) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Reservations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showReservationDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Reservation',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (reservations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reservations found',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              return _buildReservationCard(res);
            },
          ),
      ],
    );
  }

  Widget _buildTablesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildReservationCard(Reservation res) {
    final timeFormat = DateFormat('MMM dd, hh:mm a');
    final isToday =
        res.reservationTime.day == DateTime.now().day &&
        res.reservationTime.month == DateTime.now().month &&
        res.reservationTime.year == DateTime.now().year;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Table ${res.tableNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildStatusBadge(res.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            res.customerName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${res.guestCount} guests',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: isToday ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                timeFormat.format(res.reservationTime),
                style: TextStyle(
                  color: isToday ? Colors.blue : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showReservationDialog(reservation: res),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _confirmDeleteReservation(res),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Confirmed':
        color = Colors.green;
      case 'Cancelled':
        color = Colors.red;
      case 'Completed':
        color = Colors.blue;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showReservationDialog({Reservation? reservation}) async {
    final isEditing = reservation != null;
    final nameController = TextEditingController(
      text: reservation?.customerName,
    );
    final phoneController = TextEditingController(
      text: reservation?.customerPhone,
    );
    final tableController = TextEditingController(
      text: reservation?.tableNumber,
    );
    final guestController = TextEditingController(
      text: reservation?.guestCount.toString() ?? '2',
    );
    DateTime selectedDate = reservation?.reservationTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String status = reservation?.status ?? 'Pending';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Reservation' : 'New Reservation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (Optional)',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tableController,
                        decoration: const InputDecoration(
                          labelText: 'Table No',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: guestController,
                        decoration: const InputDecoration(labelText: 'Guests'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                ),
                if (isEditing)
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Pending', 'Confirmed', 'Cancelled', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => status = val!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Create',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final finalDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final res = Reservation(
        id: reservation?.id,
        customerName: nameController.text,
        customerPhone: phoneController.text,
        tableNumber: tableController.text,
        guestCount: int.tryParse(guestController.text) ?? 2,
        reservationTime: finalDateTime,
        status: status,
        createdAt: reservation?.createdAt ?? DateTime.now(),
      );

      try {
        if (isEditing) {
          await client.reservations.update(res);
        } else {
          await client.reservations.create(res);
        }
        _loadDataQuietly();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving reservation: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteReservation(Reservation res) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text(
          'Are you sure you want to cancel the reservation for ${res.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await client.reservations.delete(res.id!);
        _loadDataQuietly();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cancelling reservation: $e')),
          );
        }
      }
    }
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
    final splitOrder = orders
        .where(
          (o) => o.remainingSplitCount != null && o.remainingSplitCount! > 0,
        )
        .firstOrNull;
    final scheduledOrder = orders
        .where((o) => o.status == 'Scheduled')
        .firstOrNull;

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
                  Row(
                    children: [
                      if (splitOrder != null)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${splitOrder.remainingSplitCount} left',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (scheduledOrder != null)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 10,
                            color: Colors.blue,
                          ),
                        ),
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
              reservations: reservations
                  .where((r) => r.tableNumber == table.tableNumber)
                  .toList(),
              onUpdate: _loadDataQuietly,
              onAddItems: widget.onAddItems,
              onSplit: (t, o) => _showSplitItemsDialog(context, t, o),
              onMerge: (t) => _showMergeTableDialog(context, t),
              onAddReservation: () => _showReservationDialog(
                reservation: Reservation(
                  tableNumber: table.tableNumber,
                  customerName: '',
                  reservationTime: DateTime.now().add(const Duration(hours: 1)),
                  guestCount: 2,
                  createdAt: DateTime.now(),
                ),
              ),
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
  final List<Reservation> reservations;
  final VoidCallback onUpdate;
  final Function(String)? onAddItems;
  final Function(RestaurantTable, List<PosOrder>) onSplit;
  final Function(RestaurantTable) onMerge;
  final VoidCallback onAddReservation;
  final VoidCallback onCheckout;

  const _TableDetailsSidebar({
    required this.table,
    required this.orders,
    required this.reservations,
    required this.onUpdate,
    this.onAddItems,
    required this.onSplit,
    required this.onMerge,
    required this.onAddReservation,
    required this.onCheckout,
  });

  Future<void> _updateNif(BuildContext context, String nif) async {
    if (orders.isEmpty) return;
    try {
      // Update all orders for this table with the same NIF
      for (final order in orders) {
        await client.orders.update(order.copyWith(taxNumber: nif));
      }
      onUpdate();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating NIF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = orders.fold(0.0, (sum, o) => sum + o.total);
    final isActive = orders.isNotEmpty;
    final firstOrderWithNif = orders
        .where((o) => o.taxNumber != null && o.taxNumber!.isNotEmpty)
        .firstOrNull;
    final firstOrderWithSplit = orders
        .where(
          (o) => o.remainingSplitCount != null && o.remainingSplitCount! > 0,
        )
        .firstOrNull;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  if (firstOrderWithSplit != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${firstOrderWithSplit.remainingSplitCount} left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
              if (firstOrderWithNif != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NIF: ${firstOrderWithNif.taxNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'Manage orders and table status',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Reservations'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersTab(context, isActive, firstOrderWithNif, totalAmount),
            _buildReservationsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(
    BuildContext context,
    bool isActive,
    PosOrder? firstOrderWithNif,
    double totalAmount,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive) ...[
            const Text(
              'Order Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'NIF (Tax Number)',
                hintText: 'Enter NIF',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: TextEditingController(
                text: firstOrderWithNif?.taxNumber,
              ),
              onSubmitted: (val) => _updateNif(context, val),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
          ],
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
    );
  }

  Widget _buildReservationsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reservations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onAddReservation,
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: reservations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No upcoming reservations',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final res = reservations[index];
                      final timeFormat = DateFormat('MMM dd, hh:mm a');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  res.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    res.status,
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${res.guestCount} guests',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormat.format(res.reservationTime),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
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
