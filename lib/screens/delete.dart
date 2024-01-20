// DeleteProductPage.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteProductPage extends StatefulWidget {
  final int index;

  const DeleteProductPage({Key? key, required this.index}) : super(key: key);

  @override
  _DeleteProductPageState createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  final String apiUrl =
      'https://virashtechnologies.com/test-virash/delete-product.php';

  TextEditingController productIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    productIdController.text = widget.index.toString();
  }

  void deleteProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mobileNumber = prefs.getString('mobileNumber') ?? '';
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> data = {
      'mobile_number': mobileNumber,
      'token': token,
      'product_id': productIdController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode([data]),
      );

      print('Delete Product - API Response Status Code: ${response.statusCode}');
      print('Delete Product - API Response Body: ${response.body}');

      // Handle response as needed
      if (response.statusCode == 200) {
        // Handle successful deletion
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Handle deletion failure
      }
    } catch (e) {
      print('Delete Product - Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Product'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: productIdController,
              decoration: InputDecoration(labelText: 'Product ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteProduct,
              child: Text('Delete Product'),
            ),
          ],
        ),
      ),
    );
  }
}
