class Item {
  final String? id;               // Firestore doc ID
  final String category;
  final String? subcategory;
  final String name;
  final int quantity;
  final double price;

  Item({
    this.id,
    required this.category,
    this.subcategory,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'subcategory': subcategory,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory Item.fromFirestore(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      category: map['category'] ?? "",
      subcategory: map['subcategory'],
      name: map['name'] ?? "",
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
    );
  }
}
