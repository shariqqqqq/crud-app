import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crudapp/screens/productlist.dart';
class UpdateCategoryScreen extends StatefulWidget {
  final String categoryId;

  const UpdateCategoryScreen({Key? key, required this.categoryId})
      : super(key: key);

  @override
  _UpdateCategoryScreenState createState() => _UpdateCategoryScreenState();
}

class _UpdateCategoryScreenState extends State<UpdateCategoryScreen> {
  late String token;
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  Future<void> fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? 'none';
    });
  }

  Future<void> updateCategory() async {
    final String apiUrl =
        'https://virashtechnologies.com/test-virash/categoryData.php';

    final Map<String, dynamic> requestData = {
      'mobile_number': '1111111111',
      'token': token,
      'category_id': widget.categoryId,
      'category_name': categoryNameController.text,
      'is_image': 'no',
      'category_photo': '',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode([requestData]),
      );

      if (response.statusCode == 200) {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to ProductScreen after a delay for the user to see the SnackBar
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Navigate back
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(), // Refresh ProductScreen
            ),
          );
        });
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Category'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category ID: ${widget.categoryId}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: categoryNameController,
              decoration: InputDecoration(
                labelText: 'New Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the updateCategory function
                updateCategory();
              },
              child: Text('Update Category'),
            ),
          ],
        ),
      ),
    );
  }
}
