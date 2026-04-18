import 'package:flutter/material.dart';
import 'new_order_view.dart';
import 'tables_view.dart';
import 'reservations_view.dart';
import 'checkout_view.dart';
import 'order_history_view.dart';
import 'bills_view.dart';
import 'printer_view.dart';
import '../login_screen.dart';
import '../shared/responsive_layout.dart';

class WaiterShell extends StatefulWidget {
  final String role;
  const WaiterShell({super.key, required this.role});

  @override
  State<WaiterShell> createState() => _WaiterShellState();
}

class _WaiterShellState extends State<WaiterShell> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _viewParams;

  final List<Map<String, dynamic>> _navItems = [
    {
      'title': 'New Order',
      'icon': Icons.shopping_cart_outlined,
      'activeIcon': Icons.shopping_cart,
    },
    {
      'title': 'Tables',
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view,
    },
    {
      'title': 'Checkout',
      'icon': Icons.credit_card_outlined,
      'activeIcon': Icons.credit_card,
    },
    {
      'title': 'More',
      'icon': Icons.more_horiz_outlined,
      'activeIcon': Icons.more_horiz,
    },
  ];

  void _switchView(String view, [Map<String, dynamic>? params]) {
    final index = _navItems.indexWhere((item) => item['title'] == view);
    setState(() {
      if (index != -1) {
        _selectedIndex = index;
      } else {
        _selectedIndex = 3;
      }
      _viewParams = params;
      _currentViewTitle = view;
    });
  }

  String _currentViewTitle = 'New Order';

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              centerTitle: true,
              title: Text(
                _currentViewTitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFF1F5F9), height: 1),
              ),
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _buildTopBar(),
                Expanded(child: _buildCurrentView()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  if (index == 3) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    _switchView(_navItems[index]['title']);
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF0F172A),
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                elevation: 0,
                items: _navItems.map((item) {
                  return BottomNavigationBarItem(
                    icon: Icon(item['icon']),
                    activeIcon: Icon(item['activeIcon']),
                    label: item['title'],
                  );
                }).toList(),
              ),
            )
          : null,
    );
  }

  Widget _buildCurrentView() {
    switch (_currentViewTitle) {
      case 'New Order':
        return NewOrderView(
          initialTableNo: _viewParams?['tableNo'],
          initialOrderType: _viewParams?['orderType'],
          onOrderCreated: () => _switchView('Tables'),
        );
      case 'Tables':
        return TablesView(
          onAddItems: (tableNo) {
            _switchView('New Order', {
              'tableNo': tableNo,
              'orderType': 'Dine-In',
            });
          },
          onCheckout: (tableNo) {
            _switchView('Checkout', {'tableNo': tableNo});
          },
        );
      case 'Reservations':
        return const ReservationsView();
      case 'Checkout':
        return CheckoutView(tableNo: _viewParams?['tableNo']);
      case 'Orders':
        return const OrderHistoryView();
      case 'Bills':
        return const BillsView();
      case 'Printers':
        return const PrinterView();
      default:
        return const NewOrderView();
    }
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Text(
                  'POS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (ResponsiveLayout.isMobile(context))
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem('New Order', Icons.shopping_cart_outlined),
                _buildSidebarItem('Tables', Icons.grid_view_outlined),
                _buildSidebarItem('Reservations', Icons.event_note_outlined),
                _buildSidebarItem('Checkout', Icons.credit_card_outlined),
                _buildSidebarItem('Orders', Icons.history_outlined),
                _buildSidebarItem('Bills', Icons.request_quote_outlined),
                _buildSidebarItem('Printers', Icons.print_outlined),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSidebarItem(
              'Logout',
              Icons.logout_rounded,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon, {
    bool isLogout = false,
  }) {
    final bool isSelected = _currentViewTitle == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            return;
          }
          _switchView(title);
          if (ResponsiveLayout.isMobile(context)) {
            Navigator.pop(context); // Close drawer
          }
        },
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
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : (isLogout ? Colors.redAccent : Colors.grey[600]),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : (isLogout ? Colors.redAccent : Colors.grey[600]),
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
}
