import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import 'components/menu/menu_widgets.dart';
import '../shared/responsive_layout.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  List<PosUser> users = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedRoleFilter = 'All Roles';
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'user_updated') {
        _loadUsersQuietly();
      }
    });
  }

  Future<void> _loadUsersQuietly() async {
    try {
      final loadedUsers = await client.users.getAll();
      if (mounted) {
        setState(() {
          users = loadedUsers;
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final loadedUsers = await client.users.getAll();
      if (mounted) {
        setState(() {
          users = loadedUsers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFiltersBar(),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildUserTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage staff accounts and permissions',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showUserDialog(),
          icon: const Icon(Icons.add, size: 20, color: Colors.white),
          label: const Text(
            'Add User',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ResponsiveLayout.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildFilterElements(),
            )
          : Row(
              children: _buildFilterElements(isMobile: false),
            ),
    );
  }

  List<Widget> _buildFilterElements({bool isMobile = true}) {
    final searchWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey, size: 20),
          hintText: 'Search users...',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14),
        ),
      ),
    );

    final dropdownWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRoleFilter,
          isExpanded: isMobile,
          items: ['All Roles', 'Admin', 'Waiter', 'Kitchen', 'Bar']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedRoleFilter = v!),
        ),
      ),
    );

    if (isMobile) {
      return [
        searchWidget,
        const SizedBox(height: 16),
        dropdownWidget,
      ];
    } else {
      return [
        Expanded(flex: 3, child: searchWidget),
        const SizedBox(width: 16),
        dropdownWidget,
      ];
    }
  }

  Widget _buildUserTable() {
    final filteredUsers = users.where((u) {
      final matchesSearch =
          (u.fullName?.toLowerCase() ?? '').contains(
            searchQuery.toLowerCase(),
          ) ||
          u.username.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole =
          selectedRoleFilter == 'All Roles' ||
          u.role.toLowerCase() == selectedRoleFilter.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Staff Members (${filteredUsers.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ResponsiveLayout.isMobile(context)
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) => _buildMobileUserCard(filteredUsers[index]),
                  )
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 24,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF8FAFC),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'User',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'PIN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Created',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: filteredUsers.map((u) => _buildUserRow(u)).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUserCard(PosUser u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        u.role.toLowerCase() == 'admin'
                            ? Icons.admin_panel_settings_outlined
                            : u.role.toLowerCase() == 'kitchen'
                            ? Icons.restaurant_menu_rounded
                            : u.role.toLowerCase() == 'bar'
                            ? Icons.local_bar_rounded
                            : Icons.person_outline_rounded,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          u.fullName ?? 'Unnamed User',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showUserDialog(user: u),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed:
                          u.isDefault ? null : () => _confirmDeleteUser(u),
                      color: u.isDefault ? Colors.grey[300] : Colors.red[400],
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Username:', style: TextStyle(color: Colors.grey[600])),
                Text(u.username,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Role:', style: TextStyle(color: Colors.grey[600])),
                _buildRoleBadge(u.role),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: TextStyle(color: Colors.grey[600])),
                _buildStatusBadge(u.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PIN:', style: TextStyle(color: Colors.grey[600])),
                Text(u.pin != null ? '••••' : 'None',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildUserRow(PosUser u) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                u.role.toLowerCase() == 'admin'
                    ? Icons.admin_panel_settings_outlined
                    : u.role.toLowerCase() == 'kitchen'
                    ? Icons.restaurant_menu_rounded
                    : u.role.toLowerCase() == 'bar'
                    ? Icons.local_bar_rounded
                    : Icons.person_outline_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                u.fullName ?? 'Unnamed User',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        DataCell(Text(u.username)),
        DataCell(_buildRoleBadge(u.role)),
        DataCell(Text(u.pin != null ? '••••' : 'None')),
        DataCell(_buildStatusBadge(u.status)),
        DataCell(
          Text(
            u.createdAt != null
                ? DateFormat('M/d/yyyy').format(u.createdAt!)
                : '-',
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showUserDialog(user: u),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: u.isDefault ? null : () => _confirmDeleteUser(u),
                color: u.isDefault ? Colors.grey[300] : Colors.red[400],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toLowerCase(),
        style: TextStyle(
          color: isAdmin ? Colors.white : const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmDeleteUser(PosUser u) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${u.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await client.users.delete(u.id!);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  _loadUsers();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserDialog({PosUser? user}) {
    showDialog(
      context: context,
      builder: (context) =>
          UserDialog(client: client, user: user, onSuccess: _loadUsers),
    );
  }
}

class UserDialog extends StatefulWidget {
  final Client client;
  final PosUser? user;
  final VoidCallback onSuccess;

  const UserDialog({
    super.key,
    required this.client,
    this.user,
    required this.onSuccess,
  });

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController pinController;
  late String role;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.fullName ?? '');
    usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    pinController = TextEditingController(text: widget.user?.pin ?? '');
    role = widget.user?.role ?? 'Waiter';
    isActive =
        widget.user?.status.toLowerCase() == 'active' || widget.user == null;
  }

  Future<void> _handleSave() async {
    if (nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Full Name and Username')),
      );
      return;
    }

    final newUser = PosUser(
      id: widget.user?.id,
      fullName: nameController.text.trim(),
      username: usernameController.text.trim(),
      pin: pinController.text.trim().isEmpty ? null : pinController.text.trim(),
      role: role,
      status: isActive ? 'Active' : 'Inactive',
      isDefault: widget.user?.isDefault ?? false,
    );

    try {
      if (widget.user == null) {
        await widget.client.users.create(newUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created successfully')),
          );
        }
      } else {
        await widget.client.users.update(widget.user!.id!, newUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
        }
      }
      if (mounted) {
        widget.onSuccess();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Edit User' : 'Add User'),
                Text(
                  isEditing
                      ? 'Update staff member details'
                      : 'Create a new staff account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuDialogField(
              label: 'Full Name',
              controller: nameController,
              hint: 'John Doe',
            ),
            const SizedBox(height: 16),
            MenuDialogField(
              label: 'Username',
              controller: usernameController,
              hint: 'johndoe',
            ),
            const SizedBox(height: 16),
            MenuDialogDropdown<String>(
              label: 'Role',
              value: role,
              items: [
                'Admin',
                'Waiter',
                'Kitchen',
                'Bar',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => role = v!),
            ),
            const SizedBox(height: 16),
            MenuDialogField(
              label: '4-Digit PIN',
              controller: pinController,
              hint: '1234',
              isPIN: true,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text(
                'Active',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: isActive,
              activeThumbColor: const Color(0xFF0F172A),
              onChanged: (v) => setState(() => isActive = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Save User', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
