import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'add.dart';
import 'update.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, String>> productList = [];
  late String mobileNumber;
  late String token;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileNumber = prefs.getString('mobileNumber') ?? '';
    token = prefs.getString('token') ?? '';

    final String apiUrl =
        'https://virashtechnologies.com/test-virash/product.php';

    final Map<String, dynamic> requestData = {
      'mobile_number': mobileNumber,
      'token': token,
      'product_type': 'None',
      'category_id': '19',
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
        if (responseData is List) {
          setState(() {
            productList = responseData
                .whereType<Map<String, dynamic>>()
                .map<Map<String, String>>((dynamic map) {
              return map.cast<String, String>();
            }).toList();
          });
        } else {
          print('Invalid response format');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteProduct(String productId, String productName) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $productName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != null && confirmDelete) {
      final String deleteApiUrl =
          'https://virashtechnologies.com/test-virash/delete-product.php';

      final Map<String, dynamic> deleteRequestData = {
        'mobile_number': mobileNumber,
        'token': token,
        'product_id': productId,
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
          print('Product deleted successfully');
          fetchData();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Deletion Successful'),
                content: Text('Product $productName has been deleted.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('HTTP error: ${deleteResponse.statusCode}');
          // Handle error
          print('Failed to delete product');
        }
      } catch (e) {
        print('Error: $e');
        // Handle error
        print('Failed to delete product');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://virashtechnologies.com/test-virash/${productList[index]['category_photo']}' ?? ''),
                        ),
                        title: Text(productList[index]['product_name'] ?? ''),
                        subtitle: Text(
                            productList[index]['product_description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProductPage(
                                    product_id: productList[index]['product_id']!,
                                  ),
                                ),
                              ),
                            ),

                            // Delete button
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteProduct(
                                productList[index]['product_id']!,
                                productList[index]['product_name']!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(
                      onCategoryAdded: fetchData,
                    ),
                  ),
                ),
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
