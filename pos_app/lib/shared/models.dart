class Category {
  final int id;
  final String name;
  final int sortOrder;
  final String? station;
  final String? orderType;

  Category({required this.id, required this.name, this.sortOrder = 0, this.station, this.orderType = 'Both'});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'], 
      name: json['name'], 
      sortOrder: json['sort_order'] ?? 0, 
      station: json['station'],
      orderType: json['order_type'] ?? 'Both',
    );
  }
}

class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final int sortOrder;

  Subcategory({required this.id, required this.categoryId, required this.name, this.sortOrder = 0});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class ProductExtra {
  final int? id;
  final int? productId;
  final String name;
  final double price;

  ProductExtra({this.id, this.productId, required this.name, this.price = 0});

  factory ProductExtra.fromJson(Map<String, dynamic> json) {
    return ProductExtra(
      id: json['id'],
      productId: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'name': name,
    'price': price,
  };
}

class Product {
  final int id;
  final int categoryId;
  final int? subcategoryId;
  final String? itemCode;
  final String name;
  final double price;
  final String? imageUrl;
  final String? station;
  final String? type;
  final bool isAvailable;
  final bool allowPriceEdit;
  final List<ProductExtra> extras;

  Product({
    required this.id, required this.categoryId, this.subcategoryId, this.itemCode, required this.name,
    required this.price, this.imageUrl, this.station, this.type,
    this.isAvailable = true, this.allowPriceEdit = false, this.extras = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], categoryId: json['category_id'], subcategoryId: json['subcategory_id'], itemCode: json['item_code'],
      name: json['name'], price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'], station: json['station'], type: json['type'],
      isAvailable: json['is_available'] ?? true, allowPriceEdit: json['allow_price_edit'] ?? false,
      extras: json['extras'] != null ? (json['extras'] as List).map((e) => ProductExtra.fromJson(e)).toList() : [],
    );
  }
}

class OrderItem {
  final Product product;
  int quantity;
  String? notes;
  List<ProductExtra> selectedExtras;

  OrderItem({required this.product, this.quantity = 1, this.notes, this.selectedExtras = const []});

  double get unitPrice => product.price + selectedExtras.fold(0.0, (s, e) => s + e.price);
  double get totalPrice => unitPrice * quantity;
}

class User {
  final int id;
  final String? fullName;
  final String username;
  final String? pin;
  final String role;
  final String status;
  final DateTime? createdAt;
  final bool isDefault;

  User({
    required this.id, this.fullName, required this.username, this.pin,
    required this.role, this.status = 'Active', this.createdAt, this.isDefault = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], fullName: json['full_name'], username: json['username'] ?? '',
      pin: json['pin'], role: json['role'], status: json['status'] ?? 'Active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isDefault: json['is_default'] ?? false,
    );
  }
}

class TableRecord {
  final int id;
  final String tableNumber;
  String status; // Available, Occupied, Reserved
  String? orderCode;
  int guestCount;

  TableRecord({
    required this.id, required this.tableNumber, this.status = 'Available',
    this.orderCode, this.guestCount = 0,
  });

  factory TableRecord.fromJson(Map<String, dynamic> json) {
    return TableRecord(
      id: json['id'], tableNumber: json['table_number'],
      status: json['status'] ?? 'Available', orderCode: json['order_code'],
      guestCount: json['guest_count'] ?? 0,
    );
  }
}

class OrderDetailItem {
  final int id;
  final int quantity;
  final double price;
  final String name;
  final String? notes;
  final String? station;
  final List<ProductExtra> extras;

  OrderDetailItem({required this.id, required this.quantity, required this.price, required this.name, this.notes, this.station, this.extras = const []});

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'], price: double.parse(json['price'].toString()),
      name: json['name'], notes: json['notes'], station: json['station'],
      extras: json['extras'] != null ? (json['extras'] as List).map((e) => ProductExtra.fromJson(e)).toList() : [],
    );
  }

  double get totalPrice => price * quantity;
}

