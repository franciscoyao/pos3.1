import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';

class CheckoutHistoryView extends StatefulWidget {
  const CheckoutHistoryView({super.key});

  @override
  State<CheckoutHistoryView> createState() => _CheckoutHistoryViewState();
}

class _CheckoutHistoryViewState extends State<CheckoutHistoryView> {
  List<Bill> bills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading checkout history: $e')),
        );
      }
    }
  }

  Future<void> _showBillDetails(Bill bill) async {
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
                  'Receipt #${detailedBill.billNumber.substring(detailedBill.billNumber.length - 6)}',
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bills.isEmpty
                ? _buildEmptyState()
                : _buildHistoryTable(),
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
          'Checkout History',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete log of all processed payments',
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
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No transaction history available',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable() {
    final dateFormat = DateFormat('MMM dd, yyyy');
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
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Bill ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Waiter',
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
              label: Text('NIF', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                'Amount',
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.createdAt != null
                                ? dateFormat.format(bill.createdAt!)
                                : 'N/A',
                          ),
                          Text(
                            bill.createdAt != null
                                ? timeFormat.format(bill.createdAt!)
                                : '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        '#${bill.billNumber.substring(bill.billNumber.length - 6)}',
                      ),
                    ),
                    DataCell(Text(bill.waiterName ?? 'System')),
                    DataCell(
                      _buildPaymentBadge(bill.paymentMethod ?? 'Unknown'),
                    ),
                    DataCell(
                      Text(
                        bill.taxNumber ?? '-',
                        style: TextStyle(
                          color: bill.taxNumber != null
                              ? Colors.black
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '€${bill.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        onPressed: () => _showBillDetails(bill),
                        icon: const Icon(Icons.receipt_outlined, size: 20),
                        tooltip: 'View Receipt',
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    switch (method.toLowerCase()) {
      case 'cash':
        color = Colors.green;
        break;
      case 'card':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
