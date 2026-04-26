import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../shared/responsive_layout.dart';
import '../shared/data_cache.dart';

class NewOrderView extends StatefulWidget {
  final String? initialTableNo;
  final String? initialOrderType;
  final VoidCallback? onOrderCreated;

  const NewOrderView({
    super.key,
    this.initialTableNo,
    this.initialOrderType,
    this.onOrderCreated,
  });

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  late String orderType;
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> popularProducts = [];
  List<Product> allProducts = [];
  List<Category> categories = [];
  int? selectedCategoryId;
  DateTime? _scheduledTime;
  bool isLoading = true;
  StreamSubscription? _subscription;

  // Cart State
  final List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    orderType = widget.initialOrderType ?? 'Dine-In';
    _tableController.text = widget.initialTableNo ?? '';
    _loadData();
    _setupWebsocket();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _setupWebsocket() async {
    _subscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'product_updated' || event.eventType == 'category_updated') {
        _loadDataQuietly();
      }
    });
  }

  Future<void> _loadDataQuietly() async {
    try {
      final results = await Future.wait([
        DataCache.instance.getPopularProducts(client, orderType),
        DataCache.instance.getProducts(client),
        DataCache.instance.getCategories(client),
      ]);

      if (mounted) {
        setState(() {
          popularProducts = results[0] as List<Product>;
          allProducts = results[1] as List<Product>;
          categories = results[2] as List<Category>;
          
          if (selectedCategoryId != null &&
              !categories.any((c) => c.id == selectedCategoryId)) {
            selectedCategoryId = null;
          }
        });
      }
    } catch (e) {
      // Silently fail for background updates
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        DataCache.instance.getPopularProducts(client, orderType),
        DataCache.instance.getProducts(client),
        DataCache.instance.getCategories(client),
      ]);

      if (mounted) {
        setState(() {
          popularProducts = results[0] as List<Product>;
          allProducts = results[1] as List<Product>;
          categories = results[2] as List<Category>;
          if (categories.isNotEmpty && selectedCategoryId == null) {
            selectedCategoryId = null; // 'All' selected by default
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu: $e')));
      }
    }
  }

  void _addToCart(Product p) {
    setState(() {
      cart.add(CartItem(product: p, quantity: 1));
    });
  }

  void _incrementCartItem(int index) {
    setState(() {
      cart[index].quantity++;
    });
  }

  void _decrementCartItem(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  void _deleteFromCart(int index) {
    setState(() => cart.removeAt(index));
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);

  int _getCartItemCount(Product p) {
    return cart
        .where((item) => item.product.id == p.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _sendOrder() async {
    if (cart.isEmpty) return;
    if (orderType == 'Dine-In' && _tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a table number')),
      );
      return;
    }

    try {
      final orderItems = cart
          .map(
            (item) => OrderItem(
              productId: item.product.id!,
              productName: item.product.name,
              productStation: item.product.station,
              quantity: item.quantity,
              price: item.price,
              totalPrice: item.total,
              notes: item.notes,
              orderId: 0, // Server will set this
            ),
          )
          .toList();

      await client.orders.create(
        subtotal,
        orderType,
        orderType == 'Dine-In' ? _tableController.text : null,
        null, // Server will generate order code automatically
        'Current Waiter', // In real app, get from auth
        orderItems,
        scheduledTime: _scheduledTime,
      );

      if (mounted) {
        setState(() {
          cart.clear();
          _tableController.clear();
          _scheduledTime = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onOrderCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    final mainContent = Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderTypeSelector(isMobile),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMenuContent(),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: mainContent,
        floatingActionButton: cart.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: _buildCart(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF0F172A),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  '${cart.length} items - €${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      );
    }

    return Row(
      children: [
        // Main Menu Area
        Expanded(flex: 7, child: mainContent),

        // Cart Area (Right Sidebar)
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.grey[200]!)),
          ),
          child: _buildCart(),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector(bool isMobile) {
    final tableSettings = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.grid_view_rounded, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _tableController,
              decoration: const InputDecoration(
                hintText: 'Table No.',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(
            Icons.qr_code_scanner_rounded,
            size: 20,
            color: Colors.grey,
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTypeBtn('Dine-In', true)),
                Expanded(child: _buildTypeBtn('Takeaway', true)),
              ],
            ),
          ),
          if (orderType == 'Dine-In') ...[
            const SizedBox(height: 16),
            tableSettings,
          ],
          const SizedBox(height: 16),
          _buildScheduleButton(),
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTypeBtn('Dine-In', false),
              _buildTypeBtn('Takeaway', false),
            ],
          ),
        ),
        if (orderType == 'Dine-In') ...[
          const SizedBox(width: 16),
          Expanded(child: tableSettings),
        ],
        const SizedBox(width: 16),
        _buildScheduleButton(),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return InkWell(
      onTap: _selectScheduleTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _scheduledTime != null
              ? const Color(0xFF0F172A)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 20,
              color: _scheduledTime != null ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              _scheduledTime == null
                  ? 'Schedule'
                  : DateFormat('HH:mm').format(_scheduledTime!),
              style: TextStyle(
                color: _scheduledTime != null ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_scheduledTime != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _scheduledTime = null),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectScheduleTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        // If the time is in the past, assume it's for tomorrow
        if (_scheduledTime!.isBefore(now)) {
          _scheduledTime = _scheduledTime!.add(const Duration(days: 1));
        }
      });
    }
  }

  Widget _buildTypeBtn(String type, bool isMobile) {
    final isSelected = orderType == type;
    return GestureDetector(
      onTap: () {
        if (orderType != type) {
          setState(() {
            orderType = type;
          });
          _loadData(); // Reload popular items for the new type
        }
      },
      child: Container(
        alignment: isMobile ? Alignment.center : null,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 32,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search menu...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    final filteredCategories = categories.where((c) {
      return c.orderType == 'Both' || c.orderType == orderType;
    }).toList();

    // If selected category is not in the filtered list, reset it to null (All)
    if (selectedCategoryId != null &&
        !filteredCategories.any((c) => c.id == selectedCategoryId)) {
      selectedCategoryId = null;
    }

    final filteredProducts = allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final matchesCategory =
          selectedCategoryId == null || p.categoryId == selectedCategoryId;

      // Filter by Product Type (Dine-In, Takeaway, or Both)
      bool matchesOrderType = true;
      if (p.type != null && p.type != 'Both') {
        matchesOrderType = p.type == orderType;
      }

      // Also filter by Category's orderType
      if (matchesOrderType && p.categoryId != null) {
        final cat = categories.firstWhere(
          (c) => c.id == p.categoryId,
          orElse: () => Category(name: '', orderType: 'Both'),
        );
        if (cat.orderType != 'Both' && cat.orderType != orderType) {
          matchesOrderType = false;
        }
      }

      return matchesSearch && matchesCategory && matchesOrderType;
    }).toList();

    return ListView(
      children: [
        if (_searchController.text.isEmpty && selectedCategoryId == null) ...[
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Most Selling',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: popularProducts.isEmpty
                ? Center(
                    child: Text(
                      'No popular items for $orderType',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) =>
                        _buildPopularCard(popularProducts[index]),
                  ),
          ),
          const SizedBox(height: 32),
        ],

        // Category Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip(null, 'All'),
              ...filteredCategories.map(
                (c) => _buildCategoryChip(c.id, c.name),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grid of Products
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: ResponsiveLayout.isMobile(context) ? 400 : 220,
            childAspectRatio: ResponsiveLayout.isMobile(context) ? 2.5 : 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) =>
              _buildProductCard(filteredProducts[index]),
        ),
      ],
    );
  }

  Widget _buildPopularCard(Product p) {
    final count = _getCartItemCount(p);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: count > 0 ? const Color(0xFF0F172A) : Colors.grey[100]!,
          width: count > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '€${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _addToCart(p),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  minimumSize: Size(ResponsiveLayout.isMobile(context) ? 80 : 50, ResponsiveLayout.isMobile(context) ? 48 : 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontSize: ResponsiveLayout.isMobile(context) ? 14 : 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int? id, String name) {
    final isSelected = selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (val) => setState(() => selectedCategoryId = id),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: const Color(0xFF0F172A),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    final count = _getCartItemCount(p);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: count > 0 ? const Color(0xFF0F172A) : Colors.grey[100]!,
          width: count > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '€${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _addToCart(p),
                icon: Icon(Icons.add, size: ResponsiveLayout.isMobile(context) ? 24 : 18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  minimumSize: Size(ResponsiveLayout.isMobile(context) ? 48 : 32, ResponsiveLayout.isMobile(context) ? 48 : 32),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveLayout.isMobile(context) ? 12 : 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Current Order',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                orderType == 'Takeaway'
                    ? 'Takeaway Order'
                    : (_tableController.text.isEmpty
                          ? 'Select a table'
                          : 'Table: ${_tableController.text}'),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        Expanded(
          child: cart.isEmpty
              ? _buildEmptyCart()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: cart.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildCartItem(index),
                ),
        ),

        if (cart.isNotEmpty) _buildCartSummary(),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(int index) {
    final item = cart[index];
    final notesController = TextEditingController(text: item.notes);
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details: ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'e.g. No onions, Extra spicy',
              ),
            ),
            const SizedBox(height: 16),
            if (item.product.allowPriceEdit)
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Custom Price',
                  prefixText: '€',
                ),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.notes = notesController.text;
                if (item.product.allowPriceEdit) {
                  item.overridePrice = double.tryParse(priceController.text);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cart[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => _deleteFromCart(index),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQtyControl(index),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.overridePrice != null)
                    Text(
                      '€${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  Text(
                    '€${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showItemDetails(index),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: Size(80, ResponsiveLayout.isMobile(context) ? 48 : 36),
            ),
            child: Text(
              'Add details',
              style: TextStyle(fontSize: ResponsiveLayout.isMobile(context) ? 14 : 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _decrementCartItem(index),
            icon: Icon(Icons.remove, size: ResponsiveLayout.isMobile(context) ? 20 : 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          Text(
            '${cart[index].quantity}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => _incrementCartItem(index),
            icon: Icon(Icons.add, size: ResponsiveLayout.isMobile(context) ? 20 : 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '€${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items:', style: TextStyle(color: Colors.grey[600])),
              Text(
                '${cart.fold(0, (sum, item) => sum + item.quantity)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _sendOrder,
            icon: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            label: const Text(
              'Send Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  String? notes;
  double? overridePrice;

  CartItem({
    required this.product,
    required this.quantity,
    this.notes,
    this.overridePrice,
  });

  double get price => overridePrice ?? product.price;
  double get total => price * quantity;
}