class Order {
  final int id;
  final String? orderCode;
  final String? orderType;
  final String? tableNo;
  final String status;
  final String? waiterName;
  final double total;
  final DateTime createdAt;
  final List<OrderDetailItem> items;

  Order({
    required this.id, this.orderCode, this.orderType, this.tableNo,
    this.status = 'Pending', this.waiterName, required this.total,
    required this.createdAt, this.items = const [],
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'], orderCode: json['order_code'], orderType: json['order_type'],
      tableNo: json['table_no'], status: json['status'] ?? 'Pending',
      waiterName: json['waiter_name'], total: double.parse(json['total'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderDetailItem.fromJson(i)).toList()
          : [],
    );
  }
}

class Bill {
  final int id;
  final String billNumber;
  final String? orderType;
  final String? tableNo;
  final String? waiterName;
  final String? paymentMethod;
  final String? taxNumber;
  final double subtotal;
  final double taxAmount;
  final double serviceAmount;
  final double tipAmount;
  final double total;
  final DateTime createdAt;
  final List<OrderDetailItem>? items;

  Bill({
    required this.id, required this.billNumber, this.orderType, this.tableNo,
    this.waiterName, this.paymentMethod, this.taxNumber, required this.subtotal,
    required this.taxAmount, required this.serviceAmount, required this.tipAmount,
    required this.total, required this.createdAt, this.items,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'], billNumber: json['bill_number'], orderType: json['order_type'],
      tableNo: json['table_no'], waiterName: json['waiter_name'],
      paymentMethod: json['payment_method'], taxNumber: json['tax_number'],
      subtotal: double.parse(json['subtotal'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      serviceAmount: double.parse(json['service_amount'].toString()),
      tipAmount: double.parse(json['tip_amount'].toString()),
      total: double.parse(json['total'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderDetailItem.fromJson(i)).toList()
          : null,
    );
  }
}

// ─── Reports ─────────────────────────────────────────────────────────────────

class SalesByDay {
  final String day;
  final double revenue;
  final int orders;

  SalesByDay({required this.day, required this.revenue, required this.orders});

  factory SalesByDay.fromJson(Map<String, dynamic> json) => SalesByDay(
    day: json['day'],
    revenue: (json['revenue'] as num).toDouble(),
    orders: (json['orders'] as num).toInt(),
  );
}

class SalesByCategory {
  final String category;
  final double revenue;

  SalesByCategory({required this.category, required this.revenue});

  factory SalesByCategory.fromJson(Map<String, dynamic> json) => SalesByCategory(
    category: json['category'],
    revenue: (json['revenue'] as num).toDouble(),
  );
}

class TopItem {
  final String name;
  final int totalQty;
  final double totalRevenue;

  TopItem({required this.name, required this.totalQty, required this.totalRevenue});

  factory TopItem.fromJson(Map<String, dynamic> json) => TopItem(
    name: json['name'],
    totalQty: (json['total_qty'] as num).toInt(),
    totalRevenue: (json['total_revenue'] as num).toDouble(),
  );
}

class ReportSummary {
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final List<SalesByDay> salesByDay;
  final List<SalesByCategory> salesByCategory;
  final List<TopItem> topItems;

  ReportSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.salesByDay,
    required this.salesByCategory,
    required this.topItems,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
    totalRevenue: (json['total_revenue'] as num).toDouble(),
    totalOrders: (json['total_orders'] as num).toInt(),
    avgOrderValue: (json['avg_order_value'] as num).toDouble(),
    salesByDay: (json['sales_by_day'] as List).map((e) => SalesByDay.fromJson(e)).toList(),
    salesByCategory: (json['sales_by_category'] as List).map((e) => SalesByCategory.fromJson(e)).toList(),
    topItems: (json['top_items'] as List).map((e) => TopItem.fromJson(e)).toList(),
  );
}

