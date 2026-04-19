import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../shared/printer_service.dart';
import '../shared/responsive_layout.dart';

class CheckoutView extends StatefulWidget {
  final String? tableNo;
  const CheckoutView({super.key, this.tableNo});

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
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  // Split logic state
  int splitPeopleCount = 2;
  int peoplePayingNow = 1;
  double splitPercentage = 50.0;
  List<int> selectedItemIds = [];
  Map<int, int> itemQuantitiesToPay = {};
  List<double> customShares = [0.0];
  StreamSubscription? _eventSubscription;

  double get amountToPay {
    if (selectedOrder == null) return 0.0;
    final total = selectedOrder!.total;

    switch (splitMode) {
      case 'Part':
        return customShares.fold(0.0, (sum, val) => sum + val);
      case 'Seat':
        return (total / splitPeopleCount) * peoplePayingNow;
      case 'Item':
        return selectedOrder!.items?.fold(0.0, (sum, item) {
              final qty = itemQuantitiesToPay[item.id] ?? 0;
              final priceEach =
                  item.totalPrice / (item.quantity > 0 ? item.quantity : 1);
              return sum! + (qty * priceEach);
            }) ??
            0.0;
      case '%':
        return total * (splitPercentage / 100);
      case 'None':
      default:
        return total;
    }
  }

