import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';

class CheckoutView extends StatefulWidget {
  final String? initialTableNo;
  const CheckoutView({super.key, this.initialTableNo});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  List<PosOrder> activeOrders = [];
  bool isLoading = true;
  String? filterTableNo;
  PosOrder? selectedOrder;
  String splitMode = 'None';
  String paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    filterTableNo = widget.initialTableNo;
    _loadActiveOrders();
  }

  Future<void> _loadActiveOrders() async {
    setState(() => isLoading = true);
    try {
      final fetched = await client.orders.getAll(
        includeItems: true,
        statusFilter: 'Pending,In Progress',
      );
      if (mounted) {
        setState(() {
          activeOrders = fetched;
          isLoading = false;
          // If we have a filterTableNo, try to auto-select the order
          if (filterTableNo != null && activeOrders.isNotEmpty) {
            final filtered = activeOrders
                .where((o) => o.tableNo == filterTableNo)
                .toList();
            if (filtered.isNotEmpty) {
              selectedOrder = filtered.first;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading active orders: $e')),
        );
      }
    }
  }

  List<PosOrder> get filteredOrders {
    if (filterTableNo == null || filterTableNo!.isEmpty) return activeOrders;
    return activeOrders.where((o) => o.tableNo == filterTableNo).toList();
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
                : (selectedOrder != null
                      ? _buildDetailedCheckout()
                      : (filteredOrders.isEmpty
                            ? _buildEmptyState()
                            : _buildOrdersGrid())),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCheckout() {
    final order = selectedOrder!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Split Bill and Payment Method
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSplitBillCard(),
                const SizedBox(height: 24),
                _buildPaymentMethodCard(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Right Column: Order Summary
        Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Table ${order.tableNo ?? "N/A"}',
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: (order.items ?? []).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = order.items![index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.quantity}x ${item.productName}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 32),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _finalizePayment(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitBillCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Split Bill',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how to divide the payment',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSplitTab('None'),
                _buildSplitTab('Equal'),
                _buildSplitTab('Item'),
                _buildSplitTab('Seat'),
                _buildSplitTab('%'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            splitMode == 'None'
                ? 'Full payment - no split'
                : 'Splitting by $splitMode...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTab(String mode) {
    final isSelected = splitMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => splitMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              mode,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0F172A) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildPaymentOption('Cash', Icons.money),
          const SizedBox(height: 12),
          _buildPaymentOption('Card', Icons.credit_card),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'Mixed (Cash + Card)',
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    final isSelected = paymentMethod == method;
    return InkWell(
      onTap: () => setState(() => paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: method,
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val!),
              activeColor: const Color(0xFF0F172A),
            ),
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(method, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedOrder != null
                  ? 'Process payment and finalize order'
                  : (filterTableNo != null
                        ? 'Processing Table $filterTableNo'
                        : 'Process payments for active orders'),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            if (selectedOrder != null)
              TextButton.icon(
                onPressed: () => setState(() => selectedOrder = null),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Grid'),
              ),
            if (filterTableNo != null && selectedOrder == null)
              TextButton.icon(
                onPressed: () => setState(() => filterTableNo = null),
                icon: const Icon(Icons.clear_all),
                label: const Text('Show All Orders'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'All caught up! No orders to checkout.',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) =>
          _buildOrderCheckoutCard(filteredOrders[index]),
    );
  }

  Widget _buildOrderCheckoutCard(PosOrder order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Table ${order.tableNo ?? "N/A"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '#${order.orderCode?.substring(order.orderCode!.length - 4) ?? "N/A"}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(order.items ?? []).length} items',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => setState(() => selectedOrder = order),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizePayment(PosOrder order) async {
    try {
      await client.checkout.checkout(
        order.id!,
        paymentMethod,
        subtotal: order.total,
        total: order.total,
      );
      if (mounted) {
        setState(() => selectedOrder = null);
        _loadActiveOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to finalize payment: $e')),
        );
      }
    }
  }
}
