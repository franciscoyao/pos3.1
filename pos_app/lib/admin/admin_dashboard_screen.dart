import 'package:flutter/material.dart';
import 'reports_view.dart';
import 'menu_management_view.dart';
import 'user_management_view.dart';
import 'checkout_history_view.dart';
import 'printer_management_view.dart';
import 'settings_view.dart';
import '../login_screen.dart';
import '../shared/responsive_layout.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedView = 'Reports';

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: const Text(
                'Admin Dashboard',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black87),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
              ],
              elevation: 0,
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
          _buildSidebarItem('Reports', Icons.grid_view_outlined),
          _buildSidebarItem('Menu', Icons.restaurant_menu_outlined),
          _buildSidebarItem('Printers', Icons.print_outlined),
          _buildSidebarItem('Users', Icons.people_outline),
          _buildSidebarItem('History', Icons.history_outlined),
          _buildSidebarItem('Settings', Icons.settings_outlined),
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
        onTap: () {
          setState(() => _selectedView = title);
          if (ResponsiveLayout.isMobile(context) && Scaffold.of(context).isDrawerOpen) {
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Admin User',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Logout'),
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedView) {
      case 'Reports':
        return const ReportsView();
      case 'Menu':
        return const MenuManagementView();
      case 'Printers':
        return const PrinterManagementView();
      case 'Users':
        return const UserManagementView();
      case 'History':
        return const CheckoutHistoryView();
      case 'Settings':
        return const SettingsView();
      default:
        return Center(child: Text('$_selectedView View coming soon'));
    }
  }
}
