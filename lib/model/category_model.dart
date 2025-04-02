import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Category {
  String name;
  String description;
  String image;
  int order;
  bool active;

  Category({
    required this.name,
    required this.description,
    required this.image,
    required this.order,
    required this.active,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      name: data['name'],
      description: data['description'],
      image: data['image'],
      order: data['order'],
      active: data['active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'order': order,
      'active': active,
    };
  }
}

Future<void> generateCategories() async {
  final List<Category> categories = [
    Category(
      name: "Buckets",
      description: "Buckets are an irresistible experience for chicken lovers.",
      image: "lib/images/categoria_baldes.png",
      order: 7,
      active: true,
    ),
    Category(
      name: "Beverages",
      description: "A selection of beverages to accompany your meals.",
      image: "lib/images/categoria_bebidas.png",
      order: 2,
      active: true,
    ),
    Category(
      name: "Sandwiches and Burgers",
      description: "Indulge in our main dishes that combine bold flavors and unique textures.",
      image: "lib/images/categoria_lanches.png",
      order: 3,
      active: true,
    ),
    Category(
      name: "Appetizers",
      description: "Our appetizers are perfect to whet your appetite, with generous and crispy portions.",
      image: "lib/images/categoria_porções.png",
      order: 4,
      active: true,
    ),
    Category(
      name: "Desserts",
      description: "End your dining experience with our handcrafted desserts.",
      image: "lib/images/categoria_sobremesas.png",
      order: 5,
      active: true,
    ),
  ];

  final CollectionReference collection = FirebaseFirestore.instance.collection('categories');

  for (Category category in categories) {
    try {
      // Use the `name` field as the document ID
      await collection.doc(category.name).set(category.toMap());
      print('Category added: ${category.name}');
    } catch (e) {
      print('Error adding category: ${category.name}, Error: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Generate categories in Firestore
  await generateCategories();
}