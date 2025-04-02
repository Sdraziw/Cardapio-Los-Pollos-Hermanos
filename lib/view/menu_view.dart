import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/items_model.dart';
import '../model/category_model.dart';
import '../controller/login_controller.dart';
import '../controller/menu_controller.dart' as custom;
import '../services/order_service.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  MenuViewState createState() => MenuViewState();
}

class MenuViewState extends State<MenuView> {
  final LoginController loginController = LoginController();
  final custom.MenuController menuController = custom.MenuController();
  final OrderService orderService = OrderService();

  String searchQuery = '';
  int _currentIndex = 0;
  int cartItemCount = 0;
  bool invisibleButtonGenerateMenuItems = false;


  @override
  void initState() {
    super.initState();
    fetchCartItemCount();
  }

  fetchCartItemCount() async {
    int cartCount = await orderService.fetchCartItemCount();
    setState(() {
      cartItemCount = cartCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFD600),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    // Search field (magnifying glass)
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Type here to search...',
                          hintTextDirection: TextDirection.ltr,
                          hintStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: cartItemCount > 0
                                ? [Colors.orange, Colors.orangeAccent, Colors.blueAccent]
                                : [Colors.transparent, Colors.transparent, Colors.transparent],
                            begin: cartItemCount > 0
                                ? Alignment.topLeft
                                : Alignment.bottomCenter,
                            end: cartItemCount > 0
                                ? Alignment.bottomCenter
                                : Alignment.topRight,
                          ),
                        ),
                        padding: EdgeInsets.all(8), // Adjust padding as needed
                        child: IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.black),
                          onPressed: () {
                            // Navigate to the shopping cart screen
                            Navigator.pushNamed(context, 'cart');
                            setState(() {
                              cartItemCount = 0; // Reset the cart item count
                            });();
                            // Show a snackbar with the number of items in the cart
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                padding: EdgeInsets.all(5.0),
                                content: Text(
                                  'Shopping cart $cartItemCount items',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                padding: EdgeInsets.all(5.0),
                                content: Text(
                                  'Shopping cart $cartItemCount items',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (cartItemCount > 0) // Display cart item count (badge concept)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartItemCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Image.asset(
              'lib/images/fundo2.png',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.5),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          // Blur filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              Container(
                width: double.infinity, // Occupies the entire available width
                color: Color(0xFFFFD600), // Background color of the container
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: FutureBuilder<String>(
                  future: loginController.loggedInUserFirstName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text(
                            'Loading user...',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'CarnevaleeFreakshow',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return Text(
                        'Welcome, ${snapshot.data}! - Los Pollos Hermanos! MENU',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CarnevaleeFreakshow',
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .orderBy('order')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error loading data: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text('No categories found'));
                    }

                    List<DocumentSnapshot> categories = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, categoryIndex) {
                        DocumentSnapshot categoryDoc =
                            categories[categoryIndex];
                        String categoryName = categoryDoc['name'];
                        String categoryImage = categoryDoc['image'];
                        String categoryDescription = categoryDoc['description'];

                        return Column(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('menu_items')
                                  .where('active', isEqualTo: true)
                                  .where('category', isEqualTo: categoryName)
                                  .snapshots(),
                              builder: (context, itemSnapshot) {
                                if (itemSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (itemSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error loading items: ${itemSnapshot.error}'));
                                } else if (!itemSnapshot.hasData ||
                                    itemSnapshot.data!.docs.isEmpty) {
                                  return SizedBox.shrink();
                                }

                                List<Dish> menuItems = itemSnapshot.data!.docs
                                    .map((doc) => Dish.fromDocument(doc))
                                    .where((dish) =>
                                        categoryName.toLowerCase().contains(searchQuery
                                            .toLowerCase()) || // Checks if the category matches
                                        dish.name.toLowerCase().contains(searchQuery
                                            .toLowerCase())) // Or if any dish matches
                                    .toList();

                                if (menuItems.isEmpty &&
                                    !categoryName
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase())) {
                                  return SizedBox
                                      .shrink(); // Hides the category if nothing matches
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category title
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          if (categoryImage.isNotEmpty)
                                            categoryImage.startsWith('http')
                                                ? Image.network(categoryImage,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover)
                                                : Image.asset(categoryImage,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  categoryDescription,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    // List of dishes
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: menuItems.length,
                                      itemBuilder: (context, index) {
                                        Dish dish = menuItems[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 2,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                'details',
                                                arguments: dish,
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  if (dish.image.isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: dish.image
                                                              .startsWith(
                                                                  'http')
                                                          ? Image.network(
                                                              dish.image,
                                                              width: 80,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              dish.image,
                                                              width: 80,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          dish.name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          dish.description,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    'R\$ ${dish.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Spacing between categories
                            if (searchQuery == '') const SizedBox(height: 50),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
     floatingActionButton: invisibleButtonGenerateMenuItems
          ? null // Hides the button if invisibleButtonGenerateMenuItems is true
          : FloatingActionButton(
              onPressed: () async {
                final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
                if (categoriesSnapshot.docs.isEmpty) {
                  await generateCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categories added to Firestore!'),
                    ),
                  );
                } else {
                  print('Categories already exist.');
                }

                // Check if menu items exist
                final itemsSnapshot = await FirebaseFirestore.instance.collection('menu_items').get();
                if (itemsSnapshot.docs.isEmpty) {
                  await generateMenuItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menu items added to Firestore!'),
                    ),
                  );
                } else {
                  invisibleButtonGenerateMenuItems = true; // Set to true if items already exist
                  setState(() {}); // Refresh the UI to hide the button
                  print('Menu items already exist.');
                }
              },
        backgroundColor: Color(0xFFFFD600),
        child: Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'menu');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'history');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'profile');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu🍔'), // Hamburger character for app menu options
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}