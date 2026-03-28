import 'package:flutter/material.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final ApiService apiService = ApiService();
  List<User> users = [];
  bool isLoading = true;
  String searchQuery = '';
  String roleFilter = 'All Roles';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsers = await apiService.fetchUsers();
      if (mounted) {
        setState(() {
          users = fetchedUsers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  void _showUserDialog({User? user}) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final usernameController = TextEditingController(text: user?.username ?? '');
    final pinController = TextEditingController(text: user?.pin ?? '');
    
    String selectedRole = user?.role ?? 'Waiter';
    bool isActive = user?.status == 'Active';

    if (user == null) isActive = true; // Default for new users

    final roles = ['Admin', 'Waiter', 'Kitchen', 'Bar', 'Kiosk'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user == null ? 'Add User' : 'Edit User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 16, bottom: 0),
              contentPadding: const EdgeInsets.all(24),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogField('Full Name', nameController),
                      const SizedBox(height: 16),
                      _buildDialogField('Username', usernameController),
                      const SizedBox(height: 16),
                      const Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRole,
                            isExpanded: true,
                            items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedRole = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDialogField('4-Digit PIN', pinController, isPassword: true),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Active', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: isActive,
                            onChanged: (val) => setDialogState(() => isActive = val),
                            activeThumbColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final un = usernameController.text.trim();
                            final pin = pinController.text.trim();
                            
                            if (un.isEmpty) return;

                            final data = {
                              'full_name': name,
                              'username': un,
                              'role': selectedRole,
                              'pin': pin.isEmpty ? null : pin,
                              'status': isActive ? 'Active' : 'Inactive',
                            };

                            final nav = Navigator.of(context);
                            if (user == null) {
                              await apiService.createUser(data);
                            } else {
                              await apiService.updateUser(user.id, data);
                            }
                            _loadData();
                            nav.pop();
                          },
                          child: Text(user == null ? 'Save User' : 'Update User'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _deleteUser(User user) async {
    if (user.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete default users')),
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await apiService.deleteUser(user.id);
      if (success) {
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete user')),
          );
        }
      }
    }
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredUsers = users.where((u) {
      final matchesSearch = u.username.toLowerCase().contains(searchQuery.toLowerCase()) || 
                            (u.fullName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      final matchesRole = roleFilter == 'All Roles' || u.role == roleFilter;
      return matchesSearch && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('User Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Manage staff accounts and permissions', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      hintText: 'Search users...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: roleFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
                        items: ['All Roles', 'Admin', 'Waiter', 'Kitchen', 'Bar', 'Kiosk']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Color(0xFF64748B)))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => roleFilter = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Staff Members (${filteredUsers.length})', style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A))),
                  ),
                  
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _headerText('User')),
                        Expanded(flex: 2, child: _headerText('Username')),
                        Expanded(flex: 2, child: _headerText('Role')),
                        Expanded(flex: 2, child: _headerText('PIN')),
                        Expanded(flex: 2, child: _headerText('Status')),
                        Expanded(flex: 2, child: _headerText('Created')),
                        SizedBox(width: 80, child: _headerText('Actions', align: TextAlign.right)),
                      ],
                    ),
                  ),
                  
                  // Table Body
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(child: Text('No users found', style: TextStyle(color: Color(0xFF94A3B8))))
                        : ListView.separated(
                            itemCount: filteredUsers.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            itemBuilder: (context, index) {
                              final u = filteredUsers[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getRoleIcon(u.role),
                                            size: 20,
                                            color: const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(u.fullName ?? u.role, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                                        ],
                                      ),
                                    ),
                                    Expanded(flex: 2, child: Text(u.username, style: const TextStyle(color: Color(0xFF475569)))),
                                    Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _rolePill(u.role))),
                                    Expanded(flex: 2, child: Text(u.pin != null && u.pin!.isNotEmpty ? '****' : 'None', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _statusPill(u.status))),
                                    Expanded(flex: 2, child: Text(_formatDate(u.createdAt), style: const TextStyle(color: Color(0xFF475569)))),
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () => _showUserDialog(user: u),
                                            child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 16),
                                          InkWell(
                                            onTap: u.isDefault ? null : () => _deleteUser(u),
                                            child: Icon(Icons.delete_outline, size: 20, color: u.isDefault ? const Color(0xFFE2E8F0) : const Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _rolePill(String role) {
    bool isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.toLowerCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isAdmin ? Colors.white : const Color(0xFF475569)),
      ),
    );
  }

  Widget _statusPill(String status) {
    bool isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF475569)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '1/1/2025';
    return '${date.month}/${date.day}/${date.year}';
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.person_outline;
      case 'waiter':
        return Icons.people_outline;
      case 'kitchen':
        return Icons.restaurant_outlined;
      case 'bar':
        return Icons.local_bar_outlined;
      case 'kiosk':
        return Icons.desktop_windows_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
