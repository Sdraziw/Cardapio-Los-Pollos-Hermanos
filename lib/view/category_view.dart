import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category_model.dart'; // Update the path as necessary

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').orderBy('order').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading categories'));
          }
          final categories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Category(
              name: data['name'],
              description: data['description'],
              image: data['image'],
              order: data['order'],
              active: data['active'],
            );
          }).toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text(category.description),
                leading: category.image.isNotEmpty
                    ? Image.network(category.image, width: 50, height: 50)
                    : null,
                onTap: () {
                  Navigator.pushNamed(context, '/items', arguments: category.name);
                },
              );
            },
          );
        },
      ),
    );
  }
}
