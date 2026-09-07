import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/item.dart';
import '../main.dart'; // ThemeProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tyreSubTabController;

  final List<String> _categories = ['Tyres', 'Tubes', 'Helmets', 'Visors'];

  final List<String> _tyreSubCategories = ['Scooter', 'Bike', 'Car'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _categories.length, vsync: this);
    _tyreSubTabController =
        TabController(length: _tyreSubCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _tyreSubTabController.dispose();
    super.dispose();
  }

  /// Add Item Popup
  void _addNewItemDialog(BuildContext context, String category,
      {String? subcategory}) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subcategory != null
            ? 'Add $subcategory $category'
            : 'Add $category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            if (category == 'Tyres')
              Text(
                  "Subcategory: ${subcategory ?? _tyreSubCategories[_tyreSubTabController.index]}"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final qty = int.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (name.isNotEmpty) {
                final provider =
                    Provider.of<InventoryProvider>(context, listen: false);

                final sub = subcategory ??
                    (category == "Tyres"
                        ? _tyreSubCategories[_tyreSubTabController.index]
                        : null);

                provider.addItem(
                  Item(
                    category: category,
                    subcategory: sub,
                    name: name,
                    quantity: qty,
                    price: price,
                  ),
                );
              }

              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Edit Item Popup
  void _editItemDialog(BuildContext context, Item item) {
    final nameController = TextEditingController(text: item.name);
    final qtyController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.price.toString());
    String currentSub = item.subcategory ?? "Scooter";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            if (item.category == 'Tyres')
              DropdownButtonFormField<String>(
                initialValue: currentSub,
                items: _tyreSubCategories
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => currentSub = val ?? currentSub,
                decoration: const InputDecoration(labelText: 'Subcategory'),
              )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updated = Item(
                id: item.id,
                category: item.category,
                subcategory:
                    item.category == "Tyres" ? currentSub : item.subcategory,
                name: nameController.text.trim(),
                quantity: int.tryParse(qtyController.text) ?? 0,
                price: double.tryParse(priceController.text) ?? 0.0,
              );

              Provider.of<InventoryProvider>(context, listen: false)
                  .updateItem(updated);

              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = Provider.of<InventoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Manager"),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.sunny
                : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search items...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                if (category == "Tyres") {
                  return Column(
                    children: [
                      // FIX: Sub-Tabs clearly visible in dark mode
                      TabBar(
                        controller: _tyreSubTabController,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: _tyreSubCategories
                            .map((s) => Tab(text: s))
                            .toList(),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tyreSubTabController,
                          children: _tyreSubCategories.map((sub) {
                            List<Item> items = inventory
                                .getItemsByCategory("Tyres", subcategory: sub)
                                .where((i) =>
                                    i.name.toLowerCase().contains(_searchQuery))
                                .toList();

                            return _buildItemList(items, inventory);
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }

                // Other categories
                List<Item> items = inventory
                    .getItemsByCategory(category)
                    .where((i) => i.name.toLowerCase().contains(_searchQuery))
                    .toList();

                return _buildItemList(items, inventory);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final cat = _categories[_tabController.index];
          String? sub;

          if (cat == "Tyres") {
            sub = _tyreSubCategories[_tyreSubTabController.index];
          }

          _addNewItemDialog(context, cat, subcategory: sub);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemList(List<Item> items, InventoryProvider provider) {
    if (items.isEmpty) {
      return const Center(child: Text("No items found."));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(item.name),
            subtitle: Text("Qty: ${item.quantity} • ₹${item.price}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editItemDialog(ctx, item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteItem(item.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
