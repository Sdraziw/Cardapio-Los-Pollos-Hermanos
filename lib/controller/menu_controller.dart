import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<String> getCategoryName(int order) async {
    var name = "";
    await FirebaseFirestore.instance
        .collection('categories')
        .where('order', isEqualTo: order)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        name = value.docs[0].data()['name'] ?? '';
      }
    });
    return name;
  }

  Future<int> getCategoryOrder(String name) async {
    var order = 0;
    await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        order = value.docs[0].data()['order'] ?? 0;
      }
    });
    return order;
  }

  Future<String> getMenuItemName(String category) async {
    var name = "";
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('category', isEqualTo: category)
        .get()
        .then((value) {
      name = value.docs[0].data()['name'] ?? '';
    });
    return name;
  }

  Future<String> getMenuItemDescription(String name) async {
    var description = "";
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      description = value.docs[0].data()['description'] ?? '';
    });
    return description;
  }

  Future<double> getMenuItemPrice(String name) async {
    var price = 0.0;
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      price = value.docs[0].data()['price'] ?? 0.0;
    });
    return price;
  }

  Future<String> getMenuItemImage(String name) async {
    var image = '';
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      image = value.docs[0].data()['image'] ?? '';
    });
    return image;
  }

  Future<bool> isMenuItemActive(String name) async {
    bool active = false;
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        active = value.docs[0].data()['active'] ?? false;
      }
    });
    return active;
  }

  Future<String> getImageByName(String name) async {
    String image = '';
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        image = value.docs[0].data()['image'] ?? '';
      }
    });
    return image;
  }

  Future<List<String>> getItemsByCategory(String category) async {
    List<String> items = [];
    await FirebaseFirestore.instance
        .collection('menu_items')
        .where('category', isEqualTo: category)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        items.add(doc.data()['name']);
      }
    });
    return items;
  }
}