  @override
  void initState() {
    super.initState();
    filterTableNo = widget.tableNo;
    _loadActiveOrders();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _taxNumberController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'order_updated' ||
          event.eventType == 'checkout_completed') {
        _loadActiveOrdersQuietly();
      }
    });
  }

  Future<void> _loadActiveOrdersQuietly() async {
    try {
      final fetched = await client.orders.getAll(
        includeItems: true,
        statusFilter: 'Pending,In Progress',
      );
      if (mounted) {
        setState(() {
          activeOrders = fetched;

          // If we had a selected order, try to update it
          if (selectedOrder != null) {
            final updated = activeOrders
                .where((o) => o.id == selectedOrder!.id)
                .toList();
            if (updated.isNotEmpty) {
              selectedOrder = updated.first;
            } else {
              // Order is gone (e.g. fully paid)
              selectedOrder = null;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading active orders: $e');
    }
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
              if (selectedOrder?.taxNumber != null) {
                _taxNumberController.text = selectedOrder!.taxNumber!;
              }
              if (selectedOrder?.remainingSplitCount != null) {
                splitPeopleCount = selectedOrder!.remainingSplitCount!;
                if (splitPeopleCount > 0) {
                  splitMode = 'Part';
                }
              }
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
    final isMobile = ResponsiveLayout.isMobile(context);

    final summaryCard = Container(
      width: isMobile ? double.infinity : 400,
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
          Container(
            constraints: BoxConstraints(maxHeight: isMobile ? 200 : 400),
            child: ListView.separated(
              shrinkWrap: true,
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
                      '€${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 32),
          const SizedBox(height: 8),
          if (splitMode != 'None') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Total:'),
                Text('€${order.total.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                splitMode == 'None' ? 'Total:' : 'Amount to Pay:',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '€${amountToPay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: amountToPay > 0 ? () => _finalizePayment(order) : null,
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
    );

    if (isMobile) {
      return ListView(
        children: [
          _buildSplitBillCard(),
          const SizedBox(height: 24),
          _buildPaymentMethodCard(),
          const SizedBox(height: 32),
          summaryCard,
        ],
      );
    }

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
        summaryCard,
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSplitTab('None'),
                  _buildSplitTab('Part'),
                  _buildSplitTab('Item'),
                  _buildSplitTab('Seat'),
                  _buildSplitTab('%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSplitControls(),
        ],
      ),
    );
  }

  Widget _buildSplitControls() {
    if (selectedOrder == null) return const SizedBox.shrink();

    switch (splitMode) {
      case 'Part':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Shares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter custom amounts for each customer paying now.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...customShares.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0F172A),
                      radius: 14,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.euro, size: 18),
                          hintText: '0.00',
                          labelText: 'Customer ${index + 1} Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          setState(() => customShares[index] = parsed);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (customShares.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() => customShares.removeAt(index));
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => customShares.add(0.0));
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Another Customer'),
                ),
                TextButton.icon(
                  onPressed: () {
                    final remaining =
                        selectedOrder!.total -
                        customShares.fold(0.0, (sum, val) => sum + val);
                    if (remaining > 0.01) {
                      setState(() => customShares.add(remaining));
                    }
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Pay Remaining Balance'),
                ),
              ],
            ),
            const Divider(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total for these customers:'),
                  Text(
                    '€${amountToPay.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 'Seat':
        final label = splitMode == 'Part'
            ? 'Total People / Shares'
            : 'Total Seats';

        final isContinuous = selectedOrder!.remainingSplitCount != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isContinuous)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This order has ${selectedOrder!.remainingSplitCount} people remaining to pay.',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCounterBtn(Icons.remove, () {
                  if (splitPeopleCount > 1) {
                    setState(() {
                      splitPeopleCount--;
                      if (peoplePayingNow > splitPeopleCount) {
                        peoplePayingNow = splitPeopleCount;
                      }
                    });
                  }
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '$splitPeopleCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCounterBtn(Icons.add, () {
                  setState(() => splitPeopleCount++);
                }),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'How many are paying now?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCounterBtn(Icons.remove, () {
                  if (peoplePayingNow > 1) {
                    setState(() => peoplePayingNow--);
                  }
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '$peoplePayingNow',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCounterBtn(Icons.add, () {
                  if (peoplePayingNow < splitPeopleCount) {
                    setState(() => peoplePayingNow++);
                  }
                }),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total to pay for these people:'),
                  Text(
                    '€${amountToPay.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 'Custom':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount to Pay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customAmountController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.euro),
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _customAmountController.clear();
                    setState(() {});
                  },
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              'Maximum available: €${selectedOrder!.total.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        );
      case 'Item':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Items to Pay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: selectedOrder!.items?.length ?? 0,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = selectedOrder!.items![index];
                  final selectedQty = itemQuantitiesToPay[item.id] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '€${(item.totalPrice / (item.quantity > 0 ? item.quantity : 1)).toStringAsFixed(2)} each (Total: ${item.quantity})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildCounterBtn(Icons.remove, () {
                              if (selectedQty > 0) {
                                setState(
                                  () => itemQuantitiesToPay[item.id!] =
                                      selectedQty - 1,
                                );
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '$selectedQty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildCounterBtn(Icons.add, () {
                              if (selectedQty < item.quantity) {
                                setState(
                                  () => itemQuantitiesToPay[item.id!] =
                                      selectedQty + 1,
                                );
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case '%':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Percentage to Pay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${splitPercentage.round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: splitPercentage,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: const Color(0xFF0F172A),
              onChanged: (val) => setState(() => splitPercentage = val),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount to pay:'),
                  Text(
                    '€${(selectedOrder!.total * splitPercentage / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Text(
          'Full payment - no split',
          style: TextStyle(color: Colors.grey[600]),
        );
    }
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24),
      ),
    );
  }

  Widget _buildSplitTab(String mode) {
    final isSelected = splitMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: () => setState(() => splitMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            const SizedBox(height: 32),
            const Text(
              'Tax Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taxNumberController,
              decoration: InputDecoration(
                labelText: 'Tax Identification Number (NIF)',
                hintText: 'Enter tax number (optional)',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0F172A)),
                ),
              ),
              keyboardType: TextInputType.number,
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
              // ignore: deprecated_member_use
              groupValue: paymentMethod,
              // ignore: deprecated_member_use
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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
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
                onPressed: () {
                  setState(() {
                    selectedOrder = null;
                    _taxNumberController.clear();
                    _customAmountController.clear();
                  });
                },
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
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 0.8,
        crossAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
        mainAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
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
            '€${order.total.toStringAsFixed(2)}',
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
            onPressed: () {
              setState(() {
                selectedOrder = order;
                if (order.taxNumber != null) {
                  _taxNumberController.text = order.taxNumber!;
                } else {
                  _taxNumberController.clear();
                }
                if (order.remainingSplitCount != null) {
                  splitPeopleCount = order.remainingSplitCount!;
                  splitMode = 'Part';
                } else {
                  splitPeopleCount = 2; // default
                }
              });
            },
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
      final subtotal = amountToPay;
      final currentSplitMode = splitMode;

      List<CheckoutItem>? itemsToPay;
      if (currentSplitMode == 'Item') {
        itemsToPay = itemQuantitiesToPay.entries
            .where((e) => e.value > 0)
            .map((e) => CheckoutItem(id: e.key, quantity: e.value))
            .toList();
      }

      int? initialSplitCount;
      int? remainingSplitCount;

      if (currentSplitMode == 'Part' || currentSplitMode == 'Seat') {
        // If it's the first split, set initialSplitCount
        initialSplitCount = order.initialSplitCount ?? splitPeopleCount;
        // Remaining is current total minus people paying now
        remainingSplitCount = splitPeopleCount - peoplePayingNow;
      }

      final bill = await client.checkout.checkout(
        order.id!,
        paymentMethod,
        subtotal: subtotal,
        total: subtotal,
        taxNumber: _taxNumberController.text.isNotEmpty
            ? _taxNumberController.text
            : null,
        initialSplitCount: initialSplitCount,
        remainingSplitCount: remainingSplitCount,
        itemsToPay: itemsToPay,
      );

      // Print receipt automatically after successful checkout
      await PrinterService().printReceipt(bill, items: order.items ?? []);

      if (mounted) {
        setState(() {
          selectedOrder = null;
          splitMode = 'None';
          selectedItemIds.clear();
          itemQuantitiesToPay.clear();
          _taxNumberController.clear();
          customShares = [0.0];
        });
        _loadActiveOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentSplitMode == 'None'
                  ? 'Payment completed successfully!'
                  : 'Split payment of €${subtotal.toStringAsFixed(2)} completed!',
            ),
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
