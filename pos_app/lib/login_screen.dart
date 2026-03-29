import 'package:flutter/material.dart';
import 'main.dart';
import 'waiter/waiter_shell.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/settings_view.dart';
import 'kitchen/kitchen_screen.dart';
import 'bar/bar_screen.dart';
import 'kiosk/kiosk_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Admin';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  final List<Map<String, dynamic>> roles = [
    {
      'name': 'Admin',
      'icon': Icons.person_outline,
      'big_icon': Icons.admin_panel_settings,
    },
    {'name': 'Waiter', 'icon': Icons.people_outline, 'big_icon': Icons.people},
    {
      'name': 'Kitchen',
      'icon': Icons.restaurant_menu,
      'big_icon': Icons.soup_kitchen,
    },
    {'name': 'Bar', 'icon': Icons.local_bar, 'big_icon': Icons.local_bar},
    {
      'name': 'Kiosk',
      'icon': Icons.desktop_windows,
      'big_icon': Icons.point_of_sale,
    },
  ];

  void _onRoleSelected(String role) {
    setState(() {
      selectedRole = role;
      errorMessage = null;
      usernameController.clear();
      pinController.clear();

      if (role == 'Admin') {
        usernameController.text = 'admin';
        pinController.text = '1111';
      } else if (role == 'Waiter') {
        usernameController.text = 'waiter';
        pinController.text = '1234';
      } else if (role == 'Kitchen') {
        usernameController.text = 'kitchen';
        pinController.text = '1234';
      } else if (role == 'Bar') {
        usernameController.text = 'bar';
        pinController.text = '1234';
      } else if (role == 'Kiosk') {
        usernameController.text = 'kiosk';
        pinController.text = '1234';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _onRoleSelected('Admin');
  }

  @override
  void dispose() {
    usernameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  /// Authenticate using Serverpod client
  Future<void> _login() async {
    if (selectedRole == 'Kitchen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KitchenScreen()),
      );
      return;
    }
    if (selectedRole == 'Bar') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BarScreen()),
      );
      return;
    }
    if (selectedRole == 'Kiosk') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KioskScreen()),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final username = usernameController.text.trim();
    final pin = pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      setState(() {
        errorMessage = 'Please enter Username and PIN';
        isLoading = false;
      });
      return;
    }

    try {
      final user = await client.users.login(selectedRole, username, pin);

      if (!mounted) return;
      setState(() => isLoading = false);

      if (user != null) {
        if (selectedRole == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else if (selectedRole == 'Waiter') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const WaiterShell(role: 'Waiter'),
            ),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Invalid username or PIN';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Connection failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool requiresAuth =
        selectedRole == 'Admin' || selectedRole == 'Waiter';
    final selectedRoleData = roles.firstWhere((r) => r['name'] == selectedRole);

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'Server Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsView()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'POS System',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your role to continue',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                // Role selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: roles.map((role) {
                      final isSelected = selectedRole == role['name'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onRoleSelected(role['name'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  role['icon'] as IconData,
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                Icon(
                  selectedRoleData['big_icon'] as IconData,
                  size: 48,
                  color: const Color(0xFF0F172A),
                ),

                const SizedBox(height: 24),

                if (requiresAuth) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter username',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PIN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pinController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '4-digit PIN',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (!requiresAuth) ...[
                  Text(
                    'Quick access to $selectedRole Display',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],

                if (errorMessage != null && requiresAuth) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            requiresAuth
                                ? 'Login as $selectedRole'
                                : 'Enter $selectedRole Mode',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (selectedRole == 'Admin') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Default: admin / 1111',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
                if (selectedRole == 'Waiter') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Default: waiter / 1234',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
