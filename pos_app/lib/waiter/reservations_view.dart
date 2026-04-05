import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../shared/responsive_layout.dart';

class ReservationsView extends StatefulWidget {
  const ReservationsView({super.key});

  @override
  State<ReservationsView> createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<ReservationsView> {
  List<Reservation> reservations = [];
  bool isLoading = true;
  DateTime _selectedDate = DateTime.now();
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
      if (event.eventType == 'reservation_updated') {
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
      final fetchedReservations = await client.reservations.getAll();
      
      if (mounted) {
        setState(() {
          reservations = fetchedReservations;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reservations: $e'))
        );
      }
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    // Filter reservations by selected date
    final filteredReservations = reservations.where((r) {
      return DateUtils.isSameDay(r.reservationTime, _selectedDate);
    }).toList();

    // Sort by time
    filteredReservations.sort((a, b) => a.reservationTime.compareTo(b.reservationTime));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(filteredReservations.length),
            const SizedBox(height: 32),
            _buildDateSelector(),
            const SizedBox(height: 32),
            if (filteredReservations.isEmpty)
              _buildEmptyState()
            else
              _buildReservationsGrid(filteredReservations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reservations',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count bookings on this date',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showReservationDialog(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New Reservation',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEEE').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 12),
          if (!isToday)
            TextButton(
               onPressed: () {
                 setState(() {
                   _selectedDate = DateTime.now();
                 });
               },
               child: const Text('Go to Today')
            )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No reservations for this date',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsGrid(List<Reservation> dailyRes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 1.3,
        crossAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
        mainAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
      ),
      itemCount: dailyRes.length,
      itemBuilder: (context, index) {
        return _buildReservationCard(dailyRes[index]);
      },
    );
  }

  Widget _buildReservationCard(Reservation res) {
    final timeFormat = DateFormat('hh:mm a');
    final isPast = res.reservationTime.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
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
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 20, color: isPast ? Colors.red[400] : Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(res.reservationTime),
                    style: TextStyle(
                      color: isPast ? Colors.red[700] : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
          if (res.customerPhone != null && res.customerPhone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                res.customerPhone!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                     const Icon(Icons.table_restaurant, size: 16, color: Colors.black87),
                     const SizedBox(width: 6),
                     Text(
                        'Table ${res.tableNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                 decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      '${res.guestCount} Pax',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
               if (res.status == 'Pending' || res.status == 'Confirmed')
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () => _updateReservationStatus(res, 'Arrived'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.purple,
                       foregroundColor: Colors.white,
                       elevation: 0,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       )
                     ),
                     child: const Text('Arrived'),
                   ),
                 )
                else if (res.status == 'Arrived')
                  Expanded(
                    child: ElevatedButton(
                     onPressed: () => _updateReservationStatus(res, 'Completed'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                       elevation: 0,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       )
                     ),
                     child: const Text('Complete'),
                   ),
                  ),
               if (res.status != 'Cancelled' && res.status != 'Completed') ...[
                 const SizedBox(width: 8),
                 Expanded(
                   child: OutlinedButton(
                     onPressed: () => _showReservationDialog(reservation: res),
                     style: OutlinedButton.styleFrom(
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10)
                       )
                     ),
                     child: const Text('Edit'),
                   ),
                 ),
                 const SizedBox(width: 8),
                 IconButton(
                    onPressed: () => _confirmDeleteReservation(res),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                 ),
               ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Confirmed':
        color = Colors.blue;
      case 'Arrived':
        color = Colors.purple;
      case 'Cancelled':
        color = Colors.red;
      case 'Completed':
        color = Colors.green;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _updateReservationStatus(Reservation res, String newStatus) async {
      try {
          if (newStatus == 'Arrived') {
               await client.reservations.markAsArrived(res.id!);
          } else {
             final updated = res.copyWith(
                status: newStatus,
             );
             await client.reservations.update(updated);
          }
           _loadDataQuietly();
      } catch (e) {
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
          }
      }
  }

  Future<void> _showReservationDialog({Reservation? reservation}) async {
    final isEditing = reservation != null;
    final nameController = TextEditingController(text: reservation?.customerName);
    final phoneController = TextEditingController(text: reservation?.customerPhone);
    final tableController = TextEditingController(text: reservation?.tableNumber);
    final emailController = TextEditingController(text: reservation?.email);
    final notesController = TextEditingController(text: reservation?.notes);
    final guestController = TextEditingController(text: reservation?.guestCount.toString() ?? '2');
    DateTime selectedDate = reservation?.reservationTime ?? _selectedDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(reservation?.reservationTime ?? DateTime.now());
    String status = reservation?.status ?? 'Pending';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Reservation' : 'New Reservation'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: ResponsiveLayout.isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Customer Name*', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                       Expanded(
                         child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'Phone (Optional)', border: OutlineInputBorder()),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email (Optional)', border: OutlineInputBorder()),
                         ),
                       )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tableController,
                          decoration: const InputDecoration(labelText: 'Table No*', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: guestController,
                          decoration: const InputDecoration(labelText: 'Guests*', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                     children: [
                        Expanded(
                            child: InkWell(
                                onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setDialogState(() => selectedDate = picked);
                                    }
                                  },
                                child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Date*',
                                        border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                                            const Icon(Icons.calendar_today, size: 20),
                                        ]
                                    ),
                                )
                            )
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: InkWell(
                                onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
                                    if (picked != null) {
                                      setDialogState(() => selectedTime = picked);
                                    }
                                  },
                                child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Time*',
                                        border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text(selectedTime.format(context)),
                                            const Icon(Icons.access_time, size: 20),
                                        ]
                                    ),
                                )
                            )
                        )
                     ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Pending', 'Confirmed', 'Arrived', 'Cancelled', 'Completed']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => status = val!),
                    ),
                  ]
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty || tableController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all required fields')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
              child: Text(isEditing ? 'Save Changes' : 'Create Reservation', style: const TextStyle(color: Colors.white)),
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
        customerName: nameController.text.trim(),
        customerPhone: phoneController.text.trim(),
        email: emailController.text.trim(),
        notes: notesController.text.trim(),
        tableNumber: tableController.text.trim(),
        guestCount: int.tryParse(guestController.text.trim()) ?? 2,
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
        }
      }
    }
  }

  Future<void> _confirmDeleteReservation(Reservation res) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text('Are you sure you want to cancel the reservation for ${res.customerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
         final updated = res.copyWith(status: 'Cancelled');
         await client.reservations.update(updated);
         _loadDataQuietly();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling: $e')));
        }
      }
    }
  }
}
