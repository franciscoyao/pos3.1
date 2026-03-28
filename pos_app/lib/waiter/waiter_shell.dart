import 'package:flutter/material.dart';
import '../shared/models.dart';
import '../shared/printer_screen.dart';
import '../login_screen.dart';
import 'new_order_view.dart';
import 'tables_view.dart';
import 'checkout_view.dart';
import 'order_history_view.dart';
import 'bills_view.dart';

class WaiterShell extends StatefulWidget {
  final User user;

  const WaiterShell({super.key, required this.user});

  @override
  State<WaiterShell> createState() => _WaiterShellState();
}

class _WaiterShellState extends State<WaiterShell> {
  int _selectedIndex = 0;
  String? _prefilledTable;
  final GlobalKey<NewOrderViewState> _newOrderKey = GlobalKey<NewOrderViewState>();

  void _openNewOrderForTable(String tableNumber) {
    setState(() {
      _selectedIndex = 0;
      _prefilledTable = tableNumber;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newOrderKey.currentState?.presetTable(tableNumber);
    });
  }

  static const _navItems = [
    _NavItem(icon: Icons.add_shopping_cart_outlined, label: 'New Order'),
    _NavItem(icon: Icons.table_chart_outlined, label: 'Tables'),
    _NavItem(icon: Icons.payment_outlined, label: 'Checkout'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
    _NavItem(icon: Icons.description_outlined, label: 'Bills'),
    _NavItem(icon: Icons.print_outlined, label: 'Printer'),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return NewOrderView(key: _newOrderKey, user: widget.user, prefilledTable: _prefilledTable,
          onOrderSent: () => setState(() => _prefilledTable = null));
      case 1: return TablesView(user: widget.user, onOpenNewOrderForTable: _openNewOrderForTable);
      case 2: return CheckoutView(user: widget.user);
      case 3: return const OrderHistoryView();
      case 4: return const BillsView();
      case 5: return const PrinterScreen();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ── Left Sidebar ──────────────────────────────────────
          Container(
            width: 200,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App branding
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text('POS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.user.fullName ?? widget.user.username,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Nav items
                ...List.generate(_navItems.length, (i) => _buildNavItem(i)),

                const Spacer(),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: InkWell(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.logout, size: 18, color: Color(0xFF64748B)),
                        SizedBox(width: 10),
                        Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(item.icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(item.label, style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            )),
          ]),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
