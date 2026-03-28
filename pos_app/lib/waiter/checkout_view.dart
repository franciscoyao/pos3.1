import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/printer_service.dart';
import '../shared/socket_service.dart';

class CheckoutView extends StatefulWidget {
  final User user;

  const CheckoutView({super.key, required this.user});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final ApiService _api = ApiService();
  List<Order> _openOrders = [];
  bool _isLoading = true;

  StreamSubscription? _orderUpdatedSub;
  StreamSubscription? _orderCreatedSub;
  StreamSubscription? _checkoutSub;

  @override
  void initState() {
    super.initState();
    _loadOrders();

    final socketService = SocketService();
    _orderUpdatedSub = socketService.onOrderUpdated.listen((_) {
      if (mounted) _loadOrders();
    });
    _orderCreatedSub = socketService.onOrderCreated.listen((_) {
      if (mounted) _loadOrders();
    });
    _checkoutSub = socketService.onCheckoutCompleted.listen((_) {
      if (mounted) _loadOrders();
    });
  }

  @override
  void dispose() {
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();
    _checkoutSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _api.fetchOrders();
      setState(() {
        _openOrders = orders.where((o) => o.status != 'Completed').toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openCheckoutSheet(Order order) async {
    Order? fullOrder;
    try { fullOrder = await _api.fetchOrderDetails(order.id); } catch (_) { fullOrder = order; }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CheckoutSheet(
        order: fullOrder!,
        waiterName: widget.user.fullName ?? widget.user.username,
        onConfirm: (method) async {
          final bill = await _api.checkout(order.id, method, waiterName: widget.user.fullName ?? widget.user.username);
          if (!mounted) return;
          Navigator.pop(context);
          if (bill != null) {
            // Attempt Bluetooth receipt print (silently fails if no printer)
            try { await PrinterService().printReceipt(bill); } catch (_) {}
            _showBillSummary(bill);
            _loadOrders();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout failed.'), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  void _showBillSummary(Bill bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
          const SizedBox(height: 8),
          const Text('Payment Successful', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _row('Bill Number', bill.billNumber),
          if (bill.tableNo != null) _row('Table', bill.tableNo!),
          _row('Payment', bill.paymentMethod ?? '-'),
          const Divider(),
          _row('Total', '\$${bill.total.toStringAsFixed(2)}', bold: true),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF64748B))),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    ]),
  );

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed': return const Color(0xFF10B981);
      case 'In Progress': return const Color(0xFF3B82F6);
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(children: [
              const Text('Checkout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                child: Text('${_openOrders.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Open orders ready for payment', style: TextStyle(color: Color(0xFF64748B))),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _openOrders.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No open orders to checkout.', style: TextStyle(color: Color(0xFF94A3B8))),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _openOrders.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final order = _openOrders[i];
                          return InkWell(
                            onTap: () => _openCheckoutSheet(order),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.receipt_long, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(order.orderCode ?? '#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      if (order.tableNo != null) ...[
                                        const Icon(Icons.table_chart_outlined, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(order.tableNo!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        const SizedBox(width: 12),
                                      ],
                                      const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTime(order.createdAt),
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                      ),
                                    ]),
                                  ]),
                                ),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(order.status, style: TextStyle(color: _statusColor(order.status), fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ]),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _PartialPayment {
  final String method;
  final double amount;
  _PartialPayment(this.method, this.amount);
}

// ── Checkout Sheet ──────────────────────────────────────────────

class _CheckoutSheet extends StatefulWidget {
  final Order order;
  final String waiterName;
  final void Function(String method) onConfirm;

  const _CheckoutSheet({required this.order, required this.waiterName, required this.onConfirm});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  String _paymentMethod = 'Cash';
  bool _isSplitMode = false;
  final List<_PartialPayment> _partialPayments = [];
  late TextEditingController _amountCtrl;
  final Set<int> _selectedItemIndices = {};

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.order.total.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _paidAmount => _partialPayments.fold(0, (sum, p) => sum + p.amount);
  double get _remainingAmount => (widget.order.total - _paidAmount) > 0 ? (widget.order.total - _paidAmount) : 0;

  void _openSplitOrderDialog() {
    Navigator.pop(context); // Close checkout sheet
    showDialog(
      context: context,
      builder: (ctx) => _SplitOrderDialog(order: widget.order, apiService: ApiService()),
    );
  }

  void _confirm() {
    if (!_isSplitMode) {
      widget.onConfirm(_paymentMethod);
    } else {
      if (_remainingAmount > 0) return;
      final methodsStr = _partialPayments.map((p) => '${p.method} \$${p.amount.toStringAsFixed(2)}').join(', ');
      widget.onConfirm('Split ($methodsStr)');
    }
  }

  void _toggleItemSelection(int index) {
    setState(() {
      if (_selectedItemIndices.contains(index)) {
        _selectedItemIndices.remove(index);
      } else {
        _selectedItemIndices.add(index);
      }
      
      if (_selectedItemIndices.isNotEmpty) {
        double sum = _selectedItemIndices.fold(0, (s, i) => s + widget.order.items[i].totalPrice);
        _amountCtrl.text = sum.toStringAsFixed(2);
      } else {
        _amountCtrl.text = _remainingAmount.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(widget.order.orderCode ?? '#${widget.order.id}', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(width: 8),
            IconButton(
               icon: const Icon(Icons.call_split, color: Color(0xFF64748B)),
               tooltip: 'Split Order to New Table',
               onPressed: _openSplitOrderDialog,
            )
          ]),
          if (widget.order.tableNo != null) Text('Table: ${widget.order.tableNo}', style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // Items
          if (widget.order.items.isNotEmpty) ...[
            const Text('Order Items', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 8),
            ...widget.order.items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = _selectedItemIndices.contains(i);
              return GestureDetector(
                onTap: _isSplitMode ? () => _toggleItemSelection(i) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(_isSplitMode ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: _isSplitMode ? Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (_isSplitMode) ...[
                          Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1), size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text('${item.quantity}×', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      if (item.extras.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: _isSplitMode ? 32 : 24, top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.extras.map((e) => Text('+ ${e.name}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 24),
          ],

          // Total
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('\$${widget.order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F172A))),
          ]),
          const SizedBox(height: 16),

          // Payment Mode Toggle
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Full Payment')),
                    ButtonSegment(value: true, label: Text('Split / Partial')),
                  ],
                  selected: {_isSplitMode},
                  onSelectionChanged: (val) {
                    setState(() {
                      _isSplitMode = val.first;
                      if (!_isSplitMode) {
                        _selectedItemIndices.clear();
                      } else {
                        _amountCtrl.text = _remainingAmount.toStringAsFixed(2);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          
          if (!_isSplitMode) ...[
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 10),
            _buildMethodSelector(),
            const SizedBox(height: 20),
            _buildConfirmBtn('Confirm $_paymentMethod Payment', true),
          ] else ...[
            if (_partialPayments.isNotEmpty) ...[
              const Text('Payments Added', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 8),
              ..._partialPayments.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.method, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text('\$${p.amount.toStringAsFixed(2)}'),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _partialPayments.remove(p);
                              _amountCtrl.text = _remainingAmount.toStringAsFixed(2);
                            });
                          },
                          child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        )
                      ]
                    )
                  ],
                ),
              )),
              const Divider(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('\$${_remainingAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _remainingAmount == 0 ? Colors.green : Colors.orange)),
              ]
            ),
            if (_remainingAmount > 0) ...[
              const SizedBox(height: 16),
              _buildMethodSelector(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount (\$)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    )
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final amt = double.tryParse(_amountCtrl.text) ?? 0;
                      if (amt > 0) {
                        setState(() {
                          final toAdd = amt > _remainingAmount ? _remainingAmount : amt;
                          _partialPayments.add(_PartialPayment(_paymentMethod, toAdd));
                          _selectedItemIndices.clear(); // Clear selections after adding
                          _amountCtrl.text = _remainingAmount.toStringAsFixed(2);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                    child: const Text('Add')
                  )
                ]
              )
            ],
            const SizedBox(height: 20),
            _buildConfirmBtn('Confirm Split Payment', _remainingAmount == 0),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Row(children: ['Cash', 'Card', 'QR Code'].map((m) {
      final selected = _paymentMethod == m;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _paymentMethod = m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(m, style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ))),
            ),
          ),
        ),
      );
    }).toList());
  }

  Widget _buildConfirmBtn(String label, bool enabled) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: enabled ? _confirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF94A3B8), disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}

