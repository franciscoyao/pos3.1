import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_server_client/pos_server_client.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  final PrinterManager _printerManager = PrinterManager.instance;

  PrinterDevice? selectedPrinter;
  bool isConnected = false;

  StreamSubscription<PrinterDevice>? _subscription;

  final StreamController<List<PrinterDevice>> _devicesController =
      StreamController<List<PrinterDevice>>.broadcast();
  Stream<List<PrinterDevice>> get devicesStream => _devicesController.stream;

  final List<PrinterDevice> _devices = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('saved_printer_address');
    final savedName = prefs.getString('saved_printer_name');

    if (savedAddress != null && savedName != null) {
      selectedPrinter = PrinterDevice(name: savedName, address: savedAddress);
    }

    _printerManager.stateBluetooth.listen((status) {
      if (status == BTStatus.connected) {
        isConnected = true;
      } else {
        isConnected = false;
      }
    });
  }

  void startScan() {
    _devices.clear();
    _devicesController.add(_devices);

    _subscription?.cancel();
    _subscription = _printerManager
        .discovery(type: PrinterType.bluetooth)
        .listen((PrinterDevice device) {
          if (!_devices.any((d) => d.address == device.address)) {
            _devices.add(device);
            _devicesController.add(_devices);
          }
        });
  }

  void stopScan() {
    _subscription?.cancel();
  }

  Future<void> connect(PrinterDevice device) async {
    await _printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: device.name,
        address: device.address ?? '',
        isBle: false,
        autoConnect: false,
      ),
    );
    selectedPrinter = device;
    isConnected = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_printer_address', device.address ?? '');
    await prefs.setString('saved_printer_name', device.name);
    await prefs.setString('saved_printer_type', 'bluetooth');
  }

  Future<void> disconnect() async {
    if (selectedPrinter != null) {
      await _printerManager.disconnect(type: PrinterType.bluetooth);
      isConnected = false;
    }
  }

  Future<void> testPrint() async {
    if (!isConnected || selectedPrinter == null) return;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.text(
      'POS System',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Test Print Successful!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    await _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }

  Future<void> printReceipt(
    Bill bill, {
    List<OrderItem> items = const [],
  }) async {
    if (!isConnected || selectedPrinter == null) return;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'RESTAURANT POS',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Bill: ${bill.billNumber}',
      styles: const PosStyles(bold: true),
    );
    if (bill.tableNo != null) {
      bytes += generator.text('Table: ${bill.tableNo}');
    }
    if (bill.orderType != null) {
      bytes += generator.text('Type: ${bill.orderType}');
    }
    if (bill.waiterName != null) {
      bytes += generator.text('Waiter: ${bill.waiterName}');
    }
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );

    for (final item in items) {
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}x ${item.productName}',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: '\$${item.totalPrice.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 8,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '\$${bill.total.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    await _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }

  Future<void> printKOT(
    PosOrder order, {
    required String station,
    required List<OrderItem> items,
  }) async {
    if (!isConnected || selectedPrinter == null) return;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'KITCHEN ORDER: $station',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Order: #${order.orderCode?.substring(order.orderCode!.length - 4)}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    );
    if (order.tableNo != null) {
      bytes += generator.text(
        'Table: ${order.tableNo}',
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      );
    } else {
      bytes += generator.text(
        'Type: Takeaway',
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      );
    }
    bytes += generator.text('Time: ${DateFormat('hh:mm a').format(DateTime.now())}');
    bytes += generator.text('Waiter: ${order.waiterName ?? "System"}');
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );

    for (final item in items) {
      bytes += generator.text(
        '${item.quantity}x ${item.productName}',
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      if (item.notes != null && item.notes!.isNotEmpty) {
        bytes += generator.text('  NOTES: ${item.notes}');
      }
      bytes += generator.feed(1);
    }

    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    await _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }
}
