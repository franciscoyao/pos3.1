import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'printer_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final PrinterService _printerService = PrinterService();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _printerService.init();
  }

  @override
  void dispose() {
    _printerService.stopScan();
    super.dispose();
  }

  void _toggleScan() {
    if (_isScanning) {
      _printerService.stopScan();
    } else {
      _printerService.startScan();
    }
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  Future<void> _connect(PrinterDevice device) async {
    try {
      await _printerService.connect(device);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Connected to ${device.name}'),
        backgroundColor: Colors.green,
      ));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to connect: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _testPrintRaw() async {
    try {
      await _printerService.testPrint();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print command sent to POS printer.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _testPrintSystem() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('SYSTEM PRINTER TEST', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Date: ${DateTime.now().toString().substring(0, 16)}'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text('Everything is working perfectly!'),
                pw.Divider(),
                pw.SizedBox(height: 30),
              ]
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Test_Print_Receipt',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Printer Setup', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard OS Printer Section
            const Text('System Printer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_outlined, color: Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Standard Print Dialog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Uses your device\'s default OS printers (AirPrint, Windows Print, etc.)', 
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _testPrintSystem,
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Raw POS Printer Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Direct POS Printers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    SizedBox(height: 4),
                    Text('Scan for Bluetooth or Network raw thermal printers', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _toggleScan,
                  icon: Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching, size: 18),
                  label: Text(_isScanning ? 'Stop Search' : 'Scan for Printers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning ? Colors.red : const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_printerService.selectedPrinter != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Connected: ${_printerService.selectedPrinter!.name}', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF064E3B))),
                          const SizedBox(height: 4),
                          Text('${_printerService.selectedPrinter!.address}', 
                            style: const TextStyle(color: Color(0xFF047857), fontSize: 13)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _testPrintRaw,
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Test Print (Raw)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            StreamBuilder<List<PrinterDevice>>(
              stream: _printerService.devicesStream,
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];
                
                if (devices.isEmpty && !_isScanning) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(Icons.print_disabled, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text('No printers found', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        SizedBox(height: 4),
                        Text('Make sure your printer is turned on and discoverable.', 
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      ]
                    ),
                  );
                } else if (devices.isEmpty && _isScanning) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Color(0xFF0F172A)),
                  );
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: devices.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bluetooth, color: Color(0xFF64748B)),
                        ),
                        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(device.address ?? 'Unknown address', style: const TextStyle(fontSize: 12)),
                        trailing: OutlinedButton(
                          onPressed: () => _connect(device),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
