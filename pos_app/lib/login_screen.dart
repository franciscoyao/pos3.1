import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'waiter/waiter_shell.dart';
import 'admin/admin_dashboard_screen.dart';
import 'kiosk/kiosk_screen.dart';

import 'kitchen/kitchen_bar_screen.dart';
import 'shared/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String selectedRole = 'Admin';
  late AnimationController _fadeController;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  final List<Map<String, dynamic>> roles = [
    {
      'name': 'Admin',
      'icon': Icons.manage_accounts_outlined,
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    },
    {
      'name': 'Waiter',
      'icon': Icons.groups_outlined,
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    },
    {
      'name': 'Kitchen',
      'icon': Icons.soup_kitchen_outlined,
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    },
    {
      'name': 'Bar',
      'icon': Icons.wine_bar_outlined,
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    },
    {
      'name': 'Kiosk',
      'icon': Icons.desktop_windows_outlined,
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    },
  ];

  void _showServerSetup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 500),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Server Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the backend IP address to connect to the POS system.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current Server: http://${_ipController.text}:8080/',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Backend IP Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildIpField(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final newIp = _ipController.text.trim();
                      if (newIp.isNotEmpty) {
                        await prefs.setString('server_ip', newIp);
                        await initClient();
                        if (!context.mounted) return;
                        setState(() {}); // Update the top-right indicator
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Server IP updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Connect to Server',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final TextEditingController _ipController = TextEditingController();

  Widget _buildIpField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _ipController,
        style: const TextStyle(color: Color(0xFF0F172A)),
        decoration: const InputDecoration(
          hintText: 'e.g. localhost',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadIp();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _onRoleSelected('Admin');
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString('server_ip') ?? '192.168.1.201';
  }

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
        pinController.text = '2222';
      } else {
        usernameController.clear();
        pinController.clear();
      }
    });
    _fadeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    usernameController.dispose();
    pinController.dispose();
    _ipController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String? username =
          (selectedRole == 'Admin' || selectedRole == 'Waiter')
          ? usernameController.text.trim()
          : null;
      final String? pin = (selectedRole == 'Admin' || selectedRole == 'Waiter')
          ? pinController.text.trim()
          : null;

      if ((selectedRole == 'Admin' || selectedRole == 'Waiter') &&
          (username!.isEmpty || pin!.isEmpty)) {
        setState(() {
          errorMessage = 'Please enter Username and PIN';
          isLoading = false;
        });
        return;
      }

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
        } else if (selectedRole == 'Kitchen') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const KitchenBarScreen(station: 'Kitchen'),
            ),
          );
        } else if (selectedRole == 'Bar') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const KitchenBarScreen(station: 'Bar'),
            ),
          );
        } else if (selectedRole == 'Kiosk') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KioskScreen()),
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
        errorMessage = 'Connection failed: $e\nCheck server IP in Settings.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool requiresAuth =
        selectedRole == 'Admin' || selectedRole == 'Waiter';
    final currentRoleData = roles.firstWhere((r) => r['name'] == selectedRole);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Server IP indicator at the top
          Positioned(
            top: 40,
            right: 24,
            child: InkWell(
              onTap: _showServerSetup,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.dns_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _ipController.text.isEmpty
                          ? 'Setup Server'
                          : _ipController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                width: ResponsiveLayout.isMobile(context) ? double.infinity : 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/icon.png', height: 80, width: 80),
                      const SizedBox(height: 24),
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
                        style: TextStyle(fontSize: 16, color: Colors.black45),
                      ),
                      const SizedBox(height: 32),

                      _buildRoleSelector(context),

                      const SizedBox(height: 32),

                      FadeTransition(
                        opacity: _fadeController,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _fadeController,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: Column(
                            children: [
                              Icon(
                                currentRoleData['icon'],
                                size: 48,
                                color: const Color(0xFF0F172A),
                              ),
                              const SizedBox(height: 24),

                              if (requiresAuth) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Username',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: usernameController,
                                  label: 'Enter username',
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'PIN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: pinController,
                                  label: '4-digit PIN',
                                  isPassword: true,
                                ),
                              ] else ...[
                                Text(
                                  'Quick access to $selectedRole Display',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],

                              if (errorMessage != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: _showServerSetup,
                                        icon: const Icon(
                                          Icons.dns_outlined,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Configure Server IP',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
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
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              if (requiresAuth) ...[
                                const SizedBox(height: 24),
                                Text(
                                  'Default: ${selectedRole.toLowerCase()} / ${selectedRole == 'Admin' ? '1111' : '2222'}',
                                  style: const TextStyle(
                                    color: Colors.black26,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Help icon at bottom right
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: _showServerSetup,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Server Setup',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black26),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: roles.map((role) {
            final isSelected = selectedRole == role['name'];
            return GestureDetector(
              onTap: () => _onRoleSelected(role['name'] as String),
              child: AnimatedContainer(
                width: ResponsiveLayout.isMobile(context) ? 80 : 84,
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role['icon'],
                      size: 20,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : Colors.black45,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
