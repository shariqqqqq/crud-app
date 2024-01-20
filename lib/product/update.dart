import 'package:crudapp/product/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProductPage extends StatefulWidget {
  final String product_id;

  const UpdateProductPage({Key? key, required this.product_id}) : super(key: key);

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final String apiUrl =
      'https://virashtechnologies.com/test-virash/productData.php';

  TextEditingController productIdController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController saleRateController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate the fields with existing data using the provided index
    productIdController.text = widget.product_id.toString();
    productNameController.text = ''; // Set your initial value here
    saleRateController.text = ''; // Set your initial value here
    mrpController.text = ''; // Set your initial value here
    unitController.text = ''; // Set your initial value here
    descriptionController.text = ''; // Set your initial value here
  }

  void updateProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mobileNumber = prefs.getString('mobileNumber') ?? '';
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> data = {
      'mobile_number': mobileNumber,
      'token': token,
      'product_id': productIdController.text,
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

      print('Update Product - API Response Status Code: ${response.statusCode}');
      print('Update Product - API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully'),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pop(context, true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListPage(), // Refresh ProductScreen
          ),
        );
      } else {
      }
    } catch (e) {
      print('Update Product - Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Product'),
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
              onPressed: updateProduct,
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
