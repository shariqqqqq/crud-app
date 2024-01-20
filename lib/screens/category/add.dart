import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategoryScreen extends StatefulWidget {
  final VoidCallback? onCategoryAdded; // Callback function

  const AddCategoryScreen({Key? key, this.onCategoryAdded}) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryDescriptionController = TextEditingController();

  Future<void> addCategory() async {
    final String apiUrl =
        'https://virashtechnologies.com/test-virash/categoryData.php';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token') ?? 'none';

    final Map<String, dynamic> requestData = {
      'mobile_number': '1111111111',
      'token': token,
      'category_id': '0',
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
            content: Text('Category added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Trigger the callback to refresh the category list
        if (widget.onCategoryAdded != null) {
          widget.onCategoryAdded!();
        }

        // Navigate back to the previous screen (ProductScreen) after a delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        print('HTTP error: ${response.statusCode}');
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: categoryDescriptionController,
              decoration: InputDecoration(labelText: 'Category Description'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Call the API to add the category
                addCategory();
              },
              child: Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
