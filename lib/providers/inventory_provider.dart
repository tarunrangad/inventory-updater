import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class InventoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Item> _items = [];
  List<Item> get items => _items;

  /// REALTIME LISTENER (auto sync across devices)
  Future<void> initDatabase() async {
    _firestore.collection("inventory").snapshots().listen((snapshot) {
      _items = snapshot.docs.map((doc) {
        return Item.fromFirestore(doc.id, doc.data());
      }).toList();

      notifyListeners();
    });
  }

  /// ADD ITEM
  Future<void> addItem(Item item) async {
    await _firestore.collection("inventory").add(item.toMap());
  }

  /// UPDATE ITEM
  Future<void> updateItem(Item updated) async {
    if (updated.id == null) return; // avoid crash

    await _firestore
        .collection("inventory")
        .doc(updated.id)
        .update(updated.toMap());
  }

  /// DELETE ITEM
  Future<void> deleteItem(String id) async {
    await _firestore.collection("inventory").doc(id).delete();
  }

  /// FILTER ITEMS
  List<Item> getItemsByCategory(String category, {String? subcategory}) {
    return _items.where((item) {
      if (item.category.toLowerCase() != category.toLowerCase()) return false;

      if (subcategory != null && subcategory.isNotEmpty) {
        return (item.subcategory ?? '').toLowerCase() ==
            subcategory.toLowerCase();
      }

      return true;
    }).toList();
  }
}
