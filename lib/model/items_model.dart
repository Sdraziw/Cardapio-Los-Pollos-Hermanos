import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Dish {
  final String id;
  final bool active;
  final String name;
  final double price;
  final String image;
  final String description;
  final String summary;
  int quantity;
  final String packageItem;
  final bool coupon;
  final String category;

  Dish({
    required this.id,
    this.active = true,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.summary,
    this.quantity = 1,
    this.packageItem = 'pending',
    this.coupon = false,
    required this.category,
  });

  // Method to format the price of the dish in currency format
  String get formattedPrice {
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'en_US');
    return formatter.format(price);
  }

  // Method to update the quantity
  void updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      quantity = newQuantity;
    }
  }

  // Static method to create an instance of Dish from a Firestore document
  static Dish fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dish(
      id: data['id'] ?? '',
      active: data['active'] ?? true,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      summary: data['summary'] ?? '',
      quantity: data['quantity'] ?? 1,
      packageItem: data['packageItem'] ?? 'pending',
      coupon: data['coupon'] ?? false,
      category: data['category'] ?? '',
    );
  }

  // Factory to create an instance of Dish from a map
  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] ?? '',
      active: map['active'] ?? true,
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      summary: map['summary'] ?? '',
      quantity: map['quantity'] ?? 1,
      packageItem: map['packageItem'] ?? 'pending',
      coupon: map['coupon'] ?? false,
      category: map['category'] ?? '',
    );
  }
}

// Function to add items to Firestore
Future<void> addItemsToFirestore(List<Dish> items) async {
  final CollectionReference collection = FirebaseFirestore.instance.collection('menu_items');
  final WriteBatch batch = FirebaseFirestore.instance.batch();

  for (Dish item in items) {
    DocumentReference docRef = collection.doc(item.id); // Use the `id` as the document name
    batch.set(docRef, {
      'id': item.id,
      'active': item.active,
      'name': item.name,
      'price': item.price,
      'image': item.image,
      'description': item.description,
      'summary': item.summary,
      'quantity': item.quantity,
      'packageItem': item.packageItem,
      'coupon': item.coupon,
      'category': item.category,
    });
  }

  await batch.commit(); // Commit the batch write
  print('All items added to Firestore in the menu_items collection.');
}

// Static method to generate Appetizers
Future<void> generateAppetizers() async {
  List<Dish> appetizers = [
    Dish(
      id: 'Onion Rings',
      name: 'Onion Rings',
      price: 10.50,
      image: 'lib/images/onion rings.png',
      description: 'Breaded and fried onion rings, crispy',
      summary: '10 pieces | 300g',
      category: 'Appetizers',
    ),
    Dish(
      id: 'Nuggets',
      name: 'Nuggets',
      price: 10.50,
      image: 'lib/images/nuggets.png',
      description: 'Breaded chicken nuggets, crispy on the outside and juicy on the inside',
      summary: '10 pieces | 300g',
      category: 'Appetizers',
    ),
    // Add more items here...
  ];

  await addItemsToFirestore(appetizers);
}

// Static method to generate Main Dishes
Future<void> generateSandwichesAndBurgers() async {
  List<Dish> sandwichesAndBurgers = [
    Dish(
      id: 'X - Walter White',
      name: 'X - Walter White',
      price: 25.50,
      image: 'lib/images/burguer.png',
      description: 'Breaded chicken breast with cheese, bacon strips, and special sauce',
      summary: '400g',
      category: 'Sandwiches and Burgers',
    ),
    Dish(
      id: 'X - Heisenberg',
      name: 'X - Heisenberg',
      price: 45.50,
      image: 'lib/images/hamburger.png',
      description: 'Two burgers with lots of cheddar, bacon strips, and spicy sauce',
      summary: '500g',
      category: 'Sandwiches and Burgers',
    ),
    Dish(
      id: "X - Hank Schrader",
      name: "X - Hank Schrader",
      price: 32.50,
      image: "lib/images/hankburger.png",
      description: "Delicious gnu burger, a semi-melted slice of cheddar, onion rings, pickle slices, refreshing lettuce and tomato salad, mayonnaise, and special sauce",
      summary: '500g',
      category: 'Sandwiches and Burgers',
    ),
    Dish(
      id: "X - Gus Fring",
      name: "X - Gus Fring",
      price: 25.50,
      image: "lib/images/xsalada.png",
      description: "Juicy burger from the pampas, a slice of mozzarella, and a refreshing lettuce and tomato salad",
      summary: '500g',
      category: 'Sandwiches and Burgers',
    ),
    Dish(
      id: "X - Jesse Pinkman",
      name: "X - Jesse Pinkman",
      price: 15.50,
      image: "lib/images/jesseburger.png",
      description: "Delicious grilled burger, a generous slice of cheddar, and special sauce",
      summary: '500g',
      category: 'Sandwiches and Burgers',
    ),
    Dish(
      id: "Double Combo - Crazy Waterfall",
      name: "Double Combo - Crazy Waterfall",
      price: 55.90,
      image: "lib/images/slc que imagem.jpeg",
      description: "2 hamburger buns, 2 breaded chicken burgers, barbecue sauce",
      summary: '2 hearty sandwiches | 200g each',
      category: 'Sandwiches and Burgers',
    ),
    // Add more items here...
  ];

  await addItemsToFirestore(sandwichesAndBurgers);
}

