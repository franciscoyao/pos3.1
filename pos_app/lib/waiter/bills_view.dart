import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../shared/responsive_layout.dart';

class BillsView extends StatefulWidget {
  const BillsView({super.key});

  @override
  State<BillsView> createState() => _BillsViewState();
}

class _BillsViewState extends State<BillsView> {
  List<Bill> bills = [];
  bool isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadBills();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'checkout_completed') {
        _loadBillsQuietly();
      }
    });
  }

  Future<void> _loadBillsQuietly() async {
    try {
      final fetched = await client.checkout.getAll();
      if (mounted) {
        setState(() {
          bills = fetched;
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);
    try {
      final fetched = await client.checkout.getAll();
      if (mounted) {
        setState(() {
          bills = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bills: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: isMobile ? 16 : 32),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bills.isEmpty
                ? _buildEmptyState()
                : (isMobile ? _buildBillsMobileList() : _buildBillsTable()),
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
          'Bills',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage and reprint completed order receipts',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No bills found for today',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsMobileList() {
    final timeFormat = DateFormat('hh:mm a');
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${bill.billNumber.substring(bill.billNumber.length - 4)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Table: ${bill.tableNo ?? 'Takeaway'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      bill.createdAt != null ? timeFormat.format(bill.createdAt!) : 'N/A',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${bill.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bill.paymentMethod ?? 'N/A',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _viewBill(bill),
                icon: const Icon(Icons.receipt_outlined, size: 20, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillsTable() {
    final timeFormat = DateFormat('hh:mm a');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(
              label: Text(
                'Bill ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Table',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: bills
              .map(
                (bill) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '#${bill.billNumber.substring(bill.billNumber.length - 4)}',
                      ),
                    ),
                    DataCell(Text(bill.tableNo ?? 'Takeaway')),
                    DataCell(Text(bill.paymentMethod ?? 'N/A')),
                    DataCell(
                      Text(
                        bill.createdAt != null
                            ? timeFormat.format(bill.createdAt!)
                            : 'N/A',
                      ),
                    ),
                    DataCell(
                      Text(
                        '€${bill.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _printBill(bill),
                            icon: const Icon(
                              Icons.print_outlined,
                              size: 20,
                              color: Colors.blue,
                            ),
                            tooltip: 'Reprint',
                          ),
                          IconButton(
                            onPressed: () => _viewBill(bill),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                            tooltip: 'View',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        ),
      ),
    );
  }

  void _printBill(Bill bill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reprinting bill #${bill.billNumber}...')),
    );
  }

  void _viewBill(Bill bill) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<BillWithItems>(
        future: client.checkout.getDetails(bill.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(snapshot.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          final detailedBill = snapshot.data!.bill;
          final billItems = snapshot.data!.items;
          final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Bill #${detailedBill.billNumber.substring(detailedBill.billNumber.length - 4)}',
                ),
              ],
            ),
            content: SizedBox(
              width: ResponsiveLayout.isMobile(context) ? null : 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${detailedBill.createdAt != null ? dateFormat.format(detailedBill.createdAt!) : 'N/A'}',
                    ),
                    Text('Waiter: ${detailedBill.waiterName ?? 'System'}'),
                    Text('Table: ${detailedBill.tableNo ?? 'Takeaway'}'),
                    Text('Payment Method: ${detailedBill.paymentMethod}'),
                    if (detailedBill.taxNumber != null)
                      Text(
                        'NIF: ${detailedBill.taxNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const Divider(height: 32),
                    const Text(
                      'Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (billItems.isNotEmpty)
                      ...billItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.productName ?? 'Unknown'}',
                                ),
                              ),
                              Text('€${item.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(
                        'No item details available',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('€${detailedBill.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (detailedBill.taxAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax:'),
                          Text('€${detailedBill.taxAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '€${detailedBill.total.toStringAsFixed(2)}',
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}
