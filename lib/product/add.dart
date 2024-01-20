import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductPage extends StatefulWidget {
  final VoidCallback? onCategoryAdded; // Callback function

  const AddProductPage({Key? key, this.onCategoryAdded}) : super(key: key);
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final String apiUrl =
      'https://virashtechnologies.com/test-virash/productData.php';

  TextEditingController productNameController = TextEditingController();
  TextEditingController saleRateController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void addProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mobileNumber = prefs.getString('mobileNumber') ?? '';
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> data = {
      'mobile_number': mobileNumber,
      'token': token,
      'product_id': '0', // Assuming 0 for new product
      'category_id': '19',
      'product_name': productNameController.text,
      'sale_rate': saleRateController.text,
      'mrp': mrpController.text,
      'unit': unitController.text,
      'is_image': 'no',
      'product_image': '',
      'description': descriptionController.text,
      'product_type': 'None',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode([data]),
      );

      print('Add Product - API Response Status Code: ${response.statusCode}');
      print('Add Product - API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );

        if (widget.onCategoryAdded != null) {
          widget.onCategoryAdded!();
        }

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
      }
    } catch (e) {
      print('Add Product - Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: saleRateController,
              decoration: InputDecoration(labelText: 'Sale Rate'),
            ),
            TextField(
              controller: mrpController,
              decoration: InputDecoration(labelText: 'MRP'),
            ),
            TextField(
              controller: unitController,
              decoration: InputDecoration(labelText: 'Unit'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