// Static method to generate Buckets
Future<void> generateBuckets() async {
  List<Dish> buckets = [
    Dish(
      id: 'Chicken Bucket L',
      name: 'Chicken Bucket L',
      price: 19.50,
      image: 'lib/images/balde G.png',
      description: 'Chicken marinated in spices, fried to perfection',
      summary: '14 pieces | 600g',
      category: 'Buckets',
    ),
    Dish(
      id: 'Chicken Bucket M',
      name: 'Chicken Bucket M',
      price: 17.50,
      image: 'lib/images/balde G.png',
      description: 'Chicken marinated in spices, fried to perfection',
      summary: '12 pieces | 500g',
      category: 'Buckets',
    ),
    Dish(
      id: 'Chicken Bucket S',
      name: 'Chicken Bucket S',
      price: 15.50,
      image: 'lib/images/balde G.png',
      description: 'Chicken marinated in spices, fried to perfection',
      summary: '10 pieces | 400g',
      category: 'Buckets',
    ),
  ];

  await addItemsToFirestore(buckets);
}

// Static method to generate Beverages
Future<void> generateBeverages() async {
  List<Dish> beverages = [
    Dish(
      id: "Soda",
      name: "Soda",
      price: 10.90,
      image: "lib/images/refri G.png",
      description: "500ml cold soda to accompany your dish",
      summary: '500ml',
      category: 'Beverages',
    ),
    Dish(
      id: "Coca-Cola",
      name: "Coca-Cola",
      price: 12.90,
      image: "lib/images/coke.png",
      description: "500ml cold Coca-Cola to accompany your dish",
      summary: '500ml',
      category: 'Beverages',
    ),
    Dish(
      id: "Schweppes",
      name: "Schweppes",
      price: 9.50,
      image: "lib/images/Schweppes.png",
      description: "1500ml cold Schweppes to accompany your order",
      summary: '1.5 liters',
      category: 'Beverages',
    ),
    Dish(
      id: "Sparkling Water",
      name: "Sparkling Water",
      price: 3.00,
      image: "lib/images/agua-com-gas-500ml.png",
      description: "Refreshing sparkling mineral water",
      summary: '500ml',
      category: 'Beverages',
    ),
    Dish(
      id: "Still Water",
      name: "Still Water",
      price: 2.50,
      image: "lib/images/agua_sem_gas.png",
      description: "Natural mineral water, perfect for hydration",
      summary: '500ml',
      category: 'Beverages',
    ),
    Dish(
      id: "Dell Valle Juice",
      name: "Dell Valle Juice",
      price: 7.50,
      image: "lib/images/suco_delvale.png",
      description: "Natural fruit juice, refreshing and healthy",
      summary: '350ml',
      category: 'Beverages',
    ),
  ];

  await addItemsToFirestore(beverages);
}

// Static method to generate Desserts
Future<void> generateDesserts() async {
  List<Dish> desserts = [
    Dish(
      id: "Cheesecake",
      name: "Cheesecake",
      price: 12.00,
      image: "lib/images/cheesecake.jpg",
      description: "Delicious cheesecake with red fruit topping",
      summary: '1 slice',
      category: 'Desserts',
    ),
    Dish(
      id: "Brownie",
      name: "Brownie",
      price: 8.00,
      image: "lib/images/brownie.jpg",
      description: "Chocolate brownie with walnuts",
      summary: '1 piece',
      category: 'Desserts',
    ),
    Dish(
      id: "Negresco Ice Cream",
      name: "Negresco Ice Cream",
      price: 7.50,
      image: "lib/images/ice-cream.webp",
      description: "Negresco ice cream made with condensed milk, milk, Negresco cookies, vanilla essence, eggs, sugar, and cream. Simple and delicious! 🍦",
      summary: 'Stuffed cone and vanilla base',
      category: 'Desserts',
    ),
  ];

  await addItemsToFirestore(desserts);
}

Future<void> generateMenuItems() async {
  await generateAppetizers();
  await generateSandwichesAndBurgers();
  await generateBuckets();
  await generateBeverages();
  await generateDesserts();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Generate menu items in Firestore
  await generateMenuItems();
}