class _SplitOrderDialog extends StatefulWidget {
  final Order order;
  final ApiService apiService;
  const _SplitOrderDialog({required this.order, required this.apiService});

  @override
  State<_SplitOrderDialog> createState() => _SplitOrderDialogState();
}

class _SplitOrderDialogState extends State<_SplitOrderDialog> {
  final Map<int, int> _itemsToMove = {};
  final TextEditingController _tableCtrl = TextEditingController();
  bool _isSaving = false;

  void _increment(int i, int maxQty) {
    setState(() {
      final current = _itemsToMove[i] ?? 0;
      if (current < maxQty) _itemsToMove[i] = current + 1;
    });
  }
  
  void _decrement(int i) {
    setState(() {
      final current = _itemsToMove[i] ?? 0;
      if (current > 0) _itemsToMove[i] = current - 1;
      if (_itemsToMove[i] == 0) _itemsToMove.remove(i);
    });
  }

  Future<void> _submitSplit() async {
    final newTable = _tableCtrl.text.trim();
    if (newTable.isEmpty || _itemsToMove.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    double targetSubtotal = 0;
    List<Map<String, dynamic>> payloadItems = [];
    
    _itemsToMove.forEach((idx, qtyToMove) {
      final originalItem = widget.order.items[idx];
      targetSubtotal += originalItem.price * qtyToMove;
      
      payloadItems.add({
        'id': originalItem.id,
        'quantityToMove': qtyToMove,
      });
    });
    
    final targetTax = targetSubtotal * 0.10;
    final targetService = widget.order.orderType == 'Dine-In' ? targetSubtotal * 0.05 : 0.0;
    final targetTotal = targetSubtotal + targetTax + targetService;
    
    final sourceSubtotal = widget.order.subtotal - targetSubtotal;
    final sourceTax = sourceSubtotal * 0.10;
    final sourceService = widget.order.orderType == 'Dine-In' ? sourceSubtotal * 0.05 : 0.0;
    final sourceTotal = sourceSubtotal + sourceTax + sourceService;

    final newOrderId = await widget.apiService.splitOrder(
      sourceOrderId: widget.order.id,
      splitItems: payloadItems,
      newTableNo: newTable,
      newOrderType: widget.order.orderType ?? 'Dine-In',
      sourceNewSubtotal: sourceSubtotal,
      sourceNewTax: sourceTax,
      sourceNewService: sourceService,
      sourceNewTotal: sourceTotal,
      targetSubtotal: targetSubtotal,
      targetTax: targetTax,
      targetService: targetService,
      targetTotal: targetTotal,
    );
    
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (newOrderId != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order successfully split to new table!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to split order.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Split Order to New Table', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tableCtrl,
              decoration: InputDecoration(
                labelText: 'New Table Number (e.g. T4)', 
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select items to split off:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.order.items.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = widget.order.items[i];
                  final movedQty = _itemsToMove[i] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (item.extras.isNotEmpty)
                              Text('+ ${item.extras.length} sides', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          ]
                        )),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)), onPressed: () => _decrement(i)),
                            SizedBox(
                              width: 30, 
                              child: Text('$movedQty / ${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))
                            ),
                            IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F172A)), onPressed: () => _increment(i, item.quantity)),
                          ]
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
        ElevatedButton(
          onPressed: _isSaving ? null : _submitSplit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
          child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Split'),
        ),
      ],
    );
  }
}
