import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Settings? _settings;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Local IP from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _ipController.text = prefs.getString('server_ip') ?? 'localhost';

      // 2. Load Global Settings from Serverpod
      _settings = await client.settings.getSettings();
      if (_settings != null) {
        _taxController.text = _settings!.taxRate.toStringAsFixed(0);
        _serviceController.text = _settings!.serviceCharge.toStringAsFixed(0);
        _currencyController.text = _settings!.currencySymbol;
        _delayController.text = _settings!.orderDelayThreshold.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      // 1. Save Local IP
      final prefs = await SharedPreferences.getInstance();
      final newIp = _ipController.text.trim();
      await prefs.setString('server_ip', newIp);

      // 2. Save Global Settings to Serverpod
      if (_settings != null) {
        final updated = _settings!.copyWith(
          taxRate: double.tryParse(_taxController.text) ?? 10.0,
          serviceCharge: double.tryParse(_serviceController.text) ?? 5.0,
          currencySymbol: _currencyController.text.trim(),
          orderDelayThreshold: int.tryParse(_delayController.text) ?? 15,
        );
        await client.settings.updateSettings(updated);
      }

      // 3. Re-init client if IP changed
      await initClient();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSection(
            title: 'Network Configuration',
            subtitle: 'Set server connection details',
            child: _buildIpField(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Tax & Service Configuration',
            subtitle: 'Set default tax and service rates',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Tax Rate (%)',
                        controller: _taxController,
                        hint: '10',
                        currentValue:
                            '${double.tryParse(_taxController.text)?.toStringAsFixed(2) ?? "0.00"}%',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildField(
                        label: 'Service Charge (%)',
                        controller: _serviceController,
                        hint: '5',
                        currentValue:
                            '${double.tryParse(_serviceController.text)?.toStringAsFixed(2) ?? "0.00"}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField(
                  label: 'Currency Symbol',
                  controller: _currencyController,
                  hint: '\$',
                  width: 150,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Kitchen Display Settings',
            subtitle: 'Configure order alerts and thresholds',
            child: _buildField(
              label: 'Order Delay Threshold (minutes)',
              controller: _delayController,
              hint: '15',
              footer: 'Orders older than this will show a delay alert',
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Database Management',
            subtitle: 'Backup, restore, and maintain data',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildOutlinedButton(
                        'Backup Database',
                        Icons.download,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildOutlinedButton(
                        'Restore from Backup',
                        Icons.upload,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Data Retention',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remove old records to optimize performance',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Purge Data Older Than 90 Days',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSystemInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure system preferences',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveSettings,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 20, color: Colors.white),
          label: const Text(
            'Save Changes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildIpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Server IP Address',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              hintText: 'e.g. localhost',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? currentValue,
    String? footer,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (currentValue != null) ...[
            const SizedBox(height: 8),
            Text(
              'Current: $currentValue',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        side: BorderSide(color: Colors.grey[200]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Version:', '1.0.0'),
          const Divider(height: 24),
          _buildInfoRow('Database Size:', '2.4 MB'),
          const Divider(height: 24),
          _buildInfoRow('Last Sync:', 'Just now'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 20, color: Colors.black87),
              label: const Text(
                'Clear Cache',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: BorderSide(color: Colors.grey[200]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
