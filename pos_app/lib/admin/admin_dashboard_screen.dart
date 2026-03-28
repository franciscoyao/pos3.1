import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';
import '../login_screen.dart';
import 'menu_management_view.dart';
import 'user_management_view.dart';
import 'checkout_history_view.dart';
import 'settings_view.dart';
import '../shared/printer_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('${widget.user.role} User', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ),
                const SizedBox(height: 32),
                _buildSidebarItem(index: 0, icon: Icons.dashboard_outlined, label: 'Reports'),
                _buildSidebarItem(index: 1, icon: Icons.restaurant_menu_outlined, label: 'Menu'),
                _buildSidebarItem(index: 2, icon: Icons.print_outlined, label: 'Printers'),
                _buildSidebarItem(index: 3, icon: Icons.people_outline, label: 'Users'),
                _buildSidebarItem(index: 4, icon: Icons.history_outlined, label: 'History'),
                _buildSidebarItem(index: 5, icon: Icons.settings_outlined, label: 'Settings'),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navbar
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 6),
                            Text('Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      InkWell(
                        onTap: () => _logout(context),
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return const _ReportsDashboard();
      case 1: return const MenuManagementView();
      case 2: return const PrinterScreen();
      case 3: return const UserManagementView();
      case 4: return const CheckoutHistoryView();
      case 5: return const SettingsView();
      default: return const Center(child: Text('Under Construction'));
    }
  }

  Widget _buildSidebarItem({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Live Reports Dashboard ───────────────────────────────────────────────────

class _ReportsDashboard extends StatefulWidget {
  const _ReportsDashboard();

  @override
  State<_ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<_ReportsDashboard> {
  final ApiService _api = ApiService();
  ReportSummary? _summary;
  bool _loading = true;
  String? _error;

  StreamSubscription? _orderCreatedSub;
  StreamSubscription? _orderUpdatedSub;
  StreamSubscription? _checkoutSub;

  @override
  void initState() {
    super.initState();
    _load();
    _orderCreatedSub = SocketService().onOrderCreated.listen((_) { if (mounted) _load(); });
    _orderUpdatedSub = SocketService().onOrderUpdated.listen((_) { if (mounted) _load(); });
    _checkoutSub = SocketService().onCheckoutCompleted.listen((_) { if (mounted) _load(); });
  }

  @override
  void dispose() {
    _orderCreatedSub?.cancel();
    _orderUpdatedSub?.cancel();
    _checkoutSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final s = await _api.fetchReportSummary();
      if (mounted) setState(() { _summary = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text('Could not load reports', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
          ),
        ]),
      );
    }

    final s = _summary!;
    final totalCategoryRevenue = s.salesByCategory.fold(0.0, (a, c) => a + c.revenue);
    final maxDayRevenue = s.salesByDay.isEmpty ? 1.0
        : s.salesByDay.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reports Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                SizedBox(height: 4),
                Text('Live sales analytics from the shared database', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ]),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_outlined, color: Color(0xFF64748B)),
                tooltip: 'Refresh',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Stat Cards ────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: _statCard('Total Revenue', '\$${s.totalRevenue.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _statCard('Total Orders', '${s.totalOrders}', Icons.shopping_cart_outlined, const Color(0xFF3B82F6))),
            const SizedBox(width: 16),
            Expanded(child: _statCard('Avg Order Value', '\$${s.avgOrderValue.toStringAsFixed(2)}', Icons.trending_up, const Color(0xFF8B5CF6))),
          ]),

          const SizedBox(height: 24),

          // ── Sales by Day + Sales by Category ─────────────────────────────
          if (s.salesByDay.isNotEmpty || s.salesByCategory.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bar chart — sales by day
                Expanded(
                  flex: 2,
                  child: _card(
                    title: 'Sales Last 7 Days',
                    height: 280,
                    child: s.salesByDay.isEmpty
                        ? _emptyState('No sales data')
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: s.salesByDay.map((d) {
                                final frac = maxDayRevenue == 0 ? 0.0 : d.revenue / maxDayRevenue;
                                final label = d.day.length >= 10 ? d.day.substring(5) : d.day; // MM-DD
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('\$${d.revenue.toStringAsFixed(0)}',
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 600),
                                          height: 160 * frac,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                        Text('${d.orders}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 24),

                // Sales by Category
                Expanded(
                  flex: 1,
                  child: _card(
                    title: 'Sales by Category',
                    height: 280,
                    child: s.salesByCategory.isEmpty
                        ? _emptyState('No data')
                        : Column(
                            children: s.salesByCategory.map((c) {
                              final pct = totalCategoryRevenue == 0 ? 0.0 : c.revenue / totalCategoryRevenue;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(c.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
                                        Text('\$${c.revenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFFF1F5F9),
                                        valueColor: const AlwaysStoppedAnimation(Color(0xFF0F172A)),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // ── Top Selling Items ─────────────────────────────────────────────
          if (s.topItems.isNotEmpty)
            _card(
              title: 'Top Selling Items',
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                    children: [
                      _th('Item'), _th('Qty Sold'), _th('Revenue'),
                    ],
                  ),
                  ...s.topItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven ? const Color(0xFFF8FAFC) : Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Row(children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                              child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Text('${item.totalQty}', style: const TextStyle(color: Color(0xFF475569))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Text('\$${item.totalRevenue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          if (s.topItems.isEmpty)
            _card(
              title: 'Top Selling Items',
              child: _emptyState('No orders have been placed yet'),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: accent.withAlpha(26), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: accent),
          ),
        ]),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ]),
    );
  }

  Widget _card({required String title, required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          if (height != null) Expanded(child: child) else child,
        ],
      ),
    );
  }

  Widget _th(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
  );

  Widget _emptyState(String text) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.insert_chart_outlined, size: 48, color: Color(0xFFCBD5E1)),
      const SizedBox(height: 12),
      Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
    ]),
  );
}
