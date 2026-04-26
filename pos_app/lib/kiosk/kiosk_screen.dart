import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import '../main.dart';
import '../login_screen.dart';
import '../shared/responsive_layout.dart';
import '../shared/data_cache.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  bool _hasStarted = false;
  final List<_KioskCartItem> _cart = [];
  List<Product> _allProducts = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
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
        DataCache.instance.getProducts(client),
        DataCache.instance.getCategories(client),
      ]);

      if (mounted) {
        setState(() {
          _allProducts = (results[0] as List<Product>).where((p) {
            return p.type == 'Takeaway' || p.type == 'Both' || p.type == null;
          }).toList();
          _categories = (results[1] as List<Category>).where((c) {
            return c.orderType == 'Takeaway' || c.orderType == 'Both';
          }).toList();
          
          if (_selectedCategoryId != null &&
              !_categories.any((c) => c.id == _selectedCategoryId)) {
            _selectedCategoryId = null;
          }
        });
      }
    } catch (e) {
      // Silently fail for background updates
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        DataCache.instance.getProducts(client),
        DataCache.instance.getCategories(client),
      ]);

      if (mounted) {
        setState(() {
          _allProducts = (results[0] as List<Product>).where((p) {
            return p.type == 'Takeaway' || p.type == 'Both' || p.type == null;
          }).toList();
          _categories = (results[1] as List<Category>).where((c) {
            return c.orderType == 'Takeaway' || c.orderType == 'Both';
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu: $e')));
      }
    }
  }

  void _resetKiosk() {
    setState(() {
      _hasStarted = false;
      _cart.clear();
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStarted) {
      return _buildSplashScreen();
    }

    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: const Text(
                'Takeaway Order',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              actions: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                        if (_cart.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_cart.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
              ],
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildCategorySidebar()) : null,
      endDrawer: isMobile ? Drawer(child: SafeArea(child: _buildCartSidebar())) : null,
      body: Row(
        children: [
          // Left Sidebar: Categories
          if (!isMobile) _buildCategorySidebar(),

          // Main Content: Product Grid
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _buildTopBar(),
                Expanded(child: _buildProductGrid()),
              ],
            ),
          ),

          // Right Sidebar: Cart Summary
          if (!isMobile) _buildCartSidebar(),
        ],
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _hasStarted = true),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 120, color: Colors.white),
              const SizedBox(height: 48),
              const Text(
                'Welcome to\nOur Restaurant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TAKEAWAY ONLY',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 80),
              _buildAnimatedTapToStart(),
              const SizedBox(height: 120),
              TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.logout, color: Colors.white54),
                label: const Text(
                  'Exit Kiosk',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTapToStart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, color: Color(0xFF0F172A), size: 32),
          SizedBox(width: 16),
          Text(
            'TAP TO START',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      width: 140,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildCategoryItem(null, 'All', Icons.grid_view_rounded),
          ..._categories.map((c) => _buildCategoryItem(c.id, c.name, null)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int? id, String name, IconData? icon) {
    final isSelected = _selectedCategoryId == id;
    return InkWell(
      onTap: () {
        setState(() => _selectedCategoryId = id);
        if (ResponsiveLayout.isMobile(context) && Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          border: isSelected
              ? null
              : Border(bottom: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Column(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 32,
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.white,
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your items',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Takeaway Order',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _resetKiosk,
            icon: const Icon(Icons.home_outlined, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredProducts = _allProducts.where((p) {
      return _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
    }).toList();

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 32),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: ResponsiveLayout.isMobile(context) ? 400 : 250,
        childAspectRatio: ResponsiveLayout.isMobile(context) ? 3.0 : 0.85,
        crossAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
        mainAxisSpacing: ResponsiveLayout.isMobile(context) ? 16 : 24,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) =>
          _buildProductCard(filteredProducts[index]),
    );
  }

  Widget _buildProductCard(Product p) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return InkWell(
      onTap: () => _addToCart(p),
      borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isMobile
            ? Row(
                children: [
                  Container(
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Icon(Icons.fastfood_rounded, size: 40, color: Colors.grey[300]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '€${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for image
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fastfood_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '€${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F172A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCartSidebar() {
    final subtotal = _cart.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Container(
      width: 360,
      color: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(32),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 32),
                SizedBox(width: 16),
                Text(
                  'Your Order',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) => _buildCartItem(index),
                  ),
          ),
          if (_cart.isNotEmpty) _buildCartSummary(subtotal),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[100]),
          const SizedBox(height: 24),
          Text(
            'Your bag is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cart[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () => _updateQty(index, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildQtyBtn(Icons.add, () => _updateQty(index, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCartSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'CHECKOUT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product p) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == p.id);
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(_KioskCartItem(product: p, quantity: 1));
      }
    });
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final orderItems = _cart
          .map(
            (item) => OrderItem(
              productId: item.product.id!,
              productName: item.product.name,
              productStation: item.product.station,
              quantity: item.quantity,
              price: item.product.price,
              totalPrice: item.product.price * item.quantity,
              orderId: 0,
            ),
          )
          .toList();

      final total = _cart.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      await client.orders.create(
        total,
        'Takeaway',
        null,
        null,
        'Kiosk',
        orderItems,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order failed: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(48),
          width: ResponsiveLayout.isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 120,
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please take your receipt and wait for your number.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetKiosk();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KioskCartItem {
  final Product product;
  int quantity;

  _KioskCartItem({required this.product, required this.quantity});
}
