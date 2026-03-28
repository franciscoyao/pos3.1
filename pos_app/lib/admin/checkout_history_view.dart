import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';

class CheckoutHistoryView extends StatefulWidget {
  const CheckoutHistoryView({super.key});

  @override
  State<CheckoutHistoryView> createState() => _CheckoutHistoryViewState();
}

class _CheckoutHistoryViewState extends State<CheckoutHistoryView> {
  final ApiService apiService = ApiService();
  List<Bill> bills = [];
  bool isLoading = true;

  String searchQuery = '';
  String paymentFilter = 'All Payments';
  String typeFilter = 'All Types';

  StreamSubscription? _checkoutSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkoutSub = SocketService().onCheckoutCompleted.listen((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _checkoutSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final fetchedBills = await apiService.fetchBills();
      if (mounted) {
        setState(() {
          bills = fetchedBills;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bills: $e')),
        );
      }
    }
  }

  void _showBillDetails(Bill bill) async {
    // Show loading dialog if we want to fetch details, but let's just show it outright
    // and fetch the detailed items asynchronously inside the dialog or before opening it.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final detailedBill = await apiService.fetchBillDetails(bill.id);
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => _BillDetailsDialog(bill: detailedBill),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bill details: $e')),
      );
    }
  }

  double get totalRevenue {
    return bills.fold(0, (sum, bill) => sum + bill.total);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredBills = bills.where((b) {
      final matchesSearch = b.billNumber.toLowerCase().contains(searchQuery.toLowerCase()) || 
                            (b.tableNo?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                            (b.waiterName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                            (b.taxNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
                            
      final matchesPayment = paymentFilter == 'All Payments' || b.paymentMethod == paymentFilter;
      final matchesType = typeFilter == 'All Types' || b.orderType == typeFilter;
      
      return matchesSearch && matchesPayment && matchesType;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Checkout History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('View and reprint past orders', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Revenue', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                    Text('\$${totalRevenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      hintText: 'Search by order, table, waiter, or tax number...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDropdown(
                    value: paymentFilter,
                    items: ['All Payments', 'card', 'cash'],
                    onChanged: (val) => setState(() => paymentFilter = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDropdown(
                    value: typeFilter,
                    items: ['All Types', 'dine-in', 'takeaway'],
                    onChanged: (val) => setState(() => typeFilter = val!),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Bills (${filteredBills.length})', style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A))),
                  ),
                  
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _headerText('Order #')),
                        Expanded(flex: 3, child: _headerText('Date & Time')),
                        Expanded(flex: 2, child: _headerText('Type')),
                        Expanded(flex: 1, child: _headerText('Table')),
                        Expanded(flex: 2, child: _headerText('Waiter')),
                        Expanded(flex: 2, child: _headerText('Payment')),
                        Expanded(flex: 2, child: _headerText('Tax #')),
                        Expanded(flex: 1, child: _headerText('Total')),
                        SizedBox(width: 80, child: _headerText('Actions', align: TextAlign.right)),
                      ],
                    ),
                  ),
                  
                  // Table Body
                  Expanded(
                    child: filteredBills.isEmpty
                        ? const Center(child: Text('No order history found', style: TextStyle(color: Color(0xFF94A3B8))))
                        : ListView.separated(
                            itemCount: filteredBills.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            itemBuilder: (context, index) {
                              final b = filteredBills[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(b.billNumber, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
                                    Expanded(flex: 3, child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 8),
                                        Text(DateFormat('MM/dd/yyyy hh:mm:ss a').format(b.createdAt), style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                                      ],
                                    )),
                                    Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _typePill(b.orderType ?? 'unknown'))),
                                    Expanded(flex: 1, child: Text(b.tableNo ?? '-', style: const TextStyle(color: Color(0xFF475569)))),
                                    Expanded(flex: 2, child: Text(b.waiterName ?? 'Unknown', style: const TextStyle(color: Color(0xFF475569)))),
                                    Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _paymentPill(b.paymentMethod ?? 'unknown'))),
                                    Expanded(flex: 2, child: Text(b.taxNumber ?? '-', style: const TextStyle(color: Color(0xFF475569)))),
                                    Expanded(flex: 1, child: Text('\$${b.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () => _showBillDetails(b),
                                            child: const Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 16),
                                          InkWell(
                                            onTap: () {}, // Implement Print
                                            child: const Icon(Icons.print_outlined, size: 20, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
          items: items.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Color(0xFF64748B)))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _typePill(String type) {
    bool isDineIn = type.toLowerCase() == 'dine-in';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDineIn ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDineIn ? Colors.white : const Color(0xFF0F172A)),
      ),
    );
  }

  Widget _paymentPill(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        method,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
      ),
    );
  }
}

class _BillDetailsDialog extends StatelessWidget {
  final Bill bill;

  const _BillDetailsDialog({required this.bill});

  @override
  Widget build(BuildContext context) {
    final formatDateTime = DateFormat('MM/dd/yyyy, hh:mm:ss a').format(bill.createdAt);

    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 24, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bill Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            // Meta Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaBlock('Order Number', bill.billNumber),
                      _buildMetaBlock('Type', '', child: _typePill(bill.orderType ?? 'unknown')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaBlock('Table', bill.tableNo ?? '-'),
                      _buildMetaBlock('Waiter', bill.waiterName ?? 'Unknown'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaBlock('Date & Time', formatDateTime),
                      _buildMetaBlock('Payment Method', '', child: _paymentPill(bill.paymentMethod ?? 'unknown')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaBlock('Tax Number', bill.taxNumber ?? '-'),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Divider(color: Color(0xFFE2E8F0)),
            ),

            // Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items:', style: TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  if (bill.items == null || bill.items!.isEmpty)
                    const Text('No item details available', style: TextStyle(color: Color(0xFF94A3B8)))
                  else
                    ...bill.items!.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.quantity}x ${item.name}', style: const TextStyle(color: Color(0xFF475569)))),
                          Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0F172A))),
                        ],
                      ),
                    )),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Divider(color: Color(0xFFE2E8F0)),
            ),

            // Totals Breakdowns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal:', bill.subtotal),
                  const SizedBox(height: 8),
                  _buildTotalRow('Tax (10%):', bill.taxAmount),
                  const SizedBox(height: 8),
                  _buildTotalRow('Service (5%):', bill.serviceAmount),
                  const SizedBox(height: 8),
                  _buildTotalRow('Tip:', bill.tipAmount),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 16, color: Color(0xFF0F172A))),
                  Text('\$${bill.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
            ),

            // Reprint Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined),
                label: const Text('Reprint Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildMetaBlock(String label, String value, {Widget? child}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          child ?? Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF475569))),
        Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _typePill(String type) {
    bool isDineIn = type.toLowerCase() == 'dine-in';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDineIn ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDineIn ? Colors.white : const Color(0xFF0F172A)),
      ),
    );
  }

  Widget _paymentPill(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        method,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
      ),
    );
  }
}
