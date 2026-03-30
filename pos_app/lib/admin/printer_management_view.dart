import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/menu/menu_widgets.dart';

class PosPrinter {
  final String name;
  final String address;
  final String role; // kitchen, bar, receipt
  final String paperWidth; // 80mm, 58mm
  bool isConnected;

  PosPrinter({
    required this.name,
    required this.address,
    required this.role,
    required this.paperWidth,
    this.isConnected = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'role': role,
    'paperWidth': paperWidth,
  };

  factory PosPrinter.fromJson(Map<String, dynamic> json) => PosPrinter(
    name: json['name'],
    address: json['address'],
    role: json['role'],
    paperWidth: json['paperWidth'],
  );
}

class PrinterManagementView extends StatefulWidget {
  const PrinterManagementView({super.key});

  @override
  State<PrinterManagementView> createState() => _PrinterManagementViewState();
}

class _PrinterManagementViewState extends State<PrinterManagementView> {
  final List<PosPrinter> _configuredPrinters = [];
  final List<PrinterDevice> _foundDevices = [];
  bool _isScanning = false;
  StreamSubscription<PrinterDevice>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? printersJson = prefs.getString('configured_printers');
    if (printersJson != null) {
      final List<dynamic> decoded = jsonDecode(printersJson);
      setState(() {
        _configuredPrinters.clear();
        _configuredPrinters.addAll(
          decoded.map((item) => PosPrinter.fromJson(item)),
        );
      });
    }
  }

  Future<void> _savePrinters() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _configuredPrinters.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('configured_printers', encoded);
  }

  void _startScan() {
    setState(() {
      _foundDevices.clear();
      _isScanning = true;
    });

    _scanSubscription = PrinterManager.instance
        .discovery(type: PrinterType.bluetooth, isBle: false)
        .listen((device) {
          setState(() {
            if (!_foundDevices.any((d) => d.address == device.address)) {
              _foundDevices.add(device);
            }
          });
        });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isScanning = false);
        _scanSubscription?.cancel();
      }
    });
  }

  Future<void> _testPrinter(PosPrinter printer) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecting to ${printer.name}...')),
      );

      // Connect to the printer
      bool isConnected = await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: printer.name,
          address: printer.address,
          isBle: false,
        ),
      );

      if (!isConnected) {
        throw Exception('Could not connect to printer');
      }

      // Generate ESC/POS test receipt
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        printer.paperWidth == '80mm' ? PaperSize.mm80 : PaperSize.mm58,
        profile,
      );
      List<int> bytes = [];

      bytes += generator.text(
        'TEST RECEIPT',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'Epson TM-m30II',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Role: ${printer.role}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send to printer
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test receipt printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePrinter(int index) {
    setState(() {
      _configuredPrinters.removeAt(index);
    });
    _savePrinters();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBluetoothScanner(),
                  const SizedBox(height: 32),
                  _buildConfiguredPrintersGrid(),
                  const SizedBox(height: 32),
                  _buildBottomInfo(),
                ],
              ),
            ),
          ),
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
              'Printer & Device Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure Bluetooth printers and assign roles',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddPrinterDialog(),
          icon: const Icon(Icons.add, size: 20, color: Colors.white),
          label: const Text(
            'Add Printer',
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

  Widget _buildBluetoothScanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bluetooth Scanner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover nearby Bluetooth printers',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _startScan,
            icon: _isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.bluetooth, size: 18, color: Colors.white),
            label: Text(
              _isScanning ? 'Scanning...' : 'Scan for Devices',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_foundDevices.isNotEmpty || _isScanning) ...[
            const SizedBox(height: 24),
            const Text(
              'Found Devices:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._foundDevices.map((device) => _buildFoundDeviceTile(device)),
          ],
        ],
      ),
    );
  }

  Widget _buildFoundDeviceTile(PrinterDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                device.address ?? 'No Address',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Text(
              'Available',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguredPrintersGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 900 ? 1 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
          ),
          itemCount: _configuredPrinters.length,
          itemBuilder: (context, index) =>
              _buildPrinterCard(_configuredPrinters[index], index),
        );
      },
    );
  }

  Widget _buildPrinterCard(PosPrinter printer, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.print_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '${printer.role[0].toUpperCase()}${printer.role.substring(1)} Printer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: printer.isConnected,
                onChanged: (v) => setState(() => printer.isConnected = v),
                activeThumbColor: const Color(0xFF0F172A),
              ),
            ],
          ),
          Text(
            printer.address,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const Spacer(),
          _buildPrinterDetailRow('Role:', printer.role, true),
          const SizedBox(height: 8),
          _buildPrinterDetailRow('Paper Width:', printer.paperWidth, false),
          const SizedBox(height: 8),
          _buildPrinterDetailRow('Status:', 'Paired', true),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _testPrinter(printer),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Test'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _removePrinter(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterDetailRow(String label, String value, bool isPill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500])),
        if (isPill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toLowerCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Text(
        'Printers assigned to Kitchen, Bar, Counter, or Kiosk roles will automatically receive orders for their respective stations. Receipt printers are used for customer receipts at checkout.',
        style: TextStyle(color: Color(0xFF64748B), height: 1.5),
      ),
    );
  }

  void _showAddPrinterDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    String role = 'receipt';
    String paperWidth = '80mm';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Add Printer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuDialogField(
                  label: 'Printer Name',
                  controller: nameController,
                  hint: 'e.g. Kitchen Printer',
                ),
                const SizedBox(height: 16),
                MenuDialogField(
                  label: 'MAC Address',
                  controller: addressController,
                  hint: '00:11:22:33:44:55',
                ),
                const SizedBox(height: 16),
                MenuDialogDropdown<String>(
                  label: 'Role',
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'kitchen', child: Text('Kitchen')),
                    DropdownMenuItem(value: 'bar', child: Text('Bar')),
                    DropdownMenuItem(value: 'receipt', child: Text('Receipt')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                const SizedBox(height: 16),
                MenuDialogDropdown<String>(
                  label: 'Paper Width',
                  value: paperWidth,
                  items: const [
                    DropdownMenuItem(value: '80mm', child: Text('80mm')),
                    DropdownMenuItem(value: '58mm', child: Text('58mm')),
                  ],
                  onChanged: (v) => setDialogState(() => paperWidth = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    addressController.text.isEmpty) {
                  return;
                }
                setState(() {
                  _configuredPrinters.add(
                    PosPrinter(
                      name: nameController.text,
                      address: addressController.text,
                      role: role,
                      paperWidth: paperWidth,
                    ),
                  );
                });
                _savePrinters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
