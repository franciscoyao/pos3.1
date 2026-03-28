import 'dart:math';
import 'package:flutter/material.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';
import '../shared/socket_service.dart';
import 'dart:async';

/// The order-taking view — renders as a widget (no Scaffold) so WaiterShell can embed it.
class NewOrderView extends StatefulWidget {
  final User user;
  final String? prefilledTable; // optionally set when coming from Tables view
  final VoidCallback? onOrderSent;

  const NewOrderView({super.key, required this.user, this.prefilledTable, this.onOrderSent});

  @override
  State<NewOrderView> createState() => NewOrderViewState();
}

class NewOrderViewState extends State<NewOrderView> {
  final ApiService apiService = ApiService();
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Category> allCategories = [];
  List<Subcategory> allSubcategories = [];
  List<Product> allProducts = [];
  List<Product> displayedProducts = [];
  List<Product> popularProducts = [];
  List<OrderItem> cart = [];

  List<Category> get filteredCategories {
    return allCategories.where((c) {
      if (c.id == 0) return true; // 'All' category always shows
      if (c.orderType == null || c.orderType == 'Both') return true;
      return c.orderType == orderType;
    }).toList();
  }

  String orderType = 'Dine-In';
  int selectedCategoryId = 0;
  int selectedSubcategoryId = 0;
  bool isLoading = true;
  StreamSubscription? _productSub;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledTable != null) {
      _tableController.text = widget.prefilledTable!;
    }
    _loadData();
    _searchController.addListener(_filterProducts);
    _productSub = SocketService().onProductUpdated.listen((_) {
      if (mounted) _loadData();
    });
  }

  /// Public method so WaiterShell can call with a table pre-filled.
  void presetTable(String tableNumber) {
    setState(() {
      _tableController.text = tableNumber;
      orderType = 'Dine-In';
    });
  }

  @override
  void didUpdateWidget(NewOrderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prefilledTable != oldWidget.prefilledTable && widget.prefilledTable != null) {
      _tableController.text = widget.prefilledTable!;
    }
  }

  @override
  void dispose() {
    _productSub?.cancel();
    _tableController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularProducts() async {
    try {
      final popular = await apiService.fetchPopularProducts(orderType);
      if (mounted) {
        setState(() => popularProducts = popular);
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    try {
      final cats = await apiService.fetchCategories();
      final prods = await apiService.fetchProducts();
      final subcats = await apiService.fetchSubcategories();
      setState(() {
        allCategories = [Category(id: 0, name: 'All'), ...cats];
        allProducts = prods;
        allSubcategories = subcats;
        isLoading = false;
      });
      _loadPopularProducts();
      _filterProducts();
    } catch (_) {
      setState(() {
        allCategories = [Category(id: 0, name: 'All')];
        allProducts = [];
        allSubcategories = [];
        isLoading = false;
      });
      _filterProducts();
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    
    // Only allow products that belong to categories valid for this order type
    final validCategoryIds = filteredCategories.map((c) => c.id).toSet();
    
    setState(() {
      displayedProducts = allProducts.where((p) {
        if (!validCategoryIds.contains(p.categoryId)) return false;
        
        final matchesCategory = selectedCategoryId == 0 || p.categoryId == selectedCategoryId;
        final matchesSubcat = selectedSubcategoryId == 0 || p.subcategoryId == selectedSubcategoryId;
        final matchesSearch = p.name.toLowerCase().contains(query);
        return matchesCategory && matchesSubcat && matchesSearch;
      }).toList();
    });
  }

  void _selectCategory(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedSubcategoryId = 0;
    });
    _filterProducts();
  }

  void _selectSubcategory(int subId) {
    setState(() => selectedSubcategoryId = subId);
    _filterProducts();
  }

  void _showExtrasDialog(Product product) {
    List<ProductExtra> selected = [];
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Customize ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: product.extras.map((e) {
                    final isChecked = selected.contains(e);
                    return CheckboxListTile(
                      title: Text(e.name),
                      subtitle: Text('+\$${e.price.toStringAsFixed(2)}'),
                      value: isChecked,
                      activeColor: const Color(0xFF0F172A),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selected.add(e);
                          } else {
                            selected.remove(e);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _finishAddToCart(product, selected);
                  },
                  child: const Text('Add to Order'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void addToCart(Product product) {
    if (product.extras.isNotEmpty) {
      _showExtrasDialog(product);
    } else {
      _finishAddToCart(product, []);
    }
  }

  void _finishAddToCart(Product product, List<ProductExtra> selectedExtras) {
    setState(() {
      final idx = cart.indexWhere((item) {
        if (item.product.id != product.id) return false;
        if (item.selectedExtras.length != selectedExtras.length) return false;
        final itemExtraIds = item.selectedExtras.map((e) => e.id).toSet();
        final newExtraIds = selectedExtras.map((e) => e.id).toSet();
        return itemExtraIds.containsAll(newExtraIds);
      });

      if (idx >= 0) {
        cart[idx].quantity++;
      } else {
        cart.add(OrderItem(product: product, selectedExtras: selectedExtras));
      }
    });
  }

  void _increment(int index) => setState(() => cart[index].quantity++);
  void _decrement(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }
  void _remove(int index) => setState(() => cart.removeAt(index));

  double get cartSubtotal => cart.fold(0, (s, i) => s + i.totalPrice);
  int get cartItemCount => cart.fold(0, (s, i) => s + i.quantity);

  String _generateOrderCode() => 'ORD-${Random().nextInt(9000) + 1000}';

  Future<void> _sendOrder() async {
    if (cart.isEmpty) return;
    if (orderType == 'Dine-In' && _tableController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Table Number for Dine-In orders.'), backgroundColor: Colors.red),
      );
      return;
    }
    final orderCode = _generateOrderCode();
    try {
      final success = await apiService.submitOrder(
        cartSubtotal, cart,
        orderType: orderType,
        tableNo: orderType == 'Dine-In' ? _tableController.text.trim() : null,
        orderCode: orderCode,
        waiterName: widget.user.fullName ?? widget.user.username,
      );
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order $orderCode sent!'), backgroundColor: const Color(0xFF10B981)),
        );
        setState(() { cart.clear(); _tableController.clear(); });
        widget.onOrderSent?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send order. Try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Row(
      children: [
        Expanded(child: _buildMenuArea()),
        _buildCartPanel(),
      ],
    );
  }

  Widget _buildTopOrderBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        // Toggle
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(4),
          child: Row(children: [_toggleOption('Dine-In'), _toggleOption('Takeaway')]),
        ),
        const SizedBox(width: 16),
        // Table
        AnimatedOpacity(
          opacity: orderType == 'Dine-In' ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 180,
            child: TextField(
              controller: _tableController,
              enabled: orderType == 'Dine-In',
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.table_chart_outlined, size: 18, color: Color(0xFF94A3B8)),
                hintText: 'Table No.',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _toggleOption(String label) {
    final isSelected = orderType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          orderType = label;
          selectedCategoryId = 0;
          selectedSubcategoryId = 0;
        });
        _filterProducts();
        _loadPopularProducts();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildMenuArea() {
    final popular = popularProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopOrderBar(),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
              hintText: 'Search menu...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F172A))),
            ),
          ),
        ),

        // Popular row
        if (popular.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(children: [
              Icon(Icons.trending_up, size: 15, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text('Most Selling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
            ]),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: popular.map((p) => _popularCard(p)).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Category chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredCategories.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = filteredCategories[i];
                final isSelected = selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => _selectCategory(cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(cat.name, style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600, fontSize: 13,
                    )),
                  ),
                );
              },
            ),
          ),
        ),

        // Subcategory chips (only shown when a category is selected and has subcategories)
        Builder(builder: (context) {
          final subcats = allSubcategories.where((s) => s.categoryId == selectedCategoryId).toList();
          if (selectedCategoryId == 0 || subcats.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: subcats.length + 1, // +1 for "All"
                separatorBuilder: (ctx, i) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    final isSelected = selectedSubcategoryId == 0;
                    return GestureDetector(
                      onTap: () => _selectSubcategory(0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('All', style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600, fontSize: 12,
                        )),
                      ),
                    );
                  }
                  final sub = subcats[i - 1];
                  final isSelected = selectedSubcategoryId == sub.id;
                  return GestureDetector(
                    onTap: () => _selectSubcategory(sub.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(sub.name, style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600, fontSize: 12,
                      )),
                    ),
                  );
                },
              ),
            ),
          );
        }),

        // Product grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: displayedProducts.isEmpty
                ? const Center(child: Text('No products found.', style: TextStyle(color: Color(0xFF94A3B8))))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.6,
                      crossAxisSpacing: 10, mainAxisSpacing: 10,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (ctx, i) => _productCard(displayedProducts[i]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _popularCard(Product p) {
    return Container(
      width: 200, margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
              child: const Text('Popular', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ),
            const SizedBox(height: 6),
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => addToCart(p),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product p) {
    return GestureDetector(
      onTap: () => addToCart(p),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(7)),
              child: const Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildCartPanel() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(children: [
            const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF0F172A)),
            const SizedBox(width: 8),
            const Text('Current Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (cart.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                child: Text('$cartItemCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
            const Spacer(),
            if (cart.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => cart.clear()),
                child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              ),
          ]),
        ),

        // Cart items or empty state
        if (cart.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(orderType == 'Dine-In' ? 'Enter a table,\nthen add items' : 'Cart is empty',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ])))
        else
          Expanded(child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: cart.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, i) => _CartItemWidget(
              item: cart[i],
              onIncrement: () => _increment(i),
              onDecrement: () => _decrement(i),
              onRemove: () => _remove(i),
              onNotesChanged: (v) => setState(() => cart[i].notes = v),
            ),
          )),

        // Footer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtotal:', style: TextStyle(color: Color(0xFF64748B))),
              Text('\$${cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: cart.isEmpty ? null : _sendOrder,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Send Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Cart Item Widget ──────────────────────────────────────────────

class _CartItemWidget extends StatefulWidget {
  final OrderItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final void Function(String?) onNotesChanged;

  const _CartItemWidget({
    required this.item, required this.onIncrement, required this.onDecrement,
    required this.onRemove, required this.onNotesChanged,
  });

  @override
  State<_CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<_CartItemWidget> {
  bool _showDetails = false;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.item.notes ?? '';
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(widget.item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          GestureDetector(onTap: widget.onRemove, child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444))),
        ]),
        if (widget.item.selectedExtras.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.item.selectedExtras.map((e) => Text('+ ${e.name} (\$${e.price.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))).toList(),
            ),
          ),
        const SizedBox(height: 8),
        Row(children: [
          _qtyBtn(Icons.remove, widget.onDecrement),
          const SizedBox(width: 10),
          Text('${widget.item.quantity}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          _qtyBtn(Icons.add, widget.onIncrement),
          const Spacer(),
          Text('\$${widget.item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _showDetails = !_showDetails),
          child: Text(_showDetails ? 'Hide details' : '+ Add details',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), decoration: TextDecoration.underline)),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _showDetails
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _notesCtrl,
                    onChanged: widget.onNotesChanged,
                    maxLines: 2, style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Special instructions...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                      contentPadding: const EdgeInsets.all(10),
                      filled: true, fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: const Color(0xFF0F172A)),
    ),
  );
}
