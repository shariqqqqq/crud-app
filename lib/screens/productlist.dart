import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'category/add.dart';
import 'category/update.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> categoryList = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    const String apiUrl =
        'https://virashtechnologies.com/test-virash/category.php';

    final Map<String, dynamic> requestData = {
      'mobile_number': 'none',
      'token': 'none',
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
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          categoryList = responseData
              .whereType<Map<String, dynamic>>() // Filter only maps
              .map<Map<String, dynamic>>((dynamic map) {
            return map.cast<String, dynamic>();
          }).toList();
        });
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteCategory(String categoryId) async {
    final String deleteApiUrl =
        'https://virashtechnologies.com/test-virash/delete-category.php';

    // Retrieve token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token') ?? 'none';

    final Map<String, dynamic> deleteRequestData = {
      'mobile_number': '1111111111',
      'token': token,
      'category_id': categoryId,
    };

    try {
      final deleteResponse = await http.post(
        Uri.parse(deleteApiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode([deleteRequestData]),
      );

      if (deleteResponse.statusCode == 200) {
        // Show a success message
        _showSnackbar('Category deleted successfully');

        // Refresh the category list
        fetchCategories();
      } else {
        print('HTTP error: ${deleteResponse.statusCode}');
        // Handle error
        _showSnackbar('Failed to delete category');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
      _showSnackbar('Failed to delete category');
    }
  }

  Future<void> _showDeleteConfirmationDialog(String categoryId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(categoryId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.lightBlue[50], // Change the background color
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://virashtechnologies.com/test-virash/${categoryList[index]['category_photo']}' ?? ''),
                  ),
                  title: Text(categoryList[index]['category_name'] ?? ''),
                  subtitle:
                  Text(categoryList[index]['category_description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          final categoryId = categoryList[index]['cat_id'];
                          if (categoryId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateCategoryScreen(
                                  categoryId: categoryId,
                                ),
                              ),
                            );
                          } else {
                            _showSnackbar('Category ID is null');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              categoryList[index]['cat_id']);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[500], // Add a divider between cards
                  height: 1,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoryScreen(
                onCategoryAdded: fetchCategories,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
