import 'package:flutter/material.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';
import 'dart:async';

class BillsView extends StatefulWidget {
  const BillsView({super.key});

  @override
  State<BillsView> createState() => _BillsViewState();
}

class _BillsViewState extends State<BillsView> {
  final ApiService _api = ApiService();
  List<Bill> _bills = [];
  bool _isLoading = true;
  StreamSubscription? _checkoutSub;

  @override
  void initState() {
    super.initState();
    _loadBills();
    _checkoutSub = SocketService().onCheckoutCompleted.listen((_) {
      if (mounted) _loadBills();
    });
  }

  @override
  void dispose() {
    _checkoutSub?.cancel();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      final bills = await _api.fetchBills();
      setState(() { _bills = bills; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showBillDetail(Bill bill) async {
    Bill? full;
    try { full = await _api.fetchBillDetails(bill.id); } catch (_) { full = bill; }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(child: Text('Receipt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(dialogCtx), icon: const Icon(Icons.close)),
                ]),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _detailRow('Bill Number', full!.billNumber, bold: true),
                    if (full.tableNo != null) _detailRow('Table', full.tableNo!),
                    if (full.orderType != null) _detailRow('Type', full.orderType!),
                    _detailRow('Payment', full.paymentMethod ?? '-'),
                    _detailRow('Waiter', full.waiterName ?? '-'),
                    _detailRow('Date', _formatDate(full.createdAt)),
                  ]),
                ),
                if (full.items != null && full.items!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Items', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 8),
                  ...full.items!.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Text('${item.quantity}×', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                      Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  )),
                ],
                const Divider(height: 24),
                _detailRow('Subtotal', '\$${full.subtotal.toStringAsFixed(2)}'),
                if (full.taxAmount > 0) _detailRow('Tax', '\$${full.taxAmount.toStringAsFixed(2)}'),
                if (full.tipAmount > 0) _detailRow('Tip', '\$${full.tipAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                _detailRow('Total', '\$${full.total.toStringAsFixed(2)}', bold: true, large: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: const Color(0xFF64748B), fontSize: large ? 15 : 13)),
        Text(value, style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: large ? 17 : 13,
          color: const Color(0xFF0F172A),
        )),
      ]),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _paymentIcon(String? method) {
    switch (method) {
      case 'Card': return Icons.credit_card;
      case 'QR Code': return Icons.qr_code;
      default: return Icons.payments_outlined;
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
              const Text('Bills', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: Text('${_bills.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
              const Spacer(),
              IconButton(onPressed: _loadBills, icon: const Icon(Icons.refresh)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Checkout history & receipts', style: TextStyle(color: Color(0xFF64748B))),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bills.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No bills yet.', style: TextStyle(color: Color(0xFF94A3B8))),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _bills.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final bill = _bills[i];
                          return InkWell(
                            onTap: () => _showBillDetail(bill),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(_paymentIcon(bill.paymentMethod), color: const Color(0xFF10B981), size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(bill.billNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    if (bill.tableNo != null) ...[
                                      const Icon(Icons.table_chart_outlined, size: 13, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 3),
                                      Text(bill.tableNo!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                      const SizedBox(width: 10),
                                    ],
                                    Text(_formatDate(bill.createdAt), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                  ]),
                                ])),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text('\$${bill.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                                    child: Text(bill.paymentMethod ?? 'Cash', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
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
}
