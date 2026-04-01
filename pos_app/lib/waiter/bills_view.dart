import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';

class BillsView extends StatefulWidget {
  const BillsView({super.key});

  @override
  State<BillsView> createState() => _BillsViewState();
}

class _BillsViewState extends State<BillsView> {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bills: $e')));
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bills.isEmpty
                ? _buildEmptyState()
                : _buildBillsTable(),
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
                        '\$${bill.total.toStringAsFixed(2)}',
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
    );
  }

  void _printBill(Bill bill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reprinting bill #${bill.billNumber}...')),
    );
  }

  void _viewBill(Bill bill) {
    // Show a dialog with the full bill breakdown
  }
}
