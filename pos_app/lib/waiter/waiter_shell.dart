import 'package:flutter/material.dart';
import 'new_order_view.dart';
import 'tables_view.dart';
import 'checkout_view.dart';
import 'order_history_view.dart';
import 'bills_view.dart';
import '../login_screen.dart';

class WaiterShell extends StatefulWidget {
  final String role;
  const WaiterShell({super.key, required this.role});

  @override
  State<WaiterShell> createState() => _WaiterShellState();
}

class _WaiterShellState extends State<WaiterShell> {
  String _selectedView = 'New Order';
  Map<String, dynamic>? _viewParams;

  void _switchView(String view, [Map<String, dynamic>? params]) {
    setState(() {
      _selectedView = view;
      _viewParams = params;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildCurrentView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'POS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          _buildSidebarItem('New Order', Icons.shopping_cart_outlined),
          _buildSidebarItem('Tables', Icons.grid_view_outlined),
          _buildSidebarItem('Checkout', Icons.credit_card_outlined),
          _buildSidebarItem('Orders', Icons.history_outlined),
          _buildSidebarItem('Bills', Icons.request_quote_outlined),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon) {
    final bool isSelected = _selectedView == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _switchView(title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0F172A) : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Waiter Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Managing orders and tables',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout, size: 20, color: Colors.black87),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedView) {
      case 'New Order':
        return NewOrderView(
          initialTableNo: _viewParams?['tableNo'],
          initialOrderType: _viewParams?['orderType'],
        );
      case 'Tables':
        return TablesView(
          onAddItems: (tableNo) {
            _switchView('New Order', {
              'tableNo': tableNo,
              'orderType': 'Dine-In',
            });
          },
        );
      case 'Checkout':
        return const CheckoutView();
      case 'Orders':
        return const OrderHistoryView();
      case 'Bills':
        return const BillsView();
      default:
        return const NewOrderView();
    }
  }
}
